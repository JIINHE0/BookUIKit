//
//  Observable.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import Foundation

// KVO
class Observable<T> {
    // 3. 호출되면, 2번에서 받은 값을 전달
    private var listener: ((T) -> Void)?
    
    // 2. 값이 set 되면, listener에 해당 값을 전달
    var value: T {
        didSet {
            listener?(value)
        }
    }
    
    // 1. 초기화함수를 통해서 값을 입력받고, 그 값을 value에 저장
    init(_ value: T) {
        self.value = value
    }
    
    // 4. 다른 곳에서 bind라는 메소드를 호출하게 되면 value에 저장했던 값을 전달해주고
    // 전달받은 closure 표현식을 listener에 할당
    func bind(closure: @escaping (T) -> Void) {
        closure(value)
        listener = closure
    }
    
}
