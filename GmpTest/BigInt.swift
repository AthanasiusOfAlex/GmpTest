//
//  BigInt.swift
//  GmpTest
//
//  Created by Louis Melahn on 5/3/17.
//  Copyright © 2017 Louis Melahn. All rights reserved.
//

import Foundation
import GMP

final class BigInt {
    
    /// This is the internal GMP struct that actually holds the number.
    fileprivate var internalMpStruct: mpz_t
    
    init() {
        
        internalMpStruct = mpz_t()
        __gmpz_init(&internalMpStruct)
        
    }
    
    init(_ string: String, usingBase base: Int) {
        
        let buffer = string.cString(using: .ascii)!
        
        internalMpStruct = mpz_t()
        __gmpz_init_set_str(&internalMpStruct, buffer, Int32(base))
        
    }
    
    init(_ n: Int) {
        
        internalMpStruct = mpz_t()
        __gmpz_init_set_si(&internalMpStruct, n)
        
    }
    
    init(_ n: IntMax) {
        
        let string = String(n)
        let cString = string.cString(using: .ascii)!
        
        internalMpStruct = mpz_t()
        __gmpz_init_set_str(&internalMpStruct, cString, 10)
        
    }
    
    
    init(_ n: UInt) {
        
        internalMpStruct = mpz_t()
        __gmpz_init_set_ui(&internalMpStruct, n)
        
    }
    
    init(_ n: mpz_t) {
        
        internalMpStruct = n
        
    }
    
    convenience init(_ string: String) {
        
        self.init(string, usingBase: 10)
        
    }
    
    deinit {
        
        __gmpz_clear(&internalMpStruct)
        
    }
    
}


extension BigInt: Equatable {
    
    fileprivate static func compare(_ lhs: BigInt, to rhs: BigInt) -> Int32 {
        
        var lhsStruct = lhs.internalMpStruct
        var rhsStruct = rhs.internalMpStruct
        
        return __gmpz_cmp(&lhsStruct, &rhsStruct)
        
    }
    
    public static func ==(lhs: BigInt, rhs: BigInt) -> Bool {
        
        if compare(lhs, to: rhs)==0 {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}

extension BigInt: Comparable {
    
    public static func <(lhs: BigInt, rhs: BigInt) -> Bool {
        
        if compare(lhs, to: rhs) < 0 {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
}

extension BigInt: IntegerArithmetic {
    
    /// Explicitly convert to `IntMax`, trapping on overflow (except in
    /// -Ounchecked builds).
    func toIntMax() -> IntMax {
        
        let max = BigInt(IntMax.max)
        
        if self > max {
            
            return IntMax.max
            
        } else {
            
            let string = String(self, usingBase: 10)
            return IntMax(string)!
            
        }
        
    }
    
    
    static func addWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        __gmpz_add(&result.internalMpStruct, &lhs.internalMpStruct, &rhs.internalMpStruct)
        return (result, overflow: false)
        
    }
    
    static func subtractWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        __gmpz_sub(&result.internalMpStruct, &lhs.internalMpStruct, &rhs.internalMpStruct)
        return (result, overflow: false)
        
    }
    
    static func multiplyWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        __gmpz_mul(&result.internalMpStruct, &lhs.internalMpStruct, &rhs.internalMpStruct)
        return (result, overflow: false)
        
    }
    
    static func divideWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        let zero = BigInt()
        
        if rhs==zero {
            
            return (result, overflow: true)
            
        } else {
            
            __gmpz_tdiv_q(&result.internalMpStruct, &lhs.internalMpStruct, &rhs.internalMpStruct)
            return (result, overflow: false)
            
        }
        
    }
    
    static func remainderWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        let zero = BigInt()
        
        if rhs==zero {
            
            return (result, overflow: true)
            
        } else {
            
            __gmpz_tdiv_r(&result.internalMpStruct, &lhs.internalMpStruct, &rhs.internalMpStruct)
            return (result, overflow: false)
            
        }
        
    }
    
}

extension BigInt: CustomStringConvertible {
    
    public var description: String {
        
        return String(self, usingBase: 10)
        
    }
    
}

extension String {
    
    init(_ bigInt: BigInt, usingBase base: Int) {
        
        var buffer = [CChar]()
        
        var numberToGet = bigInt.internalMpStruct
        __gmpz_get_str(&buffer, Int32(base), &numberToGet)
        
        self = String(cString: buffer)
        
    }
    
    init(_ bigInt: BigInt) {
        
        self = String(bigInt)
        
    }
    
}
