/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package org.dyne.zshaolin.startup;
import org.dyne.zshaolin.R;

import java.io.File;

import android.app.Activity;
import android.app.Dialog;
import android.app.ProgressDialog;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.graphics.Typeface;
import android.os.Bundle;
import android.os.Environment;
import android.os.Handler;
import android.os.Message;
import android.preference.PreferenceManager;
import android.util.Log;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.TextView;
import android.widget.Toast;

import com.spartacusrex.spartacuside.TermService;
import org.dyne.zshaolin.startup.setup.filemanager;

/**
 *
 * @author Spartacus Rex
 */
public class installer extends Activity implements OnClickListener{

    //THE MAIN INSTALL VALUE
    public static int      CURRENT_INSTALL_SYSTEM_NUM  = 4;
    public static String   CURRENT_INSTALL_SYSTEM      = "System v0.6.1";
    public static String   CURRENT_INSTALL_ASSETFILE   = "system-0.6.1.tar.lzma.mp3";

    private ProgressDialog mInstallProgress;
    
    boolean mOverwriteAll = false;

    public Handler mInstallHandler = new Handler() {
        @Override
        public void handleMessage(Message zMsg) {
            Bundle msg = zMsg.getData();
            //Is it over
            if(msg.containsKey("close_install")){
                //Shut it down..
                mInstallProgress.dismiss();

                //Set the Text
                SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(installer.this);
                String current   =  prefs.getString("CURRENT_SYSTEM", "no system installed");
                TextView tv = (TextView)findViewById(R.id.install_sys);
                tv.setText("Current   : "+current+"\n"+  "Available : "+CURRENT_INSTALL_SYSTEM);

                //Start the service
                Intent mTSIntent = new Intent(installer.this, TermService.class);
                startService(mTSIntent);
                
            }else if(msg.containsKey("error")){
                String info = msg.getString("error");
                mInstallProgress.setMessage(info);
                
                Toast.makeText(installer.this, "ERROR : \n"+info, Toast.LENGTH_LONG).show();

            }else{
                String info = msg.getString("info");
                mInstallProgress.setMessage(info);
            }
        }
    };

    @Override
    public void onCreate(Bundle icicle) {
        super.onCreate(icicle);

        //Set the right Content
        setContentView(R.layout.install);

        //Get the current system
        SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(this);
        String current   =  prefs.getString("CURRENT_SYSTEM", "no system installed");
        int currentnum   =  prefs.getInt("CURRENT_SYSTEM_NUM", 0);
        String avail        =  CURRENT_INSTALL_SYSTEM;

        TextView tv = (TextView)findViewById(R.id.install_sys);
        tv.setTypeface(Typeface.MONOSPACE);
        tv.setText("Current   : "+current+"\n"+  "Available : "+avail);

        Button but = (Button)findViewById(R.id.install_start);
        but.setOnClickListener(this);
    }

