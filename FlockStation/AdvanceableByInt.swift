//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public protocol AdvanceableByInt : UnsignedIntegerType {
  func advancedBy(n: Int) -> (Self, remainder: Int)
  static func asInt (array: [Self]) -> Int
}

extension UInt8 : AdvanceableByInt {
  public func advancedBy(n: Int) -> (UInt8, remainder: Int) {
    let intValue = Int(self)
    let intResult = intValue + n
    return (UInt8(intResult), remainder: intResult - Int(UINT8_MAX))
  }
  
  public static func asInt(array: [UInt8]) -> Int {
    var result = 0
    for (var index:UInt8 = 0; Int(index) < array.count; index++) {
      result = result + Int(array[Int(index)] << (UInt8(array.count)-index))
    }
    return result
  }
}