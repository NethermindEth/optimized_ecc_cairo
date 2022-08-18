%lang starknet
%builtins range_check bitwise

from lib.uint384 import Uint384
from lib.field_arithmetic import field_arithmetic_lib
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

from starkware.cairo.common.math import assert_nn_le, assert_not_zero

from lib.g1 import g1_lib, G1Point

# Verifies that val is in the range [1, N).
# Verifies a ECDSA signature.
# Soundness assumptions:
# * All the limbs of public_key_pt.x, public_key_pt.y, msg_hash are in the range [0, 3 * BASE).

# Gx = sum(Gx_i * BASE^i)
# Secp256 K1
const GX0 = 0xe28d959f2815b16f81798
const GX1 = 0xa573a1c2c1c0a6ff36cb7
const GX2 = 0x79be667ef9dcbbac55a06

# Gy = sum(Gy_i * BASE^i)
# Secp256 K1
const GY0 = 0x554199c47d08ffb10d4b8
const GY1 = 0x2ff0384422a3f45ed1229a
const GY2 = 0x483ada7726a3c4655da4f

@view
func verify{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}():
    alloc_locals

    let gen_pt = G1Point(x=Uint384(GX0, GX1, GX2), y=Uint384(GY0, GY1, GY2), z=Uint384(1, 0, 0))

    let u1 = Uint384(2 ** 84, 2 ** 84, 2 ** 84)
    # Compute u1 and u2.

    let (gen_u1) = g1_lib.scalar_mul(u1, gen_pt)
    let (pub_u2) = g1_lib.scalar_mul(u1, gen_pt)
    let (res) = g1_lib.add(gen_u1, pub_u2)

    return ()
end
