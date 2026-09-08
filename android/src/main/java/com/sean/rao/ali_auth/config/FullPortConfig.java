package com.sean.rao.ali_auth.config;

import android.content.pm.ActivityInfo;
import android.graphics.Typeface;
import android.os.Build;
import android.view.View;
import android.widget.ImageButton;
import android.widget.RelativeLayout;
import com.alibaba.fastjson2.JSONObject;
import com.sean.rao.ali_auth.utils.AppUtils;
import com.sean.rao.ali_auth.utils.UtilTool;
import java.io.IOException;

import com.mobile.auth.gatewayauth.AuthRegisterViewConfig;
import com.sean.rao.ali_auth.common.CustomAuthUIControlClickListener;

public class FullPortConfig extends BaseUIConfig {
    private final String TAG = "全屏竖屏样式";

    public FullPortConfig() {
        super();
    }

    @Override
    public void configAuthPage() {
        if (jsonObject.getBooleanValue("logBtnTextBold")) {
            config.setLogBtnTypeface(Build.VERSION.SDK_INT >= 28
                    ? Typeface.create(Typeface.DEFAULT, 600, false)
                    : Typeface.DEFAULT_BOLD);
        }
        mAuthHelper.setUIClickListener(new CustomAuthUIControlClickListener());
        View thirdView = initSwitchView(420);
        if (thirdView != null) {
            mAuthHelper.addAuthRegistViewConfig("switch_msg", new AuthRegisterViewConfig.Builder()
                    .setView(thirdView)
                    .setRootViewId(AuthRegisterViewConfig.RootViewId.ROOT_VIEW_ID_BODY)
                    .build());
        }
        // A hidden navigation bar also hides its default back item. Keep a
        // real, accessible close button in the authorization body.
        JSONObject close = jsonObject.getJSONObject("customReturnBtn");
        if (jsonObject.getBooleanValue("navHidden") &&
                !jsonObject.getBooleanValue("navReturnHidden") && close != null &&
                close.getString("imgPath") != null) {
            ImageButton button = new ImageButton(mActivity);
            try {
                button.setBackground(UtilTool.getBitmapToBitmapDrawable(mContext,
                        UtilTool.flutterToPath(close.getString("imgPath"))));
                button.setContentDescription("关闭登录");
                RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(
                        AppUtils.dp2px(mContext, close.getFloatValue("width")),
                        AppUtils.dp2px(mContext, close.getFloatValue("height")));
                params.leftMargin = AppUtils.dp2px(mContext, close.getFloatValue("left"));
                params.topMargin = AppUtils.dp2px(mContext, close.getFloatValue("top"));
                button.setLayoutParams(params);
                button.setOnClickListener(view -> {
                    showResult("700000", "用户取消登录", "");
                    mAuthHelper.quitLoginPage();
                });
                mAuthHelper.addAuthRegistViewConfig("auth_close", new AuthRegisterViewConfig.Builder()
                        .setView(button)
                        .setRootViewId(AuthRegisterViewConfig.RootViewId.ROOT_VIEW_ID_BODY)
                        .build());
            } catch (IOException error) {
                // Preserve a way out when a caller supplies a missing image.
                config.setNavHidden(false);
            }
        }
        int authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_SENSOR_PORTRAIT;
        if (Build.VERSION.SDK_INT == 26) {
            authPageOrientation = ActivityInfo.SCREEN_ORIENTATION_BEHIND;
        }
        mAuthHelper.setAuthUIConfig(config.setScreenOrientation(authPageOrientation).create());
    }
}
