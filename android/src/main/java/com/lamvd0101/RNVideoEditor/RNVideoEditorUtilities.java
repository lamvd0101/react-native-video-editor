//
//  RNVideoEditorUtilities.java
//  ReactionSocial
//
//  Created by Vuong Duc Lam on 9/5/19.
//

package com.lamvd0101.RNVideoEditor;

import com.facebook.react.bridge.ReactApplicationContext;

import java.io.File;
import java.util.UUID;

public class RNVideoEditorUtilities {
  private static final String filePrefix = "reaction-media";

  public static File createTempFile(String extension, ReactApplicationContext ctx) throws Exception {
    try {
      UUID uuid = UUID.randomUUID();
      String imageName = uuid.toString();

      File cacheDir = ctx.getCacheDir();
      File tempFile = File.createTempFile(filePrefix + "-" + imageName, "." + extension, cacheDir);

      if (tempFile.exists()) {
        tempFile.delete();
      }

      return tempFile;
    } catch (Exception e) {
      throw new Exception("Failed to create temp file.");
    }
  }

  public static void cleanFiles(ReactApplicationContext ctx) throws Exception {
    try {
      File cacheDir = ctx.getCacheDir();
      File[] files = cacheDir.listFiles();
      for (int i = 0; i < files.length; i++) {
        if (files[i].getName().contains(RNVideoEditorUtilities.filePrefix)) {
          files[i].delete();
        }
      }
    } catch (Exception e) {
      throw new Exception("Failed to clean files.");
    }
  }

  public static boolean shouldUseURI(String path) {
    String[] protocols = {
            "content://",
            "file://",
            "http://",
            "https://"
    };
    if (path == null) {
      return false;
    }
    boolean lookupWithURI = false;
    for (String protocol : protocols) {
      if (path.toLowerCase().startsWith(protocol)) {
        lookupWithURI = true;
        break;
      }
    }
    return lookupWithURI;
  }

  public static String parseSecondsToString(double seconds) {
    int h = (int) seconds / 3600;
    int m = (int) (seconds % 3600) / 60;
    int s = (int) seconds % 60;

    return String.format("%02d:%02d:%02d", h, m, s);
  }
}