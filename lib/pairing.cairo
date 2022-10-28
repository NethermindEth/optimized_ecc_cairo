from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.fq12 import FQ12, fq12_lib
from lib.g1 import G1Point, g1_lib
from lib.g2 import G2Point, g2_lib
from lib.uint384 import Uint384, uint384_lib
from lib.fq import fq_lib
from lib.fq2 import FQ2, fq2_lib
from lib.uint384_extension import Uint768
from starkware.cairo.common.registers import get_label_location


struct GTPoint {
    x: FQ12,
    y: FQ12,
    z: FQ12,
}

namespace pairing_lib {
    func pairing{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(Q: G2Point, P: G1Point) -> (res: FQ12) {
        alloc_locals;
        //let (is_Q_on_curve) = g2_lib.is_on_curve(Q);
        //assert is_Q_on_curve = 1;
        //let (is_P_on_curve) = g1_lib.is_on_curve(P);
        //assert is_P_on_curve = 1;

        let (is_P_point_at_infinity) = g1_lib.is_point_at_infinity(P);
        if (is_P_point_at_infinity == 1) {
            let (one: FQ12) = fq12_lib.one();
            return (one,);
        }

        let (is_Q_point_at_infinity) = g2_lib.is_point_at_infinity(Q);
        if (is_Q_point_at_infinity == 1) {
            let (one: FQ12) = fq12_lib.one();
            return (one,);
        }

        let (res: FQ12) = miller_loop(Q, P);

        return (res,);
    }

    func cast_point_to_fq12{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(pt: G1Point) -> (res: GTPoint) {
        let zero = Uint384(d0=0, d1=0, d2=0);

        return (
            res=GTPoint(x=FQ12(e0=pt.x, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
            y=FQ12(e0=pt.y, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
            z=FQ12(e0=pt.z, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero)),
        );
    }

    func line_func_gt{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
        p1: GTPoint, p2: GTPoint, pt: GTPoint
    ) -> (x: FQ12, y: FQ12) {
        alloc_locals;
        let (zero: FQ12) = fq12_lib.zero();

        let (y_2_z_1) = fq12_lib.mul(p2.y, p1.z);
        let (y_1_z_2) = fq12_lib.mul(p1.y, p2.z);
        let (m_numerator: FQ12) = fq12_lib.sub(y_2_z_1, y_1_z_2);

        let (x_2_z_1) = fq12_lib.mul(p2.x, p1.z);
        let (x_1_z_2) = fq12_lib.mul(p1.x, p2.z);
        let (m_denominator: FQ12) = fq12_lib.sub(x_2_z_1, x_1_z_2);

        let (denom_eq_zero: felt) = fq12_lib.eq(m_denominator, zero);

        if (denom_eq_zero == 0) {
            let (x_t_z_1) = fq12_lib.mul(pt.x, p1.z);
            let (x_1_z_t) = fq12_lib.mul(p1.x, pt.z);
            let (temp) = fq12_lib.sub(x_t_z_1, x_1_z_t);
            let (numerator: FQ12) = fq12_lib.mul(m_numerator, temp);

            let (y_t_z_1) = fq12_lib.mul(pt.y, p1.z);
            let (y_1_z_t) = fq12_lib.mul(p1.y, pt.z);
            let (temp) = fq12_lib.sub(y_t_z_1, y_1_z_t);
            let (denominator: FQ12) = fq12_lib.mul(m_denominator, temp);

            let (x) = fq12_lib.sub(numerator, denominator);
            let (zt_z1) = fq12_lib.mul(pt.z, p1.z);
            let (y) = fq12_lib.mul(m_denominator, zt_z1);

            return (x, y);
        }

        let (num_eq_zero: felt) = fq12_lib.eq(m_numerator, zero);

        if (num_eq_zero == 1) {
            let (x_1_x_1) = fq12_lib.mul(p1.x, p1.x);
            let (three) = fq12_lib.bit_128_to_fq12(3);
            let (m_numerator) = fq12_lib.mul(a=x_1_x_1, b=three);

            let (y_1_z_1) = fq12_lib.mul(p1.y, p1.z);
            let (two) = fq12_lib.bit_128_to_fq12(2);
            let (m_denominator) = fq12_lib.mul(a=y_1_z_1, b=two);

            let (x_t_z_1) = fq12_lib.mul(pt.x, p1.z);
            let (x_1_z_t) = fq12_lib.mul(p1.x, pt.z);
            let (temp) = fq12_lib.sub(x_t_z_1, x_1_z_t);
            let (numerator: FQ12) = fq12_lib.mul(m_numerator, temp);

            let (y_t_z_1) = fq12_lib.mul(pt.y, p1.z);
            let (y_1_z_t) = fq12_lib.mul(p1.y, pt.z);
            let (temp) = fq12_lib.sub(y_t_z_1, y_1_z_t);
            let (denominator: FQ12) = fq12_lib.mul(m_denominator, temp);

            let (x) = fq12_lib.sub(numerator, denominator);
            let (zt_z1) = fq12_lib.mul(pt.z, p1.z);
            let (y) = fq12_lib.mul(m_denominator, zt_z1);

            return (x, y);
        }

        let (x_t_z_1) = fq12_lib.mul(pt.x, p1.z);
        let (x_1_z_t) = fq12_lib.mul(p1.x, pt.z);

        let (x) = fq12_lib.sub(x_t_z_1, x_1_z_t);

        let (y) = fq12_lib.mul(p1.z, pt.z);

        return (x, y);
    }

    func miller_loop{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(q: G2Point, p: G1Point) -> (
        f: FQ12
    ) {
        alloc_locals;
        let (cast_p: GTPoint) = cast_point_to_fq12(p);
        let (twist_r: GTPoint) = twist(q);
        let twist_q = twist_r;
        let r = q;
        let (f_num: FQ12) = fq12_lib.bit_128_to_fq12(1);
        let (f_den: FQ12) = fq12_lib.bit_128_to_fq12(1);
        let (twist_r, f_num, f_den, r) = ate_loop(twist_r, twist_q, cast_p, f_num, f_den, r, q, 62);

        let (inv_den) = fq12_lib.inverse(f_den);
        let (f) = fq12_lib.mul(f_num, f_den);
        let (final_exponent) = final_exponentiation(f);
        return (final_exponent,);
    }

    func get_loop_count_bits{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(index: felt) -> (bits: felt) {
        let (data) = get_label_location(bits);
        let bit_array = cast(data, felt*);
        return (bit_array[index],);

        bits:
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 1;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 1;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 0;
        dw 1;
        dw 0;
        dw 0;
        dw 1;
        dw 0;
        dw 1;
        dw 1;
    }

    func ate_loop{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
        twist_r: GTPoint,
        twist_q: GTPoint,
        cast_p: GTPoint,
        f_num: FQ12,
        f_den: FQ12,
        r: G2Point,
        q: G2Point,
        n: felt,
    ) -> (twist_r: GTPoint, f_num: FQ12, f_den: FQ12, r: G2Point) {
        if (n == 0) {
            let (v) = get_loop_count_bits(n);
            let (twist_r, f_num, f_den, r) = ate_loop_inner(
                twist_r, twist_q, cast_p, f_num, f_den, r, q, v
            );
            return (twist_r, f_num, f_den, r);
        }
        let (v) = get_loop_count_bits(n);
        let (twist_r, f_num, f_den, r) = ate_loop_inner(
            twist_r, twist_q, cast_p, f_num, f_den, r, q, v
        );
        let (v) = get_loop_count_bits(n);
        let (twist_r, f_num, f_den, r) = ate_loop(
            twist_r, twist_q, cast_p, f_num, f_den, r, q, n - 1
        );
        return (twist_r, f_num, f_den, r);
    }

    func ate_loop_inner{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
        twist_r: GTPoint,
        twist_q: GTPoint,
        cast_p: GTPoint,
        f_num: FQ12,
        f_den: FQ12,
        r: G2Point,
        q: G2Point,
        v: felt,
    ) -> (twist_r: GTPoint, f_num: FQ12, f_den: FQ12, r: G2Point) {
        alloc_locals;
        let (_n, _d) = line_func_gt(twist_r, twist_r, cast_p);
        let (f_num) = fq12_lib.mul(f_num, f_num);
        let (f_den) = fq12_lib.mul(f_den, f_den);

        let (r) = g2_lib.double(r);

        let (twist_r) = twist(r);
        if (v == 1) {
            let (_n, _d) = line_func_gt(twist_r, twist_q, cast_p);
            let (f_num) = fq12_lib.mul(f_num, _n);
            let (f_den) = fq12_lib.mul(f_den, _d);

            let (r) = g2_lib.add(r, q);

            let (twist_r) = twist(r);
            return (twist_r=twist_r, f_num=f_num, f_den=f_den, r=r);
        }
        return (twist_r=twist_r, f_num=f_num, f_den=f_den, r=r);
    }

    func twist{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(pt: G2Point) -> (res: GTPoint) {
        alloc_locals;

        let (x_min_x_i: Uint384) = fq_lib.sub(pt.x.e0, pt.x.e1);
        let (y_min_y_i: Uint384) = fq_lib.sub(pt.y.e0, pt.y.e1);
        let (z_min_z_i: Uint384) = fq_lib.sub(pt.z.e0, pt.z.e1);

        let zero = Uint384(d0=0, d1=0, d2=0);
        return (
            res=GTPoint(x=FQ12(e0=zero, e1=x_min_x_i, e2=zero, e3=zero, e4=zero, e5=zero, e6=zero, e7=pt.x.e1, e8=zero, e9=zero, e10=zero, e11=zero),
            y=FQ12(e0=y_min_y_i, e1=zero, e2=zero, e3=zero, e4=zero, e5=zero, e6=pt.y.e1, e7=zero, e8=zero, e9=zero, e10=zero, e11=zero),
            z=FQ12(e0=zero, e1=zero, e2=zero, e3=z_min_z_i, e4=zero, e5=zero, e6=zero, e7=zero, e8=zero, e9=pt.z.e1, e10=zero, e11=zero)),
        );
    }

    func exp_by_p{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x: FQ12) -> (res: FQ12) {
        alloc_locals;

            // `exptable` from py_ecc is a list with the following 12 FQ12 elements:
    let e0 = FQ12(
        Uint384(1, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e1 = FQ12(
        Uint384(0, 0, 0),
        Uint384(274243053906794192660971146501192881349, 248839457052582084733310592988125363557, 31946044062400126443559943033936702822),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(53404613921891904407638817938926750451, 112492562243608534660185144806281198687, 1309719741507389812614626496439361464),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );

    let e2 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(295212420428148721612832019131314143231, 247785614890663281114179789873493874312, 6852621763331149393),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(85839861322429279863416763247732239020, 226038966649135872939501092727193886619, 34565483545414906061936574263484276357),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e3 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(316894176541198687613159979572632210441, 96002276489854850962923926559567004101, 8884304212930445318911794655404326910),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e4 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(85839861322429279863416763247732239021, 226038966649135872939501092727193886619, 34565483545414906061936574263484276357),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e5 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(186696758317675102947667715835642708524, 307301795413431096068852170938339822285, 15149168942846111012594336317929930891),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(117562719131271218270727620745340922261, 150032500372614374287567493415633744061, 26990899073991850562492027867850460305),
    );
    let e6 = FQ12(
        Uint384(2, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(40769914829639538012874174947278170794, 133542214618860690590306275168919549476, 34565483545414906068789196026815425751),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e7 = FQ12(
        Uint384(0, 0, 0),
        Uint384(274243053906794192660971146501192881349, 248839457052582084733310592988125363557, 31946044062400126443559943033936702822),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(106809227843783808815277635877853500902, 224985124487217069320370289612562397374, 2619439483014779625229252992878722928),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e8 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(85839861322429279863416763247732239020, 226038966649135872939501092727193886619, 34565483545414906061936574263484276357),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e9 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(293505986161458911762945351713496209426, 192004552979709701925847853119134008203, 17768608425860890637823589310808653820),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
    );
    let e10 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(130909807815219021713959351548186307247, 318535718679411055288695910285468223762, 34565483545414906055083952500153126963),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(295212420428148721612832019131314143230, 247785614890663281114179789873493874312, 6852621763331149393),
        Uint384(0, 0, 0),
    );
    let e11 = FQ12(
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(186696758317675102947667715835642708524, 307301795413431096068852170938339822285, 15149168942846111012594336317929930891),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(0, 0, 0),
        Uint384(194355523432902898528581066543403673727, 166522786126368057984828711662347938646, 19416314602568795056194859708885494859),
    );
        let (aux0: FQ12) = fq12_lib.scalar_mul_uint384(x.e0, e0);
        let (aux1: FQ12) = fq12_lib.scalar_mul_uint384(x.e1, e1);
        let (res: FQ12) = fq12_lib.add(aux0, aux1);
        let (aux0: FQ12) = fq12_lib.scalar_mul_uint384(x.e2, e2);
        let (aux1: FQ12) = fq12_lib.scalar_mul_uint384(x.e3, e3);
        let (res: FQ12) = fq12_lib.add(aux0, aux1);
        let (aux0: FQ12) = fq12_lib.scalar_mul_uint384(x.e4, e4);
        let (aux1: FQ12) = fq12_lib.scalar_mul_uint384(x.e5, e5);
        let (res: FQ12) = fq12_lib.add(aux0, aux1);
        let (aux0: FQ12) = fq12_lib.scalar_mul_uint384(x.e6, e6);
        let (aux1: FQ12) = fq12_lib.scalar_mul_uint384(x.e7, e7);
        let (res: FQ12) = fq12_lib.add(aux0, aux1);
        let (aux0: FQ12) = fq12_lib.scalar_mul_uint384(x.e8, e8);
        let (aux1: FQ12) = fq12_lib.scalar_mul_uint384(x.e9, e9);
        let (res: FQ12) = fq12_lib.add(aux0, aux1);
        let (aux0: FQ12) = fq12_lib.scalar_mul_uint384(x.e10, e10);
        let (aux1: FQ12) = fq12_lib.scalar_mul_uint384(x.e11, e11);
        let (res: FQ12) = fq12_lib.add(aux0, aux1);
        return (res,);
    }

    func final_exponentiation{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x: FQ12) -> (res: FQ12) {
        alloc_locals;
        // Compute p2 (in py_ecc's notation)
        let (first_exp_by_p: FQ12) = exp_by_p(x);
        let (second_exp_by_p: FQ12) = exp_by_p(first_exp_by_p);
        let (p2: FQ12) = fq12_lib.mul(second_exp_by_p, x);

        // Compute p3
        let (third_exp_by_p: FQ12) = exp_by_p(p2);
        let (fourth_exp_by_p: FQ12) = exp_by_p(third_exp_by_p);
        let (fifth_exp_by_p: FQ12) = exp_by_p(fourth_exp_by_p);
        let (sixth_exp_by_p: FQ12) = exp_by_p(fifth_exp_by_p);
        let (seventh_exp_by_p: FQ12) = exp_by_p(sixth_exp_by_p);
        let (p3: FQ12) = exp_by_p(seventh_exp_by_p);

        // Compute p3 / p2
        // TODO: Currently the ivnerse method of fq12_lib is a DUMMY just for compilation purposes
        let (p2_inverse: FQ12) = fq12_lib.inverse(p2);
        let (p3: FQ12) = fq12_lib.mul(p3, p2_inverse);

        // TODO: Since `cofactor` is fixed, we could "hardcode" this exponentiation

        let cofactor = Uint768(
            333101798987699541459238279636142242425,
            264652144914178275364921379528999000936,
            44951674857880233365469211788470342856,
            0,0,0
        );

        let (res: FQ12) = fq12_lib.pow(p3, cofactor);
        return (res,);
    }
}