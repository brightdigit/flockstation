//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation

import ifaddrs


public protocol IpAddressNetInfoProtocol {
  var ipAddress:IpAddressProtocol { get }
  var subnetMask:IpAddressProtocol { get }
}


public struct IpAddressNetInfo : IpAddressNetInfoProtocol {
  public let ipAddress:IpAddressProtocol
  public let subnetMask:IpAddressProtocol
  
  public init?(ifaddrs_ptr : UnsafeMutablePointer<ifaddrs>) {
    let flags = Int32(ifaddrs_ptr.memory.ifa_flags)
    //var sa_addr = ifaddrs_ptr.memory.ifa_addr.memory
    let addr = UnsafeMutablePointer<sockaddr_in>(ifaddrs_ptr.memory.ifa_addr)
    
    // Check for running IPv4, IPv6 interfaces. Skip the loopback interface.
    if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
      
      let netmask = UnsafeMutablePointer<sockaddr_in>(ifaddrs_ptr.memory.ifa_netmask)
      //let addrStrLen:Int32
      //let separator:String
      let family: IpAddressFamily = IpAddressFamily(sin_family: addr.memory.sin_family)
      var ipAddressStringCharArray:[CChar]
      var netmaskStringCharArray:[CChar]
      
      guard let builder = family.builder(), length = family.length else {
        return nil
      }
      
      
      
      ipAddressStringCharArray = [CChar](count:length, repeatedValue: 0)
      inet_ntop(Int32(addr.memory.sin_family), &(addr.memory.sin_addr), &ipAddressStringCharArray, socklen_t(length))
      
      netmaskStringCharArray = [CChar](count:length, repeatedValue: 0)
      inet_ntop(Int32(netmask.memory.sin_family), &(netmask.memory.sin_addr), &netmaskStringCharArray, socklen_t(length))
      
      guard let netmaskString = String.fromCString(&netmaskStringCharArray), let ipAddress = String.fromCString(&ipAddressStringCharArray)  else {
        return nil
      }
      
      //let nmComponents = netmaskString?.componentsSeparatedByString(separator)
      //let ipComponents = ipAddress?.componentsSeparatedByString(separator)
      
      if let ipAddress = builder.build(ipAddress), netmaskAddress = builder.build(netmaskString) {
        self.ipAddress = ipAddress
        self.subnetMask = netmaskAddress
      } else {
        return nil
      }
    } else {
      return nil
    }
  }
}

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

extension String {
  public static func separator(forIpAddressFamily ipAddressFamily: IpAddressFamily) -> String? {
    switch ipAddressFamily {
    case .IpV4:
      return "."
    case .IpV6:
      return ":"
    default:
      return nil
    }
    
  }
}

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

public protocol IpAddressRangeFactoryProtocol {
  func range(fromIpAddress ipAddress: IpAddressProtocol, netmask: IpAddressProtocol) -> IpAddressRangable?
}


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

public struct IpAddressRangableSequence : SequenceType {
  public let range:IpAddressRangable
  public init (range: IpAddressRangable) {
    self.range = range
  }
  
  public func generate() -> AnyGenerator<IpAddressProtocol> {
    var index = 0
    return anyGenerator{
      return self.range[index++]
    }
  }
}

public struct IpV4AddressBuilder : IpAddressBuilderProtocol {
  public init () {
    
  }
  
  public func build(string: String) -> IpAddressProtocol? {
    let components = string.componentsSeparatedByString(".").map{UInt8($0) ?? UInt8(0)}
    return IpAddress<UInt8>(family: .IpV4, components: components)
  }
}

public struct IpAddress<T : AdvanceableByInt> {
  public let family:IpAddressFamily
  let components:[T]
  
  public init (family: IpAddressFamily, components: [T]) {
    self.family = family
    self.components = components
  }
  
  public var description: String {
    if let separator = family.separator {
      let strs = self.components.map{$0.description}
      return strs.joinWithSeparator(separator)
    } else {
      return "unknown"
    }
  }
  
}

public protocol IpAddressProtocol : CustomStringConvertible {
  var family : IpAddressFamily { get }
}

public protocol IpAddressEditable : IpAddressProtocol {
  static prefix func  ~ (address: Self) -> Self
  static func & (left: Self, right: Self) -> Self
  static func | (left: Self, right: Self) -> Self
  static func + (left: Self, right: Int) -> Self
  static func - (left: Self, right: Self) -> Int
}

public protocol AdvanceableByInt : UnsignedIntegerType {
  func advancedBy(n: Int) -> (Self, remainder: Int)
  static func asInt (array: [Self]) -> Int
}

extension UInt8 : AdvanceableByInt {
  public func advancedBy(n: Int) -> (UInt8, remainder: Int) {
    let intValue = Int(self)
    let intResult = intValue + n
    return (UInt8(intResult), remainder: intResult - Int(UINT8_MAX))
  }
  
  public static func asInt(array: [UInt8]) -> Int {
    var result = 0
    for (var index:UInt8 = 0; Int(index) < array.count; index++) {
      result = result + Int(array[Int(index)] << (UInt8(array.count)-index))
    }
    return result
  }
}

public prefix func ~<T:AdvanceableByInt>(address: IpAddress<T>) -> IpAddress<T> {
  return IpAddress<T>(family: address.family, components: address.components.map{ ~$0 })
}

public func &<T:AdvanceableByInt>(left: IpAddress<T>, right: IpAddress<T>) -> IpAddress<T> {
  return IpAddress<T>(family: left.family, components: zip(left.components, right.components).map{ $0.0 & $0.1})
}

public func |<T:AdvanceableByInt>(left: IpAddress<T>, right: IpAddress<T>) -> IpAddress<T> {
  return IpAddress<T>(family: left.family, components: zip(left.components, right.components).map{ $0.0 | $0.1})
  
}

public func +<T:UnsignedIntegerType>(left: IpAddress<T>, right: Int) -> IpAddress<T>  {
  var components = left.components
  var remainder:Int = right
  var result:T
  var index = 0
  repeat {
    (result, remainder) = components[components.count - index - 1].advancedBy(remainder)
    components[components.count - index - 1] = result
    index++
  } while (remainder > 0 && index <= components.count - 1)
  return IpAddress<T>(family: left.family, components: components)
}

public func - <T:AdvanceableByInt>(left: IpAddress<T>, right: IpAddress<T>) -> Int {
  let result = zip(left.components, right.components).map { (tuple) -> T in
    tuple.0 - tuple.1
  }
  return T.asInt(result)
}

extension IpAddress : IpAddressEditable, IpAddressProtocol, CustomStringConvertible  {
  
}

public protocol IpAddressBuilderProtocol {
  func build(string: String) -> IpAddressProtocol?
}

