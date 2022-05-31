%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.g2 import G2Point, g2_lib
from lib.fq2 import FQ2

@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : G2Point, y : G2Point) -> (
        res : G2Point):
    alloc_locals
    let (res : G2Point) = g2_lib.add(x, y)

    return (res)
end

@view
func swu{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(e : FQ2, u : FQ2) -> (x : FQ2, y : FQ2):
    alloc_locals
    let (x : FQ2, y : FQ2) = g2_lib.simplified_swu(e, u)

    return (x, y)
end
