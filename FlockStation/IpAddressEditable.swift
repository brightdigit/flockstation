//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

public protocol IpAddressEditable : IpAddressProtocol {
  static prefix func  ~ (address: Self) -> Self
  static func & (left: Self, right: Self) -> Self
  static func | (left: Self, right: Self) -> Self
  static func + (left: Self, right: Int) -> Self
  static func - (left: Self, right: Self) -> Int
}