# Swift ARC 内存管理 Demo

## 简介

展示 Swift 的自动引用计数（ARC）机制和循环引用解决方案。

## 启动和使用

```bash
cd swift-arc-demo
swift run
```

## 教程

### ARC 原理

- 引用计数自动管理内存
- 引用为 0 时自动释放

### 循环引用

两个对象相互引用导致无法释放

### 解决方案

- `weak`: 弱引用，可为 nil
- `unowned`: 无主引用，不为 nil
