package com.tencent.fluwx_worker;

import android.content.Context;
import android.content.pm.ApplicationInfo;
import android.graphics.Bitmap;
import android.graphics.drawable.BitmapDrawable;
import android.widget.EditText;

import androidx.annotation.NonNull;

import com.tencent.wework.api.IWWAPI;
import com.tencent.wework.api.IWWAPIEventHandler;
import com.tencent.wework.api.WWAPIFactory;
import com.tencent.wework.api.model.BaseMessage;
import com.tencent.wework.api.model.WWAuthMessage;
import com.tencent.wework.api.model.WWBaseMessage;
import com.tencent.wework.api.model.WWMediaFile;
import com.tencent.wework.api.model.WWMediaImage;
import com.tencent.wework.api.model.WWMediaLink;
import com.tencent.wework.api.model.WWMediaMiniProgram;
import com.tencent.wework.api.model.WWMediaText;
import com.tencent.wework.api.model.WWMediaVideo;
import com.tencent.wework.api.model.WWSimpleRespMessage;

import java.io.ByteArrayOutputStream;
import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/**
 * FluwxWorkerPlugin
 */
public class FluwxWorkerPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;
    private static final String APPID = "ww494e047807125ecf";
    private static final String AGENTID = "1000012";
    private static final String SCHEMA = "wwauth1e933be11645237c000012";

    private Context context;
    private IWWAPI iwwapi;
    private String packageName;
    private ApplicationInfo applicationInfo;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "fluwx_worker");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
        packageName = context.getPackageName();
        applicationInfo = context.getApplicationInfo();

        iwwapi = WWAPIFactory.createWWAPI(context);
        iwwapi.registerApp(SCHEMA);
    }


    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
//    if (call.method.equals("getPlatformVersion")) {
//      result.success("Android " + android.os.Build.VERSION.RELEASE);
//    } else {
//      result.notImplemented();
//    }
        HashMap data = (HashMap) call.arguments;
        switch (call.method) {
            case "shareText":
                sendTextMsg(new WWMediaText(), data);
                break;
            case "shareImage":
                sendFileMsg(new WWMediaImage(), data);
                break;
            case "shareFile":
                sendFileMsg(new WWMediaFile(), data);
                break;
            case "shareVideo":
                sendFileMsg(new WWMediaVideo(), data);
                break;
            case "shareWebPage":
                sendLinkMsg(new WWMediaLink(), data);
                break;
            case "shareMiniProgram":
                sendMiniProgramMsg(new WWMediaMiniProgram(), data);
                break;
            default:
                break;
        }
    }

    private void sendMiniProgramMsg(@NonNull WWMediaMiniProgram wwMediaMiniProgram, @NonNull HashMap data) {
        wwMediaMiniProgram.username = (String) data.get("username");
        wwMediaMiniProgram.description = (String) data.get("description");
        wwMediaMiniProgram.path = (String) data.get("path");
        wwMediaMiniProgram.title = (String) data.get("title");

        // 图片
        int resId = (int) data.get("resId");
        Bitmap bitmap = ((BitmapDrawable) context.getDrawable(resId)).getBitmap();
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, 0, stream);
        byte[] byteArray = stream.toByteArray();
        if (byteArray.length > 0) {
            wwMediaMiniProgram.hdImageData = byteArray;
        }

        sendMsg(wwMediaMiniProgram);
    }

    private void sendLinkMsg(@NonNull WWMediaLink wwMediaLink, @NonNull HashMap data) {
        wwMediaLink.thumbUrl = (String) data.get("thumbUrl");
        wwMediaLink.webpageUrl = (String) data.get("webpageUrl");
        wwMediaLink.title = (String) data.get("title");
        wwMediaLink.description = (String) data.get("description");
        iwwapi.sendMessage(wwMediaLink, iwwapiEventHandler);
    }

    private void sendTextMsg(@NonNull WWMediaText wwMediaText, @NonNull HashMap data) {
        String text = (String) data.get("text");
        wwMediaText.text = text;
        sendMsg(wwMediaText);
    }

    private void sendFileMsg(@NonNull WWMediaFile wwMediaFile, @NonNull HashMap data) {
        String fileName = (String) data.get("fileName");
        String filePath = (String) data.get("filePath");
        sendFileMsg(wwMediaFile, filePath, fileName);
    }

    private void sendFileMsg(@NonNull WWMediaFile wwMediaFile, String fileName, String filePath) {
        wwMediaFile.fileName = fileName;
        wwMediaFile.filePath = filePath;
        sendMsg(wwMediaFile);
    }

    private void sendMsg(@NonNull WWBaseMessage wwBaseMessage) {
        wwBaseMessage.appPkg = packageName;
        wwBaseMessage.appName = applicationInfo.name;
        wwBaseMessage.appId = APPID;
        wwBaseMessage.agentId = AGENTID;
        iwwapi.sendMessage(wwBaseMessage, iwwapiEventHandler);
    }

    private IWWAPIEventHandler iwwapiEventHandler = baseMessage -> {
        if (baseMessage instanceof WWAuthMessage.Resp) {
            WWAuthMessage.Resp resp = (WWAuthMessage.Resp) baseMessage;
            switch (resp.errCode) {
                case WWAuthMessage.ERR_CANCEL:
                    break;
                case WWAuthMessage.ERR_FAIL:
                    break;
                case WWAuthMessage.ERR_OK:
                    break;
                default:
                    break;
            }
        }
        if (baseMessage instanceof WWSimpleRespMessage) {
            WWSimpleRespMessage  wwSimpleRespMessage = (WWSimpleRespMessage) baseMessage;
            //
        }
    };
}
