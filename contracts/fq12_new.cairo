%lang starknet
%builtins range_check bitwise

from lib.fq12_new import fq12_lib, FQ12
from lib.uint384 import Uint384
from lib.uint384_extension import Uint768

@view
func add{range_check_ptr}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.add(x, y);

    return (res,);
}

@view
func sub{range_check_ptr}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.sub(x, y);

    return (res,);
}

@view
func sub_2{range_check_ptr}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.sub_2(x, y);

    return (res,);
}

@view
func sub_3{range_check_ptr}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.sub_3(x, y);

    return (res,);
}

@view
func scalar_mul{range_check_ptr}(x: felt, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.scalar_mul(x, y);

    return (res,);
}

@view
func scalar_mul2{range_check_ptr}(x: felt, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.scalar_mul2(x, y);

    return (res,);
}

@view
func scalar_mul_uint384{range_check_ptr}(x: Uint384, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.scalar_mul_uint384(x, y);

    return (res,);
}

@view
func mul{range_check_ptr}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.mul(x, y);

    return (res,);
}

@view
func mul_2{range_check_ptr}(x: FQ12, y: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.mul_2(x, y);

    return (res,);
}

@view
func square{range_check_ptr}(x: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.square(x);

    return (res,);
}

@view
func square_2{range_check_ptr}(x: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.square_2(x);

    return (res,);
}

@view
func inverse{range_check_ptr}(x: FQ12) -> (res: FQ12) {
    alloc_locals;

    let (res: FQ12) = fq12_lib.inverse(x);

    return (res,);
}
