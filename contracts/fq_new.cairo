%lang starknet
%builtins range_check bitwise

from lib.fq_new import fq_lib
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

@view
func add{range_check_ptr}(x: Uint384, y: Uint384) -> (res: Uint384) {
    alloc_locals;
    let (res: Uint384) = fq_lib.add(x, y);

    return (res,);
}

@view
func sub{range_check_ptr}(x: Uint384, y: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.sub(x, y);

    return (res,);
}

@view
func sub1{range_check_ptr}(x: Uint384, y: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.sub1(x, y);

    return (res,);
}

@view
func mul{range_check_ptr}(x: Uint384, y: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.mul(x, y);

    return (res,);
}

@view
func square{range_check_ptr}(x: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.square(x);

    return (res,);
}

@view
func square2{range_check_ptr}(x: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.square2(x);

    return (res,);
}

@view
func scalar_mul{range_check_ptr}(scalar, x: Uint384) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.scalar_mul(scalar, x);

    return (res,);
}

@view
func scalar_mul2{range_check_ptr}(scalar, x: Uint384) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.scalar_mul2(scalar, x);

    return (res,);
}

@view
func scalar_mul3{range_check_ptr}(scalar, x: Uint384) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.scalar_mul3(scalar, x);

    return (res,);
}

@view
func scalar_mul4{range_check_ptr}(scalar, x: Uint384) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.scalar_mul4(scalar, x);

    return (res,);
}

@view
func scalar64_mul{range_check_ptr}(scalar, x: Uint384) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.scalar64_mul(scalar, x);

    return (res,);
}

@view
func div{range_check_ptr}(x: Uint384, y: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.div(x, y);

    return (res,);
}

@view
func inverse{range_check_ptr}(x: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.inverse(x);

    return (res,);
}

@view
func pow{range_check_ptr}(x: Uint384, exponent: Uint384) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.pow(x, exponent);

    return (res,);
}

@view
func get_square_root{range_check_ptr}(x: Uint384) -> (
    success: felt, res: Uint384
) {
    alloc_locals;

    let (success, res: Uint384) = fq_lib.get_square_root(x);

    return (success, res);
}

@view
func from_256_bits{range_check_ptr}(x: Uint256) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.from_256_bits(x);

    return (res,);
}

@view
func from_64_bytes{range_check_ptr}(x: Uint256, y: Uint256) -> (
    res: Uint384
) {
    alloc_locals;

    let (res: Uint384) = fq_lib.from_64_bytes(x, y);

    return (res,);
}

@view
func neg{range_check_ptr}(x: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.neg(x);

    return (res,);
}

@view
func mul_three_terms{range_check_ptr}(x: Uint384, y: Uint384, z: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.mul_three_terms(x, y, z);

    return (res,);
}

@view
func sub_three_terms{range_check_ptr}(x: Uint384, y: Uint384, z: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.sub_three_terms(x, y, z);

    return (res,);
}

@view
func sub_three_terms_new{range_check_ptr}(x: Uint384, y: Uint384, z: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.sub_three_terms_new(x, y, z);

    return (res,);
}

@view
func sub_three_terms2{range_check_ptr}(x: Uint384, y: Uint384, z: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.sub_three_terms2(x, y, z);

    return (res,);
}

@view
func sub_three_terms3{range_check_ptr}(x: Uint384, y: Uint384, z: Uint384) -> (res: Uint384) {
    alloc_locals;

    let (res: Uint384) = fq_lib.sub_three_terms3(x, y, z);

    return (res,);
}
