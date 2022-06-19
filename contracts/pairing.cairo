%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.pairing import line_func_g1, twist
from lib.g1 import G1Point
from lib.uint384 import Uint384
from lib.pairing import GTPoint
from lib.g2 import G2Point

@view
func twist_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(pt : G2Point) -> (res : GTPoint):
    alloc_locals

    let (res) = twist(pt)

    return (res)
end

@view
func line_func{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        p1 : G1Point, p2 : G1Point, pt : G1Point) -> (x : Uint384, y : Uint384):
    alloc_locals

    let (x, y) = line_func_g1(p1, p2, pt)

    return (x, y)
end
