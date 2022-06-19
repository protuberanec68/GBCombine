import Combine
import Foundation


func example(of desc: String, action: () -> Void) {
    print("*************************************************\n")
    print("Start example of ", desc)
    action()
    print("Finish example of ", desc, "\n")
    
}


example(of: "Notification Observer") {
    
    let notification = Notification.Name("CustomNotification")
    let center = NotificationCenter.default
    
    center.addObserver(
        forName: notification,
        object: nil,
        queue: nil) { _ in
            print("Receive")
        }
    
    center.post(name: notification, object: nil)
    
}

example(of: "Notification Observer") {
    
    let notification = Notification.Name("CustomNotification")
    let center = NotificationCenter.default
    let publisher = center.publisher(for: notification)
    
    let subscription = publisher
        .sink { _ in
            print("Receive in Subscriblion")
        }
    
    center.post(name: notification, object: nil)
    
}


example(of: "Array") {
    
    let array: [Int] = [1, 3, 4, 6, 8, 9]
    let publisher = array.publisher
    
    let cancelable = publisher
        .map { $0 * 2 }
        .sink { _ in
            print("Receive completion")
        } receiveValue: { value in
            print("Receive value ", value)
        }
    
}


class Receiver {
    var value: String = "" {
        didSet {
            print("Did set to ", value)
        }
    }
    
    init(){}
}


example(of: "Set") {
    let receiver: Receiver = .init()
    let set: Set<String> = ["Tom", "Sarah", "Steve"]
    let publisher = set.publisher
    
    let cancelable = publisher
        .filter { $0 != "Tom"}
        .assign(to: \.value, on: receiver)
    
}



example(of: "Just") {
    
    let publisher = Just(5)
    let cancellable = publisher
        .sink { _ in
            print("Receive completion")
        } receiveValue: { value in
            print("Receive value ", value)
        }
}

var cancellables: Set<AnyCancellable> = []

example(of: "Future") {
    
    let publisher = Future<Int, Never> { promise in
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            promise(.success(3))
        }
    }
    
    publisher
        .sink { _ in
            print("Receive completion")
        } receiveValue: { value in
            print("Receive value ", value)
        }
        .store(in: &cancellables)
    
}

example(of: "PassthroughSubject") {
    
    let publisher = PassthroughSubject<Int, Never>()
    
    let cancellable = publisher
        .sink { _ in
            print("Receive completion")
        } receiveValue: { value in
            print("Receive value ", value)
        }
    
    publisher.send(1)
    publisher.send(2)
    publisher.send(completion: .finished)
    
}


example(of: "CurrentValueSubject") {
    
    let publisher = CurrentValueSubject<Int, Never>(555)
    
    let cancellable = publisher
        .sink { _ in
            print("Receive completion")
        } receiveValue: { value in
            print("Receive value ", value)
        }
    
    publisher.send(1)
    print("Publisher's value," , publisher.value)
    publisher.send(2)
    print("Publisher's value," , publisher.value)
    publisher.send(completion: .finished)
    print("Publisher's value," , publisher.value)
    
}



example(of: "Subsriber") {
    
    class CustomSubscriber: Subscriber {
        
        typealias Input = Int
        typealias Failure = Never
        
        func receive(subscription: Subscription) {
            subscription.request(.max(100))
        }
        
        func receive(_ input: Int) -> Subscribers.Demand {
            print("Subcriber received value: \(input)")
            return .none
        }
        
        func receive(completion: Subscribers.Completion<Never>) {
            print("Subcriber received completion")
        }
        
    }
    
    
    let pub = [1, 2, 3, 4, 5, 6,7 ].publisher
    let subscriber1 = CustomSubscriber()
    let subscriber2 = CustomSubscriber()
    
    pub.subscribe(subscriber1)
    pub.subscribe(subscriber2)
    
}

