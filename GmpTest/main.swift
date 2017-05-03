//
//  main.swift
//  GmpTest
//
//  Created by Louis Melahn on 5/3/17.
//  Copyright © 2017 Louis Melahn. All rights reserved.
//

import Foundation
import Gmp

print("Hello, World!")

var x = mpz_t();
var y = mpz_t();
var result = mpz_t();

__gmpz_init_set_str(&x, "7612058254738945", 10)
__gmpz_init_set_str(&y, "2", 10)
__gmpz_init(&result)

__gmpz_mul(&result, &x, &y);


extension mpz_t {
    
    func getString(base: Int) -> String {
        
        var buffer = [CChar]()
        
        var numberToGet = self
        __gmpz_get_str(&buffer, Int32(base), &numberToGet)

        return String(cString: buffer)
        
    }
    
    

}

extension mpz_t : CustomStringConvertible {
    
    public var description: String {
        
        return self.getString(base: 10)
    
    }
    
}



print("    \(x)")
print("*")
print("    \(y)")
print("--------------------")
print(result)
print()
let base = 12
print("In base \(base): \(result.getString(base: 16))")
__gmpz_clear(&x)
__gmpz_clear(&y)
__gmpz_clear(&result)
