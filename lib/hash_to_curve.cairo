from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from lib.fq2 import FQ2, fq2_lib
from lib.isogeny import isogeny_map_g2
from lib.swu import optimized_sswu
from lib.g2 import G2Point, g2_lib
from lib.hash_to_field import expand_msg_sha_xmd
from lib.uint384_extension import Uint768

func hash_to_curve{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(hash : Uint256) -> (
        point_on_curve : G2Point):
    let (one : Uint256, two : Uint256, three : Uint256, four : Uint256, _, _, _,
        _) = expand_msg_sha_xmd(hash)

    let (u0 : FQ2) = FQ2(one, two)
    let (u1 : FQ2) = FQ2(three, four)

    let (x0 : FQ2, y0 : FQ2, z0 : FQ2) = map_to_curve_g2(u0)
    let (x1 : FQ2, y1 : FQ2, z1 : FQ2) = map_to_curve_g2(u1)

    let (z : Uint384) = fq2_lib.one()

    let p0 : G2Point = G2Point(x=x0, y=y0, z=z0)
    let p1 : G2Point = G2Point(x=x1, y=y1, z=z1)

    let (p0 : G2Point) = g2_lib.add(p0, p1)
    # TODO : affine

    let (p0 : G2Point) = multiply_clear_cofactor_g2(p0)

    # TODO : clear cofactor
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

func multiply_clear_cofactor_g2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p : G2Point) -> (
        res : G2Point):
    alloc_locals
    let (eff : Uint768) = get_eff()

    let (res : G2Point) = g2_lib.multiply(p, eff)

    return (res)
end
