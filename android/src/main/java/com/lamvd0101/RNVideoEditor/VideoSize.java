package com.lamvd0101.RNVideoEditor;

public class VideoSize {
    int width;
    int height;

    VideoSize(int width, int height){
        this.width=width;
        this.height=height;
    }

    @Override
    public String toString() {
        return "VideoSize{" +
                "width=" + width +
                ", height=" + height +
                '}';
    }
}
