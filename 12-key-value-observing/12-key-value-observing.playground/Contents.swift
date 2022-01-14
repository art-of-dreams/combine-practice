import UIKit
import Combine

var cancellables = Set<AnyCancellable>()

public func example(of description: String,
                    action: () -> Void) {
    print("\n——— Example of:", description, "———")
    action()
}

example(of: "publisher(for:options:)") {
    let queue = OperationQueue()

    queue.publisher(for: \.operationCount)
        .sink {
            print("Outstanding operations in queue: \($0)")
        }
        .store(in: &cancellables)

    queue.addOperation {
        print("test operation")
    }
}

example(of: "Own KVO-compliant properties") {
    // 1
    class TestObject: NSObject {
        // 2
        @objc dynamic
        var integerProperty: Int = 0

        @objc dynamic
        var stringProperty: String = ""

        @objc dynamic
        var arrayProperty: [Float] = []

//        @objc dynamic
//        var structProperty = PureSwift(a: (0, false))
    }

    struct PureSwift {
        let a: (Int, Bool)
    }

    let obj = TestObject()

    // 3
    obj.publisher(for: \.integerProperty, options: [.prior])
        .sink {
            print("integerProperty changes to \($0)")
        }
        .store(in: &cancellables)

    obj.publisher(for: \.stringProperty, options: [.prior])
        .sink {
            print("stringProperty changes to \($0)")
        }
        .store(in: &cancellables)

    obj.publisher(for: \.arrayProperty, options: [.prior])
        .sink {
            print("arrayProperty changes to \($0)")
        }
        .store(in: &cancellables)

    // 4
    obj.integerProperty = 100
    obj.integerProperty = 200
    obj.stringProperty = "Hello"
    obj.arrayProperty = [1.0]
    obj.stringProperty = "World"
    obj.arrayProperty = [1.0, 2.0]
}

example(of: "ObservableObject") {
    class MonitorObject: ObservableObject {
        @Published var someProperty = false
        @Published var someOtherProperty = ""
    }

    let object = MonitorObject()

    object.objectWillChange
        .sink {
            print("object will change")
        }
        .store(in: &cancellables)

    object.someProperty = true
    object.someOtherProperty = "Hello world"
}
