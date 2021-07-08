//
//  RNVideoEditorUtilities.java
//  ReactionSocial
//
//  Created by Vuong Duc Lam on 9/5/19.
//

package com.lamvd0101.RNVideoEditor;

import android.media.MediaMetadataRetriever;
import android.net.Uri;
import android.util.Log;

import com.facebook.react.bridge.ReactApplicationContext;

import java.io.File;
import java.util.UUID;

public class RNVideoEditorUtilities {
  private static final String filePrefix = "reaction-media";
  private static final int DEFAULT_VIDEO_WIDTH = 720;
  private static final int DEFAULT_VIDEO_HEIGHT = 1280;

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

  public static VideoSize determineOutputVideoSize(String source) {
    if (source == null) {
      return new VideoSize(DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT);
    }

    MediaMetadataRetriever retriever = new MediaMetadataRetriever();
    try {
      if (RNVideoEditorUtilities.shouldUseURI(source)) {
        Uri uri = Uri.parse(source);
        retriever.setDataSource(uri.getPath());
      } else {
        retriever.setDataSource(source);
      }
      int width = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_WIDTH));
      int height = Integer.parseInt(retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_VIDEO_HEIGHT));
      VideoSize videoSize = new VideoSize(width, height);
      Log.d("RNVideoEditorUtilities", "determineOutputVideoSize video size before scale: " + videoSize.toString());
      applyScale(videoSize);
      Log.d("RNVideoEditorUtilities", "determineOutputVideoSize video size after scale: " + videoSize.toString());
      return videoSize;
    } catch (Exception e) {
      Log.e("RNVideoEditorUtilities", "getVideoRatio fail");
      e.printStackTrace();
      return new VideoSize(DEFAULT_VIDEO_WIDTH, DEFAULT_VIDEO_HEIGHT);
    } finally {
      retriever.release();
    }
  }

  private static void applyScale(VideoSize videoSize) {
    int oldWidth = videoSize.width;
    int oldHeight = videoSize.height;
    int maxPixelCount = DEFAULT_VIDEO_WIDTH * DEFAULT_VIDEO_HEIGHT;
    int newWidth = (int) Math.round(Math.sqrt(maxPixelCount * oldWidth / (float) oldHeight));
    int newHeight = newWidth * oldHeight / oldWidth;
    videoSize.width = newWidth;
    videoSize.height = newHeight;
  }
}
