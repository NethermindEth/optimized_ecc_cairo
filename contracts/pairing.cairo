%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.pairing import pairing_lib, GTPoint
from lib.g2 import G2Point
from lib.g1 import G1Point
from lib.fq12 import FQ12
from lib.fq12 import fq12_lib

@view
func pairing{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(q : G2Point, p : G1Point) -> (
        res : FQ12){
    alloc_locals;

    let (res) = pairing_lib.pairing(q, p);

    return (res,);
}

@view
func _miller_loop{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(q : G2Point, p : G1Point) -> (
        res : FQ12){
    alloc_locals;

    let (res) = pairing_lib.miller_loop(q, p);

    return (res,);
}

@view
func _ate_loop_iter{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(q : G2Point, p : G1Point) -> (){
    alloc_locals;

    let (cast_p: GTPoint) = pairing_lib.cast_point_to_fq12(p);
    let (twist_r: GTPoint) = pairing_lib.twist(q);
    let twist_q = twist_r;
    let r = q;
    let (f_num: FQ12) = fq12_lib.bit_128_to_fq12(1);
    let (f_den: FQ12) = fq12_lib.bit_128_to_fq12(1);
    let (twist_r, f_num, f_den, r) = pairing_lib.ate_loop(twist_r, twist_q, cast_p, f_num, f_den, r, q, 0);


    return ();
}


@view
func twist_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(pt : G2Point) -> (res : GTPoint){
    alloc_locals;

    let (res) = pairing_lib.twist(pt);

    return (res,);
}

@view
func line_func{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
    p1: GTPoint, p2: GTPoint, pt: GTPoint
) -> (x: FQ12, y: FQ12) {
    alloc_locals;

    let (x, y) = pairing_lib.line_func_gt(p1, p2, pt);

    return (x, y);
}
