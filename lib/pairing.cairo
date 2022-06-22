from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.fq12 import FQ12, fq12
from lib.g1 import G1Point
from lib.g2 import G2Point
from lib.uint384 import Uint384, uint384_lib
from lib.fq import fq_lib
from lib.fq2 import FQ2

# TODO rename this
struct GTPoint:
    member x : FQ12
    member y : FQ12
    member z : FQ12
end

func cast_point_to_fq12(pt : G1Point) -> (res : GTPoint):
    let zero = Uint384(d0=0, d1=0, d2=0)

    return (
        res=GTPoint(x=FQ12(e0=pt.x, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
        y=FQ12(e0=pt.y, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
        z=FQ12(e0=pt.z, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero)))
end

func line_func_gt{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        p1 : GTPoint, p2 : GTPoint, pt : GTPoint) -> (x : FQ12, y : FQ12):
    alloc_locals
    let (zero : FQ12) = fq12.zero()

    let (y_2_z_1) = fq12.mul(p2.y, p1.z)
    let (y_1_z_2) = fq12.mul(p1.y, p2.z)
    let (m_numerator : FQ12) = fq12.sub(y_2_z_1, y_1_z_2)

    let (x_2_z_1) = fq12.mul(p2.x, p1.z)
    let (x_1_z_2) = fq12.mul(p1.x, p2.z)
    let (m_denominator : FQ12) = fq12.sub(x_2_z_1, x_1_z_2)

    let (denom_eq_zero : felt) = fq12.eq(m_denominator, zero)

    if denom_eq_zero == 0:
        let (x_t_z_1) = fq12.mul(pt.x, p1.z)
        let (x_1_z_t) = fq12.mul(p1.x, pt.z)
        let (temp) = fq12.sub(x_t_z_1, x_1_z_t)
        let (numerator : FQ12) = fq12.mul(m_numerator, temp)

        let (y_t_z_1) = fq12.mul(pt.y, p1.z)
        let (y_1_z_t) = fq12.mul(p1.y, pt.z)
        let (temp) = fq12.sub(y_t_z_1, y_1_z_t)
        let (denominator : FQ12) = fq12.mul(m_denominator, temp)

        let (x) = fq12.sub(numerator, denominator)
        let (zt_z1) = fq12.mul(pt.z, p1.z)
        let (y) = fq12.mul(m_denominator, zt_z1)

        return (x, y)
    end

    let (num_eq_zero : felt) = fq12.eq(m_numerator, zero)

    if num_eq_zero == 1:
        let (x_1_x_1) = fq12.mul(p1.x, p1.x)
        let (three) = fq12.bit_128_to_fq12(3)
        let (m_numerator) = fq12.mul(a=x_1_x_1, b=three)

        let (y_1_z_1) = fq12.mul(p1.y, p1.z)
        let (two) = fq12.bit_128_to_fq12(2)
        let (m_denominator) = fq12.mul(a=y_1_z_1, b=two)

        let (x_t_z_1) = fq12.mul(pt.x, p1.z)
        let (x_1_z_t) = fq12.mul(p1.x, pt.z)
        let (temp) = fq12.sub(x_t_z_1, x_1_z_t)
        let (numerator : FQ12) = fq12.mul(m_numerator, temp)

        let (y_t_z_1) = fq12.mul(pt.y, p1.z)
        let (y_1_z_t) = fq12.mul(p1.y, pt.z)
        let (temp) = fq12.sub(y_t_z_1, y_1_z_t)
        let (denominator : FQ12) = fq12.mul(m_denominator, temp)

        let (x) = fq12.sub(numerator, denominator)
        let (zt_z1) = fq12.mul(pt.z, p1.z)
        let (y) = fq12.mul(m_denominator, zt_z1)

        return (x, y)
    end

    let (x_t_z_1) = fq12.mul(pt.x, p1.z)
    let (x_1_z_t) = fq12.mul(p1.x, pt.z)

    let (x) = fq12.sub(x_t_z_1, x_1_z_t)

    let (y) = fq12.mul(p1.z, pt.z)

    return (x, y)
end

# twist G2Point to GTPoint
func twist{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(pt : G2Point) -> (res : GTPoint):
    alloc_locals

    let (x_min_x_i : Uint384) = fq_lib.sub(pt.x.e0, pt.x.e1)
    let (y_min_y_i : Uint384) = fq_lib.sub(pt.y.e0, pt.y.e1)
    let (z_min_z_i : Uint384) = fq_lib.sub(pt.z.e0, pt.z.e1)

    let zero = Uint384(d0=0, d1=0, d2=0)
    return (
        res=GTPoint(x=FQ12(e0=zero, e1=x_min_x_i, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=pt.x.e1, e8=zero, e9=zero, e10=zero, e11=zero),
        y=FQ12(e0=y_min_y_i, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=pt.y.e1, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
        z=FQ12(e0=zero, e1=zero, e2=zero, e3=z_min_z_i, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=pt.z.e1, e10=zero, e11=zero)))
end
