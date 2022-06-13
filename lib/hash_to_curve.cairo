from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from lib.fq2 import FQ2, fq2_lib
from lib.isogeny import isogeny_map_g2
from lib.swu import optimized_sswu
from lib.g2 import G2Point, g2_lib
from lib.hash_to_field import expand_msg_sha_xmd
from lib.uint384 import Uint384
from lib.uint384_extension import Uint768

func hash_to_curve{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(hash : Uint256) -> (
        point_on_curve : G2Point):
    alloc_locals
    let (one : Uint256, two : Uint256, three : Uint256, four : Uint256) = expand_msg_sha_xmd(hash)

    let u0 : FQ2 = FQ2(
        e0=Uint384(d0=one.low, d1=one.high, d2=0), e1=Uint384(d0=two.low, d1=two.high, d2=0))
    let u1 : FQ2 = FQ2(
        e0=Uint384(d0=three.low, d1=three.high, d2=0), e1=Uint384(d0=four.low, d1=four.high, d2=0))

    let (x0 : FQ2, y0 : FQ2, z0 : FQ2) = map_to_curve_g2(u0)
    let (x1 : FQ2, y1 : FQ2, z1 : FQ2) = map_to_curve_g2(u1)

    let (z : FQ2) = fq2_lib.one()

    let p0 : G2Point = G2Point(x=x0, y=y0, z=z0)
    let p1 : G2Point = G2Point(x=x1, y=y1, z=z1)

    let (p0 : G2Point) = g2_lib.add(p0, p1)

    let (p0 : G2Point) = clear_cofactor_g2(p0)

    return (p0)
end

# @dev hash_to_curve but with the sha256 hash step omitted.
# @dev This allows us to test the rest of the function without needing the sha256 builtin
func expanded_hash_to_curve{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        one : Uint256, two : Uint256, three : Uint256, four : Uint256) -> (
        point_on_curve : G2Point):
    alloc_locals
    let u0 : FQ2 = FQ2(
        e0=Uint384(d0=one.low, d1=one.high, d2=0), e1=Uint384(d0=two.low, d1=two.high, d2=0))
    let u1 : FQ2 = FQ2(
        e0=Uint384(d0=three.low, d1=three.high, d2=0), e1=Uint384(d0=four.low, d1=four.high, d2=0))

    let (x0 : FQ2, y0 : FQ2, z0 : FQ2) = map_to_curve_g2(u0)
    let (x1 : FQ2, y1 : FQ2, z1 : FQ2) = map_to_curve_g2(u1)

    let (z : FQ2) = fq2_lib.one()

    let p0 : G2Point = G2Point(x=x0, y=y0, z=z0)
    let p1 : G2Point = G2Point(x=x1, y=y1, z=z1)

    let (p0 : G2Point) = g2_lib.add(p0, p1)

    let (p0 : G2Point) = clear_cofactor_g2(p0)

    return (p0)
end

func map_to_curve_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(u : FQ2) -> (
        x : FQ2, y : FQ2, z : FQ2):
    let (x, y, z) = optimized_sswu(u)

    let (x, y, z) = isogeny_map_g2(x, y, z)

    return (x, y, z)
end

func get_eff() -> (eff : Uint768):
    return (
        eff=Uint768(d0=119014178618821193091036287192695133521,
        d1=62146203837194039764882816477306680995,
        d2=67272353236517086857589196665811767984,
        d3=181951892428052229821697763365605670881,
        d4=15652808343759903749145074599819162920,
        d5=0))
end

# Efficent cofactor clearing - https://eprint.iacr.org/2017/419.pdf
func clear_cofactor_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p : G2Point) -> (
        res : G2Point):
    alloc_locals

    let (two_p : G2Point) = g2_lib.double(p)
    # P2 = ψ^2(2P)
    let (psi_squared_two_p : G2Point) = g2_lib.two_psi(two_p)
    # P1 = ψ(P)
    let (psi_p : G2Point) = g2_lib.psi(p)

    # -xP0
    let (p_mul_x) = mul_x(p)
    # -xP0 - P1
    let (minus_psi_p) = g2_lib.sub(psi_p, p_mul_x)

    # (x^2)P0 + xP1
    let (second_mul_x) = mul_x(minus_psi_p)

    # (-x-1)P0
    let (res : G2Point) = g2_lib.sub(p_mul_x, p)
    # (x^2-x-1)P0 + xP1
    let (res : G2Point) = g2_lib.sub(second_mul_x, res)
    # (x^2-x-1)P0 + (x-1)P1
    let (res : G2Point) = g2_lib.add(res, psi_p)
    # (x^2-x-1)P0 + (x-1)P1 + P2
    let (res : G2Point) = g2_lib.add(res, psi_squared_two_p)

    return (res)
