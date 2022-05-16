from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.fq import fq_square, fq_mul, fq_sub, fq_scalar_mul, fq_add
from lib.BigInt6 import BigInt6

# Jacobian coordinate representation
# To retrive normal cordinates perform x = x / z ^ 2 and y = y / z ^ 3
struct G1Point:
    member x : BigInt6
    member y : BigInt6
    member z : BigInt6
end

func sub_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        x : BigInt6, y : BigInt6, z : BigInt6) -> (res : BigInt6):
    alloc_locals

    let (x_sub_y : BigInt6) = fq_sub(x, y)
    let (res : BigInt6) = fq_sub(x_sub_y, z)

    return (res)
end

func mul_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        x : BigInt6, y : BigInt6, z : BigInt6) -> (res : BigInt6):
    alloc_locals

    let (x_mul_y : BigInt6) = fq_mul(x, y)
    let (res : BigInt6) = fq_mul(x_mul_y, z)

    return (res)
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
    let (z1_squared : BigInt6) = fq_square(left.z)
    # z2z2 = z2^2
    let (z2_squared : BigInt6) = fq_square(right.z)

    # U1 = X1*Z2Z2
    let (U1 : BigInt6) = fq_mul(left.x, z2_squared)
    # U2 = X2*Z1Z1
    let (U2 : BigInt6) = fq_mul(right.x, z1_squared)

    # S1 = Y1*Z2*Z2Z2
    let (S1 : BigInt6) = mul_three_terms(left.y, right.z, z2_squared)
    # S2 = Y2*Z1*Z1Z1
    let (S2 : BigInt6) = mul_three_terms(right.y, left.z, z1_squared)

    # H = U2-U1
    let (H : BigInt6) = fq_sub(U2, U1)

    # I = (2*H)^2
    let (two_H : BigInt6) = fq_scalar_mul(2, H)
    let (I : BigInt6) = fq_square(two_H)

    # J = H*I
    let (J : BigInt6) = fq_mul(H, I)

    # r = 2*(S2-S1)
    let (S_two_sub_S_one) = fq_sub(S2, S1)
    let (r : BigInt6) = fq_scalar_mul(2, S_two_sub_S_one)

    # V = U1*I
    let (V : BigInt6) = fq_mul(U1, I)

    # X3 = r^2-J-2*V
    let (two_V : BigInt6) = fq_scalar_mul(2, V)

    let (r_squared : BigInt6) = fq_square(r)

    let (X3 : BigInt6) = sub_three_terms(r_squared, J, two_V)

    # Y3 = r*(V-X3)-2*S1*J
    let (V_sub_X3 : BigInt6) = fq_sub(V, X3)
    let (r_mul_V_sub_X3 : BigInt6) = fq_mul(r, V_sub_X3)
    let (two_S1 : BigInt6) = fq_scalar_mul(2, S1)
    let (two_S1_mul_J : BigInt6) = fq_mul(two_S1, J)
    let (Y3 : BigInt6) = fq_sub(r_mul_V_sub_X3, two_S1_mul_J)

    # Z3 = ((Z1+Z2)^2-Z1Z1-Z2Z2)*H
    let (Z1_plus_Z2 : BigInt6) = fq_add(left.z, right.z)
    let (Z1_plus_Z2_squared : BigInt6) = fq_square(Z1_plus_Z2)
    let (inner : BigInt6) = sub_three_terms(Z1_plus_Z2_squared, z1_squared, z2_squared)
    let (Z3 : BigInt6) = fq_mul(inner, H)

    let res : G1Point = G1Point(x=X3, y=Y3, z=Z3)
    return (res)
end

# CONSTANTS
func g1() -> (res : G1Point):
    return (
        res=G1Point(x=BigInt6(0xfb3af00adb22c6bb,
            0x6c55e83ff97a1aef,
            0xa14e3a3f171bac58,
            0xc3688c4f9774b905,
            0x2695638c4fa9ac0f,
            0x17f1d3a73197d794),
        y=BigInt6(0x0caa232946c5e7e1,
            0xd03cc744a2888ae4,
            0xdb18cb2c04b3ed,
            0xfcf5e095d5d00af6,
            0xa09e30ed741d8ae4,
            0x08b3f481e3aaa0f1),
        z=BigInt6(
            0, 0, 0, 0, 0, 0)
        ))
end
