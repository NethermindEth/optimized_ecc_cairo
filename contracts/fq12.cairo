%lang starknet
%builtins range_check bitwise

from lib.fq12 import fq12_lib, FQ12
from lib.uint384_extension import Uint768
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12, y : FQ12) -> (res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12_lib.add(x, y)

    return (res)
end

@view
func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12, y : FQ12) -> (res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12_lib.sub(x, y)

    return (res)
end

@view
func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ12) -> (res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12_lib.scalar_mul(x, y)

    return (res)
end

@view
func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12, y : FQ12) -> (res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12_lib.mul(x, y)

    return (res)
end

@view
func pow{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12, exp : Uint768) -> (res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12_lib.pow(x, exp)

    return (res)
end

@view
func inverse{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ12) -> (res : FQ12):
    alloc_locals

    let (res : FQ12) = fq12_lib.inverse(x)

    return (res)
end
