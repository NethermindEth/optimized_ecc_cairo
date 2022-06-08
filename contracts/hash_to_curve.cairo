%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from lib.hash_to_curve import map_to_curve_g2
from lib.fq2 import FQ2
@view
func fq2_to_curve{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(u : FQ2) -> (
        x : FQ2, y : FQ2, z : FQ2):
    let (x, y, z) = map_to_curve_g2(u)

    return (z, y, z)
end
