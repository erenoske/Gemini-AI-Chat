//
//  Extension.swift
//  swift-login-system
//
//  Created by eren on 27.04.2024.
//

import Foundation
import UIKit

extension UIViewController {
    func hideKeyboardWhenTappedAround(ignoreButton button: UIButton? = nil) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        tap.delegate = self
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        guard let button = sender.view as? UIButton else {
            view.endEditing(true)
            return
        }
        
        if button.isKind(of: UIButton.self) {
            return
        }
        
        view.endEditing(true)
    }
}

extension UIViewController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view is UIButton {
            return false
        }
        return true
    }
}



extension Encodable {
    func asDictionary() -> [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return json ?? [:]
        } catch {
            return [:]
        }
    }
}

