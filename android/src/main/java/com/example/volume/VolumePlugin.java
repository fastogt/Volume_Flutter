package com.example.volume;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Context;
import android.database.ContentObserver;
import android.media.AudioManager;
import android.os.Handler;
import android.util.Log;

import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.Registrar;
import io.flutter.view.FlutterNativeView;

/**
 * VolumePlugin
 */
public class VolumePlugin extends ContentObserver implements MethodCallHandler {

    private final MethodChannel channel;
    private Activity activity;
    AudioManager audioManager;
    private int streamType;

    /**
     * Plugin registration.
     */
    public static void registerWith(final Registrar registrar) {
        final MethodChannel channel = new MethodChannel(registrar.messenger(), "volume");
        final VolumePlugin volumePlugin = new VolumePlugin(registrar.activity(), channel);
        channel.setMethodCallHandler(volumePlugin);

        registrar.activity().getContentResolver()//
                .registerContentObserver(android.provider.Settings.System.CONTENT_URI,//
                        true, volumePlugin);

        registrar.addViewDestroyListener(new PluginRegistry.ViewDestroyListener() {
            @Override
            public boolean onViewDestroy(FlutterNativeView v) {
                registrar.activity().getContentResolver().unregisterContentObserver(volumePlugin);
                return true;
            }
        });

    }

    private VolumePlugin(Activity activity, MethodChannel channel) {
        super(new Handler());
        this.activity = activity;
        this.channel = channel;
    }

    @Override
    public void onMethodCall(MethodCall call, Result result) {
        if (call.method.equals("controlVolume")) {
            streamType = call.argument("streamType");
            controlVolume(streamType);
        } else if (call.method.equals("getMaxVol")) {
            result.success(getMaxVol());
        } else if (call.method.equals("getVol")) {
            result.success(getVol());
        } else if (call.method.equals("setVol")) {
            int i = call.argument("newVol");
            setVol(i);
        } else {
            result.notImplemented();
        }
    }

    void controlVolume(int i) {
        initAudioManager();
        this.activity.setVolumeControlStream(i);
    }

    void initAudioManager() {
        audioManager = (AudioManager) this.activity.getApplicationContext().getSystemService(Context.AUDIO_SERVICE);
    }

    int getMaxVol() {
        initAudioManager();
        return audioManager.getStreamMaxVolume(streamType);
    }

    int getVol() {
        initAudioManager();
        return audioManager.getStreamVolume(streamType);
    }

    int setVol(int i) {
        initAudioManager();
        audioManager.setStreamVolume(streamType, i, 0);
        return audioManager.getStreamVolume(streamType);
    }

    @Override
    public boolean deliverSelfNotifications() {
        return false;
    }

    @Override
    public void onChange(boolean selfChange) {
        final int currentVolume = audioManager.getStreamVolume(streamType);
        final int maxVolume = audioManager.getStreamMaxVolume(streamType);
        channel.invokeMethod("volumeChanged", new HashMap<String, Integer>() {
            {
                put("currentVolume", Integer.valueOf(currentVolume));
                put("maxVolume", Integer.valueOf(maxVolume));
            }
        });

        Log.d("VOLUME", "Volume now " + currentVolume);
    }
}
