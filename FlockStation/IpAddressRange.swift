//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public struct IpAddressRange<Address : IpAddressEditable> : IpAddressRangable  {
  
  let start: Address
  public let count: Int
  
  public init (ipAddress: Address, netmask: Address) {
    let netmaskNot = ~netmask
    self.start = ipAddress & netmask
    self.count = (ipAddress | netmaskNot) - self.start
  }
  
  public subscript(index: Int) -> IpAddressProtocol? {
    return index < count ? start + index + 1 : nil
  }
  
}