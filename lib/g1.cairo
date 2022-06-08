from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.fq import fq_lib
from lib.uint384 import Uint384

# Jacobian coordinate representation
# To retrive normal cordinates perform x = x / z ^ 2 and y = y / z ^ 3
struct G1Point:
    member x : Uint384
    member y : Uint384
    member z : Uint384
end

# http://hyperelliptic.org/EFD/g1p/auto-shortw-jacobian-0.html#addition-add-2007-bl
func add_g1{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(left : G1Point, right : G1Point) -> (
        res : G1Point):
    alloc_locals
    
    if left.z.d0 == 0:
        return (right)
    end
    if right.z.d0 == 0:
        return (left)
    end

    # z1z1 = z1^2
    let (z1_squared : Uint384) = fq_lib.square(left.z)
    # z2z2 = z2^2
    let (z2_squared : Uint384) = fq_lib.square(right.z)

    # U1 = X1*Z2Z2
    let (U1 : Uint384) = fq_lib.mul(left.x, z2_squared)
    # U2 = X2*Z1Z1
    let (U2 : Uint384) = fq_lib.mul(right.x, z1_squared)

    # S1 = Y1*Z2*Z2Z2
    let (S1 : Uint384) = mul_three_terms(left.y, right.z, z2_squared)
    # S2 = Y2*Z1*Z1Z1
    let (S2 : Uint384) = mul_three_terms(right.y, left.z, z1_squared)

    # H = U2-U1
    let (H : Uint384) = fq_lib.sub(U2, U1)

    # I = (2*H)^2
    let (two_H : Uint384) = fq_lib.scalar_mul(2, H)
    let (I : Uint384) = fq_lib.square(two_H)

    # J = H*I
    let (J : Uint384) = fq_lib.mul(H, I)

    # r = 2*(S2-S1)
    let (S_two_sub_S_one) = fq_lib.sub(S2, S1)
    let (r : Uint384) = fq_lib.scalar_mul(2, S_two_sub_S_one)

    # V = U1*I
    let (V : Uint384) = fq_lib.mul(U1, I)

    # X3 = r^2-J-2*V
    let (two_V : Uint384) = fq_lib.scalar_mul(2, V)

    let (r_squared : Uint384) = fq_lib.square(r)

    let (X3 : Uint384) = sub_three_terms(r_squared, J, two_V)

    # Y3 = r*(V-X3)-2*S1*J
    let (V_sub_X3 : Uint384) = fq_lib.sub(V, X3)
    let (r_mul_V_sub_X3 : Uint384) = fq_lib.mul(r, V_sub_X3)
    let (two_S1 : Uint384) = fq_lib.scalar_mul(2, S1)
    let (two_S1_mul_J : Uint384) = fq_lib.mul(two_S1, J)
    let (Y3 : Uint384) = fq_lib.sub(r_mul_V_sub_X3, two_S1_mul_J)

    # Z3 = ((Z1+Z2)^2-Z1Z1-Z2Z2)*H
    let (Z1_plus_Z2 : Uint384) = fq_lib.add(left.z, right.z)
    let (Z1_plus_Z2_squared : Uint384) = fq_lib.square(Z1_plus_Z2)
    let (inner : Uint384) = sub_three_terms(Z1_plus_Z2_squared, z1_squared, z2_squared)
    let (Z3 : Uint384) = fq_lib.mul(inner, H)

    let res : G1Point = G1Point(x=X3, y=Y3, z=Z3)
    return (res)
end


func sub_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        x : Uint384, y : Uint384, z : Uint384) -> (res : Uint384):
    alloc_locals

    let (x_sub_y : Uint384) = fq_lib.sub(x, y)
    let (res : Uint384) = fq_lib.sub(x_sub_y, z)

    return (res)
end

func mul_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        x : Uint384, y : Uint384, z : Uint384) -> (res : Uint384):
    alloc_locals

    let (x_mul_y : Uint384) = fq_lib.mul(x, y)
    let (res : Uint384) = fq_lib.mul(x_mul_y, z)

    return (res)
end

# TODO: Not used anywhere in the repo?
# CONSTANTS
func g1() -> (res : G1Point):
    return (
        res=G1Point(x=Uint384(0xfb3af00adb22c6bb,
            0x6c55e83ff97a1aef,
            0xa14e3a3f171bac58,
            0xc3688c4f9774b905,
            0x2695638c4fa9ac0f,
            0x17f1d3a73197d794),
        y=Uint384(0x0caa232946c5e7e1,
            0xd03cc744a2888ae4,
            0xdb18cb2c04b3ed,
            0xfcf5e095d5d00af6,
            0xa09e30ed741d8ae4,
            0x08b3f481e3aaa0f1),
        z=Uint384(
            0, 0, 0, 0, 0, 0)
        ))
end
