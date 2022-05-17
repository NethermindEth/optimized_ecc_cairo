from lib.BigInt6 import (
    BigInt6, BigInt12, BASE, nondet_bigint6, big_int_6_zero, big_int_6_one,
    from_bigint6_to_bigint12, is_equal)
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.multi_precision import multi_precision
from lib.curve import get_modulus
from lib.barret_algorithm import barret_reduction
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

namespace fq:
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            sum_mod : Uint384):
        alloc_locals

        let (sum : Uint384, _) = uint384_lib.add(x, y)
        let (mod : Uint384) = get_modulus()

        let (is_mod_lt_sum : felt) = uint384_lib.lt(mod, sum)

        if is_mod_lt_sum == 0:
            return (sum)
        end

        let (_, sum_mod : Uint384) = uint384_lib.unsigned_div_rem(sum, mod)

        return (sum_mod)
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            difference : Uint384):
        alloc_locals

        let (x_lt_y : felt) = uint384_lib.lt(x, y)

        if x_lt_y == 0:
            let (difference : Uint384) = uint384_lib.sub(x, y)
            return (difference)
        end

        let (mod) = get_modulus()
        let (difference : Uint384) = uint384_lib.sub(y, x)
        let (mod_difference : Uint384) = uint384_lib.sub(mod, difference)
        return (mod_difference)
    end

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            product : Uint384):
        let (low : Uint384, high : Uint384) = uint384_lib.mul(x, y)
        let (mod : Uint384) = get_modulus()
        let (_, reduced : Uint384) = uint384_extension_lib.unsigned_div_rem_768_bits_by_uint384(
            Uint768(d0=low.d0, d1=low.d1, d2=low.d2, d3=high.d0, d4=high.d1, d5=high.d2), mod)

        return (reduced)
    end

    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (product : Uint384):
        let (res : Uint384) = mul(x, x)
        return (res)
    end

    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar : felt, x : Uint384) -> (
            product : Uint384):
        alloc_locals

        let packed : Uint384 = Uint384(d0=scalar, d1=0, d2=0)
        let (reduced : Uint384) = mul(packed, x)

        return (reduced)
    end

    # finds x in a x ≅ 1 (mod m)
    func inverse{range_check_ptr}(a : BigInt6, m : BigInt6) -> (res : BigInt6):
        alloc_locals

        if a == 0:
            return (BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0))
        end

        let (x : BigInt6) = big_int_6_zero()
        let (y : BigInt6) = big_int_6_one()

        # let (inv : BigInt6) = inverse_inner(a, m, x, y)

        return (x)
    end
end

# # func inverse_inner{range_check_ptr}(a : BigInt6, m : BigInt6, x : BigInt6, y : BigInt6) -> (
#     res : BigInt6):
# alloc_locals

# let (one : BigInt6) = big_int_6_one()

# let (a_eq_one : felt) = is_equal(a, one)
# if a_eq_one == 1:
#     return (x)
# end

# let (q : BigInt6, _) = multi_precision.div(a, m)
# let (a_as_bigint12 : BigInt12) = from_bigint6_to_bigint12(a)
# let (a_mod_m : BigInt6) = fq.reduce(a_as_bigint12)

# let (q_mul_y : BigInt12) = multi_precision.mul(q, y)
# let (reduced : BigInt6) = fq.reduce(q_mul_y)
# let (new_y : BigInt6) = multi_precision.sub(x, reduced)

# let (res : BigInt6) = inverse_inner(m, a_mod_m, m, new_y)
# return (res)
# # end
