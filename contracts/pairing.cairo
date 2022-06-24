%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.pairing import line_func_gt, twist, GTPoint, miller_loop
from lib.g2 import G2Point
from lib.g1 import G1Point
from lib.fq12 import FQ12

@view
func _miller_loop{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(q : G2Point, p : G1Point) -> (
        f_num : FQ12, f_den : FQ12):
    alloc_locals

    let (x, y) = miller_loop(q, p)

    return (x, y)
end

@view
func twist_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(pt : G2Point) -> (res : GTPoint):
    alloc_locals

    let (res) = twist(pt)

    return (res)
end

@view
func line_func{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        p1 : GTPoint, p2 : GTPoint, pt : GTPoint) -> (x : FQ12, y : FQ12):
    alloc_locals

    let (x, y) = line_func_gt(p1, p2, pt)

    return (x, y)
end
