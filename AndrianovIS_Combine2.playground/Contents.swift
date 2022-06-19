import Cocoa
import Combine
import Foundation

var cancallebles: Set<AnyCancellable> = []

//MARK: example1
let pub1 = Array(1...100).publisher
pub1.dropFirst(50)
    .prefix(20)
    .filter { $0 % 2 == 0 }
    .sink {
        print ($0)
    } receiveValue: { value in
        print(value)
    }
    .store(in: &cancallebles)

print("___________")

//MARK: example2
let pub2 = ["5", "59", "38", "a", "4"].publisher
var divider = 1.0
pub2.map { Int($0) }
    .filter { $0 != nil }
    .reduce(0) { x, y in
        divider += 1
        return x + y!
    }
    .sink {
        print ($0)
    } receiveValue: { value in
        print(Double(value)/divider)
    }
    .store(in: &cancallebles)
