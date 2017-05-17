//
//  BigIntStruct.swift
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

private final class BigIntClass {
    
    /// This is the internal GMP struct that actually holds the number.
    fileprivate var internalStruct = mpz_t()
    
    init() {
        
        __gmpz_init(&internalStruct)
        
    }

    deinit {
        __gmpz_clear(&internalStruct)
    }
    
    func set(_ value: String) {
        
        
    }
    
    func get(usingBase: Int) -> String {
        
        
        
        __gmpz_get_str(<#T##UnsafeMutablePointer<Int8>!#>, <#T##Int32#>, <#T##mpz_srcptr!#>)
        
    }
    
}