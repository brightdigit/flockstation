//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

public enum IpAddressFamily {
  case IpV4,
  IpV6,
  Unknown
  
  public init (sin_family: UInt8) {
    if sin_family == UInt8(AF_INET) {
      self = .IpV4
    } else if sin_family == UInt8(AF_INET6) {
      self = .IpV6
    } else {
      self = .Unknown
    }
  }
  
  public var radix:Int? {
    switch self {
    case .IpV6 :
      return 16
    case .IpV4:
      return 10
    default:
      return nil
    }
  }
  
  public func parse(text: String) -> Any? {
    switch self {
    case .IpV6 :
      if text.characters.count > 0 {
        return UInt16(text, radix: self.radix!)
      } else {
        return UInt16(0)
      }
    case .IpV4:
      return UInt8(text, radix: self.radix!)
    default:
      return nil
    }
  }
  
  public func builder() -> IpAddressBuilderProtocol? {
    
    switch self {
    case.IpV4:
      return IpV4AddressBuilder()
    default:
      return nil
      
    }
  }
  
  public var length : Int? {
    switch self {
    case.IpV4:
      return Int(INET_ADDRSTRLEN)
    case .IpV6:
      return Int(INET6_ADDRSTRLEN)
    default:
      return nil
      
    }
  }
  
  public var separator : String? {
    
    switch self {
    case.IpV4:
      return "."
    case .IpV6:
      return ":"
    default:
      return nil
      
    }
  }
}