//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

public protocol IpAddressBuilderProtocol {
  func build(string: String) -> IpAddressProtocol?
}

