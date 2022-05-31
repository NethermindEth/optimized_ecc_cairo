%lang starknet
%builtins range_check bitwise

from lib.fq2 import fq2_lib, FQ2
from lib.BigInt6 import BigInt6
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (
        res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.add(x, y)

    return (res)
end

@view
func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (
        res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.sub(x, y)

    return (res)
end

@view
func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ2) -> (
        res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.scalar_mul(x, y)

    return (res)
end

@view
func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (
        res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.mul(x, y)

    return (res)
end
