from lib.BigInt6 import (
    BigInt6,
    BigInt12,
    BASE,
    nondet_bigint6,
    big_int_6_zero,
    big_int_6_one,
    from_bigint6_to_bigint12,
    is_equal,
)
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic import field_arithmetic_lib
from lib.multi_precision import multi_precision
from lib.curve import get_modulus, get_p_minus_one_div_2
from lib.barret_algorithm import barret_reduction
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

namespace fq_lib:
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
        sum_mod : Uint384
    ):
        let (q : Uint384) = get_modulus()
        let (sum : Uint384) = field_arithmetic_lib.add(x, y, q)
        return (sum)
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
        difference : Uint384
    ):
        alloc_locals
        let (local q : Uint384) = get_modulus()
        local range_check_ptr = range_check_ptr

        # x and y need to be reduced modulo p
        # TODO: check that they are not already reduced before (more efficiency?)
        let (_, x : Uint384) = uint384_lib.unsigned_div_rem(x, q)
        let (_, y : Uint384) = uint384_lib.unsigned_div_rem(y, q)

        let (res) = field_arithmetic_lib.sub_reduced_a_and_reduced_b(x, y, q)
        return (res)
    end

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
        product : Uint384
    ):
        let (q : Uint384) = get_modulus()
        let (res : Uint384) = field_arithmetic_lib.mul(x, y, q)
        return (res)
    end

    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (product : Uint384):
        let (res : Uint384) = mul(x, x)
        return (res)
    end
    
    

    # NOTE: Scalar has to be at most than 2**128 - 1
    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar : felt, x : Uint384) -> (
        product : Uint384
    ):
        # TODO: I want to check that scalar is at most 2**128
        # But I get an error if I do, even fi the scalar is less than 2**128. I think [range_check_ptr] is already filled?
       
        # assert [range_check_ptr] = scalar
        
        let packed : Uint384 = Uint384(d0=scalar, d1=0, d2=0)
        let (reduced : Uint384) = mul(packed, x)

        return (reduced)
    end
    
    # TODO: in field_arithmetic we implement first the function a/x mod p. Make consistent
    # finds x in a x ≅ 1 (mod q)
    func inverse{range_check_ptr}(a : Uint384) -> (res : Uint384):
        alloc_locals
        let (q : Uint384) = get_modulus()
        let one = Uint384(1, 0, 0)
        let (res : Uint384) = field_arithmetic_lib.div(one, a, q)
        return (res)
    end

    func pow{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, exponent : Uint384) -> (
        res : Uint384
    ):
        alloc_locals
        let (q : Uint384) = get_modulus()
        let (res : Uint384) = field_arithmetic_lib.pow(x, exponent, q)
        return (res)
    end

    # checks if x is a square in F_q, i.e. x ≅ y**2 (mod q) for some y
    func is_square_non_optimized{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (bool : felt):
        alloc_locals
        let (p : Uint384) = get_modulus()
        let (p_minus_one_div_2 : Uint384) = get_p_minus_one_div_2()
        let (res) = field_arithmetic_lib.is_square_non_optimized(x, p, p_minus_one_div_2)
        return (res)
    end
    
    # Finds a square of x in F_p, i.e. x ≅ y**2 (mod p) for some y
    # WARNING: Expects x to satisy 0 <= x < p-1
    func get_square_root{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (success : felt, res: Uint384):
        alloc_locals
        let (p : Uint384) = get_modulus()
        # 2 happens to be a generator
        let generator = Uint384(2,0,0)
        let (success, res: Uint384) = field_arithmetic_lib.get_square_root(x, p, generator)
        return (success, res)
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
# let (a_mod_m : BigInt6) = fq_lib.reduce(a_as_bigint12)

# let (q_mul_y : BigInt12) = multi_precision.mul(q, y)
# let (reduced : BigInt6) = fq_lib.reduce(q_mul_y)
# let (new_y : BigInt6) = multi_precision.sub(x, reduced)

# let (res : BigInt6) = inverse_inner(m, a_mod_m, m, new_y)
# return (res)
# # end
