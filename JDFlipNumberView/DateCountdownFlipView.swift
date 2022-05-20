//
//
//  Created by Markus Emrich on 20.05.22
//

import Foundation
import SwiftUI

public struct DateCountdownFlipView: UIViewRepresentable {
    var dayDigitCount: Int
    var imageBundleName: String?

    var targetDate: Date
    var animationsEnabled: Bool
    var zDistance: Int?

    public init(dayDigitCount: Int = 3,
                imageBundleName: String? = nil,
                targetDate: Date,
                animationsEnabled: Bool = true,
                zDistance: Int? = nil) {
        self.dayDigitCount = dayDigitCount
        self.imageBundleName = imageBundleName
        self.targetDate = targetDate
        self.animationsEnabled = animationsEnabled
        self.zDistance = zDistance
    }

    private func updateStaticState(_ flipView: JDDateCountdownFlipView) {
        flipView.targetDate = targetDate
        if animationsEnabled != flipView.animationsEnabled {
            flipView.animationsEnabled = animationsEnabled
        }
        if let z = zDistance {
            flipView.zDistance = UInt(z)
        }
    }

    public func makeUIView(context: Context) -> JDDateCountdownFlipView {
        let flipView = JDDateCountdownFlipView(dayDigitCount: dayDigitCount, imageBundleName: imageBundleName)!
        flipView.animationsEnabled = animationsEnabled
        updateStaticState(flipView)
        return flipView
    }

    public func updateUIView(_ uiView: JDDateCountdownFlipView, context: Context) {
        updateStaticState(uiView)
    }
}
