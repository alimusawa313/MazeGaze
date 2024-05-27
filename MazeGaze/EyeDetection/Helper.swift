//
//  Helper.swift
//  MazeGaze
//
//  Created by Ali Haidar on 26/05/24.
//

import Foundation
import SwiftUI
import UIKit

struct Device {
    static var screenSize: CGSize {
        
//        let screenWidthPixel: CGFloat = UIScreen.main.nativeBounds.width
//        let screenHeightPixel: CGFloat = UIScreen.main.nativeBounds.height
//
//        let ppi: CGFloat = UIScreen.main.scale * 163 // Assuming a standard PPI value of 163
//
//        let a_ratio=(1125/458)/0.0623908297
//        let b_ratio=(2436/458)/0.135096943231532
//
////        return CGSize(width: (screenWidthPixel/ppi)/a_ratio, height: (screenHeightPixel/ppi)/b_ratio)
        
        let screenSize = CGSize(width: 0.0623908297, height: 0.135096943231532)
        return screenSize
    }
    
    static var frameSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 82)
        
        
    }
}

struct Ranges {
    static let widthRange: ClosedRange<CGFloat> = (0...Device.frameSize.width)
    static let heightRange: ClosedRange<CGFloat> = (0...Device.frameSize.height)
}

extension CGFloat {
    func clamped(to: ClosedRange<CGFloat>) -> CGFloat {
        return to.lowerBound > self ? to.lowerBound
            : to.upperBound < self ? to.upperBound
            : self
    }
}
