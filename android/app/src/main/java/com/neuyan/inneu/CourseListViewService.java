package com.neuyan.inneu;

import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.util.Log;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import androidx.annotation.RequiresApi;

public class CourseListViewService extends RemoteViewsService {

    @Override
    public RemoteViewsFactory onGetViewFactory(Intent intent) {
        return new CourseListViewFactory(this.getApplicationContext(), intent);
    }

}

class CourseItem {
    private String courseName;
    private String courseCode;
    private int len;
    private int day;
    private int section;
    private int[] weeks;
    private String[] teachers;
    private String classroom;

    public String getCourseName() {
        return courseName;
    }

    public void setCourseName(String courseName) {
        this.courseName = courseName;
    }

    public String getCourseCode() {
        return courseCode;
    }

    public void setCourseCode(String courseCode) {
        this.courseCode = courseCode;
    }

    public int getLen() {
        return len;
    }

    public void setLen(int len) {
        this.len = len;
    }

    public int getDay() {
        return day;
    }

    public void setDay(int day) {
        this.day = day;
    }

    public int[] getWeeks() {
        return weeks;
    }

    public void setWeeks(int[] weeks) {
        this.weeks = weeks;
    }

    public String[] getTeachers() {
        return teachers;
    }

    public void setTeachers(String[] teachers) {
        this.teachers = teachers;
    }

    public String getClassroom() {
        return classroom;
    }

    public void setClassroom(String classroom) {
        this.classroom = classroom;
    }

    public int getSection() {
        return section;
    }

    public void setSection(int section) {
        this.section = section;
    }
}

class CourseListViewFactory implements RemoteViewsService.RemoteViewsFactory {

    private Context context;
    private ArrayList<CourseItem> data;

    // 给课程按照上课时间排序
    private void sortData() {
        quickSort(data, 0, data.size() - 1);
    }

    // 低版本SDK不能使用sort方法 自己实现快排
    private void quickSort(ArrayList<CourseItem> s, int l, int r)
    {
        if (l < r)
        {
            int i = l, j = r;
            CourseItem x = s.get(l);
            while (i < j)
            {
                while(i < j && s.get(j).getSection() >= x.getSection())
                    j--;
                if(i < j)
                    s.set(i++, s.get(j));

                while(i < j && s.get(i).getSection() < x.getSection())
                    i++;
                if(i < j)
                    s.set(j--, s.get(i));
            }
            s.set(i, x);
            quickSort(s, l, i - 1);
            quickSort(s, i + 1, r);
        }
    }

    public CourseListViewFactory(Context context, Intent intent) {
        this.context = context;
        // int appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);
    }

    @Override
    public void onCreate() {
        data = new ArrayList<>();
        onDataSetChanged();
    }

    @Override
    public void onDataSetChanged() {

        data.clear();

        SharedPreferences sharedPreferences = context.getSharedPreferences("native_cache", Context.MODE_PRIVATE);
        String courseJsonStr = sharedPreferences.getString("courses", null);
        long startTimestamp = sharedPreferences.getLong("start", -1);

        if (courseJsonStr == null || startTimestamp == -1) {
            return;
        }

        try {
            JSONArray jsonArray = new  JSONArray(courseJsonStr);
            long deltaTime = System.currentTimeMillis() - startTimestamp;
            if (deltaTime <= 0) {
                return;
            }

            double dayIndex = deltaTime/(3600000*24.0);
            int weekIndex = (int) Math.ceil(dayIndex/7);
            int day = (int) Math.floor(dayIndex - 7*(weekIndex-1));

            for (int i = 0;i < jsonArray.length();i++) {
                JSONObject courseItem = jsonArray.getJSONObject(i);
                JSONArray weekList = courseItem.getJSONArray("weeks");
                for (int j = 0; j < weekList.length(); j++) {
                    if (weekList.getInt(j) == weekIndex && courseItem.getInt("day") == day) {
                        CourseItem item = new CourseItem();
                        item.setCourseName(courseItem.getString("course_name"));
                        item.setLen(courseItem.getInt("len"));
                        item.setSection(courseItem.getInt("section"));
                        item.setClassroom(courseItem.optString("classroom"));

                        JSONArray teachersJsonArray = courseItem.getJSONArray("teachers");
                        String[] teachers = new String[teachersJsonArray.length()];

                        for (int teacherIndex = 0; teacherIndex < teachersJsonArray.length(); teacherIndex++) {
                            teachers[teacherIndex] = teachersJsonArray.getString(teacherIndex);
                        }

                        item.setTeachers(teachers);

                        data.add(item);

                        break;
                    }
                }
            }

            sortData();

        } catch (JSONException e) {
            e.printStackTrace();
        }
    }

    @Override
    public void onDestroy() {
        data.clear();
    }

    @Override
    public int getCount() {
        return data.size();
    }


    @Override
    public RemoteViews getViewAt(int position) {
        RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.schedule_glance_item);

        CourseItem courseItem = data.get(position);
        remoteViews.setTextViewText(R.id.schedule_item_name, courseItem.getCourseName());

        String sectionStr = courseItem.getLen() == 1 ?
                String.valueOf(courseItem.getSection()+1) :
                (courseItem.getSection()+1) + "~" + (courseItem.getLen()+courseItem.getSection());


        remoteViews.setTextViewText(R.id.schedule_item_section, "第"+sectionStr+"节");
        remoteViews.setTextViewText(
                R.id.schedule_item_classroom,
                courseItem.getClassroom() == null || courseItem.getClassroom().equals("")? "教室未安排" : courseItem.getClassroom()
        );

        // 拼接教师字符串 低版本SDK不支持join方法
        StringBuilder stringBuffer = new StringBuilder();
        for (int teacherIndex = 0; teacherIndex < courseItem.getTeachers().length; teacherIndex++) {
            stringBuffer.append(courseItem.getTeachers()[teacherIndex]);
            if (teacherIndex+1 != courseItem.getTeachers().length) {
                stringBuffer.append(",");
            }
        }

        remoteViews.setTextViewText(
                R.id.schedule_item_teachers,
                stringBuffer.toString()
        );

        return remoteViews;
    }

    @Override
    public RemoteViews getLoadingView() {
        return null;
    }

    @Override
    public int getViewTypeCount() {
        return 1;
    }

    @Override
    public long getItemId(int position) {
        return position;
    }

    @Override
    public boolean hasStableIds() {
        return false;
    }
}
