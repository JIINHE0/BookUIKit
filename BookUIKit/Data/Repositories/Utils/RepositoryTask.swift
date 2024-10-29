//
//  RepositoryTask.swift
//  BookUIKit
//
//  Created by jiin heo on 10/29/24.
//

import Foundation

class RepositoryTask: Cancellable {
    var networkTask: NetworkCancellable?
    var isCancelled: Bool = false
    
    func cancel() {
        networkTask?.cancel()
        isCancelled = true
    }
}
