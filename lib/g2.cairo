from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.uint384 import Uint384
from lib.fq import fq_lib
from lib.fq2 import FQ2, fq2_lib

# Jacobian coordinate representation
# To retrive normal cordinates perform x = x / z ^ 2 and y = y / z ^ 3
struct G2Point:
    member x : FQ2
    member y : FQ2
    member z : FQ2
end

namespace g2_lib:
    func is_point_at_infinity(point : G2Point) -> (bool : felt):
        let (is_z_coord_zero) = fq2_lib.is_zero(point.z)
        return (is_z_coord_zero)
    end

    # Following `py_ecc` for these functions.
    # TODO: For G1 we used a different (but equivalent) version of addition. Should we uniformize?

    func eq{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p1 : G2Point, p2 : G2Point) -> (
        bool : felt
    ):
        alloc_locals
        let (local p1_x_times_z: FQ2) = fq2_lib.mul(p1.x, p1.z)
        let (p2_x_times_z: FQ2) = fq2_lib.mul(p2.x, p2.z)
        let (is_x_coord_eq) = fq2_lib.eq(p1_x_times_z, p2_x_times_z)
        if is_x_coord_eq == 0:
            return (0)
        end
        let (p1_y_times_z: FQ2) = fq2_lib.mul(p1.y, p1.z)
        let (p2_y_times_z: FQ2) = fq2_lib.mul(p2.y, p2.z)
        let (is_y_coord_eq) = fq2_lib.eq(p1_y_times_z, p2_y_times_z)
        if is_y_coord_eq == 0:
            return (0)
        end
        return (1)
    end

    # Addition optimized for the curve y**2 = x**3 + 4 using Jacobian coordinate representation
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p1 : G2Point, p2 : G2Point) -> (
        res : G2Point
    ):
        alloc_locals
        let (is_p1_z_coord_zero) = fq2_lib.is_zero(p1.z)
        if is_p1_z_coord_zero == 1:
            return (p2)
        end
        let (is_p2_z_coord_zero) = fq2_lib.is_zero(p2.z)
        if is_p2_z_coord_zero == 1:
            return (p1)
        end

        let (U1 : FQ2) = fq2_lib.mul(p2.y, p1.z)
        let (U2 : FQ2) = fq2_lib.mul(p1.y, p2.z)

        let (local V1 : FQ2) = fq2_lib.mul(p2.x, p1.z)
        let (V2 : FQ2) = fq2_lib.mul(p1.x, p2.z)

        let (is_v1_eq_v2) = fq2_lib.eq(V1, V2)
        let (is_u1_eq_u2) = fq2_lib.eq(U1, U2)
        if is_v1_eq_v2 == 1:
            if is_u1_eq_u2 == 1:
                let (double_p1 : G2Point) = double(p1)
                return (double_p1)
            else:
                let (one : FQ2) = fq2_lib.get_one()
                let (zero : FQ2) = fq2_lib.get_zero()
                # Point at infinity
                let res = G2Point(one, one, zero)
                return (res)
            end
        end

        let (U : FQ2) = fq2_lib.sub(U1, U2)
        let (V : FQ2) = fq2_lib.sub(V1, V2)
        let (V_squared : FQ2) = fq2_lib.mul(V, V)
        let (V_squared_times_V2 : FQ2) = fq2_lib.mul(V_squared, V2)
        let (V_cubed : FQ2) = fq2_lib.mul(V, V_squared)
        let (W : FQ2) = fq2_lib.mul(p1.z, p2.z)

        let (U_squared_times_W : FQ2) = fq2_lib.mul_three_terms(U, U, W)
        let (twice_V_squared_times_V2 : FQ2) = fq2_lib.scalar_mul(2, V_squared_times_V2)
        let (A : FQ2) = fq2_lib.sub_three_terms(
            U_squared_times_W, V_cubed, twice_V_squared_times_V2
        )

        let (new_x : FQ2) = fq2_lib.mul(V, A)

        # newy = U * (V_squared_times_V2 - A) - V_cubed * U2
        let (V_squared_times_V2_sub_A : FQ2) = fq2_lib.sub(V_squared_times_V2, A)
        let (inner_term_1 : FQ2) = fq2_lib.mul(U, V_squared_times_V2_sub_A)
        let (inner_term_2 : FQ2) = fq2_lib.mul(V_cubed, U2)
        let (new_y : FQ2) = fq2_lib.sub(inner_term_1, inner_term_2)

        let (new_z : FQ2) = fq2_lib.mul(V_cubed, W)

        return (G2Point(new_x, new_y, new_z))
    end

    # Computes `point + point`
    func double{bitwise_ptr : BitwiseBuiltin*, range_check_ptr}(point : G2Point) -> (res : G2Point):
        alloc_locals
        let (W : FQ2) = fq2_lib.mul(point.x, point.x)
        let (local W : FQ2) = fq2_lib.scalar_mul(3, W)
        let (S : FQ2) = fq2_lib.mul(point.y, point.z)
        let (B : FQ2) = fq2_lib.mul_three_terms(point.x, point.y, S)

        let (W_squared : FQ2) = fq2_lib.mul(W, W)
        let (eight_times_B : FQ2) = fq2_lib.scalar_mul(8, B)
        let (H : FQ2) = fq2_lib.sub(W_squared, eight_times_B)

        # Compute new_x
        let (H_times_S : FQ2) = fq2_lib.mul(H, S)
        let (new_x : FQ2) = fq2_lib.scalar_mul(2, H_times_S)

        # Compute new_y
        let (S_squared : FQ2) = fq2_lib.mul(S, S)
        let (inner_term_2 : FQ2) = fq2_lib.mul_three_terms(point.y, point.y, S_squared)
        let (eight_times_inner_term_2 : FQ2) = fq2_lib.scalar_mul(8, inner_term_2)
        let (four_times_B : FQ2) = fq2_lib.scalar_mul(4, B)
        let (four_times_B_sub_H : FQ2) = fq2_lib.sub(four_times_B, H)
        let (inner_term_1 : FQ2) = fq2_lib.mul(W, four_times_B_sub_H)
        let (new_y : FQ2) = fq2_lib.sub(inner_term_1, inner_term_2)

        # Compute new_z
        let (S_cubed : FQ2) = fq2_lib.mul(S, S_squared)
        let (new_z : FQ2) = fq2_lib.scalar_mul(8, S_cubed)

        return (G2Point(new_x, new_y, new_z))
    end
    
    # TODO: Do we need scalar mult by Uint384 here? Not just felt?
    # Computes scalar * point, which means point added with itself `scalar` times
    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar, point : G2Point) -> (
        res : G2Point
    ):
        %{print("findme", ids.scalar)%}
        alloc_locals
        if scalar == 0:
            return get_zero()
        end
        if scalar == 1:
            return (point)
        end
        let (double_point: G2Point) = double(point)
        let (local quotient, local remainder) = unsigned_div_rem(scalar, 2)
        let (quotient_mul_double_point: G2Point) = scalar_mul(quotient, double_point)
        if remainder == 0:
            return (quotient_mul_double_point)
        else:
            let (res: G2Point) = add(point, quotient_mul_double_point)
            return (res)
        end
    end
    
    # TODO: Not tested
    func get_zero{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}() -> (res : G2Point):
        let (one: FQ2) = fq2_lib.get_one()
        let (zero: FQ2) = fq2_lib.get_zero()
        return (G2Point(x=one, y=one, z=zero))
    end
    
    # Check that a point is on the curve defined by y**2 = x**3 + 4
    # TODO: check that this is the correct equation
    func is_on_curve{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(point: G2Point, b) -> (bool : felt):
        let (is_point_at_infinity) = is_point_at_infinity(point)
        if is_point_at_infinity == 1:
            return (1)
        end
        let x = point.x
        let y = point.y
        let z = point.z
        let (x_square) = fq2_lib.mul(x,x)
        let (y_square) = fq2_lib.mul(y,y)
        let (z_square) = fq2_lib.mul(z,z)
        let (x_cubed) = fq2_lib.mul(x, x_cubed)
        let (z_cubed) = fq2_lib.mul(z, z_cubed)
        let (y_square_times_z) = fq2_lib.mul(y_square, z)
        let (y_square_times_z) = fq2_lib.mul(y_square, z)
        let (x_cubed_times_z) = fq2_lib.mul(x_cubed, z)
        let (four_times_z) = fq2_lib.scalar_mul(4,z)
        let (res) = fq2_lib.sub_three_terms(y_square_times_z, x_cubed_times_z, four_times_z)
        let (is_res_zero) = fq2_lib.is_zero(res)
        return (is_res_zero)
    end
end