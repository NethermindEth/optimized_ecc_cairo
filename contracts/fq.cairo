%lang starknet
%builtins range_check bitwise

from lib.fq import fq_lib
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
# Returns the current balance.
@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
        res : Uint384):
    alloc_locals
    let (res : Uint384) = fq_lib.add(x, y)

    return (res)
end

@view
func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
        res : Uint384):
    alloc_locals

    let (res : Uint384) = fq_lib.sub(x, y)

    return (res)
end

@view
func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar, x : Uint384) -> (
        res : Uint384):
    alloc_locals

    let (res : Uint384) = fq_lib.scalar_mul(scalar, x)

    return (res)
end

@view
func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
        res : Uint384):
    alloc_locals

    let (res : Uint384) = fq_lib.mul(x, y)

    return (res)
end

@view
func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (res : Uint384):
    alloc_locals

    let (res : Uint384) = fq_lib.square(x)

    return (res)
end

@view
func pow{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, exponent : Uint384) -> (
        res : Uint384):
    alloc_locals

    let (res : Uint384) = fq_lib.pow(x, exponent)

    return (res)
end

@view
func is_square_non_optimized{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (bool):
    alloc_locals

    let (bool) = fq_lib.is_square_non_optimized(x)

    return (bool)
end

@view
func from_64_bytes{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint256, y : Uint256) -> (
        res : Uint384):
    alloc_locals

    let (res : Uint384) = fq_lib.from_64_bytes(x, y)

    return (res)
end

@view
func get_square_root{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (
        success : felt, res : Uint384):
    alloc_locals

    let (success, res : Uint384) = fq_lib.get_square_root(x)

    return (success, res)
end
