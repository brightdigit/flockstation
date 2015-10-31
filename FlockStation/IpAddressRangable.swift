//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public protocol IpAddressRangable {
  var count: Int { get }
  subscript(index: Int) -> IpAddressProtocol? {
    get
  }
}

extension IpAddressRangable {
  public func sequence () -> IpAddressRangableSequence {
    return IpAddressRangableSequence(range: self)
  }
}