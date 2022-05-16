%lang starknet
%builtins range_check bitwise

from lib.fq2 import fq2
from lib.BigInt6 import BigInt6
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : fq2.FQ2, y : fq2.FQ2) -> (
        res : fq2.FQ2):
    alloc_locals

    let (res : fq2.FQ2) = fq2.add(x, y)

    return (res)
end

@view
func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : fq2.FQ2, y : fq2.FQ2) -> (
        res : fq2.FQ2):
    alloc_locals

    let (res : fq2.FQ2) = fq2.sub(x, y)

    return (res)
end

@view
func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : fq2.FQ2) -> (
        res : fq2.FQ2):
    alloc_locals

    let (res : fq2.FQ2) = fq2.scalar_mul(x, y)

    return (res)
end

@view
func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : fq2.FQ2, y : fq2.FQ2) -> (
        res : fq2.FQ2):
    alloc_locals

    let (res : fq2.FQ2) = fq2.mul(x, y)

    return (res)
end
