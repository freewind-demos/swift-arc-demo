# Swift ARC 内存管理 Demo

## 简介

本示例演示 Swift 的自动引用计数（Automatic Reference Counting, ARC）机制，展示引用计数如何工作，以及如何解决循环引用导致的内存泄漏问题。

## 基本原理

### 什么是 ARC？

ARC 是 Swift 的自动内存管理机制，类似 Objective-C 的引用计数。它通过追踪对象的引用数量来决定何时释放内存：

1. **引用计数**：每个对象有一个计数器，记录有多少个引用指向它
2. **引用增加**：当创建新引用时，计数 +1
3. **引用减少**：当引用被销毁时，计数 -1
4. **自动释放**：当计数变为 0 时，对象被自动销毁

Swift 的 ARC 与手动引用计数相比更加安全，因为编译器会自动插入增减计数的代码，开发者无需手动管理。

### 引用计数的工作流程

```swift
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

var person1: Person? = Person(name: "Tom")  // 引用计数 = 1
var person2 = person1                        // 引用计数 = 2
var person3 = person1                        // 引用计数 = 3

person1 = nil  // 引用计数 = 2
person2 = nil  // 引用计数 = 1
person3 = nil  // 引用计数 = 0，对象被销毁
```

### 循环引用问题

循环引用发生在两个或多个对象相互引用，形成"引用环"：

```swift
class Person {
    var apartment: Apartment?  // Person 持有 Apartment
}

class Apartment {
    var tenant: Person?  // Apartment 持有 Person
}

var tom: Person? = Person()
var apartment: Apartment? = Apartment()

tom?.apartment = apartment  // tom 持有 apartment
apartment?.tenant = tom     // apartment 持有 tom

// 即使设为 nil，对象也不会被释放！
tom = nil
apartment = nil  // 内存泄漏！
```

为什么会这样？
- tom 持有 apartment
- apartment 持有 tom
- 设为 nil 后，双方各有一个引用，计数都是 1
- 谁也不会被释放

## 启动和使用

### 环境要求

- macOS 系统（自带 Swift）
- 或从 https://swift.org/download/ 安装 Swift

### 安装和运行

```bash
cd swift-arc-demo
swift run
```

### 预期输出

```
Tom 被创建
赋值完成
person1 置 nil
person2 置 nil
Tom 被销毁

--- 使用 weak 打破循环引用 ---
Tom 被创建
公寓创建
Tom 被销毁
公寓被销毁
```

## 教程

### 理解引用计数

当你创建一个类的实例时，ARC 会自动分配内存并设置引用计数为 1。每次你将实例赋值给另一个变量或常量时，引用计数会增加。每次你将变量或常量设为 nil 时，引用计数减少。当引用计数变为 0 时，对象的 deinit 方法被调用，然后内存被回收。

### 循环引用的危害

循环引用会导致内存泄漏，即对象应该被释放但没有被释放。这会：

1. **占用内存**：内存无法被回收，导致占用越来越多
2. **性能下降**：内存不足时可能导致系统变慢
3. **应用崩溃**：极端情况下可能导致应用崩溃

### 解决方案：weak 和 unowned

Swift 提供了两种解决循环引用的方式：

#### 弱引用（weak）

使用 `weak` 关键字声明弱引用：

```swift
class Person {
    var apartment: Apartment?
}

class Apartment {
    weak var tenant: Person?  // 弱引用，不增加引用计数
}
```

弱引用的特点：
- 不会增加对象的引用计数
- 可选类型，值为 nil 时不会崩溃
- 当引用的对象被销毁时，自动设为 nil
- 适合可能为 nil 的场景

#### 无主引用（unowned）

使用 `unowned` 关键字声明无主引用：

```swift
class Customer {
    var card: CreditCard?
}

class CreditCard {
    unowned let customer: Customer  // 无主引用
}
```

无主引用的特点：
- 不会增加引用计数
- 非可选类型，假设引用的对象始终存在
- 当对象被销毁后访问会导致崩溃
- 适合对象生命周期确定不会为 nil 的场景

### 如何选择 weak 还是 unowned？

根据引用关系选择：

| 场景 | 解决方案 |
|------|----------|
| 引用可能为 nil | 使用 weak |
| 引用永远不会为 nil | 使用 unowned |
| 不确定时 | 默认使用 weak，更安全 |

### 使用场景示例

**weak 场景：父子关系**

```swift
class Parent {
    var children: [Child] = []
}

class Child {
    weak var parent: Parent?  // 子知道父，但父可能不存在
}
```

**unowned 场景：拥有关系**

```swift
class Person {
    var creditCard: CreditCard?
}

class CreditCard {
    unowned let owner: Person  // 信用卡一定属于某个人
}
```

### 闭包中的循环引用

闭包也是引用类型，可能导致循环引用：

```swift
class Person {
    var name: String
    var greet: () -> Void

    init(name: String) {
        self.name = name
        // 循环引用！
        greet = { [weak self] in
            print("你好，我是 \(self?.name)")
        }
    }
}
```

解决方式：使用 `[weak self]` 或 `[unowned self]`

## 关键代码详解

### main.swift 完整代码

```swift
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
```

### 核心代码解析

1. **ARC 基础**：通过 `var person1 = Person(name: "Tom")` 创建对象
   - 引用计数从 0 变为 1
   - 每次赋值给新变量，计数 +1

2. **deinit 方法**：对象被销毁时自动调用
   - 类似于其他语言的析构函数
   - 用于清理资源

3. **循环引用**：`Person2` 和 `Apartment` 相互引用
   - 即使设为 nil，对象也不会被释放
   - 引用计数无法变为 0

4. **weak 关键字**：`weak var apartment: Apartment2?`
   - 声明弱引用
   - 值为可选类型
   - 对象销毁时自动设为 nil

5. **unowned 关键字**：`unowned let customer: Customer`
   - 声明无主引用
   - 非可选类型
   - 假设对象始终存在

6. **内存释放顺序**：
   - 弱引用一方先被释放
   - 另一方引用计数变为 0，也被释放