    @Override
    protected Dialog onCreateDialog(int id) {
        mInstallProgress = new ProgressDialog(this);
        mInstallProgress.setTitle("System installing..");
        mInstallProgress.setMessage("Please wait..");
        mInstallProgress.setCancelable(false);

        return mInstallProgress;
    }
    public void onClick(View zButton) {
        if(zButton == findViewById(R.id.install_start)){
            //Extract all the files..
            showDialog(0);
            
            //Shut down the service
            Intent mTSIntent = new Intent(this, TermService.class);
            stopService(mTSIntent);

            //Overwrite
            CheckBox over = (CheckBox)findViewById(R.id.install_overwrite);
            mOverwriteAll = over.isChecked();

            //Start the Installer
            Thread tt = new Thread(){
                public void run(){
                    //Set the Message
                    Message msg = new Message();
                    msg.getData().putString("info", "Starting System install..");
                    mInstallHandler.sendMessage(msg);

                    //Main HOME FOlder
                    File home = installer.this.getFilesDir();

                    //Where to store the system number
                    SharedPreferences prefs = PreferenceManager.getDefaultSharedPreferences(installer.this);
                        
                    try {
                        //Create a working Directory
                        File tmp = new File(home, "tmp");
                        if (!tmp.exists()) {
                            tmp.mkdirs();
                        }

                        //Working directory
                        File worker = new File(tmp,"sys_install_"+System.currentTimeMillis());
                        if(!worker.exists()){
                            worker.mkdirs();
                        }

                        //Extract the assets..
                        msg = new Message();
                        msg.getData().putString("info", "Preparing tar..");
                        mInstallHandler.sendMessage(msg);

                        File busytar = new File(worker, "busybox");
                        if(busytar.exists()){
                           busytar.delete();
                        }

                        //Extract BusyBox, need it just for ln and cp
                        filemanager.extractAsset(installer.this, "busybox.mp3", busytar);

                        //Set up a simple environment
                        String[] env = new String[2];
                        env[0] = "PATH=/sbin:/vendor/bin:/system/sbin:/system/bin:/system/xbin";
                        env[1] = "LD_LIBRARY_PATH=/vendor/lib:/system/lib";

                        //Set executable
                        Process pp = Runtime.getRuntime().exec
			    ("chmod 770 "+busytar.getPath(),env,home);

                        pp.waitFor();

                        msg = new Message();
                        msg.getData().putString("info", "Preparing "+CURRENT_INSTALL_SYSTEM+" ..");
                        mInstallHandler.sendMessage(msg);

                        File systar = new File(worker, "system.tar.gz");
                        filemanager.extractAsset(installer.this, CURRENT_INSTALL_ASSETFILE, systar);

                        //Now start
                        msg = new Message();
                        msg.getData().putString("info", "Removing the old system..");
                        mInstallHandler.sendMessage(msg);
                        
                        File system = new File(home,"system");
                        filemanager.deleteFolder(system);
                        
                        msg = new Message();
                        msg.getData().putString("info", "Extracting the new system..");
                        mInstallHandler.sendMessage(msg);
                        

			File bins = new File(system,"bin");

                        //Now run the extract command
                        pp = Runtime.getRuntime().exec
			    (busytar.getPath()+
			     " tar -C "+home.getPath()+" -xaf "+systar.getPath(),env,home);
                        pp.waitFor();                        

                        //Now copy some initial files..
                        msg = new Message();
                        msg.getData().putString("info", "Initializing the environment..");
                        mInstallHandler.sendMessage(msg);

                        File etc = new File(system,"etc");
			File skel = new File(etc, "skel");
                        // zshrc
			
                        File zshrc   = new File(skel,"zshrc");
                        File zshrcu  = new File(home,".zshrc");
                        if(!zshrcu.exists()  || mOverwriteAll){
                            pp = Runtime.getRuntime().exec
				(busytar.getPath()+
				 " cp -f "+zshrc.getPath()+" "+zshrcu.getPath(),env,home);
                            pp.waitFor();
                        }

                        // grml.conf
                        File grml   = new File(skel,"grml.conf");
                        File grmlu  = new File(home,".grml.conf");
                        if(!grmlu.exists()  || mOverwriteAll){
                            pp = Runtime.getRuntime().exec
				(busytar.getPath()+
				 " cp -f "+grml.getPath()+" "+grmlu.getPath(),env,home);
                            pp.waitFor();
                        }

                        //Create a link to the sdcard
                        File sdcard  = Environment.getExternalStorageDirectory();
                        File lnsdcard = new File(home,"sdcard");
                        String func = busytar.getPath()+" ln -s "+sdcard.getPath()+" "+lnsdcard.getPath();
                        Log.v("ZShaolin", "SDCARD ln : "+func);
//                        pp = Runtime.getRuntime().exec(func);
                        pp = Runtime.getRuntime().exec(func,env,home);
                        pp.waitFor();

			//Make a few initial folders
                        //File public_html = new File(home,"public_html");
                        //if(!.exists()){public_html.mkdirs();}

                        msg = new Message();
                        msg.getData().putString("info", "Cleaning up..");
                        mInstallHandler.sendMessage(msg);
                        filemanager.deleteFolder(worker);

                        //SYSTEM INSTALLED!!
                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("CURRENT_SYSTEM", CURRENT_INSTALL_SYSTEM);
                        editor.putInt("CURRENT_SYSTEM_NUM", CURRENT_INSTALL_SYSTEM_NUM);
                        editor.commit();
                        
                    } catch (Exception iOException) {
                        Log.v("ZShaolin", "INSTALL SYSTEM EXCEPTION : "+iOException);

                        msg = new Message();
                        msg.getData().putString("error", iOException.toString());
                        mInstallHandler.sendMessage(msg);

                        SharedPreferences.Editor editor = prefs.edit();
                        editor.putString("CURRENT_SYSTEM", "ERROR : Last Install");
                        editor.putInt("CURRENT_SYSTEM_NUM", -1);
                        editor.commit();
                    }

                    //Its done..
                    msg = new Message();
                    msg.getData().putString("info", "System install complete!");
                    mInstallHandler.sendMessage(msg);

                    msg = new Message();
                    msg.getData().putString("close_install", "1");
                    mInstallHandler.sendMessage(msg);

                    Log.v("ZShaolin", "Finished Binary Install");
                }
            };
            tt.start();
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);   
        Log.v("ZShaolin","Installer onConfigurationChanged!!!!");
    }
}
