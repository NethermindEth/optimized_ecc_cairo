from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, bitwise_xor
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import assert_in_range, assert_le, assert_nn_le, assert_not_zero
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.pow import pow
from starkware.cairo.common.registers import get_ap, get_fp_and_pc
# Import uint384 files (path may change in the future)
from uint384_cairo_imported.lib.uint384 import uint384_lib, Uint384
from lib.uint384_extension import uint384_extension_lib, Uint768

# Functions for operating elements in a finite field F_p (i.e. modulo a prime p), with p of at most 384 bits

namespace field_arithmetic:
    # Computes (a + b) modulo p .
    func add{range_check_ptr}(a : Uint384, b : Uint384, p : Uint384) -> (res : Uint384):
        let (sum : Uint384, carry) = uint384_lib.add(a, b)
        let sum_with_carry : Uint768 = Uint768(sum.d0, sum.d1, sum.d2, carry, 0, 0)

        let (quotient : Uint768,
            remainder : Uint384) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384(
            sum_with_carry, p
        )
        return (remainder)
    end

    # Computes (a - b) modulo p .
    # NOTE: Expects a and b to be reduced modulo p (i.e. between 0 and p-1). The function will revert if a > p.
    # NOTE: To reduce a, take the remainder of uint384_lin.unsigned_div_rem(a, p), and similarly for b.
    # @dev First it computes res =(a-b) mod p in a hint and then checks outside of the hint that res + b = a modulo p
    func sub_reduced_a_and_reduced_b{range_check_ptr}(a : Uint384, b : Uint384, p : Uint384) -> (
        res : Uint384
    ):
        alloc_locals
        local res : Uint384
        %{
            def split(num: int, num_bits_shift: int, length: int):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift 
                return tuple(a)

            def pack(z, num_bits_shift: int) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            a = pack(ids.a, num_bits_shift = 128)
            b = pack(ids.b, num_bits_shift = 128)
            p = pack(ids.p, num_bits_shift = 128)

            res = (a - b) % p


            res_split = split(res, num_bits_shift=128, length=3)

            ids.res.d0 = res_split[0]
            ids.res.d1 = res_split[1]
            ids.res.d2 = res_split[2]
        %}
        let (b_plus_res) = add(b, res, p)
        assert b_plus_res = a
        return (res)
    end

    # Computes a * b modulo p
    func mul{range_check_ptr}(a : Uint384, b : Uint384, p : Uint384) -> (res : Uint384):
        let (low : Uint384, high : Uint384) = uint384_lib.mul(a, b)
        let full_mul_result : Uint768 = Uint768(low.d0, low.d1, low.d2, high.d0, high.d1, high.d2)
        let (quotient : Uint768,
            remainder : Uint384) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384(
            full_mul_result, p
        )
        return (remainder)
    end

    # Computes a * b^{-1} modulo p
    # NOTE: The modular inverse of b modulo p is computed in a hint and verified outside the hind with a multiplicaiton
    func div{range_check_ptr}(a : Uint384, b : Uint384, p : Uint384) -> (res : Uint384):
        alloc_locals
        local b_inverse_mod_p : Uint384
        %{
            def split(num: int, num_bits_shift: int, length: int):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift 
                return tuple(a)

            def pack(z, num_bits_shift: int) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            a = pack(ids.a, num_bits_shift = 128)
            b = pack(ids.b, num_bits_shift = 128)
            p = pack(ids.p, num_bits_shift = 128)
            b_inverse_mod_p = pow(b, -1, p)
            a_div_b = (a* b_inverse_mod_p) % p

            b_inverse_mod_p_split = split(b_inverse_mod_p, num_bits_shift=128, length=3)

            ids.b_inverse_mod_p.d0 = b_inverse_mod_p_split[0]
            ids.b_inverse_mod_p.d1 = b_inverse_mod_p_split[1]
            ids.b_inverse_mod_p.d2 = b_inverse_mod_p_split[2]
        %}
        let (b_times_b_inverse) = mul(b, b_inverse_mod_p, p)
        assert b_times_b_inverse = Uint384(1, 0, 0)

        let (res : Uint384) = mul(a, b_inverse_mod_p, p)
        return (res)
    end

    # Computes (a**exp) % p. Uses the fast exponentiation algorithm, so it takes at most 384 squarings: https://en.wikipedia.org/wiki/Exponentiation_by_squaring
    func pow{range_check_ptr}(a : Uint384, exp : Uint384, p : Uint384) -> (res : Uint384):
        alloc_locals
        let (is_exp_zero) = uint384_lib.eq(exp, Uint384(0, 0, 0))

        if is_exp_zero == 1:
            return (Uint384(1, 0, 0))
        end

        let (is_exp_one) = uint384_lib.eq(exp, Uint384(1, 0, 0))
        if is_exp_one == 1:
            # If exp = 1, it is possible that `a` is not reduced mod p, 
            # so we check and reduce if necessary
            let (is_a_lt_p) = uint384_lib.lt(a, p)
            if is_a_lt_p == 1:            
                return (a)
            else:
                let (quotient, remainder) = uint384_lib.unsigned_div_rem(a, p)
                return (remainder)
            end
        end

        let (exp_div_2, remainder) = uint384_lib.unsigned_div_rem(exp, Uint384(2, 0, 0))
        let (is_remainder_zero) = uint384_lib.eq(remainder, Uint384(0, 0, 0))

        if is_remainder_zero == 1:
            # NOTE: Code is repeated in the if-else to avoid declaring a_squared as a local variable
            let (a_squared : Uint384) = mul(a, a, p)
            let (res) = pow(a_squared, exp_div_2, p)
            return (res)
        else:
            let (a_squared : Uint384) = mul(a, a, p)
            let (res) = pow(a_squared, exp_div_2, p)
            let (res_mul) = mul(a, res, p)
            return (res_mul)
        end
    end
end
