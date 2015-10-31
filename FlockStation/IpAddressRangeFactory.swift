//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public struct IpAddressRangeFactory : IpAddressRangeFactoryProtocol {
  public static var factory:IpAddressRangeFactoryProtocol = IpAddressRangeFactory()
  
  public func range(fromIpAddress ipAddress: IpAddressProtocol, netmask: IpAddressProtocol) -> IpAddressRangable? {
    if ipAddress.family == netmask.family {
      if let ipAddress = ipAddress as? IpAddress<UInt8>, netmask = netmask as? IpAddress<UInt8> {
        return IpAddressRange<IpAddress<UInt8>>(ipAddress: ipAddress, netmask: netmask)
      }
    }
    return nil
  }
  
  public func range(fromIpAddressNetInfo netinfo: IpAddressNetInfoProtocol) -> IpAddressRangable? {
    return self.range(fromIpAddress: netinfo.ipAddress, netmask: netinfo.subnetMask)
  }
}