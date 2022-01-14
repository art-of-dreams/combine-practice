import UIKit
import Combine

public func example(of description: String,
                    action: () -> Void) {
    print("\n——— Example of:", description, "———")
    action()
}

example(of: "URLSession extensions") {
    guard let url = URL(string: "https://mysite.com/mydata.json") else {
        return
    }

    // 1
    let subscription = URLSession.shared
    // 2
        .dataTaskPublisher(for: url)
        .sink(receiveCompletion: { completion in
            // 3
            if case .failure(let err) = completion {
                print("Retrieving data failed with error \(err)")
            }
        }, receiveValue: { data, response in
            // 4
            print("Retrieved data of size \(data.count), response = \(response)")
        })
}

example(of: "Codable support") {
    let subscription = URLSession.shared
        .dataTaskPublisher(for: url)
        .map(\.data)
        .decode(type: MyType.self, decoder: JSONDecoder())
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Retrieving data failed with error \(err)")
            }
        }, receiveValue: { object in
            print("Retrieved object \(object)")
        })
}

example(of: "Publishing network data to multiple subscribers") {
    let url = URL(string: "https://www.raywenderlich.com")!
    let publisher = URLSession.shared
    // 1
        .dataTaskPublisher(for: url)
        .map(\.data)
        .multicast { PassthroughSubject<Data, URLError>() }

    // 2
    let subscription1 = publisher
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Sink1 Retrieving data failed with error \(err)")
            }
        }, receiveValue: { object in
            print("Sink1 Retrieved object \(object)")
        })

    // 3
    let subscription2 = publisher
        .sink(receiveCompletion: { completion in
            if case .failure(let err) = completion {
                print("Sink2 Retrieving data failed with error \(err)")
            }
        }, receiveValue: { object in
            print("Sink2 Retrieved object \(object)")
        })

    // 4
    let subscription = publisher.connect()
}
