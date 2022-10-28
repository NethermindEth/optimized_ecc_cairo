from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, bitwise_xor
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import assert_in_range, assert_le, assert_nn_le, assert_not_zero
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.pow import pow
from starkware.cairo.common.registers import get_ap, get_fp_and_pc
// Import uint384 files (path may change in the future)
from lib.uint384 import uint384_lib, Uint384, Uint384_expand, ALL_ONES

// Functions for operating 384-bit integers with 768-bit integers

// Represents an integer in the range [0, 2^768).
// NOTE: As in Uint256 and Uint384, all functions expect each d_0, d_1, ..., d_5 to be less than 2**128
struct Uint768 {
    d0: felt,
    d1: felt,
    d2: felt,
    d3: felt,
    d4: felt,
    d5: felt,
}

const HALF_SHIFT = 2 ** 64;
  
namespace uint384_extension_lib {
    // Adds a 768-bit integer and a 384-bit integer. Returns the result as a 768-bit integer and the (1-bit) carry.
    func add_uint768_and_uint384{range_check_ptr}(a: Uint768, b: Uint384) -> (
        res: Uint768, carry: felt
    ) {
        alloc_locals;

        let a_low = Uint384(d0=a.d0, d1=a.d1, d2=a.d2);
        let a_high = Uint384(d0=a.d3, d1=a.d4, d2=a.d5);

        let (sum_low, carry0) = uint384_lib.add(a_low, b);

        local res: Uint768;

        res.d0 = sum_low.d0;
        res.d1 = sum_low.d1;
        res.d2 = sum_low.d2;

        let (a_high_plus_carry, carry1) = uint384_lib.add(a_high, Uint384(carry0, 0, 0));

        res.d3 = a_high_plus_carry.d0;
        res.d4 = a_high_plus_carry.d1;
        res.d5 = a_high_plus_carry.d2;

        return (res, carry1);
    }

    // Multiplies a 768-bit integer and a 384-bit integer.
    // Returns the result (1152 bits) as a 768-bit integer (the lower bits of the result) and
    // a 384-bit integer (the higher bits of the result)
    func mul_uint768_by_uint384{range_check_ptr}(a: Uint768, b: Uint384) -> (
        low: Uint768, high: Uint384
    ) {
        alloc_locals;
        let (a0, a1) = uint384_lib.split_64(a.d0);
        let (a2, a3) = uint384_lib.split_64(a.d1);
        let (a4, a5) = uint384_lib.split_64(a.d2);
        let (a6, a7) = uint384_lib.split_64(a.d3);
        let (a8, a9) = uint384_lib.split_64(a.d4);
        let (a10, a11) = uint384_lib.split_64(a.d5);
        let (b0, b1) = uint384_lib.split_64(b.d0);
        let (b2, b3) = uint384_lib.split_64(b.d1);
        let (b4, b5) = uint384_lib.split_64(b.d2);

	local B0 = b0*HALF_SHIFT;
	local b12 = b1 + b2*HALF_SHIFT;
	local b34 = b3 + b4*HALF_SHIFT;

        let (res0, carry) = uint384_lib.split_128(a1 * B0 + a0 * b.d0);
        let (res2, carry) = uint384_lib.split_128(
            a3 * B0 + a2 * b.d0 + a1 * b12 + a0 * b.d1 + carry
        );
        let (res4, carry) = uint384_lib.split_128(
            a5 * B0 + a4 * b.d0 + a3 * b12 + a2 * b.d1 + a1 * b34 + a0 * b.d2 + carry
        );
        let (res6, carry) = uint384_lib.split_128(
            a7 * B0 + a6 * b.d0 + a5 * b12 + a4 * b.d1 + a3 * b34 + a2 * b.d2 + a1 * b5 + carry
        );
        let (res8, carry) = uint384_lib.split_128(
            a9 * B0 + a8 * b.d0 + a7 * b12 + a6 * b.d1 + a5 * b34 + a4 * b.d2 + a3 * b5 + carry
        );
        let (res10, carry) = uint384_lib.split_128(
            a11 * B0 + a10 * b.d0 + a9 * b12 + a8 * b.d1 + a7 * b34 + a6 * b.d2 + a5 * b5 + carry
        );
        let (res12, carry) = uint384_lib.split_128(
            a11 * b12 + a10 * b.d1 + a9 * b34 + a8 * b.d2 + a7 * b5 + carry
        );
        let (res14, carry) = uint384_lib.split_128(
            a11 * b34 + a10 * b.d2 + a9 * b5 + carry
        );
        // let (res16, carry) = split_64(a11 * b5 + carry)

        return (
	    low=Uint768(d0=res0, d1=res2, d2=res4, d3=res6, d4=res8, d5=res10),
            high=Uint384(d0=res12, d1=res14, d2=a11 * b5 + carry),
        );
    }
    
