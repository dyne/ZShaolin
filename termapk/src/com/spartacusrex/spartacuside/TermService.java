/*
 * Copyright (C) 2007 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.spartacusrex.spartacuside;

import java.io.File;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.net.InetAddress;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.dyne.zshaolin.R;

import android.app.Notification;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.wifi.WifiManager;
import android.os.Binder;
import android.os.IBinder;
import android.os.PowerManager;
import android.preference.PreferenceManager;
import android.util.Log;

import com.spartacusrex.spartacuside.session.TermSession;
import com.spartacusrex.spartacuside.util.ServiceForegroundCompat;
import com.spartacusrex.spartacuside.util.TermSettings;
import com.spartacusrex.spartacuside.web.webserver;

public class TermService extends Service implements SharedPreferences.OnSharedPreferenceChangeListener
{
    /* Parallels the value of START_STICKY on API Level >= 5 */
    private static final int COMPAT_START_STICKY = 1;

    private static final int RUNNING_NOTIFICATION = 1;
    private ServiceForegroundCompat compat;

    private ArrayList<TermSession> mTermSessions;

    private webserver mServer;

    private SharedPreferences mPrefs;
    private TermSettings mSettings;
    private boolean mSessionInit;

    private PowerManager.WakeLock mScreenLock;
    private PowerManager.WakeLock mWakeLock;
    private WifiManager.WifiLock  mWifiLock;

    public void onSharedPreferenceChanged(SharedPreferences arg0, String zKey) {
        if(zKey.contains("lock")){
            setupWakeLocks();
        }
    }

    public class TSBinder extends Binder {
        TermService getService() {
            Log.i("TermService", "Activity binding to service");
            return TermService.this;
        }
    }
    private final IBinder mTSBinder = new TSBinder();

    @Override
    public void onStart(Intent intent, int flags) {
    }

    /* This should be @Override if building with API Level >=5 */
    public int onStartCommand(Intent intent, int flags, int startId) {
        return COMPAT_START_STICKY;
    }

    @Override
    public IBinder onBind(Intent intent) {
        Log.i("TermService", "Activity called onBind()");
        return mTSBinder;
    }

    @Override
    public void onCreate() {
        compat = new ServiceForegroundCompat(this);
        mTermSessions = new ArrayList<TermSession>();

        /* Put the service in the foreground. */
        Notification notification = new Notification(R.drawable.terminal, getText(R.string.service_notify_text), System.currentTimeMillis());
        notification.flags |= Notification.FLAG_ONGOING_EVENT;
        Intent notifyIntent = new Intent(this, Term.class);
        notifyIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
        PendingIntent pendingIntent = PendingIntent.getActivity(this, 0, notifyIntent, 0);
        notification.setLatestEventInfo(this, getText(R.string.application_terminal), getText(R.string.service_notify_text), pendingIntent);
        compat.startForeground(RUNNING_NOTIFICATION, notification);

        mPrefs = PreferenceManager.getDefaultSharedPreferences(this);
        mPrefs.registerOnSharedPreferenceChangeListener(this);
        
        mSettings = new TermSettings(mPrefs);

        //Need to set the HOME Folder and Bash startup..
        //Sometime getfilesdir return NULL ?
        mSessionInit = false;
        File home    = getFilesDir();
        if(home!= null){
            initSessions(home);
        }

        //Start a webserver for comms..
//        mServer = new webserver(this);
//        mServer.start();

        PowerManager pm = (PowerManager)getSystemService(Context.POWER_SERVICE);
        WifiManager wm  = (WifiManager)getSystemService(Context.WIFI_SERVICE);

        //Get a wake lock
        mWakeLock   = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, TermDebug.LOG_TAG);
        mScreenLock = pm.newWakeLock(PowerManager.SCREEN_DIM_WAKE_LOCK, TermDebug.LOG_TAG);
        mWifiLock   = wm.createWifiLock(WifiManager.WIFI_MODE_FULL, TermDebug.LOG_TAG);

        //Get the Initial Values
