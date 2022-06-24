from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.fq12 import FQ12, fq12
from lib.g1 import G1Point
from lib.g2 import G2Point, g2_lib
from lib.uint384 import Uint384, uint384_lib
from lib.fq import fq_lib
from lib.fq2 import FQ2
from starkware.cairo.common.registers import get_label_location

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
    %{ print("line func starting") %}
    let (y_2_z_1) = fq12.mul(p2.y, p1.z)
    let (y_1_z_2) = fq12.mul(p1.y, p2.z)
    let (m_numerator : FQ12) = fq12.sub(y_2_z_1, y_1_z_2)

    let (x_2_z_1) = fq12.mul(p2.x, p1.z)
    let (x_1_z_2) = fq12.mul(p1.x, p2.z)
    let (m_denominator : FQ12) = fq12.sub(x_2_z_1, x_1_z_2)

    let (denom_eq_zero : felt) = fq12.eq(m_denominator, zero)
    %{ print("denom is", ids.denom_eq_zero) %}
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
    %{ print("num is", ids.num_eq_zero) %}
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

# currently no final exponentiation
func miller_loop{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(q : G2Point, p : G1Point) -> (
        f_num : FQ12, f_den : FQ12):
    alloc_locals
    %{ print("start miller loop") %}
    let (cast_p : GTPoint) = cast_point_to_fq12(p)
    let (twist_r : GTPoint) = twist(q)
    let twist_q = twist_r
    %{ print("done twisting") %}
    let r = q
    let (f_num : FQ12) = fq12.bit_128_to_fq12(1)
    let (f_den : FQ12) = fq12.bit_128_to_fq12(1)
    %{ print("entering ate loop") %}
    let (twist_r, f_num, f_den, r) = ate_loop(twist_r, twist_q, cast_p, f_num, f_den, r, q, 1)
    %{ print("exiting ate loop") %}
    return (f_num, f_den)
end

func get_loop_count_bits(index : felt) -> (bits : felt):
    let (data) = get_label_location(bits)
    let bit_array = cast(data, felt*)
    return (bit_array[index])

    bits:
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 1
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 1
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 0
    dw 1
    dw 0
    dw 0
    dw 1
    dw 0
    dw 1
    dw 1
end

func ate_loop{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        twist_r : GTPoint, twist_q : GTPoint, cast_p : GTPoint, f_num : FQ12, f_den : FQ12,
        r : G2Point, q : G2Point, n : felt) -> (
        twist_r : GTPoint, f_num : FQ12, f_den : FQ12, r : G2Point):
    %{ print("ate loop ", ids.n) %}
    if n == 0:
        %{ print("ate loop finishing at 0 ") %}
        let (v) = get_loop_count_bits(n)
        let (twist_r, f_num, f_den, r) = ate_loop_inner(
            twist_r, twist_q, cast_p, f_num, f_den, r, q, v)
        %{ print("returning ate loop") %}
        return (twist_r, f_num, f_den, r)
    end
    %{ print("ate loop continuing ") %}
    let (v) = get_loop_count_bits(n)
    let (twist_r, f_num, f_den, r) = ate_loop_inner(twist_r, twist_q, cast_p, f_num, f_den, r, q, v)
    let (v) = get_loop_count_bits(n)
    let (twist_r, f_num, f_den, r) = ate_loop(twist_r, twist_q, cast_p, f_num, f_den, r, q, n - 1)
    return (twist_r, f_num, f_den, r)
end

func ate_loop_inner{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        twist_r : GTPoint, twist_q : GTPoint, cast_p : GTPoint, f_num : FQ12, f_den : FQ12,
        r : G2Point, q : G2Point, v : felt) -> (
        twist_r : GTPoint, f_num : FQ12, f_den : FQ12, r : G2Point):
    alloc_locals
    %{ print("ate loop inner ") %}
    let (_n, _d) = line_func_gt(twist_r, twist_r, cast_p)
    %{ print("finish gt line func ") %}
    let (f_num) = fq12.mul(f_num, f_num)
    let (f_den) = fq12.mul(f_den, f_den)

    let (r) = g2_lib.double(r)

    let (twist_r) = twist(r)
    %{ print("entering v ", ids.v) %}
    if v == 1:
        %{ print("entering gt line func 2 ") %}
        let (_n, _d) = line_func_gt(twist_r, twist_q, cast_p)
        %{ print("finish gt line func 2 ") %}
        let (f_num) = fq12.mul(f_num, _n)
        let (f_den) = fq12.mul(f_den, _d)

        let (r) = g2_lib.add(r, q)

        let (twist_r) = twist(r)
        return (twist_r=twist_r, f_num=f_num, f_den=f_den, r=r)
    end
    %{ print("returning " ) %}
    return (twist_r=twist_r, f_num=f_num, f_den=f_den, r=r)
end
