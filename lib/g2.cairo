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

    # Following TODO: add link
    # Addition optimized for the curve y**2 = x**3 + 4 using Jacobian coordinate representation
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(p1 : G2Point, p2 : G2Point) -> (
        res : G2Point
    ):
        let (is_p1_z_coord_zero) = fq2_lib.is_zero(p1.z)
        if is_z_coord_zero == 1:
            return (p2)
        end
        let (is_p2_z_coord_zero) = fq2_lib.is_zero(p2.z)
        if is_z_coord_zero == 1:
            return (p1)
        end

        let (U1 : FQ2) = fq2_lib.mul(p2.y, p1.z)
        let (U2 : FQ2) = fq2_lib.mul(p1.y, p2.z)

        let (V1 : FQ2) = fq2_lib.mul(p2.x, p1.z)
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
                return (one, one, zero)
            end
        end

        let (U : FQ2) = fq2_lib.sub(U1, U2)
        let (V : FQ2) = fq2_lib.sub(V1, V2)
        let (V_squared : FQ2) = fq2_lib.mul(V, V)
        let (V_squared_times_V2 : FQ2) = fq2_lib.mul(V_squared, V2)
        let (V_cubed : FQ2) = fq2_lib.mul(V, V_cubed)
        let (W : FQ2) = fq2_lib.mul(p1.z, p2.z)

        let (U_squared_times_W : FQ2) = fq2_lib.mul_three_terms(U, U, W)
        let (twice_V_squared_times_V2 : FQ2) = fq2_lib.scalar_mul(2, V_squared_times_V2)
        let (A : FQ2) = fq2_lib.sub_three_terms(
            U_squared_times_W, V_cubed, twice_V_squared_times_V2
        )

        let (new_x : FQ2) = fq2_lib.mul(V, A)

        let (V_squared_times_V2_sub_A : FQ2) = fq2_lib.sub(V2_squared_times_V2, A)
        let (inner_term_1 : FQ2) = fq2_lib.mul(U, inner_term_1)
        let (inner_term_2 : FQ2) = fq2_lib.mul(V_cubed, U2)
        let (new_y : FQ2) = fq2_lib.sub(inner_term_1, inner_term_2)

        let (new_z : FQ2) = fq2_lib.mul(V_cubed, W)

        return (G2Point(new_x, new_y, new_z))
    end
    
    func double(point: G2Point) -> (res: G2Point):
        let (W: FQ2) = fq2_lib.mul(point.x, point.x)
        let (W: FQ2) = fq2_lib.scalar_mul(3, W)
        let (S: FQ2) = fq2_lib.mul(point.y, point.z)
        let (B: FQ2) = fq2_lib.mul_three_terms(point.x, point.y, S)
        
        let (W_squared: FQ2) = fq2_lib.mul(W, W) 
        let (eight_times_B: FQ2) = fq2_lib.scalar_mul(8, B)
        let (H: FQ2) = fq2_lib.sub(W_squared, eight_times_B)
        
        # Compute new_x
        let (H_times_S : FQ2) = fq2_lib.mul(H, S)
        let (new_x: FQ2) = fq2_lib.scalar_mul(2, H_times_S)
        
        # Compute new_y
        let (S_squared: FQ2) = fq2_lib.mul(S, S)
        let (inner_term_2 : FQ2) = fq2_lib.mul_three_terms(point.y, point.y, S_squared)
        let (eight_times_inner_term_2: FQ2) = fq2_lib.sacalar_mul(8, inner_term_2)
        let (four_times_B: FQ2) = fq2_lib.scalar_mul(4, B)
        let (four_times_B_sub_H: FQ2) = fq2_lib.sub(four_times_B, H)
        let (inner_term_1: FQ2) = fq2_lib.mul(W, four_times_B_sub_H)
        let (new_y : FQ2) = fq2_lib.sub(inner_term_1, inner_term_2)
        
        # Compute new_z
        let (S_cubed: FQ2) = fq2_lib.mul(S, S_squared)
        let (new_z: FQ2) = fq2_lib.scalar_mul(8, S_cubed)
        
        return (G2Point(new_x, new_y, new_z))
    end

struct ParamsSWU:
    member a : fq2_lib.FQ2
    member b : fq2_lib.FQ2
    member z : fq2_lib.FQ2
    member z_inv : fq2_lib.FQ2
    member minus_b_over_a : fq2_lib.FQ2
end

func get_swu_g2_params() -> (params : ParamsSWU):
    return (
        params=ParamsSWU(
        a=FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=16517514583386313282, d1=74322656156451461, d2=16683759486841714365)),
        b=FQ2(e0=Uint384(d0=2515823342057463218, d1=7982686274772798116, d2=30992210165343854), e1=Uint384(d0=2515823342057463218, d1=7982686274772798116, d2=7934098172177393262)),
        z=FQ2(e0=Uint384(d0=9794203289623549276, d1=7309342082925068282, d2=1139538881605221074), e1=Uint384(d0=4897101644811774638, d1=3654671041462534141, d2=569769440802610537)),
        z_inv=FQ2(e0=Uint384(d0=12452452969679491344, d1=11374291236854484173, d2=13099329512014041791), e1=Uint384(d0=16399576568092893731, d1=5746367929944742296, d2=886009817557060804)),
        minus_b_over_a=FQ2(e0=Uint384(d0=10393275865055580083, d1=6888480573845999877, d2=11497223857339693790), e1=Uint384(d0=3009155151022283512, d1=13768405011380760314, d2=14385194789933939525))
        ))
end

# parameters https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-06#section-8.7
# implementation https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-06#section-6.6.2.1
func simplified_swu{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(e : FQ2, u : FQ2) -> (
        x : FQ2, y : FQ2):
    alloc_locals

    let (params : ParamsSWU) = get_swu_g2_params()

    # should use squaring algorithm
    let (u_squared : fq2_lib.FQ2) = fq2_lib.square(u)
    let (tv1 : FQ2) = fq2_lib.mul(u_squared, params.z)
    let (tv2 : FQ2) = fq2_lib.square(tv1)
    let (x1 : fq2.FQ2) = fq2_lib.add(tv1, tv2)
    let (x1 : fq2.FQ2) = fq2_lib.inverse(x1)

    let (x1_is_not_zero : felt) = fq2.check_is_not_zero(x1)

    if x1_is_not_zero == 0:
        tempvar x1 : fq2.FQ2 = params.z_inv
    else:
        tempvar x1 = x1
    end

    let (x1 : fq2.FQ2) = fq2.mul(x1, params.minus_b_over_a)

    let (gx1 : fq2.FQ2) = fq2.square(x1)
    let (gx1 : fq2.FQ2) = fq2.add(gx1, params.a)
    let (gx1 : fq2.FQ2) = fq2.mul(gx1, x1)
    let (gx1 : fq2.FQ2) = fq2.add(gx1, params.b)

    let (x2 : fq2.FQ2) = fq2.mul(tv1, x1)

    let (tv2 : fq2.FQ2) = fq2.mul(tv1, tv2)
    let (gx2 : fq2.FQ2) = fq2.mul(gx1, tv2)

    let (is_nonresidue : felt) = fq2.is_quadratic_nonresidue(gx1)

    if is_nonresidue == 1:
        let x = x1
        let y2 = gx1
    else:
        let x = x2
        let y2 = gx2
    end

    let (y : Uint384) = 

    return (params.a, params.b)
end
