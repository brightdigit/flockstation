//
//  IpAddress.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation
import ifaddrs

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
