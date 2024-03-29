%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from lib.hash_to_curve import map_to_curve_g2, clear_cofactor_g2, expanded_hash_to_curve
from lib.fq2 import FQ2
from lib.isogeny import isogeny_map_g2
from lib.g2 import G2Point
from lib.hash_to_field import expand_msg_sha_xmd
from lib.swu import optimized_sswu, sqrt_div

@view
func exp_hash_to_curve{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    one: Uint256, two: Uint256, three: Uint256, four: Uint256
) -> (point_on_curve: G2Point) {
    let (res: G2Point) = expanded_hash_to_curve(one, two, three, four);

    return (res,);
}

@view
func sqrt_div_fq2{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(u: FQ2, v: FQ2) -> (
    success: felt, sqrt_candidate: FQ2
) {
    alloc_locals;
    let (success: felt, sqrt_candidate) = sqrt_div(u, v);

    return (success, sqrt_candidate);
}

@view
func sswu{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(t: FQ2) -> (x: FQ2, y: FQ2, z: FQ2) {
    alloc_locals;
    let (x, y, z) = optimized_sswu(t);

    return (x, y, z);
}

@view
func fq2_to_curve{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(u: FQ2) -> (
    x: FQ2, y: FQ2, z: FQ2
) {
    let (x, y, z) = map_to_curve_g2(u);

    return (x, y, z);
}

@view
func isogeny_g2{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: FQ2, y: FQ2, z: FQ2) -> (
    x_res: FQ2, y_res: FQ2, z_res: FQ2
) {
    alloc_locals;

    let (x_res, y_res, z_res) = isogeny_map_g2(x, y, z);

    return (x_res, y_res, z_res);
}

@view
func clear_cofactor{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(p: G2Point) -> (res: G2Point) {
    alloc_locals;

    let (res) = clear_cofactor_g2(p);

    return (res,);
}

@view
func hash_to_field{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}(msg: Uint256) -> (
    one: Uint256, two: Uint256, three: Uint256, four: Uint256
) {
    let (one, two, three, four) = expand_msg_sha_xmd(msg);

    return (one, two, three, four);
}
