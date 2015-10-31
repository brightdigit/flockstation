//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public protocol IpAddressNetInfoProtocol {
  var ipAddress:IpAddressProtocol { get }
  var subnetMask:IpAddressProtocol { get }
}
