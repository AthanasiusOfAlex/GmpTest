//
//  BigInt.swift
//  GmpTest
//
//  Created by Louis Melahn on 5/3/17.
//  Copyright © 2017 Louis Melahn. All rights reserved.
//

import Foundation
import GMP

extension String {

    init(_ bigInt: BigInt, usingBase base: Int) {

        var buffer = [CChar]()

        var numberToGet = bigInt.internalStruct
        __gmpz_get_str(&buffer, Int32(base), &numberToGet)

        self = String(cString: buffer)

    }

    init(_ bigInt: BigInt) {

        self = String(bigInt)

    }

}

extension Int {
    
    init(_ bigInt: BigInt) {
        
        var numberToGet = bigInt.internalStruct
        
        if __gmpz_fits_slong_p(&numberToGet)==0 {
            
            fatalError("BigInt is too large to be converted to Int.")
            
        } else {
            
            self = __gmpz_get_si(&numberToGet)
            
        }
        
    }
    
}

extension IntMax {
    
    init(_ bigInt: BigInt) {
        
        var numberToGet = bigInt.internalStruct
        
        if __gmpz_fits_slong_p(&numberToGet)==0 {
        
            fatalError("BigInt is too large to be converted to IntMax.")

        } else {
        
            self = IntMax(__gmpz_get_si(&numberToGet))
        
        }
        
    }
    
}


protocol SignedMaxable: SignedInteger {
    
    static var max: Self { get }
    init?(_ value: String, radix: Int)

}

protocol UnsignedMaxable: UnsignedInteger {
    
    static var max: Self { get }
    init?(_ value: String, radix: Int)

}

extension Int: SignedMaxable {}
extension Int64: SignedMaxable {}
extension Int32: SignedMaxable {}
extension Int16: SignedMaxable {}
extension Int8: SignedMaxable {}

extension UInt: UnsignedMaxable {}
extension UInt64: UnsignedMaxable {}
extension UInt32: UnsignedMaxable {}
extension UInt16: UnsignedMaxable {}
extension UInt8: UnsignedMaxable {}


extension SignedMaxable {
    
    init(_ bigInt: BigInt) {
        
        
        guard bigInt < BigInt(Self.max) else {
            
            fatalError("Tried to convert BigInt greater than maximum allowed for \(Mirror(reflecting: Self.max).subjectType)")
            
        }
        
        let string = String(bigInt)
        self.init(string, radix: 10)!
        
    }
    
}

//extension Maxable {
//    
//    init(_ bigInt: BigInt) {
//        
//        //var numberToGet = bigInt.internalStruct
//        
//        if bigInt > BigInt(Maxable.max) {}
//        
//        let string = String(bigInt)
//        
//        
//    }
//}


protocol GenericInteger: Integer {
    init(_ value: BigInt)
}



final class BigInt {
    
    /// This is the internal GMP struct that actually holds the number.
    fileprivate var internalStruct: mpz_t
    
    init() {
        
        internalStruct = mpz_t()
        __gmpz_init(&internalStruct)
        
    }
    
    init(_ string: String, usingBase base: Int=10) {
        
        let buffer = string.cString(using: .ascii)!
        
        internalStruct = mpz_t()
        __gmpz_init_set_str(&internalStruct, buffer, Int32(base))
        
    }
    
    convenience init<T>(_ n: T) where T:SignedInteger {
        
        let string = String(n)
        self.init(string)
        
    }
    
    convenience init<T>(_ n: T) where T:UnsignedInteger {
        
        let string = String(n)
        self.init(string)
        
    }

    
    init(_ n: mpz_t) {
        
        internalStruct = n
        
    }
        
    deinit {
        
        __gmpz_clear(&internalStruct)
        
    }
    
    static func addWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        __gmpz_add(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return (result, overflow: false)
        
    }
    
    static func subtractWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        __gmpz_sub(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return (result, overflow: false)
        
    }
    
    static func multiplyWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        __gmpz_mul(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
        return (result, overflow: false)
        
    }
    
    static func divideWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        let zero = BigInt()
        
        if rhs==zero {
            
            return (result, overflow: true)
            
        } else {
            
            __gmpz_tdiv_q(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
            return (result, overflow: false)
            
        }
        
    }
    
    static func remainderWithOverflow(_ lhs: BigInt, _ rhs: BigInt) -> (BigInt, overflow: Bool) {
        
        let result = BigInt()
        let zero = BigInt()
        
        if rhs==zero {
            
            return (result, overflow: true)
            
        } else {
            
            __gmpz_tdiv_r(&result.internalStruct, &lhs.internalStruct, &rhs.internalStruct)
            return (result, overflow: false)
            
        }
        
    }
    
    fileprivate static func compare(_ lhs: BigInt, to rhs: BigInt) -> Int32 {
        
        var lhsStruct = lhs.internalStruct
        var rhsStruct = rhs.internalStruct
        
        return __gmpz_cmp(&lhsStruct, &rhsStruct)
        
    }
    
    static func ==(lhs: BigInt, rhs: BigInt) -> Bool {
        
        if compare(lhs, to: rhs)==0 {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }
    
    static func <(lhs: BigInt, rhs: BigInt) -> Bool {
        
        if compare(lhs, to: rhs) < 0 {
            
            return true
            
        } else {
            
            return false
            
        }
        
    }

    func toIntMax() -> IntMax {
        
        return IntMax(self)
        
    }
    
    var description: String {
        
        return String(self, usingBase: 10)
        
    }


    typealias IntegerLiteralType = Int
    
    convenience init(integerLiteral: IntegerLiteralType) {
        
        self.init(integerLiteral)
        
    }
    


}

extension BigInt: Equatable, Comparable, IntegerArithmetic, CustomStringConvertible, ExpressibleByIntegerLiteral {}


extension BigInt: Strideable {
    
    typealias Stride = IntMax
    
    func distance(to other: BigInt) -> Stride {
        
        return (other - self).toIntMax()
        
    }
    
    func advanced(by n: Stride) -> BigInt {
        
        return BigInt(n) + self
        
    }
    
}

extension BigInt: Hashable {
    
    var hashValue: Int {
        
        let string = String(self)
        return string.hashValue
        
    }
    
}

//extension BigInt: BitwiseOperations {
//    /// Returns the intersection of bits set in the two arguments.
//    ///
//    /// The bitwise AND operator (`&`) returns a value that has each bit set to
//    /// `1` where *both* of its arguments had that bit set to `1`. This is
//    /// equivalent to the intersection of two sets. For example:
//    ///
//    ///     let x: UInt8 = 5        // 0b00000101
//    ///     let y: UInt8 = 14       // 0b00001110
//    ///     let z = x & y           // 0b00000100
//    ///
//    /// Performing a bitwise AND operation with a value and `allZeros` always
//    /// returns `allZeros`.
//    ///
//    ///     print(x & .allZeros)    // 0b00000000
//    ///     // Prints "0"
//    ///
//    /// - Complexity: O(1).
//    static func &(lhs: BigInt, rhs: BigInt) -> Self {
//        <#code#>
//    }
//
//
//}
