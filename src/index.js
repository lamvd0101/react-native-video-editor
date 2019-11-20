import { NativeModules } from "react-native";
const { RNVideoEditor } = NativeModules;

export class VideoEditor {
  // Info functions
  static async getVideoInfo(source) {
    return await RNVideoEditor.getVideoInfo(source);
  }
  static async getPictureAtPosition(source, { format = "base64", second }) {
    return await RNVideoEditor.getPictureAtPosition(source, {
      format,
      second
    });
  }
  static async getPictures(source) {
    return await RNVideoEditor.getPictures(source);
  }

  // Main functions
  static async merge(videos = []) {
    return await RNVideoEditor.merge(videos);
  }
  static async mergeWithAudio(source, audioSource) {
    return await RNVideoEditor.mergeWithAudio(source, audioSource);
  }
  static async trim(source, { startTime, endTime }) {
    return await RNVideoEditor.trim(source, {
      startTime,
      endTime
    });
  }
  static async compress() {}
  static async crop() {}

  // Draw functions
  static async addImage() {}
  static async addText() {}

  // Effect functions
  static async filter() {}
  static async reverse() {}
  static async boomerang() {}
  static async effect() {}

  // Clean functions
  static async cleanFiles(callback = () => {}) {
    return await RNVideoEditor.cleanFiles(callback);
  }
}
