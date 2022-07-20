import Cocoa
import Combine

enum MyError: Error {
    case testError
}

//MARK: Publisher
class MyPublisher<T: Comparable>: Publisher {
    typealias Output = T
    typealias Failure = Never
    
    private let output: Output

    init(_ value: Output) {
        self.output = value
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, T == S.Input {
        subscriber.receive(output)
        subscriber.receive(completion: .finished)
    }
}

//MARK: Subscriber
class MySubscriber: Subscriber {
    typealias Input = Double
    typealias Failure = Never
    
    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }
    
    func receive(_ input: Double) -> Subscribers.Demand {
        print("Subscriber: Value: \(input + 1.0)")
        return .none
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("Subscriber: Completion")
    }
}

let publisher = MyPublisher<Double>(1.5)
let subscriber = MySubscriber()
publisher.subscribe(subscriber)

print("\n_____________\n")

//MARK: *Subject
class MySubject: Subject {
    typealias Output = String
    typealias Failure = MyError
    
    private var subject = CurrentValueSubject<Output, Failure>("empty")
    
    init() {}
    
    init(_ value: String) {
        self.subject = CurrentValueSubject(value)
    }
    
    func receive<S>(subscriber: S) where S : Subscriber, MyError == S.Failure, String == S.Input {
        subject.subscribe(subscriber)
    }
    
    func send(_ value: Output) {
        subject.send(value)
    }
    
    func send(completion: Subscribers.Completion<Failure>) {
        switch completion {
        case .finished:
            subject.send(completion: .finished)
        case .failure(.testError):
            subject.send(completion: .failure(.testError))
        }
    }
    
    func send(subscription: Subscription) {
        subscription.request(.unlimited)
    }
}

let subject = MySubject("Привет")
subject.sink { _ in
    print("Мы закончили")
} receiveValue: { value in
    print("Я скажу тебе \(value)")
}

subject.send("макарена")
subject.send("ничего")
subject.send(completion: .finished)
