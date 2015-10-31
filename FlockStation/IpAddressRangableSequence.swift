//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public struct IpAddressRangableSequence : SequenceType {
  public let range:IpAddressRangable
  public init (range: IpAddressRangable) {
    self.range = range
  }
  
  public func generate() -> AnyGenerator<IpAddressProtocol> {
    var index = 0
    return anyGenerator{
      return self.range[index++]
    }
  }
}