end

func mul_x{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p : G2Point) -> (res : G2Point):
    alloc_locals

    # g.Double(p, t)
    let (double_1) = g2_lib.double(p)
    # chain(p, 2, t)
    let (add) = g2_lib.add(p, p)
    let (double_1) = g2_lib.double(add)
    let (double_2) = g2_lib.double(double_1)
    # chain(p, 3, t)
    let (add) = g2_lib.add(double_2, p)
    let (double_1) = g2_lib.double(add)
    let (double_2) = g2_lib.double(double_1)
    let (double_3) = g2_lib.double(double_2)
    # chain(p, 9, t)
    let (add) = g2_lib.add(double_3, p)
    let (double_1) = g2_lib.double(add)
    let (double_2) = g2_lib.double(double_1)
    let (double_3) = g2_lib.double(double_2)
    let (double_4) = g2_lib.double(double_3)
    let (double_5) = g2_lib.double(double_4)
    let (double_6) = g2_lib.double(double_5)
    let (double_7) = g2_lib.double(double_6)
    let (double_8) = g2_lib.double(double_7)
    let (double_9) = g2_lib.double(double_8)
    # chain(p, 32, t)
    let (add) = g2_lib.add(double_9, p)
    let (double_1) = g2_lib.double(add)
    let (double_2) = g2_lib.double(double_1)
    let (double_3) = g2_lib.double(double_2)
    let (double_4) = g2_lib.double(double_3)
    let (double_5) = g2_lib.double(double_4)
    let (double_6) = g2_lib.double(double_5)
    let (double_7) = g2_lib.double(double_6)
    let (double_8) = g2_lib.double(double_7)
    let (double_9) = g2_lib.double(double_8)
    let (double_10) = g2_lib.double(double_9)
    let (double_11) = g2_lib.double(double_10)
    let (double_12) = g2_lib.double(double_11)
    let (double_13) = g2_lib.double(double_12)
    let (double_14) = g2_lib.double(double_13)
    let (double_15) = g2_lib.double(double_14)
    let (double_16) = g2_lib.double(double_15)
    let (double_17) = g2_lib.double(double_16)
    let (double_18) = g2_lib.double(double_17)
    let (double_19) = g2_lib.double(double_18)
    let (double_20) = g2_lib.double(double_19)
    let (double_21) = g2_lib.double(double_20)
    let (double_22) = g2_lib.double(double_21)
    let (double_23) = g2_lib.double(double_22)
    let (double_24) = g2_lib.double(double_23)
    let (double_25) = g2_lib.double(double_24)
    let (double_26) = g2_lib.double(double_25)
    let (double_27) = g2_lib.double(double_26)
    let (double_28) = g2_lib.double(double_27)
    let (double_29) = g2_lib.double(double_28)
    let (double_30) = g2_lib.double(double_29)
    let (double_31) = g2_lib.double(double_30)
    let (double_32) = g2_lib.double(double_31)
    # chain(p, 16, t)
    let (add) = g2_lib.add(double_9, p)
    let (double_1) = g2_lib.double(add)
    let (double_2) = g2_lib.double(double_1)
    let (double_3) = g2_lib.double(double_2)
    let (double_4) = g2_lib.double(double_3)
    let (double_5) = g2_lib.double(double_4)
    let (double_6) = g2_lib.double(double_5)
    let (double_7) = g2_lib.double(double_6)
    let (double_8) = g2_lib.double(double_7)
    let (double_9) = g2_lib.double(double_8)
    let (double_10) = g2_lib.double(double_9)
    let (double_11) = g2_lib.double(double_10)
    let (double_12) = g2_lib.double(double_11)
    let (double_13) = g2_lib.double(double_12)
    let (double_14) = g2_lib.double(double_13)
    let (double_15) = g2_lib.double(double_14)
    let (double_16) = g2_lib.double(double_15)

    return (double_16)
end