//        boolean cpulock     = getStringPref("cpulock","1") == 1 ? true : false;
//        boolean wifilock    = getStringPref("wifilock","0") == 1 ? true : false;
//        boolean screenlock  = getStringPref("screenlock","0") == 1 ? true : false;
        setupWakeLocks();

        Log.d(TermDebug.LOG_TAG, "TermService started");

        return;
    }

    private int getStringPref(String zKey, String zDefault){
        int ival = 0;
        try {
            String value = mPrefs.getString(zKey, zDefault);
            ival = Integer.parseInt(value);
        } catch (NumberFormatException numberFormatException) {
            return 0;
        }
        return ival;
    }

    public void setupWakeLocks(){
        //Get the Initial Values
        boolean cpulock     = getStringPref("cpulock","1") == 1 ? true : false;
        boolean wifilock    = getStringPref("wifilock","0") == 1 ? true : false;
        boolean screenlock  = getStringPref("screenlock","0") == 1 ? true : false;

        Log.d(TermDebug.LOG_TAG, "AQUIRING LOCKS "+cpulock+" "+screenlock+" "+wifilock);
        
        //Turn each Wake Lock On..
        try {
            if (cpulock) {
                if (!mWakeLock.isHeld()) {
                    mWakeLock.acquire();
                }
            } else {
                if (mWakeLock.isHeld()) {
                    mWakeLock.release();
                }
            }

            if (screenlock) {
                if (!mScreenLock.isHeld()) {
                    mScreenLock.acquire();
                }
            } else {
                if (mScreenLock.isHeld()) {
                    mScreenLock.release();
                }
            }

            if (wifilock) {
                if (!mWifiLock.isHeld()) {
                    mWifiLock.acquire();
                }
            } else {
                if (mWifiLock.isHeld()) {
                    mWifiLock.release();
                }
            }
            
        } catch (Exception e) {
            Log.d(TermDebug.LOG_TAG, "Error getting WAKELOCK "+e);
        }
    }

    private void initSessions(File zHome){
        if(mSessionInit){
            return;
        }

        //Create the initial BASH init-file
        if(!createBashInit(zHome)){
            return;
        }
        
        //Create 4 initial Terminals
        mTermSessions.add(createTermSession(zHome));
        mTermSessions.add(createTermSession(zHome));
        mTermSessions.add(createTermSession(zHome));
        mTermSessions.add(createTermSession(zHome));

        mSessionInit = true;
    }

    private boolean createBashInit(File zHome){
        File init = new File(zHome,".init");
        if(init.exists()){
           init.delete(); 
        }

        try {
            //Create from scratch
            init.createNewFile();
            
            FileOutputStream fos = new FileOutputStream(init);
            PrintWriter pw = new PrintWriter(fos);
            pw.println("#BASH init-file");
            pw.println("#AUTOMAGICALLY GENERATED - DO NOT TOUCH!");
            pw.println("export HOME="+zHome.getPath());
            pw.println("export APK="+getPackageResourcePath());
            pw.println("export HOSTNAME="+getLocalIpAddress());
            pw.println("");
            pw.println("#If ~/.bashrc exists - run it.");
            pw.println("if [ -f $HOME/.bashrc ]; then");
            pw.println("    . $HOME/.bashrc");
            pw.println("fi");
            pw.println("");
            pw.flush();
            pw.close();
            fos.close();

            //Make sure the /tmp folder ALWAYS exists
            File temp = new File(zHome,"tmp");
            if(!temp.exists()){
                temp.mkdirs();
            }
            
        } catch (Exception ex) {
            Logger.getLogger(TermService.class.getName()).log(Level.SEVERE, null, ex);

            return false;
        }

        return true;
    }

    @Override
    public void onDestroy() {
        compat.stopForeground(true);
        for (TermSession session : mTermSessions) {
            session.finish();
        }
        mTermSessions.clear();

        if (mWakeLock.isHeld()) {
            mWakeLock.release();
        }

        if(mScreenLock.isHeld()){
            mScreenLock.release();
        }

        if(mWifiLock.isHeld()){
            mWifiLock.release();
        }

//        mServer.stop();
        
        return;
    }

    public ArrayList<TermSession> getSessions(File zHome) {
        if(zHome!=null){
           initSessions(zHome);
        }

        return mTermSessions;
    }


    public String getLocalIpAddress() {
        String addr = null;
        
        try {
            for (Enumeration<NetworkInterface> en = NetworkInterface.getNetworkInterfaces(); en.hasMoreElements();) {
                NetworkInterface intf = en.nextElement();
                for (Enumeration<InetAddress> enumIpAddr = intf.getInetAddresses(); enumIpAddr.hasMoreElements();) {
                    InetAddress inetAddress = enumIpAddr.nextElement();
                    String ip = inetAddress.getHostAddress().toString();
                    if (!inetAddress.isLoopbackAddress()) {
                        if(addr==null || ip.length() < addr.length()){
                            addr = ip;
                        }
                    }
                }
            }

        } catch (SocketException ex) {
            Log.e("SpartacusRex GET LOCAL IP : ", ex.toString());
        }

        if(addr!=null){
            return addr;
        }

        return "127.0.0.1";
    }

    private TermSession createTermSession(File zHome) {
        //String HOME = getApplicationContext().getFilesDir().getPath();
        //String APK  = getPackageResourcePath();
        //String IP   = getLocalIpAddress();
        //if(IP == null){
        //   IP = "127.0.0.1";
        //}

        String initialCommand = "";//export HOME="+HOME+";cd $HOME;~/system/init "+HOME+" "+APK+" "+IP;

//        return new TermSession(getApplicationContext(),mSettings, null, initialCommand);
        return new TermSession(zHome.getPath(),mSettings, null, initialCommand);
    }
}
