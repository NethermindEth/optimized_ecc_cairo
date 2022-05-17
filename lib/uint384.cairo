from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, bitwise_xor
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import assert_in_range, assert_le, assert_nn_le, assert_not_zero
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.pow import pow
from starkware.cairo.common.registers import get_ap, get_fp_and_pc

# Represents an integer in the range [0, 2^384).
struct Uint384:
    # The low 128 bits of the value.
    member d0 : felt
    # The middle 128 bits of the value.
    member d1 : felt
    # The high 128 bits of the value.
    member d2 : felt
end

const SHIFT = 2 ** 128
const ALL_ONES = 2 ** 128 - 1
const HALF_SHIFT = 2 ** 64

namespace uint384_lib:
    # Verifies that the given integer is valid.
    func check{range_check_ptr}(a : Uint384):
        [range_check_ptr] = a.d0
        [range_check_ptr + 1] = a.d1
        [range_check_ptr + 2] = a.d2
        let range_check_ptr = range_check_ptr + 3
        return ()
    end

    # Arithmetics.

    # Adds two integers. Returns the result as a 384-bit integer and the (1-bit) carry.
    func add{range_check_ptr}(a : Uint384, b : Uint384) -> (res : Uint384, carry : felt):
        alloc_locals
        local res : Uint384
        local carry_d0 : felt
        local carry_d1 : felt
        local carry_d2 : felt
        %{
            sum_d0 = ids.a.d0 + ids.b.d0
            ids.carry_d0 = 1 if sum_d0 >= ids.SHIFT else 0
            sum_d1 = ids.a.d1 + ids.b.d1 + ids.carry_d0
            ids.carry_d1 = 1 if sum_d1 >= ids.SHIFT else 0
            sum_d2 = ids.a.d2 + ids.b.d2 + ids.carry_d1
            ids.carry_d2 = 1 if sum_d2 >= ids.SHIFT else 0
        %}

        # Either 0 or 1
        assert carry_d0 * carry_d0 = carry_d0
        assert carry_d1 * carry_d1 = carry_d1
        assert carry_d2 * carry_d2 = carry_d2

        assert res.d0 = a.d0 + b.d0 - carry_d0 * SHIFT
        assert res.d1 = a.d1 + b.d1 + carry_d0 - carry_d1 * SHIFT
        assert res.d2 = a.d2 + b.d2 + carry_d1 - carry_d2 * SHIFT

        check(res)

        return (res, carry_d2)
    end

    # Splits a field element in the range [0, 2^192) to its low 64-bit and high 128-bit parts.
    func split_64{range_check_ptr}(a : felt) -> (low : felt, high : felt):
        alloc_locals
        local low : felt
        local high : felt

        %{
            ids.low = ids.a & ((1<<64) - 1)
            ids.high = ids.a >> 64
        %}
        assert a = low + high * HALF_SHIFT
        assert [range_check_ptr + 0] = low
        assert [range_check_ptr + 1] = HALF_SHIFT - 1 - low
        assert [range_check_ptr + 2] = high
        let range_check_ptr = range_check_ptr + 3
        return (low, high)
    end

    # Multiplies two integers. Returns the result as two 384-bit integers (low and high parts).
    func mul{range_check_ptr}(a : Uint384, b : Uint384) -> (low : Uint384, high : Uint384):
        alloc_locals
        let (a0, a1) = split_64(a.d0)
        let (a2, a3) = split_64(a.d1)
        let (a4, a5) = split_64(a.d2)
        let (b0, b1) = split_64(b.d0)
        let (b2, b3) = split_64(b.d1)
        let (b4, b5) = split_64(b.d2)

        let (res0, carry) = split_64(a0 * b0)
        let (res1, carry) = split_64(a1 * b0 + a0 * b1 + carry)
        let (res2, carry) = split_64(a2 * b0 + a1 * b1 + a0 * b2 + carry)
        let (res3, carry) = split_64(a3 * b0 + a2 * b1 + a1 * b2 + a0 * b3 + carry)
        let (res4, carry) = split_64(a4 * b0 + a3 * b1 + a2 * b2 + a1 * b3 + a0 * b4 + carry)
        let (res5, carry) = split_64(
            a5 * b0 + a4 * b1 + a3 * b2 + a2 * b3 + a1 * b4 + a0 * b5 + carry
        )
        let (res6, carry) = split_64(a5 * b1 + a4 * b2 + a3 * b3 + a2 * b4 + a1 * b5 + carry)
        let (res7, carry) = split_64(a5 * b2 + a4 * b3 + a3 * b4 + a2 * b5 + carry)
        let (res8, carry) = split_64(a5 * b3 + a4 * b4 + a3 * b5 + carry)
        let (res9, carry) = split_64(a5 * b4 + a4 * b5 + carry)
        let (res10, carry    ) = split_64(a5 * b5 + carry)

        return (
            low=Uint384(d0=res0 + HALF_SHIFT * res1, d1=res2 + HALF_SHIFT * res3, d2=res4 + HALF_SHIFT * res5),
            high=Uint384(d0=res6 + HALF_SHIFT * res7, d1=res8 + HALF_SHIFT * res9, d2=res10 + HALF_SHIFT * carry),
        )
    end

    # Returns the floor value of the square root of a Uint384 integer.
    # func Uint384_sqrt{range_check_ptr}(n : Uint384) -> (res : # Uint384):
    # end

    # Returns 1 if the first unsigned integer is less than the second unsigned integer.
    func lt{range_check_ptr}(a : Uint384, b : Uint384) -> (res):
        if a.d2 == b.d2:
            if a.d1 == b.d1:
                return is_le(a.d0 + 1, b.d0)
            end
            return is_le(a.d1 + 1, b.d1)
        end
        return is_le(a.d2 + 1, b.d2)
    end

    # Returns the bitwise NOT of an integer.
    func not{range_check_ptr}(a : Uint384) -> (res : Uint384):
        return (Uint384(d0=ALL_ONES - a.d0, d1= ALL_ONES - a.d1, d2=ALL_ONES - a.d2))
    end

    # Returns the negation of an integer.
    # Note that the negation of -2**383 is -2**383.
    func neg{range_check_ptr}(a : Uint384) -> (res : Uint384):
        let (not_num) = not(a)
        let (res, _) = add(not_num, Uint384(d0=1, d1=0, d2=0))
        return (res)
    end

    # Returns 1 if the first signed integer is less than or equal to the second signed integer.
    # func Uint384_signed_le{range_check_ptr}(a : Uint384, b : # Uint384) -> (res):
    # end

    # Returns 1 if the signed integer is nonnegative.
    # @known_ap_change
    # func Uint384_signed_nn{range_check_ptr}(a : Uint384) -> (res):
    # end

    # Returns 1 if the first signed integer is less than or equal to the second signed integer
    # and is greater than or equal to zero.
    # func Uint384_signed_nn_le{range_check_ptr}(a : Uint384, b : Uint384) -> (res):
    # end

    # Unsigned integer division between two integers. Returns the quotient and the remainder.
    # Conforms to EVM specifications: division by 0 yields 0.
    func unsigned_div_rem{range_check_ptr}(a : Uint384, div : Uint384) -> (
        quotient : Uint384, remainder : Uint384
    ):
        alloc_locals
        local quotient : Uint384
        local remainder : Uint384

        # If div == 0, return (0, 0).
        if div.d0 + div.d1 + div.d2 == 0:
            return (quotient=Uint384(0, 0, 0), remainder=Uint384(0, 0, 0))
        end

        %{
            # TODO: how to import these from another file?
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
            div = pack(ids.div, num_bits_shift = 128)
            quotient, remainder = divmod(a, div)
            
            quotient_split = split(quotient, num_bits_shift=128, length=3)
            assert len(quotient_split) == 3
            
            ids.quotient.d0 = quotient_split[0]
            ids.quotient.d1 = quotient_split[1]
            ids.quotient.d2 = quotient_split[2]
            
            remainder_split = split(remainder, num_bits_shift=128, length=3)
            ids.remainder.d0 = remainder_split[0]
            ids.remainder.d1 = remainder_split[1]
            ids.remainder.d2 = remainder_split[2]
        %}
        let (res_mul : Uint384, carry : Uint384) = mul(quotient, div)
        assert carry = Uint384(0, 0, 0)

        let (check_val : Uint384, add_carry : felt) = add(res_mul, remainder)
        assert check_val = a
        assert add_carry = 0

        let (is_valid) = lt(remainder, div)
        assert is_valid = 1
        return (quotient=quotient, remainder=remainder)
    end
    
   
    # Subtracts two integers. Returns the result as a 384-bit integer.
    func sub{range_check_ptr}(a : Uint384, b : Uint384) -> (res : Uint384):
        let (b_neg) = neg(b)
        let (res, _) = add(a, b_neg)
        return (res)
    end

end
