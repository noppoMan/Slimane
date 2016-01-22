//
//  Logger.swift
//  slimane
//
//  Created by Yuki Takei on 1/17/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Suv

func getTime() -> String {
    return Time().string
}

public struct Logger {
    public static func info(message: String) {
        print("[\(getTime())] [\(getpid())] [INFO] \(message)")
    }
    
    public static func warn(message: String) {
        print("[\(getTime())] [\(getpid())] [WARN] \(message)")
    }
    
    public static func error(message: String) {
        print("[\(getTime())] [\(getpid())] [ERROR] \(message)")
    }
    
    public static func error(error: ErrorType) {
        print("[\(getTime())] [\(getpid())] [ERROR] \(error)")
    }
    
    public static func fatal(message: String) {
        print("[\(getTime())] [\(getpid())] [FATAL] \(message)")
    }
    
    public static func fatal(error: ErrorType) {
        print("[\(getTime())] [\(getpid())] [FATAL] \(error)")
    }
}