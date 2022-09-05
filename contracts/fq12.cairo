%lang starknet
%builtins range_check bitwise

from lib.fq12 import fq12_lib, FQ12
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

@view
func add{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.add(x, y);

    return (res,);
}

@view
func sub{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.sub(x, y);

    return (res,);
}

@view
func scalar_mul{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: felt, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.scalar_mul(x, y);

    return (res,);
}

@view
func mul{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.mul(x, y);

    return (res,);
}
