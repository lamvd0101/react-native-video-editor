import {NativeEventEmitter, NativeModules, Platform} from 'react-native';
const {RNVideoEditor} = NativeModules;

const getChatEmitter = () => {
  try {
    return new NativeEventEmitter(NativeModules.VideoEditEmitter);
  } catch (error) {}
};


export class VideoEditor {
  static emitter = getChatEmitter();
  // Source is path with Android & PhotoAsset with iOS
  static logEvent(callback=()=>{}){
    try {
      VideoEditor.emitter?.addListener('logEvent', callback);
    } catch (error) {}
  }
  // Info functions
  static async getLocalURL(source) {
    return await RNVideoEditor.getLocalURL(source);
  }
  static async getVideoInfo(source) {
    return await RNVideoEditor.getVideoInfo(source);
  }
  static async getPictureAtPosition(source, {format = 'base64', second}) {
    return await RNVideoEditor.getPictureAtPosition(source, {
      format,
      second,
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
  static async trim(source, {startTime, endTime, logFunc}) {
    return await RNVideoEditor.trim(source, {
      startTime,
      endTime,
      logFunc,
    });
  }
  static async compress() {}
  static async crop() {}
  static async cancel(callback = () => {}) {
    return await RNVideoEditor.cancel(callback);
  }

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
