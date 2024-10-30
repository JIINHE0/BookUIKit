//
//  UseCase.swift
//  BookUIKit
//
//  Created by jiin heo on 10/27/24.
//

import Foundation

protocol UseCase {
    @discardableResult
    func start() -> Cancellable?
}
