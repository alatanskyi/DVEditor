//
//  VideoSegment.swift
//  Dot Video Editor
//
//  Created by RX on 4/21/20.
//  Copyright © 2020 RX. All rights reserved.
//

import UIKit
import AVFoundation

enum FilterType {
    case None
    case MotionBlur
    case PhotoEffectNoir
    case Brightness
    case Temperature
    case AnalogFilm
    case Focusing
    case Vignette
}

struct VideoSegment {
    var asset: AVAsset?
    
    var url: URL? {
        didSet {
            if let assetUrl = url {
                asset = AVAsset(url: assetUrl)
            }
        }
    }
    
    var filterType: FilterType = .None
    var brightness: Bool = false
    var temperature: Bool = false
    var rotation: CGFloat = 0
}
