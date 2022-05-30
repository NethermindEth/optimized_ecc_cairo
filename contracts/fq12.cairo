%lang starknet
%builtins range_check bitwise

from lib.fq12 import fq12, FQ12
from lib.BigInt6 import BigInt6
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12, y : FQ12) -> (
        res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12.add(x, y)

    return (res)
end

@view
func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12, y : FQ12) -> (
        res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12.sub(x, y)

    return (res)
end

@view
func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ12) -> (
        res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12.scalar_mul(x, y)

    return (res)
end

@view
func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12, y : FQ12) -> (
        res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12.mul(x, y)

    return (res)
end
