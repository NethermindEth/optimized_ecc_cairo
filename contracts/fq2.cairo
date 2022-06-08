%lang starknet
%builtins range_check bitwise

from lib.fq2 import fq2_lib, FQ2
from lib.uint384 import Uint384
from lib.uint384_extension import Uint768
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
func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ2) -> (res : FQ2):
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
func pow{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, exp : Uint768) -> (res : FQ2):
    alloc_locals

    let (res : FQ2) = fq2_lib.pow(x, exp)

    return (res)
end

@view
func eq{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (res : felt):
    alloc_locals

    let (res) = fq2_lib.eq(x, y)

    return (res)
end

@view
func sgn0{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2) -> (sign : felt):
    alloc_locals

    let (res : felt) = fq2_lib.sgn0(x)

    return (res)
end

@view
func is_zero{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2) -> (bool : felt):
    alloc_locals

    let (res) = fq2_lib.is_zero(x)

    return (res)
end
