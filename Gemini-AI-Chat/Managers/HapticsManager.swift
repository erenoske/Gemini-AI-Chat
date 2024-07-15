//
//  HapticsManager.swift
//  swift-login-system
//
//  Created by eren on 13.07.2024.
//

import UIKit

class HapticsManager {
    static let shared = HapticsManager()
    
    init() {}
    
    public func vibrate() {
        DispatchQueue.main.async {
            let selectionFeedbackGenerator = UISelectionFeedbackGenerator()
            selectionFeedbackGenerator.prepare()
            selectionFeedbackGenerator.selectionChanged()
        }
    }
}
