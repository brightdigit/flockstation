//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public struct IpV4AddressBuilder : IpAddressBuilderProtocol {
  public init () {
    
  }
  
  public func build(string: String) -> IpAddressProtocol? {
    let components = string.componentsSeparatedByString(".").map{UInt8($0) ?? UInt8(0)}
    return IpAddress<UInt8>(family: .IpV4, components: components)
  }
}
