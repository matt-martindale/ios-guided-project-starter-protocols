import Foundation

//: # Protocols
//: Protocols are, as per Apple's definition in the _Swift Programming Language_ book:
//:
//: "... a blueprint of methods, properties, and other requirements that suit a particular task or piece of functionality. The protocol can then be adopted by a class, structure, or enumeration to provide an actual implementation of those requirements. Any type that satisfies the requirements of a protocol is said to conform to that protocol."
//:
//: The below example shows a protocol that requires conforming types have a particular property defined.

protocol FullyNamed {
    var fullName: String { get }
}

struct Person: FullyNamed {
    var fullName: String
}

let johnny = Person(fullName: "Johnny Hicks")
let spencer = Person(fullName: "Spencer Curtis")

class Starship: FullyNamed {
    var prefix: String?
    var name: String
    
    init(name: String, prefix: String? = nil) {
        self.name = name
        self.prefix = prefix
    }
    
    //computed property - run a calculation when callling the getter
    var fullName: String {
        return (prefix != nil ? prefix! + " " : " ") + name
    }
}

var ncc1701 = Starship(name: "Enterprise", prefix: "USS")
ncc1701.fullName

var fireFly = Starship(name: "Serenity")
fireFly.fullName

//: Protocols can also require that conforming types implement certain methods.

protocol GeneratesRandomNumbers {
    func random() -> Int
}

class OneThroughTen: GeneratesRandomNumbers {
    ///generates random number on call
    func random() -> Int {
        return Int.random(in: 1...10)
    }
}

class OneThroughOneHundred: GeneratesRandomNumbers {
    ///generates random number on call
    func random() -> Int {
        return Int.random(in: 1...100)
    }
}

let rand = OneThroughTen()
rand.random()

let rand100 = OneThroughOneHundred()
rand100.random()

//: Using built-in Protocols

extension Starship: Equatable {
    static func == (lhs: Starship, rhs: Starship) -> Bool {
        if lhs.fullName == rhs.fullName { return true }
        return false
    }
}

if ncc1701 == fireFly {
    print("the ships are the same")
} else {
    print("the ships are different")
}

//: ## Protocols as Types

class Dice {
    let sides: Int
    let generator: GeneratesRandomNumbers
    
    init(sides: Int, generator: GeneratesRandomNumbers) {
        self.sides = sides
        self.generator = generator
    }
    
    func roll() -> Int {
        return Int(generator.random() % sides) + 1
    }
}

var d6 = Dice(sides: 6, generator: OneThroughOneHundred())
for _ in 1...5 {
    print("Random dice roll is \(d6.roll())")
}
