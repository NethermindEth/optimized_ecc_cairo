%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from lib.hash_to_curve import map_to_curve_g2, multiply_clear_cofactor_g2
from lib.fq2 import FQ2
from lib.isogeny import isogeny_map_g2
from lib.g2 import G2Point
from lib.hash_to_field import expand_msg_sha_xmd
@view
func fq2_to_curve{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(u : FQ2) -> (
        x : FQ2, y : FQ2, z : FQ2):
    let (x, y, z) = map_to_curve_g2(u)

    return (z, y, z)
end

@view
func isogeny_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2, z : FQ2) -> (
        x_res : FQ2, y_res : FQ2, z_res : FQ2):
    alloc_locals

    let (x_res, y_res, z_res) = isogeny_map_g2(x, y, z)

    return (x_res, y_res, z_res)
end

@view
func clear_cofactor_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p : G2Point) -> (
        res : G2Point):
    alloc_locals

    let (res) = multiply_clear_cofactor_g2(p)

    return (res)
end

@view
func hash_to_field{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(msg : Uint256) -> (
        one : Uint256, two : Uint256, three : Uint256, four : Uint256):
    let (one, two, three, four) = expand_msg_sha_xmd(msg)

    return (one, two, three, four)
end
