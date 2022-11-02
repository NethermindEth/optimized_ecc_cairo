from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.uint384 import Uint384, Uint384_expand, uint384_lib
from lib.field_arithmetic_new import field_arithmetic
from curve_new import get_modulus_expand
from lib.fq_new import fq_lib

// Alternative coordinate representation : a triple (X,Y,Z) represents a solution to Z*Y^2=X^3+4Z^3
// To go back to affine coordinates perform x = x / z  and y = y / z 
struct G1Point {
    x: Uint384,
    y: Uint384,
    z: Uint384,
}

namespace g1_lib {
    func is_point_at_infinity{range_check_ptr}(point: G1Point) -> (bool: felt) {
        let (is_z_coord_zero) = uint384_lib.is_zero(point.z);
        return (is_z_coord_zero,);
    }

    // Following `py_ecc` for these functions.

    func eq{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(p1: G1Point, p2: G1Point) -> (
        bool: felt
    ) {
        alloc_locals;
        let (is_p1_infinity) = is_point_at_infinity(p1);
        let (is_p2_infinity) = is_point_at_infinity(p2);
        if (is_p1_infinity == 1) {
            if (is_p2_infinity == 1) {
                return (1,);
            } else {
                return (0,);
            }
        } else {
            if (is_p2_infinity == 1) {
                return (0,);
            }
        }
        // TODO: can be done without normalizing, using multiplication instead of division
        // None of the point is the point at infinity
        let (p1_x: Uint384, p1_y: Uint384) = normalize(p1);
        let (p2_x: Uint384, p2_y: Uint384) = normalize(p2);
        let (is_x_coord_eq) = uint384_lib.eq(p1_x, p2_x);
        if (is_x_coord_eq == 0) {
            return (0,);
        }
        let (is_y_coord_eq) = uint384_lib.eq(p1_y, p2_y);
        if (is_y_coord_eq == 0) {
            return (0,);
        }
        return (1,);
    }

    //Rewriting eq to use multiplication instead of division. 
    func eq_new{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(p1: G1Point, p2: G1Point) -> (
        bool: felt
    ) {
        alloc_locals;
        let (is_p1_infinity) = is_point_at_infinity(p1);
        let (is_p2_infinity) = is_point_at_infinity(p2);
        if (is_p1_infinity == 1) {
            if (is_p2_infinity == 1) {
                return (1,);
            } else {
                return (0,);
            }
        } else {
            if (is_p2_infinity == 1) {
                return (0,);
            }
        }
        let (p_expand : Uint384_expand) = get_modulus_expand();

        let (p1_x: Uint384) = field_arithmetic.mul(p1.x, p2.z, p_expand);
        let (p1_y: Uint384) = field_arithmetic.mul(p1.y, p2.z, p_expand);
        let (p2_x: Uint384) = field_arithmetic.mul(p2.x, p1.z, p_expand);
        let (p2_y: Uint384) = field_arithmetic.mul(p2.y, p1.z, p_expand);
        
        let (is_x_coord_eq) = uint384_lib.eq(p1_x, p2_x);
        if (is_x_coord_eq == 0) {
            return (0,);
        }
        let (is_y_coord_eq) = uint384_lib.eq(p1_y, p2_y);
        if (is_y_coord_eq == 0) {
            return (0,);
        }
        return (1,);
    }

    // Addition optimized for the curve y**2 = x**3 + 4 using alternative coordinate representation
    // Made it such that it has as fewer modulus expansion as possible.
    // Used sub_three_terms_no_input_check where it was possible
    func add{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(p1: G1Point, p2: G1Point) -> (
        res: G1Point
    ) {
        alloc_locals;
        let (p_expand:Uint384_expand) = get_modulus_expand();
        let (is_p1_z_coord_zero) = uint384_lib.is_zero(p1.z);
        if (is_p1_z_coord_zero == 1) {
            return (p2,);
        }
        let (is_p2_z_coord_zero) = uint384_lib.is_zero(p2.z);
        if (is_p2_z_coord_zero == 1) {
            return (p1,);
        }

        let (U1: Uint384) = field_arithmetic.mul(p2.y, p1.z, p_expand);
        let (U2: Uint384) = field_arithmetic.mul(p1.y, p2.z, p_expand);

        let (local V1: Uint384) = field_arithmetic.mul(p2.x, p1.z, p_expand);
        let (V2: Uint384) = field_arithmetic.mul(p1.x, p2.z);

        let (is_v1_eq_v2) = uint384_lib.eq(V1, V2);
        let (is_u1_eq_u2) = uint384_lib.eq(U1, U2);

        if (is_v1_eq_v2 == 1) {
            if (is_u1_eq_u2 == 1) {
                let (double_p1: G1Point) = double(p1);
                return (double_p1,);
            } else {
                let one: Uint384 = Uint384(d0=1, d1=0, d2=0);
                let zero: Uint384 = Uint384(d0=0, d1=0, d2=0);
                // Point at infinity
                let res = G1Point(one, one, zero);
                return (res,);
            }
        }

        let (U: Uint384) = fq_lib.sub1(U1, U2);
        let (V: Uint384) = fq_lib.sub1(V1, V2);
        let (V_squared: Uint384) = field_arithmetic.square(V, p_expand);
        let (V_squared_times_V2: Uint384) = field_arithmetic.mul(V_squared, V2, p_expand);
        let (V_cubed: Uint384) = field_arithmetic.mul(V, V_squared, p_expand);
        let (W: Uint384) = field_arithmetic.mul(p1.z, p2.z, p_expand);
        let (U_squared:Uint384) = field_arithmetic.square(U, p_expand);
        let (U_squared_times_W: Uint384) = field_arithmetic.mul(U_squared, W, p_expand);
        let (twice_V_squared_times_V2: Uint384) = fq_lib.scalar_mul4(2, V_squared_times_V2);
        //field_arithmetic.mul always outputs integers less than p
        let (A: Uint384) = fq_lib.sub_three_terms_no_input_check(
            U_squared_times_W, V_cubed, twice_V_squared_times_V2
        );

        let (new_x: Uint384) = field_arithmetic.mul(V, A, p_expand);

        // newy = U * (V_squared_times_V2 - A) - V_cubed * U2
        //fq_lib.sub_three_terms_no_input_check always outputs an integer less than p
        let (V_squared_times_V2_sub_A: Uint384) = fq_lib.sub_three_terms_no_input_check(V_squared_times_V2, A);
        let (inner_term_1: Uint384) = field_arithmetic.mul(U, V_squared_times_V2_sub_A, p_expand);
        let (inner_term_2: Uint384) = field_arithmetic.mul(V_cubed, U2, p_expand);
        //field_arithmetic.mul always outputs integers less than p
        let (new_y: Uint384) = fq_lib.sub_three_terms_no_input_check(inner_term_1, inner_term_2);

        let (new_z: Uint384) = field_arithmetic.mul(V_cubed, W, p_expand);

        return (G1Point(new_x, new_y, new_z),);
    }

    // Computes `point + point`
    func double{bitwise_ptr: BitwiseBuiltin*, range_check_ptr}(point: G1Point) -> (res: G1Point) {
        alloc_locals;
        let (p_expand:Uint384_expand) = get_modulus_expand();
        let (W: Uint384) = field_arithmetic.square(point.x, p_expand);
        let (W: Uint384) = fq_lib.scalar64_mul(3, W);
        let (S: Uint384) = field_arithmetic.mul(point.y, point.z, p_expand);
        let (B: Uint384) = field_arithmetic.mul(point.x, point.y, p_expand);
        let (B: Uint384) = field_arithmetic.mul(S, B, p_expand);

        let (W_squared: Uint384) = field_arithmetic.square(W, p_expand);
        let (eight_times_B: Uint384) = fq_lib.scalar64_mul(8, B);
        //field_arithmetic.square and fq_lib.scalar64_mul both ouput integers less than p
        let (H: Uint384) = fq_lib.sub_three_terms_no_input_check(W_squared, eight_times_B);

        // Compute new_x
        let (H_times_S: Uint384) = field_arithmetic.mul(H, S, p_expand);
        let (new_x: Uint384) = fq_lib.scalar64_mul(2, H_times_S);

        // Compute new_y
        let (S_squared: Uint384) = field_arithmetic.square(S, p_expand);
        let (pointy_squared:Uint384) = field_arithmetic.square(point.y, p_expand);
        let (aux_inner_term_2: Uint384) = field_arithmetic.mul(pointy_squared, S_squared, p_expand);
        let (inner_term_2: Uint384) = fq_lib.scalar64_mul(8, aux_inner_term_2);
        let (four_times_B: Uint384) = fq_lib.scalar64_mul(4, B);

        let (four_times_B_sub_H: Uint384) = fq_lib.sub1(four_times_B, H);
        let (inner_term_1: Uint384) = field_arithmetic.mul(W, four_times_B_sub_H, p_expand);
        let (new_y: Uint384) = fq_lib.sub1(inner_term_1, inner_term_2);

        // Compute new_z
        let (S_cubed: Uint384) = field_arithmetic.mul(S, S_squared, p_expand);
        let (new_z: Uint384) = fq_lib.scalar64_mul(8, S_cubed);

        return (G1Point(new_x, new_y, new_z),);
    }

    // Computes scalar * point, which means point added with itself `scalar` times
    func scalar_mul{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(
        scalar: Uint384, point: G1Point
    ) -> (res: G1Point) {
        alloc_locals;

        let (local is_scalar_zero) = uint384_lib.eq(scalar, Uint384(0, 0, 0));
        let (local is_scalar_one) = uint384_lib.eq(scalar, Uint384(1, 0, 0));

        if (is_scalar_zero == 1) {
            return get_zero();
        }
        if (is_scalar_one == 1) {
            return (point,);
        }
        let (double_point: G1Point) = double(point);
        let (quotient: Uint384, remainder: Uint384) = uint384_lib.unsigned_div_rem(
            scalar, Uint384(2, 0, 0)
        );

        let (is_remainder_zero) = uint384_lib.eq(remainder, Uint384(0, 0, 0));
        if (is_remainder_zero == 0) {
            let (quotient_mul_double_point: G1Point) = scalar_mul(quotient, double_point);
            return (quotient_mul_double_point,);
        } else {
            // Repeating code to avoid using local variables
            let (quotient_mul_double_point: G1Point) = scalar_mul(quotient, double_point);
            let (res: G1Point) = add(point, quotient_mul_double_point);
            return (res,);
        }
    }

    // TODO: Not tested
    func get_zero{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}() -> (res: G1Point) {
        let one: Uint384 = Uint384(d0=1, d1=0, d2=0);
        let zero: Uint384 = Uint384(d0=0, d1=0, d2=0);
        return (G1Point(x=one, y=one, z=zero),);
    }

    // TODO: Not tested
    // Transforms (x,y,z) into (x/z, y/z) assuming z != 0, i.e. (x,y,z) != point_at_infinity
    // expands modulus only once
    func normalize{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(point: G1Point) -> (
        normalized_x: Uint384, normalized_y: Uint384
    ) {
        alloc_locals;
        let (p_expand : Uint384_expand) = get_modulus_expand();
        let (bool) = is_point_at_infinity(point);
        assert bool = 0;
        let (z_inverse: Uint384) = field_arithmetic.div_b(Uint384(1,0,0), point.z, p_expand);
        let (normalized_x: Uint384) = field_arithmetic.mul(point.x, z_inverse, p_expand);
        let (normalized_y: Uint384) = field_arithmetic.mul(point.y, z_inverse, p_expand);
        return (normalized_x, normalized_y);
    }

    // TODO: Not tested
    // Check that a point is on the curve defined by y**2 = x**3 + 4
    // only one expansion of the modulus
    func is_on_curve{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(point: G1Point) -> (
        bool: felt
    ) {
        alloc_locals;
        let (p_expand : Uint384_expand) = get_modulus_expand();
        let (_is_point_at_infinity) = is_point_at_infinity(point);
        if (_is_point_at_infinity == 1) {
            return (1,);
        }
        let (x_normalized: Uint384, y_normalized: Uint384) = normalize(point);
        let (y_square) = field_arithmetic.square(y_normalized, p_expand);
        let (x_cubed) = field_arithmetic.cube(x_normalized, p_expand);
        let four = Uint384(4, 0, 0);
        //field_arithmetic functions return integers less than p, and four is less than p
        let (res) = fq_lib.sub_three_terms_no_input_check(y_square, x_cubed, four);
        let (is_res_zero) = uint384_lib.is_zero(res);
        return (is_res_zero,);
    }

    //avoids making divisions
    //apparently worse, but I don't understand why: 1 squaring, 2 cubings, 1 mul and 1 mul_expanded + 1 sub3terms should take less steps 
    //than the original function which has 1 division, 2 mul, 1 squaring and 1 cubing + 1 sub3terms.
    func is_on_curve_new{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(point: G1Point) -> (
        bool: felt
    ) {
        alloc_locals;
        let (p_expand : Uint384_expand) = get_modulus_expand();
        let (_is_point_at_infinity) = is_point_at_infinity(point);
        if (_is_point_at_infinity == 1) {
            return (1,);
        }
        let (y_square:Uint384) = field_arithmetic.square(point.y, p_expand);
        let (y_square_times_z:Uint384) = field_arithmetic.mul(y_square, point.z, p_expand);
        let (x_cubed:Uint384) = field_arithmetic.cube(point.x, p_expand);
        let (z_cubed:Uint384) = field_arithmetic.cube(point.z, p_expand);
        let (four_z_cubed:Uint384) = field_arithmetic.mul_expanded(z_cubed, Uint384_expand(73786976294838206464,4,0,0,0,0,0), p_expand);
        //everything is less than p
        let (res) = fq_lib.sub_three_terms_no_input_check(y_square_times_z, x_cubed, four_z_cubed);
        let (is_res_zero) = uint384_lib.is_zero(res);
        return (is_res_zero,);
    }
}