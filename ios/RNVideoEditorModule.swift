//
//  RNVideoEditorModule.swift
//  ReactionSocial
//
//  Created by Vuong Duc Lam on 9/3/19.
//

import Foundation
import AVFoundation
import UIKit

@objc(RNVideoEditorModule)
class RNVideoEditorModule: NSObject {
    let VIDEO_WIDTH: Int = 720
    let VIDEO_HEIGHT: Int = 1280
    let VIDEO_FPS: Int = 30
    let VIDEO_BITRATE: Int = 4000000
    var exportSession: SDAVAssetExportSession? = nil
    
    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }
    func exportSession(
            asset: AVAsset,
            outputURL: URL,
            timeRange: CMTimeRange?,
            resolver resolve: @escaping RCTPromiseResolveBlock,
            rejecter reject: @escaping RCTPromiseRejectBlock
        ) -> Void {
            VideoEditEmitter.logEvent(params:["name": "step2"])
            self.exportSession = SDAVAssetExportSession(asset: asset)
            guard self.exportSession != nil else { return reject(nil, nil, "Export failed.") }
            VideoEditEmitter.logEvent(params:["name": "step3"])
            self.exportSession!.outputURL = outputURL
            self.exportSession!.outputFileType = AVFileType.mp4.rawValue
            self.exportSession!.shouldOptimizeForNetworkUse = true
            if (timeRange != nil) {
                self.exportSession!.timeRange = timeRange!
            }
            VideoEditEmitter.logEvent(params:["name": "step4"])
            var size: CGSize = .zero
            if let track = asset.tracks(withMediaType: AVMediaType.video).first {
                size = track.naturalSize.applying(track.preferredTransform)
            }
        VideoEditEmitter.logEvent(params:["name": "step5", "height": String(format: "%.f", size.height),"width": String(format: "%.f", size.width)])
//            logEvent("{name: step2, size: \(size)}")
            var newWidth = Double(VIDEO_WIDTH)
            var newHeight = Double(VIDEO_HEIGHT)
            let width = abs(size.width), height = abs(size.height)
            print("mai.nguyen \(String(format: "%.f", size.width)) ")
            // case size.width <0 or size.height < 0
            if(size != .zero && (Double(size.width)<0 || Double(size.height)<0) && timeRange != nil){
                VideoEditEmitter.logEvent(params:["name": "step6"])
                self.compositionSession(
                    asset: asset,
                    outputURL: outputURL,
                    timeRange: timeRange,
                    resolver: resolve,
                    rejecter: reject
                )
                return;
            }
        
       
        
            if(size != .zero){
                let maxPixelCount = VIDEO_WIDTH * VIDEO_HEIGHT;
                newWidth = Double(round(sqrt(CGFloat(maxPixelCount) * width / height)));
                newHeight = Double(CGFloat(newWidth) * height / width);
            }
            VideoEditEmitter.logEvent(params:["name": "step7"])
            self.exportSession!.videoSettings = [
                AVVideoCodecKey: AVVideoCodecH264,
                AVVideoWidthKey: String(format: "%.f", newWidth),
                AVVideoHeightKey: String(format: "%.f", newHeight),
                AVVideoCompressionPropertiesKey: [
                    AVVideoMaxKeyFrameIntervalKey: self.VIDEO_FPS,
                    AVVideoAverageBitRateKey: self.VIDEO_BITRATE,
                    AVVideoProfileLevelKey: AVVideoProfileLevelH264High40
                ]
            ]
            self.exportSession!.audioSettings = [
                AVFormatIDKey: kAudioFormatMPEG4AAC,
                AVNumberOfChannelsKey: 2,
                AVSampleRateKey: 44100,
                AVEncoderBitRateKey: 128000
            ]
            
            self.exportSession!.exportAsynchronously(completionHandler: {
                switch self.exportSession!.status {
                case .completed:
                    self.exportSession = nil
                    resolve(outputURL.absoluteString)
                case .failed:
                    reject(nil, nil, "Export failed.")
                case .cancelled:
                    reject(nil, nil, "Cancelled by user.")
                default:
                    reject(nil, nil, "Export failed.")
                }
            })
        }
    
    func compositionSession(
        asset: AVAsset,
        outputURL: URL,
        timeRange: CMTimeRange!,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        VideoEditEmitter.logEvent(params:["name": "step8"])
        let compositionAsset = AVMutableComposition()

        let audioTrack: AVMutableCompositionTrack = compositionAsset.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: kCMPersistentTrackID_Invalid)!
        let videoTrack: AVMutableCompositionTrack = compositionAsset.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!
        
        
        if let videoAssetTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first,
            let audioAssetTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first {
            do {
                VideoEditEmitter.logEvent(params:["name": "step9"])
                try videoTrack.insertTimeRange(timeRange, of: videoAssetTrack, at: kCMTimeZero)
                try audioTrack.insertTimeRange(timeRange, of: audioAssetTrack, at: kCMTimeZero)
                videoTrack.preferredTransform = videoAssetTrack.preferredTransform
            } catch{
                VideoEditEmitter.logEvent(params:["name": "step10"])
                reject(nil, nil, error)
            }
        }
        VideoEditEmitter.logEvent(params:["name": "step11"])
        guard let exportSession = AVAssetExportSession(asset: compositionAsset, presetName: AVAssetExportPresetHighestQuality) else {return reject(nil, nil, "Export failed.")}
        VideoEditEmitter.logEvent(params:["name": "step12"])
        exportSession.outputURL = outputURL

        exportSession.shouldOptimizeForNetworkUse = true

        exportSession.outputFileType = .mp4

        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                self.exportSession = nil
                resolve(outputURL.absoluteString)
            case .failed:
                reject(nil, nil, "Export failed.")
            case .cancelled:
                reject(nil, nil, "Cancelled by user.")
            default:
                reject(nil, nil, "Export failed.")
            }
        }
    }

    @objc func getLocalURL(
        _ source: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        do {
            let asset: AVURLAsset! = try RNVideoEditorUtilities.requestAsset(source) as? AVURLAsset
            resolve(asset.url.absoluteString)
        } catch {
            reject(nil, nil, error)
        }
    }
    
    @objc func getVideoInfo(
        _ source: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        do {
            let asset: AVAsset! = try RNVideoEditorUtilities.requestAsset(source)
            var data: [String: Any] = [:]
            
            data["duration"] = asset.duration.seconds
            
            resolve(data)
        } catch {
            reject(nil, nil, error)
        }
    }
    
    @objc func getPictureAtPosition(
        _ source: String,
        options: NSDictionary,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        do {
            let asset: AVAsset! = try RNVideoEditorUtilities.requestAsset(source)
            let format: String = options.object(forKey: "format") as? String ?? "base64"
            var second: Double = options.object(forKey: "second") as? Double ?? 0
            if second > Double(asset.duration.seconds) || second < 0 {
                second = 0
            }
            
            let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let timestamp: CMTime = CMTime(seconds: second, preferredTimescale: 600)
            
            let imageRef: CGImage = try imageGenerator.copyCGImage(at: timestamp, actualTime: nil)
            let image: UIImage = UIImage(cgImage: imageRef)
            let imgData: Data? = UIImageJPEGRepresentation(image, 0.5)
            
            if format == "jpg" {
                let outputURL: URL = try RNVideoEditorUtilities.createTempFile("jpg")
                try imgData?.write(to: outputURL, options: .atomic)
                resolve(outputURL.absoluteString)
            } else {
                let base64String: String? = imgData?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
                resolve(base64String != nil ? "data:image/png;base64,\(base64String!)" : "")
            }
        } catch {
            reject(nil, nil, error)
        }
    }
    
    @objc func getPictures(
        _ source: String,
        resolver resolve: RCTPromiseResolveBlock,
        rejecter reject: RCTPromiseRejectBlock
    ) -> Void {
        do {
            let asset: AVAsset! = try RNVideoEditorUtilities.requestAsset(source)
            
            var numberOfPictures: Double = 8
            let duration: Double = asset.duration.seconds
            if duration > 30 {
                numberOfPictures = 4 * (floor((duration / 30) + 1))
            }
            let second: Double = floor(duration / numberOfPictures)
            
            let imageGenerator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            
            var pictures: Array<String> = []
            for n in 0..<Int(numberOfPictures) {
                let timestamp: CMTime = CMTime(seconds: (Double(n) * second), preferredTimescale: 600)
                let imageRef: CGImage = try imageGenerator.copyCGImage(at: timestamp, actualTime: nil)
                let image: UIImage = UIImage(cgImage: imageRef)
                let imgData: Data? = UIImageJPEGRepresentation(image, 0.5)
                
                let base64String: String? = imgData?.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
                let picture = base64String != nil ? "data:image/png;base64,\(base64String!)" : ""
                pictures.append(picture)
            }
            
            resolve(pictures)
        } catch {
            reject(nil, nil, error)
        }
    }
    
    @objc func merge(
        _ videoFiles: Array<String>,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        do {
            var assets: Array<AVAsset> = Array()
            for source in videoFiles {
                let asset: AVAsset! = try RNVideoEditorUtilities.requestAsset(source)
                assets.append(asset)
            }
            
            let compositionAsset: AVMutableComposition = AVMutableComposition()
            let videoTrack: AVMutableCompositionTrack? = compositionAsset.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            let soundTrack: AVMutableCompositionTrack? = compositionAsset.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            
            var insertTime = kCMTimeZero
            for asset in assets {
                //        let track = asset.tracks(withMediaType: .video)[0]
                //        let width: CGFloat = track.naturalSize.width
                //        let height: CGFloat = track.naturalSize.height
                //        var transforms: CGAffineTransform = track.preferredTransform
                //        if width > height {
                //          transforms = transforms.concatenating(CGAffineTransform(rotationAngle: .pi / 2))
                //          transforms = transforms.concatenating(CGAffineTransform(translationX: height, y: 0))
                //        }
                //        videoTrack?.preferredTransform = transforms
                
                try videoTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: .video)[0], at: insertTime)
                try soundTrack?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, asset.duration), of: asset.tracks(withMediaType: .audio)[0], at: insertTime)
                insertTime = CMTimeAdd(insertTime, asset.duration)
            }
            
            let outputURL: URL = try RNVideoEditorUtilities.createTempFile("mp4")
            
            self.exportSession(
                asset: compositionAsset,
                outputURL: outputURL,
                timeRange: nil,
                resolver: resolve,
                rejecter: reject
            )
        } catch {
            reject(nil, nil, error)
        }
    }
    
    @objc func mergeWithAudio(
        _ source: String,
        audioSource: String,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        do {
            let videoAsset: AVAsset! = try RNVideoEditorUtilities.requestAsset(source)
            let audioAsset: AVAsset! = try RNVideoEditorUtilities.requestAsset(audioSource)
            
            let compositionAsset: AVMutableComposition = AVMutableComposition()
            var videoTracks: [AVMutableCompositionTrack] = []
            var soundTracks: [AVMutableCompositionTrack] = []
            
            if let videoTrack = compositionAsset.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid),
                let audioTrack = compositionAsset.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
                videoTracks.append(videoTrack)
                soundTracks.append(audioTrack)
                
                if let videoAssetTrack: AVAssetTrack = videoAsset.tracks(withMediaType: .video).first,
                    let audioAssetTrack: AVAssetTrack = audioAsset.tracks(withMediaType: .audio).first {
                    do {
                        try videoTracks.first?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, videoAssetTrack.timeRange.duration), of: videoAssetTrack, at: kCMTimeZero)
                        try soundTracks.first?.insertTimeRange(CMTimeRangeMake(kCMTimeZero, audioAssetTrack.timeRange.duration), of: audioAssetTrack, at: kCMTimeZero)
                        videoTrack.preferredTransform = videoAssetTrack.preferredTransform
                        
                    } catch{
                        throw "Export failed."
                    }
                }
            }
            
            let outputURL: URL = try RNVideoEditorUtilities.createTempFile("mp4")
            
            self.exportSession(
                asset: compositionAsset,
                outputURL: outputURL,
                timeRange: nil,
                resolver: resolve,
                rejecter: reject
            )
        } catch {
            reject(nil, nil, error)
        }
    }
    
    @objc func trim(
        _ source: String,
        options: NSDictionary,
        resolver resolve: @escaping RCTPromiseResolveBlock,
        rejecter reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        do {
            let asset: AVAsset! = try RNVideoEditorUtilities.requestAsset(source)
            let duration: Double = asset.duration.seconds
            
            var start: Double = options.object(forKey: "startTime") as? Double ?? 0
            var end: Double = options.object(forKey: "endTime") as? Double ?? 0
            if start < 0 { start = 0 }
            if end > duration { end = duration }
            
            let startTime: CMTime = CMTime(seconds: start, preferredTimescale: asset.duration.timescale)
            let endTime: CMTime = CMTime(seconds: end, preferredTimescale: asset.duration.timescale)
            
            let outputURL: URL = try RNVideoEditorUtilities.createTempFile("mp4")
            
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            VideoEditEmitter.logEvent(params:["name": "step1", "outputURL": source])
            self.exportSession(
                asset: asset,
                outputURL: outputURL,
                timeRange: timeRange,
                resolver: resolve,
                rejecter: reject
            )
            
        } catch {
            reject(nil, nil, error)
        }
    }
    
    func logA (){
        
    }
    @objc func cleanFiles(
        _ callBack: RCTResponseSenderBlock?
    ) -> Void {
        do {
            try RNVideoEditorUtilities.cleanFiles()
            callBack!(nil)
        } catch {
        }
    }
    
    @objc func cancel(
        _ callBack: RCTResponseSenderBlock?
    ) -> Void {
        guard self.exportSession != nil else { return callBack!(nil) }
        self.exportSession!.cancelExport()
        callBack!(nil)
    }
    
}
