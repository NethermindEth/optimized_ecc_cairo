%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.g1 import G1Point, g1_lib

@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : G1Point, y : G1Point) -> (
    res : G1Point
):
    alloc_locals
    let (res : G1Point) = g1_lib.add(x, y)

    return (res)
end
