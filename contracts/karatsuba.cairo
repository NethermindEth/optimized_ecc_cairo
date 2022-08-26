%lang starknet
%builtins range_check bitwise

from lib.karatsuba import karatsuba
from starkware.cairo.common.uint256 import Uint256, uint256_mul

@view
func mul_a{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
    alloc_locals
    let (low : Uint256, high : Uint256) = karatsuba.uint256_mul(a, b)

    return (low, high)
end

@view
func mul_b{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
    alloc_locals
    let (low : Uint256, high : Uint256) = karatsuba.uint256_mul_b(a, b)

    return (low, high)
end

@view
func mul_c{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
    alloc_locals
    let (low : Uint256, high : Uint256) = karatsuba.uint256_mul_c(a, b)

    return (low, high)
end

@view
func kar_a{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
    alloc_locals
    let (low : Uint256, high : Uint256) = karatsuba.uint256_mul_kar(a, b)

    return (low, high)
end


@view
func kar_b{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
    alloc_locals
    let (low : Uint256, high : Uint256) = karatsuba.uint256_mul_kar_b(a, b)

    return (low, high)
end

@view
func kar_c{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
    alloc_locals
    let (low : Uint256, high : Uint256) = karatsuba.uint256_mul_kar_c(a, b)

    return (low, high)
end