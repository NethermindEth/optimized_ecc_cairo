from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.fq12 import FQ12
from lib.g1 import G1Point
from lib.uint384 import Uint384, uint384_lib
from lib.fq import fq_lib

struct G2PointFQ12:
    member x : FQ12
    member y : FQ12
    member z : FQ12
end

func cast_point_to_fq12(pt : G1Point) -> (res : G2PointFQ12):
    let zero = Uint384(d0=0, d1=0, d2=0)

    return (
        res=G2PointFQ12(x=FQ12(e0=pt.x, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
        y=FQ12(e0=pt.y, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
        z=FQ12(e0=pt.z, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero)))
end

func line_func_g1{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        p1 : G1Point, p2 : G1Point, pt : G1Point) -> (x : Uint384, y : Uint384):
    alloc_locals
    let zero : Uint384 = Uint384(d0=0, d1=0, d2=0)

    let (y_2_z_1) = fq_lib.mul(p2.y, p1.z)
    let (y_1_z_2) = fq_lib.mul(p1.y, p2.z)
    let (m_numerator : Uint384) = fq_lib.sub(y_2_z_1, y_1_z_2)

    let (x_2_z_1) = fq_lib.mul(p2.x, p1.z)
    let (x_1_z_2) = fq_lib.mul(p1.x, p2.z)
    let (m_denominator : Uint384) = fq_lib.sub(x_2_z_1, x_1_z_2)

    let (denom_eq_zero : felt) = uint384_lib.eq(m_denominator, zero)

    if denom_eq_zero == 0:
        let (x_t_z_1) = fq_lib.mul(pt.x, p1.z)
        let (x_1_z_t) = fq_lib.mul(p1.x, pt.z)
        let (temp) = fq_lib.sub(x_t_z_1, x_1_z_t)
        let (numerator : Uint384) = fq_lib.mul(m_numerator, temp)

        let (y_t_z_1) = fq_lib.mul(pt.y, p1.z)
        let (y_1_z_t) = fq_lib.mul(p1.y, pt.z)
        let (temp) = fq_lib.sub(y_t_z_1, y_1_z_t)
        let (denominator : Uint384) = fq_lib.mul(m_denominator, temp)

        let (x) = fq_lib.sub(numerator, denominator)
        let (zt_z1) = fq_lib.mul(pt.z, p1.z)
        let (y) = fq_lib.mul(m_denominator, zt_z1)

        return (x, y)
    end

    let (num_eq_zero : felt) = uint384_lib.eq(m_numerator, zero)

    if num_eq_zero == 1:
        %{ print("num is zero ") %}
        let (x_1_x_1) = fq_lib.square(p1.x)
        let (m_numerator) = fq_lib.mul(x=x_1_x_1, y=Uint384(d0=3, d1=0, d2=0))

        let (y_1_z_1) = fq_lib.mul(p1.y, p1.z)
        let (m_denominator) = fq_lib.mul(x=y_1_z_1, y=Uint384(d0=2, d1=0, d2=0))

        let (x_t_z_1) = fq_lib.mul(pt.x, p1.z)
        let (x_1_z_t) = fq_lib.mul(p1.x, pt.z)
        let (temp) = fq_lib.sub(x_t_z_1, x_1_z_t)
        let (numerator : Uint384) = fq_lib.mul(m_numerator, temp)

        let (y_t_z_1) = fq_lib.mul(pt.y, p1.z)
        let (y_1_z_t) = fq_lib.mul(p1.y, pt.z)
        let (temp) = fq_lib.sub(y_t_z_1, y_1_z_t)
        let (denominator : Uint384) = fq_lib.mul(m_denominator, temp)

        let (x) = fq_lib.sub(numerator, denominator)
        let (zt_z1) = fq_lib.mul(pt.z, p1.z)
        let (y) = fq_lib.mul(m_denominator, zt_z1)

        return (x, y)
    end

    let (x_t_z_1) = fq_lib.mul(pt.x, p1.z)
    let (x_1_z_t) = fq_lib.mul(p1.x, pt.z)

    let (x) = fq_lib.sub(x_t_z_1, x_1_z_t)

    let (y) = fq_lib.mul(p1.z, pt.z)

    return (x, y)
end
