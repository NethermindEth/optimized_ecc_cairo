%lang starknet
%builtins range_check bitwise

from lib.karatsuba import karatsuba
from starkware.cairo.common.uint256 import Uint256

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