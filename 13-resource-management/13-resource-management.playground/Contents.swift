import UIKit
import Combine

var cancellables = Set<AnyCancellable>()

public func example(of description: String,
                    action: () -> Void) {
    print("\n——— Example of:", description, "———")
    action()
}

example(of: "The share() operator") {
    let shared = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("shared")
        .share()

    print("subscribing first")

//    shared
//        .sink(
//            receiveCompletion: { _ in },
//            receiveValue: { print("subscription1 received: '\($0)'") }
//        )
//        .store(in: &cancellables)

//    print("subscribing second")
//
//    shared
//        .sink(
//            receiveCompletion: { _ in },
//            receiveValue: { print("subscription2 received: '\($0)'") }
//        )
//        .store(in: &cancellables)

//    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//        print("subscribing second")
//
//        shared
//            .sink(
//                receiveCompletion: { print("subscription2 completion \($0)") },
//                receiveValue: { print("subscription2 received: '\($0)'") }
//            )
//            .store(in: &cancellables)
//    }
}

example(of: "The multicast(_:) operator") {
    // 1
    let subject = PassthroughSubject<Data, URLError>()

    // 2
    let multicasted = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .print("multicast")
        .multicast(subject: subject)

    // 3
    multicasted
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { print("subscription1 received: '\($0)'") }
        )
        .store(in: &cancellables)

    multicasted
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { print("subscription2 received: '\($0)'") }
        )
        .store(in: &cancellables)

    // 4
//    DispatchQueue.main.async {
//        multicasted
//            .connect()
//            .store(in: &cancellables)
//    }
}

example(of: "The makeConnectable() operator") {
    let connectable = URLSession.shared
        .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
        .map(\.data)
        .replaceError(with: Data())
        .print("makeConnectable")
        .makeConnectable()

    // 3
    connectable
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { print("subscription1 received: '\($0)'") }
        )
        .store(in: &cancellables)

    connectable
        .sink(
            receiveCompletion: { _ in },
            receiveValue: { print("subscription2 received: '\($0)'") }
        )
        .store(in: &cancellables)

    // 4
//    DispatchQueue.main.async {
//        connectable
//            .connect()
//            .store(in: &cancellables)
//    }
}

example(of: "Future") {
    // 1
    func performSomeWork() throws -> Int {
        print("Performing some work and returning a result")
        return 5
    }

    // 2
    let future = Future<Int, Error> { fulfill in
        do {
            let result = try performSomeWork()
            // 3
            fulfill(.success(result))
        } catch {
            // 4
            fulfill(.failure(error))
        }
    }

    print("Subscribing to future...")

    // 5
    future
        .sink(
            receiveCompletion: { _ in print("subscription1 completed") },
            receiveValue: { print("subscription1 received: '\($0)'") }
        )
        .store(in: &cancellables)

    // 6
    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
        future
            .sink(
                receiveCompletion: { _ in print("subscription2 completed") },
                receiveValue: { print("subscription2 received: '\($0)'") }
            )
            .store(in: &cancellables)
    }
}
