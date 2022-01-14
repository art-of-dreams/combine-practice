import UIKit
import Combine

var cancellables = Set<AnyCancellable>()

public func example(of description: String,
                    action: () -> Void) {
    print("\n——— Example of:", description, "———")
    action()
}

example(of: "Printing events") {
    let subscription = (1...3).publisher
        .print("publisher")
        .sink { _ in }

//    Output:
//
//    publisher: receive subscription: (1...3)
//    publisher: request unlimited
//    publisher: receive value: (1)
//    publisher: receive value: (2)
//    publisher: receive value: (3)
//    publisher: receive finished
}

class TimeLogger: TextOutputStream {
    private var previous = Date()
    private let formatter = NumberFormatter()

    init() {
        formatter.maximumFractionDigits = 5
        formatter.minimumFractionDigits = 5
    }

    func write(_ string: String) {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let now = Date()
        print("+\(formatter.string(for: now.timeIntervalSince(previous))!)s: \(string)")
        previous = now
    }
}

example(of: "Custom text output stream") {
    let subscription = (1...3).publisher
        .print("publisher", to: TimeLogger())
        .sink { _ in }
}

example(of: "Acting on events — performing side effects") {
    let request = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)

    request
        .handleEvents(receiveSubscription: { _ in
            print("Network request will start")
        }, receiveOutput: { _ in
            print("Network request data received")
        }, receiveCancel: {
            print("Network request cancelled")
        })
        .sink(receiveCompletion: { completion in
            print("Sink received completion: \(completion)")
        }) { (data, _) in
            print("Sink received data: \(data)")
        }
        .store(in: &cancellables)
}
