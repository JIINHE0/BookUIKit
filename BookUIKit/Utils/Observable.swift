//
//  Observable.swift
//  BookUIKit
//
//  Created by jiin heo on 10/20/24.
//

import Foundation

// KVO


// 옵저버의 약한 참조를 고려하지 않아 메모리 관리가 필요함

//class Observable<T> {
//    // 3. 호출되면, 2번에서 받은 값을 전달
//    private var listener: ((T) -> Void)?
//    
//    // 2. 값이 set 되면, listener에 해당 값을 전달
//    var value: T {
//        didSet {
//            listener?(value)
//        }
//    }
//    
//    // 1. 초기화함수를 통해서 값을 입력받고, 그 값을 value에 저장
//    init(_ value: T) {
//        self.value = value
//    }
//    
//    // 4. 다른 곳에서 bind라는 메소드를 호출하게 되면 value에 저장했던 값을 전달해주고
//    // 전달받은 closure 표현식을 listener에 할당
//    func bind(closure: @escaping (T) -> Void) {
//        closure(value)
//        listener = closure
//    }
//    
//}

final class Observable<Value> { // 여러 옵저버를 관리
    
    struct Observer<Value> {
        weak var observer: AnyObject?
        let block: (Value) -> Void
    }
    
    private var observers = [Observer<Value>]()
    
    var value: Value {
        didSet { notifyObservers() }
    }
    
    init(_ value: Value) {
        self.value = value
    }
    
    func observe(on observer: AnyObject, observerBlock: @escaping (Value) -> Void) {
        observers.append(Observer(observer: observer, block: observerBlock))
        observerBlock(self.value)
    }
    
    func remove(observer: AnyObject) {
        observers = observers.filter { $0.observer !== observer }
    }
    
    private func notifyObservers() {
        for observer in observers {
            observer.block(self.value)
        }
    }
}

