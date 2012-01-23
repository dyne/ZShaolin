/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */

package com.spartacusrex.spartacuside.startup.setup;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import android.content.Context;
import android.util.Log;

/**
 *
 * @author Spartacus Rex
 */
public class filemanager {

    private static void log(String zLog){
        Log.v("SpartacusRex","BinaryManager : "+zLog);
    }

    private static void copyFile(InputStream in, OutputStream out) throws IOException {
        byte[] buffer = new byte[1024];
        int read;
        while((read = in.read(buffer)) != -1){
          out.write(buffer, 0, read);
        }
    }

    public static void extractAsset(Context zContext, String zAssetFile, File zOuput) throws IOException {
        InputStream in  = zContext.getAssets().open(zAssetFile);
        OutputStream os = new FileOutputStream(zOuput);
        copyFile(in,os);
        in.close();
        os.close();
    }

    public static void deleteFolder(File zFile){
        if(zFile.isDirectory()){
            //Its a directory
            File[] files = zFile.listFiles();
            for(File ff : files){
                deleteFolder(ff);
            }
        }

        //Now delete
        zFile.delete();
    }

    public static void extractBinaryFiles(Context zContext){
        //Extract some stuff..
        File home = zContext.getFilesDir();
        log("Main Files dir : "+home.getPath());

        if(true){
            return;
        }

        File system = new File(home,"system");

        File andr   = new File(system,"android");
        andr.mkdirs();
        File andjar = new File(andr,"android.jar");

        File bindir = new File(system,"bin");
        bindir.mkdirs();
        File busyb = new File(bindir,"busybox");
        File bbdir = new File(bindir,"bbdir");
        bbdir.mkdirs();

        //get the assets
        try {
            String[] files = zContext.getAssets().list("binary");
            boolean onefound=false;

            for (int i = 0; i < files.length; i++) {
                String name = files[i];

                String pname = new String(name);
                if(name.endsWith(".mp3")){
                    //Remove it..
                    pname = files[i].substring(0, files[i].length()-4);
                }
                
                //Bin file
                File binfile = new File(bindir,pname);

                //Check exists
                if(!binfile.exists()){
                    onefound=true;
                    log("Copying file : "+files[i]);

                    //Asset file
                    InputStream in  = zContext.getAssets().open("binary/"+files[i]);

                    //Output
                    OutputStream os = new FileOutputStream(binfile);

                    copyFile(in, os);

                    //CLose both streams
                    in.close();
                    os.close();

                    log("File copied: "+files[i]+" as "+binfile.getPath());

                    //Now set the mode..
//                    log("RUN CHMOD : chmod 550 "+binfile.getPath());
                    Process pp = Runtime.getRuntime().exec("chmod 550 "+binfile.getPath());
                    pp.waitFor();
                }
            }

            //Now copy over android.jar
            if(!andjar.exists()){
                onefound = true;
                
                log("Install android.jar");
                extractAsset(zContext, "androidjar/android.jar", andjar);
            }
            
            //Now extract home files..
            if(onefound){
                //reinstall busybox links
                File binfile = new File(bindir,"busybox");
                String command = binfile.getPath()+" --install -s "+bbdir.getPath();
                log("BB INSTALL command "+command);
                Runtime.getRuntime().exec(command);

                log("Install home files");
                extractAsset(zContext, "home/vimrc", new File(home, ".vimrc"));
                extractAsset(zContext, "home/bashrc", new File(home, ".bashrc"));
                extractAsset(zContext, "home/bash_profile", new File(home, ".bash_profile"));
                extractAsset(zContext, "home/inputrc", new File(home, ".inputrc"));
                
                //Now extract etc
                File extract = new File(system,"etc.tar.gz");
                log("Extract ETC ");
                extractAsset(zContext, "etc/etc.tar.gz.mp3", extract);

                //Now run bbox..
                command = binfile.getPath()+" tar -xz -C "+system.getPath()+" -f "+extract.getPath();
                log("BB command "+command);
                Process pp = Runtime.getRuntime().exec(command);
                log("BB command started..");
                int result = pp.waitFor();
                log("BB command finshed .."+result);

                //And now remove it..
                extract.delete();
                
                //Now extract the init file
                File init = new File(system,"init");
                extractAsset(zContext, "sys/init", init);
            }
            
        } catch (IOException iOException) {
            log("Exception extracting files : "+iOException);
        } catch (InterruptedException iOException) {
            log("Exception extracting files : "+iOException);
        }

        log("All done..!");
    }
}
