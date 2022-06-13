from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.uint384 import Uint384
from lib.fq import fq_lib
from lib.fq2 import FQ2, fq2_lib
from lib.uint384_extension import Uint768, uint384_extension_lib

# Jacobian coordinate representation
# To retrive normal cordinates perform x = x / z ^ 2 and y = y / z ^ 3
struct G2Point:
    member x : FQ2
    member y : FQ2
    member z : FQ2
end

namespace g2_lib:
    func is_point_at_infinity{range_check_ptr}(point : G2Point) -> (bool : felt):
        let (is_z_coord_zero) = fq2_lib.is_zero(point.z)
        return (is_z_coord_zero)
    end

    # Following `py_ecc` for these functions.
    # TODO: For G1 we used a different (but equivalent) version of addition. Should we uniformize?

    func eq{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p1 : G2Point, p2 : G2Point) -> (
            bool : felt):
        alloc_locals

        let (is_p1_infinity) = is_point_at_infinity(p1)
        let (is_p2_infinity) = is_point_at_infinity(p2)
        if is_p1_infinity == 1:
            if is_p2_infinity == 1:
                return (1)
            else:
                return (0)
            end
        else:
            if is_p2_infinity == 1:
                return (0)
            end
        end

        # TODO: can be done without normalizing, using multiplication instead of division
        # None of the point is the point at infinity
        let (p1_x : FQ2, p1_y : FQ2) = normalize(p1)
        let (p2_x : FQ2, p2_y : FQ2) = normalize(p2)
        let (is_x_coord_eq) = fq2_lib.eq(p1_x, p2_x)
        if is_x_coord_eq == 0:
            return (0)
        end
        let (is_y_coord_eq) = fq2_lib.eq(p1_y, p2_y)
        if is_y_coord_eq == 0:
            return (0)
        end
        return (1)
    end

    # Addition optimized for the curve y**2 = x**3 + 4 using Jacobian coordinate representation
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p1 : G2Point, p2 : G2Point) -> (
            res : G2Point):
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

        %{ print("findme", ids.is_v1_eq_v2, ids.is_u1_eq_u2) %}

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
            U_squared_times_W, V_cubed, twice_V_squared_times_V2)

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
        # TODO: remove all possible locals when done debugging
        let (W : FQ2) = fq2_lib.mul(point.x, point.x)
        let (local W : FQ2) = fq2_lib.scalar_mul(3, W)
        let (S : FQ2) = fq2_lib.mul(point.y, point.z)
        let (B : FQ2) = fq2_lib.mul_three_terms(point.x, point.y, S)

        let (W_squared : FQ2) = fq2_lib.mul(W, W)
        let (local eight_times_B : FQ2) = fq2_lib.scalar_mul(8, B)
        let (H : FQ2) = fq2_lib.sub(W_squared, eight_times_B)

        # Compute new_x
        let (local H_times_S : FQ2) = fq2_lib.mul(H, S)
        let (new_x : FQ2) = fq2_lib.scalar_mul(2, H_times_S)

        # Compute new_y
        let (S_squared : FQ2) = fq2_lib.mul(S, S)
        let (aux_inner_term_2 : FQ2) = fq2_lib.mul_three_terms(point.y, point.y, S_squared)
        let (local inner_term_2 : FQ2) = fq2_lib.scalar_mul(8, aux_inner_term_2)
        let (local four_times_B : FQ2) = fq2_lib.scalar_mul(4, B)
        let (local four_times_B_sub_H : FQ2) = fq2_lib.sub(four_times_B, H)
        let (local inner_term_1 : FQ2) = fq2_lib.mul(W, four_times_B_sub_H)
        let (local new_y : FQ2) = fq2_lib.sub(inner_term_1, inner_term_2)

        # Compute new_z
        let (local S_cubed : FQ2) = fq2_lib.mul(S, S_squared)
        let (local new_z : FQ2) = fq2_lib.scalar_mul(8, S_cubed)

        %{
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (limb for limb in z)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def packFQP(z):
                z = [[z.e0.d0, z.e0.d1, z.e0.d2], [z.e1.d0, z.e1.d1, z.e1.d2]]
                return tuple(pack(z_component) for z_component in z)

            print("HI")
            print("W", packFQP(ids.W))
            print("S", packFQP(ids.S))
            print("B", packFQP(ids.B))
            print("W_squared", packFQP(ids.W_squared))
            print("8_times_B", packFQP(ids.eight_times_B))
            print("H", packFQP(ids.H))
            print("H_times_S", packFQP(ids.H_times_S))
            print("new_x", packFQP(ids.new_x))
            print("S_squared", packFQP(ids.S_squared))
            print("inner_term_2", packFQP(ids.inner_term_2))
            #print("eight_times_inner_term_2", packFQP(ids.eight_times_inner_term_2))
            print("four_times_B", packFQP(ids.four_times_B))
            print("four_times_B_sub_H", packFQP(ids.four_times_B_sub_H))
            print("inner_term_1", packFQP(ids.inner_term_1))
            print("new_y", packFQP(ids.new_y))
            print("S_cubed", packFQP(ids.S_cubed))
            print("new_z", packFQP(ids.new_z))
        %}

        return (G2Point(new_x, new_y, new_z))
    end

    func multiply{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(point : G2Point, n : Uint768) -> (
            res : G2Point):
        alloc_locals

        let (is_eq_one : felt) = uint384_extension_lib.eq(
            n, Uint768(d0=1, d1=0, d2=0, d3=0, d4=0, d5=0))

        if is_eq_one == 1:
            return (res=point)
        end

        let (n_halved : Uint768,
            is_odd : Uint384) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384(
            n, Uint384(d0=2, d1=0, d2=0))
        let (doubled : G2Point) = double(point)
        if is_odd.d0 == 1:
            let (res : G2Point) = multiply(doubled, n_halved)
        else:
            let (res : G2Point) = multiply(doubled, n_halved)
            let (res : G2Point) = add(res, point)
        end

        return (res=res)
    end

    # http://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#addition-add-2007-bl
    func add_noncents{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
            left : G2Point, right : G2Point) -> (res : G2Point):
        alloc_locals

        # if left.z.d0 == 0:
        #     return (right)
        # end
        # if right.z.d0 == 0:
        #     return (left)
        # end
        let (is_left_z_zero) = fq2_lib.is_zero(left.z)
        if is_left_z_zero == 1:
            return (right)
        end
        let (is_right_z_zero) = fq2_lib.is_zero(right.z)
        if is_right_z_zero == 1:
            return (left)
        end

        # z1z1 = z1^2
        let (z1_squared : FQ2) = fq2_lib.square(left.z)
        # z2z2 = z2^2
        let (z2_squared : FQ2) = fq2_lib.square(right.z)

        # U1 = X1*Z2Z2
        let (U1 : FQ2) = fq2_lib.mul(left.x, z2_squared)
        # U2 = X2*Z1Z1
        let (U2 : FQ2) = fq2_lib.mul(right.x, z1_squared)

        # S1 = Y1*Z2*Z2Z2
        let (S1 : FQ2) = fq2_lib.mul_three_terms(left.y, right.z, z2_squared)
        # S2 = Y2*Z1*Z1Z1
        let (S2 : FQ2) = fq2_lib.mul_three_terms(right.y, left.z, z1_squared)

        # H = U2-U1
        let (H : FQ2) = fq2_lib.sub(U2, U1)

        # I = (2*H)^2
        let (two_H : FQ2) = fq2_lib.scalar_mul(2, H)
        let (I : FQ2) = fq2_lib.square(two_H)

        # J = H*I
        let (J : FQ2) = fq2_lib.mul(H, I)

        # r = 2*(S2-S1)
        let (S_two_sub_S_one) = fq2_lib.sub(S2, S1)
        let (r : FQ2) = fq2_lib.scalar_mul(2, S_two_sub_S_one)

        # V = U1*I
        let (V : FQ2) = fq2_lib.mul(U1, I)

        # X3 = r^2-J-2*V
        let (two_V : FQ2) = fq2_lib.scalar_mul(2, V)

        let (r_squared : FQ2) = fq2_lib.square(r)

        let (X3 : FQ2) = fq2_lib.sub_three_terms(r_squared, J, two_V)

        # Y3 = r*(V-X3)-2*S1*J
        let (V_sub_X3 : FQ2) = fq2_lib.sub(V, X3)
        let (r_mul_V_sub_X3 : FQ2) = fq2_lib.mul(r, V_sub_X3)
        let (two_S1 : FQ2) = fq2_lib.scalar_mul(2, S1)
        let (two_S1_mul_J : FQ2) = fq2_lib.mul(two_S1, J)
        let (Y3 : FQ2) = fq2_lib.sub(r_mul_V_sub_X3, two_S1_mul_J)

        # Z3 = ((Z1+Z2)^2-Z1Z1-Z2Z2)*H
        let (Z1_plus_Z2 : FQ2) = fq2_lib.add(left.z, right.z)
        let (Z1_plus_Z2_squared : FQ2) = fq2_lib.square(Z1_plus_Z2)
        let (inner : FQ2) = fq2_lib.sub_three_terms(Z1_plus_Z2_squared, z1_squared, z2_squared)
        let (Z3 : FQ2) = fq2_lib.mul(inner, H)

        let res : G2Point = G2Point(x=X3, y=Y3, z=Z3)
        return (res)
    end

    # TODO: Do we need scalar mult by Uint384 here? Not just felt?
    # Computes scalar * point, which means point added with itself `scalar` times
    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar, point : G2Point) -> (
            res : G2Point):
        %{
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (limb for limb in z)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            print("findme", ids.scalar, pack([ids.point.x.e0.d0,ids.point.x.e0.d1,ids.point.x.e0.d2]), pack([ids.point.x.e1.d0,ids.point.x.e1.d1,ids.point.x.e1.d2]), pack([ids.point.y.e0.d0,ids.point.y.e0.d1,ids.point.y.e0.d2]), pack([ids.point.y.e1.d0,ids.point.y.e1.d1,ids.point.y.e1.d2]), pack([ids.point.z.e0.d0,ids.point.z.e0.d1,ids.point.z.e0.d2]), pack([ids.point.z.e1.d0,ids.point.z.e1.d1,ids.point.z.e1.d2]))
        %}
        if scalar == 0:
            return get_zero()
        end
        if scalar == 1:
            return (point)
        end
        let (double_point : G2Point) = double(point)
        let (quotient, remainder) = unsigned_div_rem(scalar, 2)
        if remainder == 0:
            let (quotient_mul_double_point : G2Point) = scalar_mul(quotient, double_point)
            return (quotient_mul_double_point)
        else:
            # Repeating code to avoid using local variables
            let (quotient_mul_double_point : G2Point) = scalar_mul(quotient, double_point)
            let (res : G2Point) = add(point, quotient_mul_double_point)
            return (res)
        end
    end

    # TODO: Not tested
    func get_zero{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}() -> (res : G2Point):
        let (one : FQ2) = fq2_lib.get_one()
        let (zero : FQ2) = fq2_lib.get_zero()
        return (G2Point(x=one, y=one, z=zero))
    end

    # TODO: Not tested
    # Transforms (x,y,z) into (x/z^3, y/z^2) assuming z != 0, i.e. (x,y,z) != point_at_infinity
    func normalize{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(point : G2Point) -> (
            normalized_x : FQ2, normalized_y : FQ2):
        alloc_locals
        let (bool) = is_point_at_infinity(point)
        assert bool = 0
        # let (z_squared : FQ2) = fq2_lib.mul(point.z, point.z)
        # let (local z_cubed : FQ2) = fq2_lib.mul(z_squared, point.z)
        # let (z_squared_inverse : FQ2) = fq2_lib.inv(z_squared)
        # let (z_cubed_inverse : FQ2) = fq2_lib.inv(z_cubed)
        # let (normalized_x : FQ2) = fq2_lib.mul(point.x, z_squared_inverse)
        # let (normalized_y : FQ2) = fq2_lib.mul(point.y, z_cubed_inverse)
        # return (normalized_x, normalized_y)
        let (z_inverse : FQ2) = fq2_lib.inv(point.z)
        let (normalized_x : FQ2) = fq2_lib.mul(point.x, z_inverse)
        let (normalized_y : FQ2) = fq2_lib.mul(point.y, z_inverse)
        return (normalized_x, normalized_y)
    end

    # Check that a point is on the curve defined by y**2 = x**3 + 4
    # TODO: check that this is the correct equation
    # TODO: Can be done without normalizing, avoiding making divisions
    func is_on_curve{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(point : G2Point, b) -> (
            bool : felt):
        let (is_point_at_infinity) = is_point_at_infinity(point)
        if is_point_at_infinity == 1:
            return (1)
        end
        let (x_normalized : FQ2, y_normalized : FQ2) = normalize(point)
        let (x_square) = fq2_lib.mul(x_normalized, x_normalized)
        let (y_square) = fq2_lib.mul(y_normalized, y_normalized)
        let (x_cubed) = fq2_lib.mul(x_normalized, x_square)
        let four = FQ2(Uint384(4, 0, 0), Uint384(0, 0, 0))
        let (res) = fq2_lib.sub_three_terms(y_square, x_cubed, four)
        let (is_res_zero) = fq2_lib.is_zero(res)
        return (is_res_zero)
    end

    # # psix = 1 / (nr ^ (p - 1)/3)
    # # p = 16019282247729705411943748644318972617695120099330552659862384536985976748491357143400656079302193429974954385540170730531103884539706905936200202421036435811093013034271812758016407969496331661418541023677774899971425993489485369
    # # r = 0x73eda753299d7d483339d80809a1d80553bda402fffe5bfeffffffff00000001
    # # n = 0x5d543a95414e7f1091d50792876a202cd91de4547085abaa68a205b2e5a7ddfa628f1cb4d9e82ef21537e293a6691ae1616ec6e786f0c70cf1c38e31c7238e5
    func get_psi_x() -> (psi_x : FQ2):
        return (
            psi_x=FQ2(e0=Uint384(d0=0, d1=0, d2=0),
            e1=Uint384(d0=57090000153090263371005173459775210947, d1=215402993932478976138402828039445249580, d2=27775811676944536350107783208663486568)))
    end

    func get_psi_y() -> (psi_y : FQ2):
        return (
            psi_y=FQ2(e0=Uint384(d0=88498181851007361581448886694209952465, d1=194966426654809473394864639982321153842, d2=15730448420644313803453897928225910969),
            e1=Uint384(d0=292554099899570639894799895684836429786, d1=278858154884989680658816242618366607089, d2=18835035124770592265335298098589514781)))
    end

    func psi{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(point : G2Point) -> (res : G2Point):
        alloc_locals

        let (conjugate_x : FQ2) = fq2_lib.conjugate(point.x)
        let (conjugate_y : FQ2) = fq2_lib.conjugate(point.y)
        let (conjugate_z : FQ2) = fq2_lib.conjugate(point.z)

        let (psi_x : FQ2) = get_psi_x()
        let (x_psi_x) = fq2_lib.mul(conjugate_x, psi_x)
        let (psi_y : FQ2) = get_psi_y()
        let (y_psi_y) = fq2_lib.mul(conjugate_y, psi_y)

        return (res=G2Point(x=x_psi_x, y=y_psi_y, conjugate_z))
    end

    # TODO Use two_psi optimized equation
    func two_psi{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(point : G2Point) -> (
            res : G2Point):
        alloc_locals

        let (psi_one : G2Point) = psi(point)
        let (psi_two : G2Point) = psi(psi_one)

        return (res=psi_two)
    end

    func neg{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p : G2Point) -> (res : G2Point):
        alloc_locals

        let (neg_y : FQ2) = fq2_lib.neg(p.y)

        return (res=G2Point(x=p.x, y=neg_y, z=p.z))
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : G2Point, b : G2Point) -> (
            res : G2Point):
        alloc_locals

        let (neg_b : G2Point) = neg(b)

        let (a_plus_b : G2Point) = add(a, neg_b)

        return (res=a_plus_b)
    end
end
