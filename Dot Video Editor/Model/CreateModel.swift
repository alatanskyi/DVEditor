//
//  CreateModel.swift
//  Dot Video Editor
//
//  Created by RX on 4/21/20.
//  Copyright © 2020 RX. All rights reserved.
//

import UIKit
import AVFoundation

enum ResolutionType: Int {
    case None
    case ThirtySix
    case FourtyEight
    case SeventyTwo
    case HundredEight
    case FourHundred
}

enum FramesType: Int {
    case None
    case TwentyFour
    case TwentyFive
    case Thirty
    case Fifty
    case Sixty
}

class CreateModel {

    let defaultSize = CGSize(width: 1920, height: 1080)
    
    var segments: [VideoSegment] = []
    var editingIndex: Int = 0
    
    var photoDuration: CGFloat = 3.0
    var filters: [(filter: FilterType, startTime: CMTime, endTime: CMTime)] = []
    var rotations: [(angle: CGFloat, startTime: CMTime, endTime: CMTime)] = []
    
    init(segmentCount: Int) {
        for _ in 0..<segmentCount {
            let segment = VideoSegment()
            segments.append(segment)
        }
    }
    
    func setVideoUrl(url: URL) {
        var segment = segments[editingIndex]
        segment.url = url
        segments[editingIndex] = segment
        
        filters = []
        rotations = []
        var lastTime: CMTime = CMTime.zero

        for segment in segments {
            if let asset = segment.asset {
                filters.append((segment.filterType, lastTime, CMTimeAdd(lastTime, asset.duration)))
                if segment.brightness {
                    filters.append((.Brightness, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                if segment.temperature {
                    filters.append((.Temperature, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                rotations.append((segment.rotation, lastTime, CMTimeAdd(lastTime, asset.duration)))
                lastTime = CMTimeAdd(lastTime, asset.duration)
            }
        }
    }
    
    func setFilter(filter: FilterType) {
        var segment = segments[editingIndex]
        segment.filterType = filter
        segments[editingIndex] = segment
        
        filters = []
        rotations = []
        var lastTime: CMTime = CMTime.zero

        for segment in segments {
            if let asset = segment.asset {
                filters.append((segment.filterType, lastTime, CMTimeAdd(lastTime, asset.duration)))
                if segment.brightness {
                    filters.append((.Brightness, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                if segment.temperature {
                    filters.append((.Temperature, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                rotations.append((segment.rotation, lastTime, CMTimeAdd(lastTime, asset.duration)))
                lastTime = CMTimeAdd(lastTime, asset.duration)
            }
        }
    }
    
    func setBrightness(bright: Bool) {
        var segment = segments[editingIndex]
        segment.brightness = bright
        segments[editingIndex] = segment
        
        filters = []
        rotations = []
        var lastTime: CMTime = CMTime.zero

        for segment in segments {
            if let asset = segment.asset {
                filters.append((segment.filterType, lastTime, CMTimeAdd(lastTime, asset.duration)))
                if segment.brightness {
                    filters.append((.Brightness, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                if segment.temperature {
                    filters.append((.Temperature, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                rotations.append((segment.rotation, lastTime, CMTimeAdd(lastTime, asset.duration)))
                lastTime = CMTimeAdd(lastTime, asset.duration)
            }
        }
    }
    
    func setTemperature(temperature: Bool) {
        var segment = segments[editingIndex]
        segment.temperature = temperature
        segments[editingIndex] = segment
        
        filters = []
        rotations = []
        var lastTime: CMTime = CMTime.zero

        for segment in segments {
            if let asset = segment.asset {
                filters.append((segment.filterType, lastTime, CMTimeAdd(lastTime, asset.duration)))
                if segment.brightness {
                    filters.append((.Brightness, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                if segment.temperature {
                    filters.append((.Temperature, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                rotations.append((segment.rotation, lastTime, CMTimeAdd(lastTime, asset.duration)))
                lastTime = CMTimeAdd(lastTime, asset.duration)
            }
        }
    }
    
    func setRotation() {
        var segment = segments[editingIndex]
        var angle = segment.rotation
        angle += .pi/2
        if angle >= 2 * .pi {
            angle -= (2 * .pi)
        }
        segment.rotation = angle
        segments[editingIndex] = segment
        
        filters = []
        rotations = []
        var lastTime: CMTime = CMTime.zero

        for segment in segments {
            if let asset = segment.asset {
                filters.append((segment.filterType, lastTime, CMTimeAdd(lastTime, asset.duration)))
                if segment.brightness {
                    filters.append((.Brightness, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                if segment.temperature {
                    filters.append((.Temperature, lastTime, CMTimeAdd(lastTime, asset.duration)))
                }
                rotations.append((segment.rotation, lastTime, CMTimeAdd(lastTime, asset.duration)))
                lastTime = CMTimeAdd(lastTime, asset.duration)
            }
        }
    }
    
    func playerItem() -> AVPlayerItem {
        let mutableComposition = layerComposition()
        let playerItem = AVPlayerItem(asset: mutableComposition.composition)
        playerItem.videoComposition = filterComposition(asset: mutableComposition.composition, size: mutableComposition.size, transforms: mutableComposition.transforms)
        
        return playerItem
    }
    
    func export(resolutionType: ResolutionType, fpsType: FramesType, completion:@escaping (URL?, Error?) -> Void) {
        let mutableComposition = layerComposition(resolutionType: resolutionType)
        let mixComposition = mutableComposition.composition
        let videoComposition = filterComposition(asset: mixComposition, size: mutableComposition.size, transforms: mutableComposition.transforms)
        
        if let outputURL = mergeVideoFilePath() {
            deleteFile(pathURL: outputURL) {
                let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
                exporter?.outputURL = outputURL
                exporter?.outputFileType = AVFileType.mov
                exporter?.shouldOptimizeForNetworkUse = true
                exporter?.videoComposition = videoComposition
                exporter?.exportAsynchronously(completionHandler: {
                    if exporter?.status == AVAssetExportSession.Status.completed {
                        print("Exported file: \(outputURL.absoluteString)")
                        completion(outputURL, nil)
                    }
                    else if exporter?.status == AVAssetExportSession.Status.failed {
                        print("failed export")
                        completion(nil, exporter?.error)
                    }
                })
            }
        }
    }
    
    fileprivate func mergeVideoFilePath() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("mergeVideo.mov")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    fileprivate func fpsVideoFilePath() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        if directory != "" {
            let path = directory.appendingPathComponent("fpsVideo.mov")
            return URL(fileURLWithPath: path)
        }
        return nil
    }
    
    fileprivate func deleteFile(pathURL: URL, completion: @escaping () throws -> ()) {
        do {
            if FileManager.default.fileExists(atPath: pathURL.path) {
                try FileManager.default.removeItem(at: pathURL)
            }
        } catch {
            print(error.localizedDescription)
        }
        
        do {
            try completion()
        } catch {
            print(error.localizedDescription)
        }
    }
    
}

extension CreateModel {
    fileprivate func filterComposition(asset: AVAsset, size: CGSize, transforms: [(transform: CGAffineTransform, startTime: CMTime, endTime: CMTime)]) -> AVMutableVideoComposition {
        let background = CIImage(color: CIColor.clear)

        let filterComposition = AVMutableVideoComposition(asset: asset) { (request) in
            let inputImage = request.sourceImage
            let compositionTime = request.compositionTime
            
            var outputImage = inputImage
            
            // Set transform
            var transform = CGAffineTransform.identity
            for trans in transforms {
                if CMTimeGetSeconds(compositionTime) >= CMTimeGetSeconds(trans.startTime) && CMTimeGetSeconds(compositionTime) < CMTimeGetSeconds(trans.endTime) {
                    transform = trans.transform
                }
            }
            let transformedImage = inputImage.transformed(by: transform)

            
            // Set rotation
            let transformedImageSize = transformedImage.extent.size
            var rotation = CGAffineTransform(translationX: size.width / 2, y: size.height / 2)
            
            for rotate in self.rotations {
                if CMTimeGetSeconds(compositionTime) >= CMTimeGetSeconds(rotate.startTime) && CMTimeGetSeconds(compositionTime) < CMTimeGetSeconds(rotate.endTime) {
                    rotation = rotation.rotated(by: rotate.angle)
                    
                    var imageSize = transformedImageSize
                    let multiply = Int(rotate.angle * 2 / .pi)
                    if multiply % 2 == 1 {
                        imageSize.width = transformedImageSize.height
                        imageSize.height = transformedImageSize.width
                    }
                    let imageRatio = imageSize.height / imageSize.width

                    var actualSize: CGSize = .zero
                    actualSize.height = size.height
                    actualSize.width = size.height / imageRatio
                    if actualSize.width > size.width {
                        actualSize.width = size.width
                        actualSize.height = size.width * imageRatio
                    }

                    let scale = actualSize.width / imageSize.width
                    rotation = rotation.scaledBy(x: scale, y: scale)
                }
            }
            rotation = rotation.translatedBy(x: -size.width / 2, y: -size.height / 2)
            let rotatedImage = transformedImage.transformed(by: rotation).composited(over: background)
            
            // Apply Video Filter
            var videoFilters: [FilterType] = []
            for filter in self.filters {
                if CMTimeGetSeconds(compositionTime) >= CMTimeGetSeconds(filter.startTime) && CMTimeGetSeconds(compositionTime) < CMTimeGetSeconds(filter.endTime) {
                    videoFilters.append(filter.filter)
                }
            }
            
            var filteredImage = rotatedImage
            for filter in videoFilters {
                filteredImage = filteredImage.applyFilter(type: filter).clampedToExtent()
            }
            
            outputImage = filteredImage
            
            request.finish(with: outputImage, context: nil)
        }
        filterComposition.renderSize = size
        
        return filterComposition
    }
}

extension CreateModel {
    fileprivate func layerComposition(resolutionType: ResolutionType = .None) -> (composition: AVMutableComposition, transforms: [(CGAffineTransform, CMTime, CMTime)], size: CGSize) {
        var videoClips = [AVAsset]()
        for segment in segments {
            if let asset = segment.asset {
                videoClips.append(asset)
            }
        }
        
        var isAudioEnable = false
        
        var arrayLayerTransforms: [(CGAffineTransform, CMTime, CMTime)] = []
        var outputSize = CGSize.zero
        var aspectRatio: CGFloat = 0
        var maxSize: CGFloat = 0
        
        // Determine video output size
        for clip in videoClips {
            let videoTrack = clip.tracks(withMediaType: AVMediaType.video)[0]
            
            let assetInfo = orientationFromTransform(transform: videoTrack.preferredTransform)
            
            var videoSize = videoTrack.naturalSize
            if assetInfo.isPortrait == true {
                videoSize.width = videoTrack.naturalSize.height
                videoSize.height = videoTrack.naturalSize.width
            }
            
            if aspectRatio == 0 {
                aspectRatio = videoSize.height / videoSize.width
            }
            
            if videoSize.width > maxSize {
                maxSize = videoSize.width
            }
            if videoSize.height > maxSize {
                maxSize = videoSize.height
            }
            
            if clip.tracks(withMediaType: AVMediaType.audio).count > 0 {
                isAudioEnable = true
            }
        }
        
        if aspectRatio == 0 || maxSize == 0 {
            outputSize = defaultSize
        }
        
        if aspectRatio > 1 {
            outputSize.height = maxSize
            outputSize.width = maxSize / aspectRatio
        } else {
            outputSize.width = maxSize
            outputSize.height = maxSize * aspectRatio
        }

        
        var targetWidth: Int = Int(outputSize.width)
        var targetHeight: Int = Int(outputSize.width)

        if outputSize.height > outputSize.width {
            switch resolutionType {
            case .ThirtySix:
                targetHeight = 640
                break
            case .FourtyEight:
                targetHeight = 852
                break
            case .SeventyTwo:
                targetHeight = 1280
                break
            case .HundredEight:
                targetHeight = 1920
                break
            case .FourHundred:
                targetHeight = 3840
                break
            default:
                break
            }
            
            targetWidth = Int(CGFloat(targetHeight) * outputSize.width / outputSize.height)
            if targetWidth % 10 > 5 {
                targetWidth = (targetWidth / 10 + 1) * 10
            } else {
                targetWidth = (targetWidth / 10) * 10
            }
        } else {
            switch resolutionType {
            case .ThirtySix:
                targetWidth = 360
                break
            case .FourtyEight:
                targetWidth = 480
                break
            case .SeventyTwo:
                targetWidth = 720
                break
            case .HundredEight:
                targetWidth = 1080
                break
            case .FourHundred:
                targetWidth = 2160
                break
            default:
                break
            }
            
            targetHeight = Int(CGFloat(targetWidth) * outputSize.height / outputSize.width)
            if targetHeight % 10 > 5 {
                targetHeight = (targetHeight / 10 + 1) * 10
            } else {
                targetHeight = (targetHeight / 10) * 10
            }
        }
        outputSize = CGSize(width: CGFloat(targetWidth), height: CGFloat(targetHeight))
        
        
        let composition = AVMutableComposition()
        var lastTime: CMTime = CMTime.zero

        let videoCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        
        var audioCompositionTrack: AVMutableCompositionTrack?
        if isAudioEnable {
            audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        }
        
        for clip in videoClips {
            do {
                if let videoTrack = clip.tracks(withMediaType: AVMediaType.video).first {
                    try videoCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: clip.duration), of: videoTrack, at: lastTime)
                }
                
                if isAudioEnable {
                    if let audioTrack = clip.tracks(withMediaType: AVMediaType.audio).first {
                        try audioCompositionTrack?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: clip.duration), of: audioTrack, at: lastTime)
                    }
                }
                
                // Transform for video asset
                let layerTransform = videoTransformForAsset(asset: clip, standardSize: outputSize)
                arrayLayerTransforms.append((layerTransform, lastTime, CMTimeAdd(lastTime, clip.duration)))
                
                // Increase the insert time
                lastTime = CMTimeAdd(lastTime, clip.duration)
            } catch {
                print("Failed to insert track")
            }
        }
        
        return (composition, arrayLayerTransforms, outputSize)
    }
    
    fileprivate func videoTransformForAsset(asset: AVAsset, standardSize: CGSize) -> CGAffineTransform {
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var assetTrackSize = assetTrack.naturalSize
        if assetInfo.isPortrait && (assetInfo.orientation == .right || assetInfo.orientation == .left) {
            assetTrackSize.width = assetTrack.naturalSize.height
            assetTrackSize.height = assetTrack.naturalSize.width
        }
        
        var scaleToFitRatio: CGFloat = 1
        let videoRatio = assetTrackSize.height / assetTrackSize.width
        var targetSize = CGSize(width: standardSize.width, height: standardSize.width * videoRatio)
        if targetSize.height > standardSize.height {
            targetSize.height = standardSize.height
            targetSize.width = standardSize.height / videoRatio
        }
        scaleToFitRatio = targetSize.width / assetTrackSize.width
        
        
        var concat = assetTrack.preferredTransform
        let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
        
        if assetInfo.isPortrait {
            if assetInfo.orientation == .right {
                concat = concat.concatenating(CGAffineTransform(translationX: -assetTrack.preferredTransform.tx, y: -assetTrack.preferredTransform.ty))
                concat = concat.concatenating(CGAffineTransform(translationX: assetTrack.naturalSize.height / 2, y: -assetTrack.naturalSize.width / 2))
                concat = concat.concatenating(scaleFactor)
                concat = concat.concatenating(CGAffineTransform(rotationAngle: -.pi))
                concat = concat.concatenating(CGAffineTransform(translationX: standardSize.width / 2, y: standardSize.height / 2))
            }
            
            if assetInfo.orientation == .left {
                concat = concat.concatenating(CGAffineTransform(translationX: -assetTrack.preferredTransform.tx, y: -assetTrack.preferredTransform.ty))
                concat = concat.concatenating(CGAffineTransform(translationX: -assetTrack.naturalSize.height / 2, y: assetTrack.naturalSize.width / 2))
                concat = concat.concatenating(scaleFactor)
                concat = concat.concatenating(CGAffineTransform(rotationAngle: .pi))
                concat = concat.concatenating(CGAffineTransform(translationX: standardSize.width / 2, y: standardSize.height / 2))
            }
            
        } else {
            let posX = standardSize.width / 2 - (assetTrack.naturalSize.width * scaleToFitRatio) / 2
            let posY = standardSize.height / 2 - (assetTrack.naturalSize.height * scaleToFitRatio) / 2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            concat = concat.concatenating(scaleFactor)
            concat = concat.concatenating(moveFactor)
        }
        
        return concat
    }
    
    fileprivate func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == 1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .rightMirrored
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .leftMirrored
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
}

extension CreateModel {
    func writeImageAsMovie(image: UIImage, completion:@escaping (URL?, Error?) -> Void) {
        // Create AVAssetWriter to write video
        guard let newImage = image.fixedOrientation() else {
            completion(nil, nil)
            return
        }
        
        let directory = NSTemporaryDirectory() as NSString
        let videoPath = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
        
        let videoSize = newImage.size
        let videoFPS: Int32 = 4
        
        guard let assetWriter = createAssetWriter(path: videoPath, size: videoSize) else {
            print("Error converting images to video: AVAssetWriter not created")
            return
        }

        // If here, AVAssetWriter exists so create AVAssetWriterInputPixelBufferAdaptor
        let writerInput = assetWriter.inputs.filter{ $0.mediaType == AVMediaType.video }.first!
        let sourceBufferAttributes : [String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB),
            kCVPixelBufferWidthKey as String : videoSize.width,
            kCVPixelBufferHeightKey as String : videoSize.height
            ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceBufferAttributes)

        // Start writing session
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: CMTime.zero)
        if (pixelBufferAdaptor.pixelBufferPool == nil) {
            print("Error converting images to video: pixelBufferPool nil after starting session")
            return
        }

        // -- Create queue for <requestMediaDataWhenReadyOnQueue>
        let mediaQueue = DispatchQueue(__label: "mediaInputQueue", attr: nil)

        // -- Set video parameters
        let frameDuration = CMTimeMake(value: 1, timescale: videoFPS)
        var frameCount = 0

        // -- Add images to video
        let numImages = Int(CGFloat(videoFPS) * photoDuration)
        writerInput.requestMediaDataWhenReady(on: mediaQueue, using: { () -> Void in
            // Append unadded images to video but only while input ready
            while (writerInput.isReadyForMoreMediaData && frameCount < numImages) {
                let lastFrameTime = CMTimeMake(value: Int64(frameCount), timescale: videoFPS)
                let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)

                if !self.appendPixelBufferForImageAtURL(image: newImage, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                    print("Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
                    return
                }

                frameCount += 1
            }

            // No more images to add? End video.
            if (frameCount >= numImages) {
                writerInput.markAsFinished()
                assetWriter.finishWriting {
                    completion(URL(fileURLWithPath: videoPath), assetWriter.error)
                }
            }
        })
    }


    func createAssetWriter(path: String, size: CGSize) -> AVAssetWriter? {
        // Convert <path> to NSURL object
        let pathURL = URL(fileURLWithPath: path)

        // Return new asset writer or nil
        do {
            // Create asset writer
            let newWriter = try AVAssetWriter(outputURL: pathURL, fileType: AVFileType.mp4)

            // Define settings for video input
            let videoSettings: [String : Any] = [
                AVVideoCodecKey  : AVVideoCodecType.h264,
                AVVideoWidthKey  : size.width,
                AVVideoHeightKey : size.height,
                ]

            // Add video input to writer
            let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            newWriter.add(assetWriterVideoInput)

            // Return writer
            print("Created asset writer for \(size.width)x\(size.height) video")
            return newWriter
        } catch {
            print("Error creating asset writer: \(error)")
            return nil
        }
    }


    func appendPixelBufferForImageAtURL(image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        
        /// at the beginning of the append the status is false
        var appendSucceeded = false
        
        /**
         *  The proccess of appending new pixels is put inside a autoreleasepool
         */
        autoreleasepool {
            
            // check posibilitty of creating a pixel buffer pool
            if let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: MemoryLayout<CVPixelBuffer?>.size)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferPool,
                    pixelBufferPointer
                )
                
                /// check if the memory of the pixel buffer pointer can be accessed and the creation status is 0
                if let pixelBuffer = pixelBufferPointer.pointee, status == 0 {
                    
                    // if the condition is satisfied append the image pixels to the pixel buffer pool
                    fillPixelBufferFromImage(image: image, pixelBuffer: pixelBuffer)
                    
                    // generate new append status
                    appendSucceeded = pixelBufferAdaptor.append(
                        pixelBuffer,
                        withPresentationTime: presentationTime
                    )
                    
                    /**
                     *  Destroy the pixel buffer contains
                     */
                    pixelBufferPointer.deinitialize(count: 1)
                } else {
                    NSLog("error: Failed to allocate pixel buffer from pool")
                }
                
                /**
                 Destroy the pixel buffer pointer from the memory
                 */
                pixelBufferPointer.deallocate()
            }
        }
        
        return appendSucceeded
    }


    func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBuffer) {
        
        // lock the buffer memoty so no one can access it during manipulation
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        
        // get the pixel data from the address in the memory
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        
        // create a color scheme
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        /// set the context size
        let contextSize = image.size
        
        // generate a context where the image will be drawn
        if let context = CGContext(data: pixelData, width: Int(contextSize.width), height: Int(contextSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue) {
            // draw the image in the context
            if let cgImage = image.cgImage {
                context.draw(cgImage, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            }
            
            // unlock the buffer memory
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        }
    }
}

extension CreateModel {
    fileprivate func changeFrameRate(inputURL: URL, outputURL: URL, fpsType: FramesType, completion: @escaping (Bool) -> Void) {

        let videoAsset = AVAsset(url: inputURL)
        let videoTracks = videoAsset.tracks(withMediaType: AVMediaType.video)
        let videoSize = videoTracks[0].naturalSize
        
        let videoWriterSettings: [String : Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoWidthKey : videoSize.width,
            AVVideoHeightKey : videoSize.height
        ]

        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoWriterSettings)
        videoWriterInput.expectsMediaDataInRealTime = true
        
        let videoWriter = try! AVAssetWriter(outputURL: outputURL, fileType: AVFileType.mov)
        videoWriter.add(videoWriterInput)
        //setup video reader
        let videoReaderSettings:[String : Any] = [
            kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
        ]

        let videoReaderOutput = AVAssetReaderVideoCompositionOutput.init(videoTracks: videoTracks, videoSettings: videoReaderSettings)
        videoReaderOutput.alwaysCopiesSampleData = true
        videoReaderOutput.videoComposition = videoComposition(asset: videoAsset, fpsType: fpsType)
        
        var videoReader: AVAssetReader!

        do{
            videoReader = try AVAssetReader(asset: videoAsset)
        }
        catch {
            print("video reader error: \(error)")
            completion(false)
        }
        videoReader.add(videoReaderOutput)
        //setup audio writer
        let audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: nil)
        audioWriterInput.expectsMediaDataInRealTime = false
        videoWriter.shouldOptimizeForNetworkUse = true
        videoWriter.add(audioWriterInput)
        //setup audio reader
        let audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio)[0]
        let audioReaderOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
        let audioReader = try! AVAssetReader(asset: videoAsset)
        audioReader.add(audioReaderOutput)
        videoWriter.startWriting()

        //start writing from video reader
        videoReader.startReading()
        videoWriter.startSession(atSourceTime: CMTime.zero)
        let processingQueue = DispatchQueue(label: "processingQueue1")
        videoWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
            while videoWriterInput.isReadyForMoreMediaData {
                let sampleBuffer:CMSampleBuffer? = videoReaderOutput.copyNextSampleBuffer();
                if videoReader.status == .reading && sampleBuffer != nil {
                    videoWriterInput.append(sampleBuffer!)
                }
                else {
                    videoWriterInput.markAsFinished()
                    if videoReader.status == .completed {
                        //start writing from audio reader
                        audioReader.startReading()
                        videoWriter.startSession(atSourceTime: CMTime.zero)
                        let processingQueue = DispatchQueue(label: "processingQueue2")
                        audioWriterInput.requestMediaDataWhenReady(on: processingQueue, using: {() -> Void in
                            while audioWriterInput.isReadyForMoreMediaData {
                                let sampleBuffer:CMSampleBuffer? = audioReaderOutput.copyNextSampleBuffer()
                                if audioReader.status == .reading && sampleBuffer != nil {
                                    audioWriterInput.append(sampleBuffer!)
                                }
                                else {
                                    audioWriterInput.markAsFinished()
                                    if audioReader.status == .completed {
                                        videoWriter.finishWriting(completionHandler: {() -> Void in
                                            completion(true)
                                        })
                                    }
                                }
                            }
                        })
                    }
                }
            }
        })
    }
    
    fileprivate func videoComposition(asset: AVAsset, fpsType: FramesType) -> AVMutableVideoComposition {
        let videoComposition = AVMutableVideoComposition()
        
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let videoSize = videoTrack.naturalSize
        
        var timescale: Int32 = 30
        switch fpsType {
        case .TwentyFour:
            timescale = 24
            break
        case .TwentyFive:
            timescale = 25
            break
        case .Thirty:
            timescale = 30
            break
        case .Fifty:
            timescale = 50
            break
        case .Sixty:
            timescale = 60
            break
        default:
            break
        }
        videoComposition.frameDuration = CMTimeMake(value: 1, timescale: timescale)
        videoComposition.renderSize = videoSize
        
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        layerInstruction.setTransform(videoTrack.preferredTransform, at: .zero)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: .zero, duration: asset.duration)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        return videoComposition
    }
}