    func mul_uint768_by_uint384_expanded{range_check_ptr}(a: Uint768, b: Uint384_expand) -> (
        low: Uint768, high: Uint384
    ) {
        let (a0, a1) = uint384_lib.split_64(a.d0);
        let (a2, a3) = uint384_lib.split_64(a.d1);
        let (a4, a5) = uint384_lib.split_64(a.d2);
        let (a6, a7) = uint384_lib.split_64(a.d3);
        let (a8, a9) = uint384_lib.split_64(a.d4);
        let (a10, a11) = uint384_lib.split_64(a.d5);

        let (res0, carry) = uint384_lib.split_128(a1 * b.B0 + a0 * b.b01);
        let (res2, carry) = uint384_lib.split_128(
            a3 * b.B0 + a2 * b.b01 + a1 * b.b12 + a0 * b.b23 + carry
        );
        let (res4, carry) = uint384_lib.split_128(
            a5 * b.B0 + a4 * b.b01 + a3 * b.b12 + a2 * b.b23 + a1 * b.b34 + a0 * b.b45 + carry
        );
        let (res6, carry) = uint384_lib.split_128(
            a7 * b.B0 + a6 * b.b01 + a5 * b.b12 + a4 * b.b23 + a3 * b.b34 + a2 * b.b45 + a1 * b.b5 + carry
        );
        let (res8, carry) = uint384_lib.split_128(
            a9 * b.B0 + a8 * b.b01 + a7 * b.b12 + a6 * b.b23 + a5 * b.b34 + a4 * b.b45 + a3 * b.b5 + carry
        );
        let (res10, carry) = uint384_lib.split_128(
            a11 * b.B0 + a10 * b.b01 + a9 * b.b12 + a8 * b.b23 + a7 * b.b34 + a6 * b.b45 + a5 * b.b5 + carry
        );
        let (res12, carry) = uint384_lib.split_128(
            a11 * b.b12 + a10 * b.b23 + a9 * b.b34 + a8 * b.b45 + a7 * b.b5 + carry
        );
        let (res14, carry) = uint384_lib.split_128(
            a11 * b.b34 + a10 * b.b45 + a9 * b.b5 + carry
        );
        // let (res16, carry) = split_64(a11 * b.b5 + carry)

        return (
	    low=Uint768(d0=res0, d1=res2, d2=res4, d3=res6, d4=res8, d5=res10),
            high=Uint384(d0=res12, d1=res14, d2=a11 * b.b5 + carry),
        );
    }
    
    // Unsigned integer division between a 768-bit integer and a 384-bit integer. Returns the quotient (768 bits) and the remainder (384 bits).
    // Conforms to EVM specifications: division by 0 yields 0.
    func unsigned_div_rem_uint768_by_uint384{range_check_ptr}(a: Uint768, div: Uint384) -> (
        quotient: Uint768, remainder: Uint384
    ) {
        alloc_locals;
        local quotient: Uint768;
        local remainder: Uint384;

        // If div == 0, return (0, 0).
        if (div.d0 + div.d1 + div.d2 == 0) {
            return (quotient=Uint768(0, 0, 0, 0, 0, 0), remainder=Uint384(0, 0, 0));
        }

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

        let (res_mul_low: Uint768, res_mul_high: Uint384) = mul_uint768_by_uint384(quotient, div);

        assert res_mul_high = Uint384(0, 0, 0);

        let (check_val: Uint768, add_carry: felt) = add_uint768_and_uint384(res_mul_low, remainder);

        assert add_carry = 0;
        assert check_val = a;

        let (is_valid) = uint384_lib.lt(remainder, div);
        assert is_valid = 1;

        return (quotient=quotient, remainder=remainder);
    }
    
    // Unsigned integer division between a 768-bit integer and a 384-bit integer. Returns the quotient (768 bits) and the remainder (384 bits).
    func unsigned_div_rem_uint768_by_uint384_expand{range_check_ptr}(a: Uint768, div: Uint384_expand) -> (
        quotient: Uint768, remainder: Uint384
    ) {
        alloc_locals;
        local quotient: Uint768;
        local remainder: Uint384;

        %{
            def split(num: int, num_bits_shift: int, length: int):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift 
                return tuple(a)

            def pack(z, num_bits_shift: int) -> int:
                limbs = (z.b01, z.b23, z.b45)
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

        let (res_mul_low: Uint768, res_mul_high: Uint384) = mul_uint768_by_uint384_expanded(quotient, div);

        assert res_mul_high = Uint384(0, 0, 0);

        let (check_val: Uint768, add_carry: felt) = add_uint768_and_uint384(res_mul_low, remainder);

        assert add_carry = 0;
        assert check_val = a;
	
	let div2 = Uint384(div.b01,div.b23,div.b45);
        let (is_valid) = uint384_lib.lt(remainder, div2);
        assert is_valid = 1;

        return (quotient=quotient, remainder=remainder);
    }

    func eq{range_check_ptr}(a: Uint768, b: Uint768) -> (res: felt) {
        if (a.d5 != b.d5) {
            return (0,);
        }
        if (a.d4 != b.d4) {
            return (0,);
        }
        if (a.d3 != b.d3) {
            return (0,);
        }
        if (a.d2 != b.d2) {
            return (0,);
        }
        if (a.d1 != b.d1) {
            return (0,);
        }
        if (a.d0 != b.d0) {
            return (0,);
        }
        return (1,);
    }
    
    func bit_and{bitwise_ptr: BitwiseBuiltin*}(a: Uint768, b: Uint768) -> (
        res: Uint768
    ) {
        let (d0) = bitwise_and(a.d0, b.d0);
        let (d1) = bitwise_and(a.d1, b.d1);
        let (d2) = bitwise_and(a.d2, b.d2);
        let (d3) = bitwise_and(a.d3, b.d3);
        let (d4) = bitwise_and(a.d4, b.d4);
        let (d5) = bitwise_and(a.d5, b.d5);
        return (Uint768(d0, d1, d2, d3, d4, d5),);
    }
}
