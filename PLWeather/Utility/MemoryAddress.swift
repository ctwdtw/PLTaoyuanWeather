//
//  MemoryAddress.swift
//  moshi
//
//  Created by Paul Lee on 2018/5/6.
//  Copyright © 2018年 Paul Lee. All rights reserved.
//
//https://gist.github.com/nyg/b6a80bf79e72599230c312c69e963e60

import Foundation

struct MemoryAddress<T>: CustomStringConvertible {
  
  let intValue: Int
  
  var description: String {
    let length = 2 + 2 * MemoryLayout<UnsafeRawPointer>.size
    return String(format: "%0\(length)p", intValue)
  }
  
  // for structures
  init(of structPointer: UnsafePointer<T>) {
    intValue = Int(bitPattern: structPointer)
  }
}

extension MemoryAddress where T: AnyObject {
  
  // for classes
  init(of classInstance: T) {
    intValue = unsafeBitCast(classInstance, to: Int.self)
  }
}

/* Testing */

//class MyClass { let foo = 42 }
//var classInstance = MyClass()
//let classInstanceAddress = MemoryAddress(of: classInstance) // and not &classInstance
//print(String(format: "%018p", classInstanceAddress.intValue))
//print(classInstanceAddress)
//
//struct MyStruct { let foo = 1 } // using empty struct gives weird results (see StackOverflow comments)
//var structInstance = MyStruct()
//let structInstanceAddress = MemoryAddress(of: &structInstance)
//print(String(format: "%018p", structInstanceAddress.intValue))
//print(structInstanceAddress)


//only support class at this point
func deinitMessage(from obj: Any) {
  let objClass = type(of: obj)
  let memoryAddress = MemoryAddress(of: obj as AnyObject)
  let address = String(format: "%014p", memoryAddress.intValue)
  
  print("<\(objClass): \(address)> is about to  deinit")
}

//only support class at this point
func allocateMessage(from obj: Any) {
  let objClass = type(of: obj)
  let memoryAddress = MemoryAddress(of: obj as AnyObject)
  let address = String(format: "%014p", memoryAddress.intValue)
  print("<\(objClass): \(address)> is allocated ")
}
