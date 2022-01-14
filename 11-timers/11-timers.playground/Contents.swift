import UIKit
import Combine

var cancellables = Set<AnyCancellable>()

public func example(of description: String,
                    action: () -> Void) {
    print("\n——— Example of:", description, "———")
    action()
}

example(of: "Using RunLoop") {
//    let runLoop = RunLoop.main
//
//    runLoop
//        .schedule(
//            after: runLoop.now,
//            interval: .seconds(1),
//            tolerance: .milliseconds(100)
//        ) {
//            print("Timer fired")
//        }
//        .store(in: &cancellables)
}

example(of: "Using the Timer class") {
//    Timer
//        .publish(every: 1.0, on: .main, in: .common)
//        .autoconnect()
//        .scan(0) { counter, _ in counter + 1 }
//        .sink { counter in
//            print("Counter is \(counter)")
//        }
//        .store(in: &cancellables)
}

example(of: "Using DispatchQueue") {
    let queue = DispatchQueue.main

    // 1
    let source = PassthroughSubject<Int, Never>()

    // 2
    var counter = 0

    // 3
    let cancellable = queue.schedule(
        after: queue.now,
        interval: .seconds(1)
    ) {
        source.send(counter)
        counter += 1
    }

    // 4
    source
        .sink {
            print("Timer emitted \($0)")
        }
        .store(in: &cancellables)
}
