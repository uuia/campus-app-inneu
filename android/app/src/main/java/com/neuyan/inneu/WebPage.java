package com.neuyan.inneu;

import androidx.annotation.RequiresApi;
import androidx.appcompat.app.AppCompatActivity;

import android.annotation.SuppressLint;
import android.app.ActionBar;
import android.app.Activity;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.view.KeyEvent;
import android.view.MenuItem;
import android.webkit.CookieManager;
import android.webkit.WebResourceRequest;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;

import java.time.Duration;

public class WebPage extends AppCompatActivity {

    private WebView webView;

    private WebViewClient webViewClient = new WebViewClient(){
        @SuppressLint("ShowToast")
        @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, WebResourceRequest request) {

            String url = request.getUrl().toString();
            Log.i("[url]", url);

            if (url.toLowerCase().contains("platformapi/startapp")) {
                Log.i("[pay]","loading");
                Intent intent;
                try {
                    intent = Intent.parseUri(url,
                            Intent.URI_INTENT_SCHEME);
                    intent.addCategory(Intent.CATEGORY_BROWSABLE);
                    intent.setComponent(null);
                    startActivity(intent);
                    webView.loadUrl("https://ecardh5.17wanxiao.com/ecardh5/ecard_n/index.html");
                    return true;
                } catch (Exception e) {
                    Toast.makeText(getApplicationContext(),"您没有安装相关App", Toast.LENGTH_LONG);
                    e.printStackTrace();
                    return super.shouldOverrideUrlLoading(view, request);
                }
            }

            if (request.getMethod().toUpperCase().equals("GET")) {
                webView.loadUrl(url);
                return true;
            }
            return super.shouldOverrideUrlLoading(view, request);
        }

        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            webView.loadUrl(url);
            return true;
        }
    };

    @SuppressLint("SetJavaScriptEnabled")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_web_page);

        Bundle bundle = this.getIntent().getExtras();
        assert bundle != null;

        if(getSupportActionBar() != null) {
            getSupportActionBar().setHomeButtonEnabled(true);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setTitle(bundle.getString("title")==null? "" : bundle.getString("title"));
        }

        webView = (WebView) findViewById(R.id.webview);
        WebSettings webSettings = webView.getSettings();
        webSettings.setJavaScriptEnabled(true);
        webView.setWebViewClient(webViewClient);


        String url = bundle.getString("url");
        webView.loadUrl(url);

    }

    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode==KeyEvent.KEYCODE_BACK && webView.canGoBack()) {
            webView.goBack();
            return true;
        }

        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        Log.i("[-]",String.valueOf(item.getItemId()));
        if (item.getItemId() == android.R.id.home) {
            this.finish();
        }
        return super.onOptionsItemSelected(item);
    }
}