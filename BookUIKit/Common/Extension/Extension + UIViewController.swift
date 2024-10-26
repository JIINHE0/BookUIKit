//
//  Extension + UIViewController.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import UIKit

extension UIViewController {
    static func instantiate() -> Self {
        let className = String(describing: self)
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}

//extension UIViewController {
//    static func instantiate() -> Self {
//        let className = String(describing: self)
//        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
//        return storyboard.instantiateViewController(withIdentifier: className) as! Self
//    }
//}
