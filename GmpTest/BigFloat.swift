//
//  BigFloat.swift
//  GmpTest
//
//  Created by Louis Melahn on 5/18/17.
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

fileprivate final class _BigFloat {
    
    /// This is the internal GMP struct that actually holds the number.
    fileprivate var internalStruct = mpf_t()
    
    init() {
        
        __gmpf_init(&internalStruct)
        
    }
    
    deinit {
        
        __gmpf_clear(&internalStruct)
        
    }
    
    func set(_ value: String, usingBase base: Int=10) {
        
        let buffer = value.cString(using: .ascii)!
        __gmpf_set_str(&internalStruct, buffer, Int32(base))

    }
    
    func getString(usingBase base: Int=10, returningUpToThisManyDigits n: Int=15) -> String {
        
        var position = 0
        var internalStructCopy = self.internalStruct
        let significandBuffer = __gmpf_get_str(nil, &position, Int32(base), n, &internalStructCopy)!
        let significand = String(cString: significandBuffer)
        
        return formatFloat(significand: significand, position: position, separator: ".")
        
    }
    
    private func formatFloat(significand: String, position: Int, separator: String = ".") -> String {
        
        var result: String = ""
        
        if position<=0 {
            
            if significand == "" {
                
                result = "0"
            
            } else {
            
                let frameshift = -position
                result = "0" + separator + String(repeating: "0", count: frameshift) + significand
            
            }
            
        } else { // exp > 0
        
            let count = significand.characters.count
            let prefixCount = position

            if prefixCount < count {
                
                let suffixCount = count - prefixCount
                let prefix = String(significand.characters.prefix(prefixCount))
                let suffix = String(significand.characters.suffix(suffixCount))
                result = prefix + separator + suffix
                
            } else if prefixCount==count {
                
                return significand
                
            } else { // prefixCount > count
            
                let zeros = prefixCount - count
                result = significand + String(repeating: "0", count: zeros)
                
            }
        }
        
        return result
        
    }
    
    func getDouble() -> Double? {
        
        let max = _BigFloat()
        max.set(String(Double.greatestFiniteMagnitude))
        
        // Make sure that "self" is less than or equal to the maximum allowed integer.
        guard _BigFloat.compare(self, to: max) <= 0 else { return nil }
        
        let min = _BigFloat()
        min.set(String(-1 * Double.greatestFiniteMagnitude))
        
        // Make sure that "self" is greater than or equal to the minimum allowed integer.
        guard _BigFloat.compare(self, to: min) >= 0 else { return nil }
        
        return Double(self.getString())
        
    }
    
    
    /// Returns 0 if the lhs and rhs are equal,
    /// negative if lhs < rhs, and positive is lhs > rhs
    fileprivate static func compare(_ lhs: _BigFloat, to rhs: _BigFloat) -> Int32 {
        
        var lhsStruct = lhs.internalStruct
        var rhsStruct = rhs.internalStruct
        
        return __gmpf_cmp(&lhsStruct, &rhsStruct)
        
    }
    
    static func add(_ lhs: _BigFloat, _ rhs: _BigFloat) -> _BigFloat {
        
        let result = _BigFloat()
        __gmpf_add(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return result
        
    }
    
    static func subtract(_ lhs: _BigFloat, _ rhs: _BigFloat) -> _BigFloat {
        
        let result = _BigFloat()
        __gmpf_sub(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return result
        
    }
    
    static func multiply(_ lhs: _BigFloat, _ rhs: _BigFloat) -> _BigFloat {
        
        let result = _BigFloat()
        __gmpf_mul(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return result
        
    }
    
    static func divide(_ lhs: _BigFloat, _ rhs: _BigFloat) -> _BigFloat? {
        
        let result = _BigFloat()
        
        if compare(lhs, to: rhs) == 0 { // N.B.: result == 0
            
            return nil
            
        } else {
            
            __gmpf_div(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
            return result
            
        }
        
    }
    
}

struct BigFloat {
    
    /// This is the internal object that handles the actual interaction with GMP
    fileprivate var internalObject: _BigFloat
    
}


// Initializers
extension BigFloat{
    
    init() {
        
        internalObject = _BigFloat()
        
    }
    
    init(_ value: String) {
        
        self.init()
        internalObject.set(value)
        
    }
    
    init(_ value: Double) {
        
        self.init()
        internalObject.set(String(value))
        
    }
    
    init<T>(_ value: T) where T:SignedInteger {
        
        self.init()
        internalObject.set(String(value))
        
    }
    
    init<T>(_ value: T) where T:UnsignedInteger {
        
        self.init()
        internalObject.set(String(value))
        
    }
    
    fileprivate init(_ value: _BigFloat) {
        
        internalObject = value
        
    }
    
}

extension BigFloat: Equatable, Comparable {
    
    static func ==(lhs: BigFloat, rhs: BigFloat) -> Bool {
        
        return _BigFloat.compare(lhs.internalObject, to: rhs.internalObject) == 0
        
    }
    
    static func <(lhs: BigFloat, rhs: BigFloat) -> Bool {
        
        return _BigFloat.compare(lhs.internalObject, to: rhs.internalObject) < 0
        
    }
    
}

extension BigFloat: CustomStringConvertible {
    
    var description: String {
        
        return self.internalObject.getString()
        
    }
    
}


extension Double {
    
    init? (_ value: BigFloat) {
        
        if let value = value.internalObject.getDouble() {
            
            self = value
            
        } else {
        
            return nil
    
        }
    
    }
    
}

//
//extension String {
//
//    init(_ bigInt: BigFloat, usingBase base: Int=10, withThisManyDigits n: Int=15) {
//
//        var buffer = [CChar]()
//
//        var numberToGet = bigInt.internalStruct
//        
//        //__gmpf_get_str(&buffer, Int32(base), n, &numberToGet)
//
//        self = String(cString: buffer)
//
//    }
//
//    init(_ bigInt: BigFloat) {
//
//        self = String(bigInt)
//
//    }
//
//}
//
//extension Int {
//    
//    init(_ bigInt: BigFloat) {
//        
//        var numberToGet = bigInt.internalStruct
//
//        if __gmpf_fits_slong_p(&numberToGet)==0 {
//            
//            fatalError("BigFloat is too large to be converted to Int.")
//            
//        } else {
//            
//            self = __gmpf_get_si(&numberToGet)
//            
//        }
//        
//    }
//    
//}
//
//extension IntMax {
//    
//    init(_ bigInt: BigFloat) {
//        
//        var numberToGet = bigInt.internalStruct
//        
//        if __gmpf_fits_slong_p(&numberToGet)==0 {
//        
//            fatalError("BigFloat is too large to be converted to IntMax.")
//
//        } else {
//        
//            self = IntMax(__gmpf_get_si(&numberToGet))
//        
//        }
//        
//    }
//    
//}
//
//final class BigFloat {
//    
//    /// This is the internal GMP struct that actually holds the number.
//    fileprivate var internalStruct: mpf_t
//    
//    init() {
//        
//        internalStruct = mpf_t()
//        __gmpf_init(&internalStruct)
//        
//    }
//    
//    init(_ string: String, usingBase base: Int=10) {
//        
//        let buffer = string.cString(using: .ascii)!
//        
//        internalStruct = mpf_t()
//        __gmpf_init_set_str(&internalStruct, buffer, Int32(base))
//        
//    }
//    
//    convenience init<T>(_ n: T) where T:SignedInteger {
//        
//        let string = String(n)
//        self.init(string)
//        
//    }
//    
//    convenience init<T>(_ n: T) where T:UnsignedInteger {
//        
//        let string = String(n)
//        self.init(string)
//        
//    }
//
//    
//    init(_ n: mpf_t) {
//        
//        internalStruct = n
//        
//    }
//        
//    deinit {
//        
//        __gmpf_clear(&internalStruct)
//        
//    }
//}
//
//extension BigFloat {
//    
//    static func addWithOverflow(_ lhs: BigFloat, _ rhs: BigFloat) -> (BigFloat, overflow: Bool) {
//        
//        let result = BigFloat()
//        __gmpf_add(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
//        return (result, overflow: false)
//        
//    }
//    
//    static func subtractWithOverflow(_ lhs: BigFloat, _ rhs: BigFloat) -> (BigFloat, overflow: Bool) {
//        
//        let result = BigFloat()
//        __gmpf_sub(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
//        return (result, overflow: false)
//        
//    }
//    
//    static func multiplyWithOverflow(_ lhs: BigFloat, _ rhs: BigFloat) -> (BigFloat, overflow: Bool) {
//        
//        let result = BigFloat()
//        __gmpf_mul(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
//        return (result, overflow: false)
//        
//    }
//    
//    static func divideWithOverflow(_ lhs: BigFloat, _ rhs: BigFloat) -> (BigFloat, overflow: Bool) {
//        
//        let result = BigFloat()
//        let zero = BigFloat()
//        
//        if rhs==zero {
//            
//            return (result, overflow: true)
//            
//        } else {
//            
//            __gmpf_div(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
//            return (result, overflow: false)
//            
//        }
//        
//    }
//    
////    static func remainderWithOverflow(_ lhs: BigFloat, _ rhs: BigFloat) -> (BigFloat, overflow: Bool) {
////        
////        let result = BigFloat()
////        let zero = BigFloat()
////        
////        if rhs==zero {
////            
////            return (result, overflow: true)
////            
////        } else {
////            
////            __gmpf_di(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
////            return (result, overflow: false)
////            
////        }
////        
////    }
//    
//}
//
//extension BigFloat: Equatable {
//
//    fileprivate static func compare(_ lhs: BigFloat, to rhs: BigFloat) -> Int32 {
//        
//        var lhsStruct = lhs.internalStruct
//        var rhsStruct = rhs.internalStruct
//        
//        return __gmpf_cmp(&lhsStruct, &rhsStruct)
//        
//    }
//    
//    static func ==(lhs: BigFloat, rhs: BigFloat) -> Bool {
//        
//        if compare(lhs, to: rhs)==0 {
//            
//            return true
//            
//        } else {
//            
//            return false
//            
//        }
//        
//    }
//}
//
//extension BigFloat: Comparable {
//    
//    static func <(lhs: BigFloat, rhs: BigFloat) -> Bool {
//        
//        if compare(lhs, to: rhs) < 0 {
//            
//            return true
//            
//        } else {
//            
//            return false
//            
//        }
//        
//    }
//    
//}
//
//extension BigFloat: CustomStringConvertible {
//    
//    var description: String {
//        
//        return String(self, usingBase: 10)
//        
//    }
//
//}
//
//extension BigFloat: Hashable {
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
//extension BigFloat: ExpressibleByIntegerLiteral {
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
//extension BigFloat: ExpressibleByStringLiteral {
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
//
