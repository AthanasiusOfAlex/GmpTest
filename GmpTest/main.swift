//
//  main.swift
//  GmpTest
//
//  Created by Louis Melahn on 5/3/17.
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

let n: BigInt = "10000000000001"

extension BigInt {
    
    func toThePowerOf(_ n: BigInt) -> BigInt {
        
        guard self != 0 || n != 0 else { fatalError("Attempt to raise 0 to the 0th power") }
        guard n >= 0 else { fatalError("This function only takes nonnegative powers") }
        guard n > 0 else { return 1 }
        guard n > 1 else { return self }
        
        var result: BigInt = self

        for _ in 2...n {
            
            result *= self

        }
        
        return result
        
    }
    
}

for i in BigInt(1)...BigInt(1000) {
    
    print("\(i) to the power of \(i) is \(i.toThePowerOf(i))")
    
}
