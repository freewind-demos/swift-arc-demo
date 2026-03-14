// swift-arc-demo.swift

// ============ ARC 简介 ============
class Person {
    var name: String
    init(name: String) {
        self.name = name
        print("\(name) 被创建")
    }
    deinit {
        print("\(name) 被销毁")
    }
}

// 引用计数 +1
var person1: Person? = Person(name: "Tom")
var person2 = person1  // 引用计数 +1
var person3 = person1  // 引用计数 +1

print("赋值完成")

// 引用计数 -1
person1 = nil
print("person1 置 nil")

person2 = nil
print("person2 置 nil")

person3 = nil
print("person3 置 nil")

// ============ 循环引用问题 ============
class Person2 {
    var name: String
    var apartment: Apartment?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) 被销毁")
    }
}

class Apartment {
    var tenant: Person2?

    init() {
        print("公寓创建")
    }

    deinit {
        print("公寓被销毁")
    }
}

// 循环引用
var tom: Person2? = Person2(name: "Tom")
var apartment: Apartment? = Apartment()

tom?.apartment = apartment
apartment?.tenant = tom

// 打破循环引用
tom = nil
apartment = nil  // 不会自动销毁！

print("--- 使用 weak 打破循环引用 ---")

// ============ 弱引用 ============
class Person3 {
    var name: String
    weak var apartment: Apartment2?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) 被销毁")
    }
}

class Apartment2 {
    var tenant: Person3?

    init() {
        print("公寓创建")
    }

    deinit {
        print("公寓被销毁")
    }
}

var tom3: Person3? = Person3(name: "Tom")
var apartment3: Apartment2? = Apartment2()

tom3?.apartment = apartment3
apartment3?.tenant = tom3

tom3 = nil
apartment3 = nil  // 正确销毁

// ============ 无主引用 ============
class Customer {
    let name: String
    var card: CreditCard?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) 被销毁")
    }
}

class CreditCard {
    let number: Int
    unowned let customer: Customer

    init(number: Int, customer: Customer) {
        self.number = number
        self.customer = customer
    }

    deinit {
        print("信用卡 \(number) 被销毁")
    }
}

var customer: Customer? = Customer(name: "John")
customer?.card = CreditCard(number: 1234, customer: customer!)

customer = nil  // 都会被销毁
