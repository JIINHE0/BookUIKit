//
//  DispatchQueueType.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import Foundation

protocol DispatchQueueType {
    func async(execute work: @escaping () -> Void)
}

extension DispatchQueue: DispatchQueueType {
    func async(execute work: @escaping () -> Void) {
        async(group: nil, execute: work)
    }
}
