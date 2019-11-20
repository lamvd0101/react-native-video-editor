//
//  RNVideoEditorModule.m
//  ReactionSocial
//
//  Created by Vuong Duc Lam on 9/3/19.
//

#import "React/RCTBridgeModule.h"

@interface RCT_EXTERN_REMAP_MODULE(RNVideoEditor, RNVideoEditorModule, NSObject)

RCT_EXTERN_METHOD(
                  getVideoInfo: (NSString *)source
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  );
RCT_EXTERN_METHOD(
                  getPictureAtPosition: (NSString *)source
                  options: (NSDictionary *)options
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  );
RCT_EXTERN_METHOD(
                  getPictures: (NSString *)source
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  );
RCT_EXTERN_METHOD(
                  merge: (NSArray *)videoFiles
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  );
RCT_EXTERN_METHOD(
                  mergeWithAudio: (NSString *)source
                  audioSource: (NSString *)audioSource
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  );
RCT_EXTERN_METHOD(
                  trim: (NSString *)source
                  options: (NSDictionary *)options
                  resolver: (RCTPromiseResolveBlock)resolve
                  rejecter: (RCTPromiseRejectBlock)reject
                  );
RCT_EXTERN_METHOD(
                  cleanFiles: (RCTResponseSenderBlock)callback
                  );

@end
