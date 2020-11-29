//
//  FilterUtility.swift
//  Dot Video Editor
//
//  Created by RX on 5/11/20.
//  Copyright © 2020 RX. All rights reserved.
//

import UIKit

extension CIImage {
    func applyFilter(type: FilterType) -> CIImage {
        switch type {
        case .None:
            return self
        case .MotionBlur:
            let filter = CIFilter(name: "CIMotionBlur")
            filter!.setValue(self, forKey: kCIInputImageKey)
            return filter!.outputImage ?? self
        case .PhotoEffectNoir:
            let filter = CIFilter(name: "CIPhotoEffectNoir")
            filter!.setValue(self, forKey: kCIInputImageKey)
            return filter!.outputImage ?? self
        case .Brightness:
            let filter = CIFilter(name: "CIColorControls")
            filter!.setValue(0.4, forKey: kCIInputBrightnessKey)
            filter!.setValue(self, forKey: kCIInputImageKey)
            return filter!.outputImage ?? self
        case .Temperature:
            let filter = CIFilter(name: "CITemperatureAndTint")
            filter!.setValue(CIVector(x: 6500, y: 500), forKey: "inputNeutral")// Default value: [6500, 0] Identity: [6500, 0]
            filter!.setValue(CIVector(x: 1000, y: 630), forKey: "inputTargetNeutral")// Default value: [6500, 0] Identity: [6500, 0]
            filter!.setValue(self, forKey: kCIInputImageKey)
            return filter!.outputImage ?? self
        case .AnalogFilm:
            let sepiaFilter = CIFilter(name:"CISepiaTone")
            sepiaFilter!.setValue(1.0, forKey: kCIInputIntensityKey)
            sepiaFilter!.setValue(self, forKey: kCIInputImageKey)
            let sepiaCIImage: CIImage = sepiaFilter!.outputImage ?? self
            
            let coloredNoise = CIFilter(name:"CIRandomGenerator")
            let noiseImage: CIImage = coloredNoise!.outputImage ?? self
            
            let whitenVector = CIVector(x: 0, y: 1, z: 0, w: 0)
            let fineGrain = CIVector(x:0, y:0.005, z:0, w:0)
            let zeroVector = CIVector(x: 0, y: 0, z: 0, w: 0)
            
            let whiteningFilter = CIFilter(name:"CIColorMatrix")
            whiteningFilter!.setValue(whitenVector, forKey: "inputRVector")
            whiteningFilter!.setValue(whitenVector, forKey: "inputGVector")
            whiteningFilter!.setValue(whitenVector, forKey: "inputBVector")
            whiteningFilter!.setValue(fineGrain, forKey: "inputAVector")
            whiteningFilter!.setValue(zeroVector, forKey: "inputBiasVector")
            whiteningFilter!.setValue(noiseImage, forKey: kCIInputImageKey)
            let whiteSpecks: CIImage = whiteningFilter!.outputImage ?? self
            
            let speckCompositor = CIFilter(name:"CISourceOverCompositing")
            speckCompositor!.setValue(whiteSpecks, forKey: kCIInputImageKey)
            speckCompositor!.setValue(sepiaCIImage, forKey: kCIInputBackgroundImageKey)
            let speckledImage: CIImage = speckCompositor!.outputImage ?? self
            
            let verticalScale = CGAffineTransform(scaleX: 1.5, y: 25)
            let transformedNoise = noiseImage.transformed(by: verticalScale)
            let darkenVector = CIVector(x: 4, y: 0, z: 0, w: 0)
            let darkenBias = CIVector(x: 0, y: 1, z: 1, w: 1)
            
            let darkeningFilter = CIFilter(name:"CIColorMatrix")
            darkeningFilter!.setValue(darkenVector, forKey: "inputRVector")
            darkeningFilter!.setValue(zeroVector, forKey: "inputGVector")
            darkeningFilter!.setValue(zeroVector, forKey: "inputBVector")
            darkeningFilter!.setValue(zeroVector, forKey: "inputAVector")
            darkeningFilter!.setValue(darkenBias, forKey: "inputBiasVector")
            darkeningFilter!.setValue(transformedNoise, forKey: kCIInputImageKey)
            let randomScratches = darkeningFilter!.outputImage ?? self
            
            let grayscaleFilter = CIFilter(name:"CIMinimumComponent")
            grayscaleFilter!.setValue(randomScratches, forKey: kCIInputImageKey)
            let darkScratches: CIImage = grayscaleFilter!.outputImage ?? self
            
            let oldFilmCompositor = CIFilter(name:"CIMultiplyCompositing")
            oldFilmCompositor!.setValue(darkScratches, forKey: kCIInputImageKey)
            oldFilmCompositor!.setValue(speckledImage, forKey: kCIInputBackgroundImageKey)
            let oldFilmImage: CIImage = oldFilmCompositor!.outputImage ?? self
            
            let finalImage = oldFilmImage.cropped(to: self.extent)
            
            return finalImage
        case .Focusing:
            let inputRadius = self.extent.height > self.extent.width ? 0.4 * self.extent.width : 0.4 * self.extent.height
            let radialMask = CIFilter(name:"CIRadialGradient")
            let imageCenter = CIVector(x: 0.5 * self.extent.width, y: 0.5 * self.extent.height)
            radialMask!.setValue(imageCenter, forKey:kCIInputCenterKey)
            radialMask!.setValue(inputRadius, forKey:"inputRadius0")
            radialMask!.setValue(inputRadius * 1.2, forKey:"inputRadius1")
            radialMask!.setValue(CIColor(red:0, green:1, blue:0, alpha:0),
                                forKey:"inputColor0")
            radialMask!.setValue(CIColor(red:0, green:1, blue:0, alpha:1),
                                forKey:"inputColor1")
            let maskImage: CIImage = radialMask!.outputImage ?? self
            
            let maskedVariableBlur = CIFilter(name:"CIMaskedVariableBlur")
            maskedVariableBlur!.setValue(self, forKey: kCIInputImageKey)
            maskedVariableBlur!.setValue(10, forKey: kCIInputRadiusKey)
            maskedVariableBlur!.setValue(maskImage, forKey: "inputMask")
            let selectivelyFocusedCIImage: CIImage = maskedVariableBlur!.outputImage ?? self
            
            let finalImage = selectivelyFocusedCIImage.cropped(to: self.extent)

            return finalImage
        case .Vignette:
            let inputRadius = self.extent.height > self.extent.width ? 0.5 * self.extent.width : 0.5 * self.extent.height
            let vignetteFilter = CIFilter(name: "CIVignetteEffect")
            vignetteFilter!.setValue(self, forKey: kCIInputImageKey)
            let center = CIVector(x: self.extent.width / 2, y: self.extent.height / 2)
            vignetteFilter!.setValue(center, forKey: kCIInputCenterKey)
            vignetteFilter!.setValue(inputRadius, forKey: kCIInputRadiusKey)
            let finalImage: CIImage = vignetteFilter!.outputImage ?? self

            return finalImage
        }
    }
}
