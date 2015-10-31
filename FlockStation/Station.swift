//
//  Station.swift
//  flockstation
//
//  Created by Leo Dion on 10/31/15.
//
//

import Foundation
import ifaddrs

public class Station : NSObject {
  public static var localIpAddresses : [IpAddressNetInfoProtocol] = {
    
    var addresses = [IpAddressNetInfoProtocol]()
    // Get list of all interfaces on the local machine:
    var ifaddr:UnsafeMutablePointer<ifaddrs> = nil
    
    if getifaddrs(&ifaddr) == 0 {
      // For each interface ...
      for (var ptr = ifaddr; ptr != nil; ptr = ptr.memory.ifa_next) {
        /*
        if let range = IpAddressRangeBuilder.builder.build(ptr) {
          for address in range.sequence() {
            print(address)
          }
        }
        
        */
        if let address = IpAddressNetInfo(ifaddrs_ptr: ptr) {
          addresses.append(address)
        }
      }
      freeifaddrs(ifaddr)
    }
    return addresses
  }()
}