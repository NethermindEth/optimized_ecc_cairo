from lib.BigInt6 import (
    BigInt6, BigInt12, BASE, nondet_bigint6, big_int_6_zero, big_int_6_one,
    from_bigint6_to_bigint12, is_equal)
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic import field_arithmetic_lib
from lib.multi_precision import multi_precision
from lib.curve import get_modulus
from lib.barret_algorithm import barret_reduction
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

namespace fq:
    
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            sum_mod : Uint384):
        let (q : Uint384) = get_modulus()
        let (sum : Uint384, _) = field_arithmetic_lib.add(x, y, q)
        return (sum)
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            difference : Uint384):
        let (mod) = get_modulus()
        
        # x and y need to be reduced modulo p            
        let (x_lt_q : felt) = uint384_lib.lt(x, q)
        if x_lt_q == 0:
            let (_, x: Uint384) = uint384_lib.unsigned_div_rem(x, q)
        end
        let (y_lt_q : felt) = uint384_lib.lt(y, q)
        if x_lt_q == 0:
            let (_, y: Uint384) = uint384_lib.unsigned_div_rem(y, q)
        end
        
        let (res) = field_arithmetic_lib.sub_reduced_a_and_reduced_b(x, y, q)
        return (res)
    end

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            product : Uint384):
        let (q : Uint384) = get_modulus()
        let (res : Uint384) = field_arithmetic_lib.mul(x, y, q)
        return (res)
    end

    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (product : Uint384):
        let (res : Uint384) = mul(x, x)
        return (res)
    end

    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar : felt, x : Uint384) -> (
            product : Uint384):

        let packed : Uint384 = Uint384(d0=scalar, d1=0, d2=0)
        let (reduced : Uint384) = mul(packed, x)

        return (reduced)
    end

    # finds x in a x ≅ 1 (mod q)
    func inverse{range_check_ptr}(a : Uint384) -> (res : Uint384):
        alloc_locals
        let (q : Uint384) = get_modulus()
        let one = Uint384(1, 0,0)
        let (res: Uint384) =  field_arithmetic_lib.div(one, a)
        return (res)
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
