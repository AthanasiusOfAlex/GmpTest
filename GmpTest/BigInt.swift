//
//  BigInt.swift
//  GmpTest
//
//  Created by Louis Melahn on 5/17/17.
//  Copyright © 2017 Louis Melahn
//
//  Permission is hereby granted, free of charge, to any person obtaining a
//  copy of this software and associated documentation files (the "Software"),
//  to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense,
//  and/or sell copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
//  IN THE SOFTWARE.
//

import Foundation
import GMP


fileprivate final class _BigInt {
    
    /// This is the internal GMP struct that actually holds the number.
    fileprivate var internalStruct = mpz_t()
    
    init() {
        
        __gmpz_init(&internalStruct)
        
    }
    
    deinit {
        
        __gmpz_clear(&internalStruct)
        
    }
    
    func set(_ value: String, usingBase base: Int=10) {
        
        let buffer = value.cString(using: .ascii)!
        __gmpz_set_str(&internalStruct, buffer, Int32(base))
        
    }
    
    func getString(usingBase base: Int=10) -> String {
        
        var buffer = [CChar]()
        
        var internalStructCopy = self.internalStruct
        __gmpz_get_str(&buffer, Int32(base), &internalStructCopy)
        
        return String(cString: buffer)
        
    }
    
    func getIntMax() -> IntMax? {
        
        let max = _BigInt()
        max.set(String(IntMax.max))
        
        // Make sure that "self" is less than or equal to the maximum allowed integer.
        guard _BigInt.compare(self, to: max) <= 0 else { return nil }
        
        let min = _BigInt()
        min.set(String(IntMax.min))
        
        // Make sure that "self" is greater than or equal to the minimum allowed integer.
        guard _BigInt.compare(self, to: min) >= 0 else { return nil }
        
        return IntMax(self.getString())
        
    }
    
    /// Returns 0 if the lhs and rhs are equal,
    /// negative if lhs < rhs, and positive is lhs > rhs
    fileprivate static func compare(_ lhs: _BigInt, to rhs: _BigInt) -> Int32 {
        
        var lhsStruct = lhs.internalStruct
        var rhsStruct = rhs.internalStruct
        
        return __gmpz_cmp(&lhsStruct, &rhsStruct)
        
    }
    
    static func add(_ lhs: _BigInt, _ rhs: _BigInt) -> _BigInt {
        
        let result = _BigInt()
        __gmpz_add(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return result
        
    }
    
    static func subtract(_ lhs: _BigInt, _ rhs: _BigInt) -> _BigInt {
        
        let result = _BigInt()
        __gmpz_sub(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return result
        
    }
    
    static func multiply(_ lhs: _BigInt, _ rhs: _BigInt) -> _BigInt {
        
        let result = _BigInt()
        __gmpz_mul(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return result
        
    }
    
    
    
    static func divide(_ lhs: _BigInt, _ rhs: _BigInt) -> _BigInt? {
        
        let result = _BigInt()
        
        if compare(lhs, to: rhs) == 0 { // N.B.: result == 0
            
            return nil
            
        } else {
            
            __gmpz_tdiv_q(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
            return result
            
        }
        
    }
    
    static func remainder(_ lhs: _BigInt, _ rhs: _BigInt) -> _BigInt? {
        
        let result = _BigInt()
        
        if compare(lhs, to: rhs) == 0 { // N.B.: result == 0
            
            return nil
            
        } else {
            
            __gmpz_tdiv_r(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
            return result
            
        }
        
    }
    
}

struct BigInt {
    
    /// This is the internal object that handles the actual interaction with GMP
    fileprivate var bigIntObject: _BigInt // = BigIntClass()
    
}

// Initializers
extension BigInt{
    
    init() {
        
        bigIntObject = _BigInt()
        
    }
    
    init(_ value: String) {
        
        self.init()
        bigIntObject.set(value)
        
    }
    
    init<T>(_ value: T) where T:SignedInteger {
        
        self.init()
        bigIntObject.set(String(value))
        
    }
    
    init<T>(_ value: T) where T:UnsignedInteger {
        
        self.init()
        bigIntObject.set(String(value))
        
    }
    
    fileprivate init(_ value: _BigInt) {
        
        bigIntObject = value
        
    }
    
}

extension BigInt: Equatable, Comparable {
    
    static func ==(lhs: BigInt, rhs: BigInt) -> Bool {
        
        return _BigInt.compare(lhs.bigIntObject, to: rhs.bigIntObject) == 0
        
    }
    
    static func <(lhs: BigInt, rhs: BigInt) -> Bool {
        
        return _BigInt.compare(lhs.bigIntObject, to: rhs.bigIntObject) < 0
        
    }
    
}

extension BigInt: IntegerArithmetic {
    
    func toIntMax() -> IntMax {
        
        if let max = self.bigIntObject.getIntMax() {
            
            return max
            
        } else {
            
            fatalError("Tried to return an IntMax greater than the maximum allowed or less then the minimum allowed")
            
        }
        
    }
    
    static func addWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = _BigInt.add(lhs.bigIntObject, rhs.bigIntObject)
        return (BigInt(result), false)
        
    }
    
    static func subtractWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = _BigInt.subtract(lhs.bigIntObject, rhs.bigIntObject)
        return (BigInt(result), false)
        
    }
    
    static func multiplyWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = _BigInt.multiply(lhs.bigIntObject, rhs.bigIntObject)
        return (BigInt(result), false)
        
    }
    
    static func divideWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        if let result = _BigInt.divide(lhs.bigIntObject, rhs.bigIntObject) {
            
            return (BigInt(result), false)
            
        } else {
            
            return(BigInt(), true)
            
        }
        
    }
    
    static func remainderWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        if let result = _BigInt.remainder(lhs.bigIntObject, rhs.bigIntObject) {
            
            return (BigInt(result), false)
            
        } else {
            
            return(BigInt(), true)
            
        }
        
    }
    
}

