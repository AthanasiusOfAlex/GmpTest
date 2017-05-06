//
//  main.swift
//  GmpTest
//
//  Created by Louis Melahn on 5/3/17.
//  Copyright © 2017 Louis Melahn. All rights reserved.
//

import Foundation
import GMP


protocol Junk {
    
    static func +(lhs: Self, rhs: Self) -> Self
    static func *(lhs: Self, rhs: Self) -> Self
    
}


extension Int: Junk {}
extension Double: Junk {}

func throwAway<T: Junk>(_ m: T, _ n: T) -> T {
    
    return m * n + n
    
}

let ta = throwAway(5.5, 6.234324)
let tb = throwAway(5, 6)
let tc = throwAway(5.5, 6)

print("Junk: \(ta), \(tb), \(tc)")

func doSomething<T: Integer>(n: T) -> T {

    print(Mirror(reflecting: n).subjectType)
    
    return 1
    
}

let n8: Int8 = 5
let n16: Int16 = 5
let n32: Int32 = 5
let n64: Int64 = 5

print(doSomething(n: n8))
print(doSomething(n: n16))
print(doSomething(n: n32))
print(doSomething(n: n64))




//let x = BigInt(Int.max)
//let y = BigInt(55)
//let z: BigInt = 678
//let zz: BigInt = "65535"
//
//print("zz: \(zz); in base 16: \(String(zz, usingBase: 16))")
//print("in base 15: \(String(zz, usingBase: 15))")
//
//print("x: \(x); y: \(y); x+y: \(x+y); x*y: \(x*y); x/y: \(x/y); x%y: \(x%y)")
//
//var g = mpz_t()
//var cStrG = [CChar]()
//__gmpz_get_str(&cStrG, Int32(10), &g)
//__gmpz_clear(&g)
//__gmpz_clear(&g)


//for i in BigInt("500000")..<BigInt("500100") {
//
//    print(i)
//    
//}

print(IntMax.max)

//_ = BigInt(UInt(234))
print(Int("453534")!)
