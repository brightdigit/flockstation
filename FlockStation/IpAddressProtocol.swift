//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public protocol IpAddressProtocol : CustomStringConvertible {
  var family : IpAddressFamily { get }
  func equals (other: IpAddressProtocol) -> Bool
}

public func != (left: IpAddressProtocol, right: IpAddressProtocol) -> Bool {
  if left.family == right.family {
    return left.equals(right)
  } else {
    return false
  }
}