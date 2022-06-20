%lang starknet
%builtins range_check bitwise
from lib.uint384 import Uint384
from lib.fq2 import fq2_lib, FQ2
from lib.BigInt6 import BigInt6
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.add(x, y)

    return (res)
end

@view
func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.sub(x, y)

    return (res)
end

@view
func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : FQ2) -> (res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.scalar_mul(x, y)

    return (res)
end

@view
func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.mul(x, y)

    return (res)
end

@view
func inv{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2) -> (res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.inv(x)

    return (res)
end

@view
func eq{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (res : felt):
    alloc_locals

    let (res) = fq2_lib.eq(x, y)

    return (res)
end

@view
func is_zero{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2) -> (bool : felt):
    alloc_locals

    let (res) = fq2_lib.is_zero(x)

    return (res)
end

@view
func get_square_root{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(value : FQ2) -> (
    success : felt, res : FQ2
):
    alloc_locals

    let (success, res : FQ2) = fq2_lib.get_square_root(value)

    return (success, res)
end
