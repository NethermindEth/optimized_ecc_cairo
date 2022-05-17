from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, bitwise_xor
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import assert_in_range, assert_le, assert_nn_le, assert_not_zero
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.pow import pow
from starkware.cairo.common.registers import get_ap, get_fp_and_pc

from lib.uint384 import uint384_lib, Uint384

# Represents an integer in the range [0, 2^768).
struct Uint768:
    member d0 : felt
    member d1 : felt
    member d2 : felt
    member d3 : felt
    member d4 : felt
    member d5 : felt
end

namespace uint384_extension_lib:
    # @dev to be used after multuplying two Uint384, if modular reduction is needed
    # @dev the 768 bit number n is given as two Uint384's (matching the output of `mul`), so that n= low + 2**385 * high
    func unsigned_div_rem_768_bits_by_uint384{range_check_ptr}(a : Uint768, div : Uint384) -> (
            quotient : Uint768, remainder : Uint384):
        alloc_locals
        local quotient : Uint768
        local remainder : Uint384

        # If div == 0, return (0, 0).
        if div.d0 + div.d1 + div.d2 == 0:
            return (quotient=Uint768(0, 0, 0, 0, 0, 0), remainder=Uint384(0, 0, 0))
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
                
            def pack_extended(z, num_bits_shift: int) -> int:
                limbs = (z.d0, z.d1, z.d2, z.d3, z.d4, z.d5)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            a = pack_extended(ids.a, num_bits_shift = 128)
            div = pack(ids.div, num_bits_shift = 128)

            quotient, remainder = divmod(a, div)

            quotient_split = split(quotient, num_bits_shift=128, length=6)

            ids.quotient.d0 = quotient_split[0]
            ids.quotient.d1 = quotient_split[1]
            ids.quotient.d2 = quotient_split[2]
            ids.quotient.d3 = quotient_split[3]
            ids.quotient.d4 = quotient_split[4]
            ids.quotient.d5 = quotient_split[5]

            remainder_split = split(remainder, num_bits_shift=128, length=3)
            ids.remainder.d0 = remainder_split[0]
            ids.remainder.d1 = remainder_split[1]
            ids.remainder.d2 = remainder_split[2]
        %}

        let (res_mul_low : Uint768, res_mul_high : Uint384) = mul_uint768_by_uint384(quotient, div)

        assert res_mul_high = Uint384(0, 0, 0)

        let (check_val : Uint768, add_carry : felt) = add_uint768_and_uint384(
            res_mul_low, remainder)

        assert add_carry = 0
        assert check_val = a

        let (is_valid) = uint384_lib.lt(remainder, div)
        assert is_valid = 1

        return (quotient=quotient, remainder=remainder)
    end

    # TODO: document
    func mul_uint768_by_uint384{range_check_ptr}(a : Uint768, b : Uint384) -> (
            low : Uint768, high : Uint384):
        alloc_locals
        let a_low = Uint384(d0=a.d0, d1=a.d1, d2=a.d2)
        let a_high = Uint384(d0=a.d3, d1=a.d4, d2=a.d5)

        let (low_low, low_high) = uint384_lib.mul(a_low, b)
        let (high_low, high_high) = uint384_lib.mul(a_high, b)

        let (sum_low_high_and_high_low : Uint384, carry0 : felt) = uint384_lib.add(
            low_high, high_low)

        # TODO: sanity check: to be removed later on
        assert_le(carry0, 2)
        # TODO: innefficient? Avoid doing this sum if carry=0
        let (high_high_with_carry : Uint384, carry1 : felt) = uint384_lib.add(
            high_high, Uint384(carry0, 0, 0))
        # TODO: sanity check: to be removed later on

        assert carry1 = 0

        local res_low : Uint768
        local res_high : Uint384

        res_low.d0 = low_low.d0
        res_low.d1 = low_low.d1
        res_low.d2 = low_low.d2

        res_low.d3 = sum_low_high_and_high_low.d0
        res_low.d4 = sum_low_high_and_high_low.d1
        res_low.d5 = sum_low_high_and_high_low.d2

        res_high.d0 = high_high_with_carry.d0
        res_high.d1 = high_high_with_carry.d1
        res_high.d2 = high_high_with_carry.d2

        return (low=res_low, high=res_high)
    end

    func add_uint768_and_uint384{range_check_ptr}(a : Uint768, b : Uint384) -> (
            res : Uint768, carry : felt):
        alloc_locals

        let a_low = Uint384(d0=a.d0, d1=a.d1, d2=a.d2)
        let a_high = Uint384(d0=a.d3, d1=a.d4, d2=a.d5)

        let (sum_low, carry0) = uint384_lib.add(a_low, b)

        local res : Uint768

        res.d0 = sum_low.d0
        res.d1 = sum_low.d1
        res.d2 = sum_low.d2

        let (a_high_plus_carry, carry1) = uint384_lib.add(a_high, Uint384(carry0, 0, 0))

        res.d3 = a_high_plus_carry.d0
        res.d4 = a_high_plus_carry.d1
        res.d5 = a_high_plus_carry.d2

        return (res, carry1)
    end
end
