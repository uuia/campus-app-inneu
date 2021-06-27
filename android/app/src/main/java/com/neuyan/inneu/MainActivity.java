package com.neuyan.inneu;

import android.annotation.SuppressLint;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Build;
import android.os.Bundle;
import android.os.PersistableBundle;
import android.preference.PreferenceManager;
import android.util.Log;
import android.webkit.CookieManager;
import android.webkit.CookieSyncManager;
import android.widget.RemoteViews;


import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;


import java.util.Date;

import androidx.annotation.NonNull;
import constant.UiType;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.view.FlutterMain;
import model.UiConfig;
import model.UpdateConfig;
import update.UpdateAppUtils;

public class MainActivity extends FlutterActivity {

    final static String CHANNEL = "com.neuyan.inneu/native";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        UpdateAppUtils.init(this);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL).setMethodCallHandler(
                (call, result) -> {
                    Log.i("[+]","receive call");
                    switch (call.method) {
                        case "open":
                            try {
                                JSONObject argumentObj = new JSONObject((String) call.arguments);
                                String url = argumentObj.optString("url");
                                String title = argumentObj.optString("title");
                                Intent intent = new Intent(MainActivity.this, WebPage.class);
                                Bundle bundle = new Bundle();
                                bundle.putString("url", url);
                                bundle.putString("title", title);
                                intent.putExtras(bundle);
                                startActivity(intent);
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            break;
                        case "save_schedule":
                            try {

                                JSONObject argument = new JSONObject((String) call.arguments);
                                long startTimestamp = argument.getLong("start");

                                SharedPreferences sharedPreferences = getSharedPreferences("native_cache", MODE_PRIVATE);
                                @SuppressLint("CommitPrefEdits") SharedPreferences.Editor editor = sharedPreferences.edit();

                                editor.putLong("start", startTimestamp);
                                editor.putString("courses", argument.getJSONArray("courses").toString());
                                editor.apply();
                                AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(this);
                                int[] appWidgetIds = appWidgetManager.getAppWidgetIds(new ComponentName(this, ScheduleGlanceAppWidget.class));

                                RemoteViews views = new RemoteViews(this.getPackageName(), R.layout.schedule_glance_app_widget);
                                appWidgetManager.updateAppWidget(appWidgetIds, views);
                                appWidgetManager.notifyAppWidgetViewDataChanged(appWidgetIds, R.id.appwidget_list);



                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            break;
                        case "set_cookie":
                            try {
                                JSONArray argumentArr = new JSONArray((String) call.arguments);
                                CookieManager cookieManager = CookieManager.getInstance();
                                cookieManager.setAcceptCookie(true);
                                for (int i = 0; i < argumentArr.length(); i++) {
                                    JSONObject item = argumentArr.getJSONObject(i);
                                    cookieManager.setCookie(item.getString("domain"), item.getString("cookie"));
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                                        cookieManager.flush();
                                    } else {
                                        CookieSyncManager.getInstance().sync();
                                    }
                                }
                            } catch (JSONException e) {
                                e.printStackTrace();
                            }
                            break;
                        case "update":

                            UpdateConfig updateConfig = new UpdateConfig();
                            updateConfig.setCheckWifi(false);
                            updateConfig.setNeedCheckMd5(false);
                            updateConfig.setNotifyImgRes(R.drawable.ic_update_logo);

                            UiConfig uiConfig = new UiConfig();
                            uiConfig.setUiType(UiType.PLENTIFUL);

                            try {
                                String jsonStr = (String) call.arguments;
                                JSONObject jsonObject = new JSONObject(jsonStr);
                                Log.i("[-]", "updating...." + jsonObject.getString("url") + jsonObject.getString("content"));
                                UpdateAppUtils.getInstance()
                                        .apkUrl(jsonObject.getString("url"))
                                        .updateTitle("有新版本")
                                        .updateContent(jsonObject.getString("content"))
                                        .uiConfig(uiConfig)
                                        .updateConfig(updateConfig)
                                        .update();

                            } catch (JSONException e) {
                                e.printStackTrace();
                            }

                            break;
                    }

                }
        );

    }
}
