//
//  Alertable.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import UIKit

protocol Alertable {}

extension Alertable where Self: UIViewController {
    
    func showAlert(
        title: String = "",
        message: String,
        perferredStyle: UIAlertController.Style = .alert,
        completion: (() -> Void)? = nil
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: completion)
    }
}