extension BigInt: CustomStringConvertible {
    
    var description: String {
        
        return self.bigIntObject.getString()
        
    }
    
}

extension String {
    
    init(_ value: BigInt, usingBase base: Int=10) {
        
        self = value.bigIntObject.getString(usingBase: base)
        
    }
    
}

//extension BigInt: ExpressibleByIntegerLiteral {
//    
//    typealias IntegerLiteralType = Int
//    
//    convenience init(integerLiteral: IntegerLiteralType) {
//        
//        self.init(integerLiteral)
//        
//    }
//
//}
//
//extension BigInt: Strideable {
//    
//    typealias Stride = IntMax
//    
//    func distance(to other: BigInt) -> Stride {
//        
//        return (other - self).toIntMax()
//        
//    }
//    
//    func advanced(by n: Stride) -> BigInt {
//        
//        return BigInt(n) + self
//        
//    }
//    
//}
//
//extension BigInt: Hashable {
//    
//    var hashValue: Int {
//        
//        let string = String(self)
//        return string.hashValue
//        
//    }
//    
//}
//
//extension BigInt : BitwiseOperations {
//
//    static func &(lhs: BigInt, rhs: BigInt) -> BigInt {
//        
//        let result = BigInt()
//        __gmpz_and(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
//        return result
//        
//    }
//    
//    static func |(lhs: BigInt, rhs: BigInt) -> BigInt {
//        
//        let result = BigInt()
//        __gmpz_ior(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
//        return result
//        
//    }
//    
//    static func ^(lhs: BigInt, rhs: BigInt) -> BigInt {
//        
//        let result = BigInt()
//        __gmpz_xor(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
//        return result
//        
//    }
//    
//    static prefix func ~(x: BigInt) -> BigInt {
//        
//        let result = BigInt()
//        __gmpz_com(&result.internalStruct, &x.internalStruct)
//        return result
//        
//    }
//    
//    static var allZeros: BigInt {
//        
//        return BigInt()
//        
//    }
//
//}
//
//extension BigInt: ExpressibleByStringLiteral {
//    
//    typealias StringLiteralType = String
//    
//    convenience init(stringLiteral value: StringLiteralType) {
//        
//        self.init(value)
//        
//    }
//
//    typealias ExtendedGraphemeClusterLiteralType = Character
//    
//    convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
//        
//        self.init(String(value))
//        
//    }
//    
//    typealias UnicodeScalarLiteralType = UnicodeScalar
//    
//    convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
//        
//        self.init(String(value))
//        
//    }
//
//}

