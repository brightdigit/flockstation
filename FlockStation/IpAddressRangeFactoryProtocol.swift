//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public protocol IpAddressRangeFactoryProtocol {
  func range(fromIpAddress ipAddress: IpAddressProtocol, netmask: IpAddressProtocol) -> IpAddressRangable?
}
