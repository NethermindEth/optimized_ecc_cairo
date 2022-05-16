# @dev Algorithms from https://cacr.uwaterloo.ca/hac/about/chap14.pdf
from lib.BigInt6 import BigInt6, BigInt12, BASE, big_int_12_zero
from starkware.cairo.common.math_cmp import is_le, is_nn, is_not_zero
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

const MASK = 2 ** 64 - 1
const ZERO = 0

func mod_range{range_check_ptr}(dividend : felt) -> (remainder : felt):
    alloc_locals

    let (_, remainder) = unsigned_div_rem(dividend, BASE)

    return (remainder)
end

# Public namespace for multi_precision math
namespace multi_precision:
    # @dev truncates overflow on most signifigant bit
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
            res : BigInt6):
        alloc_locals

        let res_0 = x.d0 + y.d0

        # If x + y = sum, sum >= BASE then remainder
        # sum = 2^64 - 1 : No Remainder
        # sum = 2^64 : Remainder
        let (has_remainder_0) = is_le(BASE, res_0)

        let res_1 = x.d1 + y.d1 + has_remainder_0

        let (has_remainder_1) = is_le(BASE, res_1)

        let res_2 = x.d2 + y.d2 + has_remainder_1

        let (has_remainder_2) = is_le(BASE, res_2)

        let res_3 = x.d3 + y.d3 + has_remainder_2

        let (has_remainder_3) = is_le(BASE, res_3)

        let res_4 = x.d4 + y.d4 + has_remainder_3

        let (has_remainder_4) = is_le(BASE, res_4)

        let res_5 = x.d5 + y.d5 + has_remainder_4

        # Overflow trunaction
        let (d0) = bitwise_and(res_0, MASK)
        let (d1) = bitwise_and(res_1, MASK)
        let (d2) = bitwise_and(res_2, MASK)
        let (d3) = bitwise_and(res_3, MASK)
        let (d4) = bitwise_and(res_4, MASK)
        let (trunacted_d5) = bitwise_and(res_5, MASK)

        return (
            BigInt6(
            d0=d0,
            d1=d1,
            d2=d2,
            d3=d3,
            d4=d4,
            d5=trunacted_d5
            ))
    end

    # @dev truncates overflow on most signifigant bit
    # @dev Do you call it a carry or a remainder when underflowing a particular digit?
    # @dev Expects x > y! Does not handle underflow! Minimum value = 0
    func sub{range_check_ptr}(x : BigInt6, y : BigInt6) -> (res : BigInt6):
        alloc_locals

        let res_0 = x.d0 - y.d0

        # If x - y = sum, sum < 0 then carry
        # Cairo only has <= operator so add one to the left hand side to make <
        # sum = 0 : No Carry
        # sum = -1 : Carry
        let (has_carry_0) = is_le(res_0 + 1, ZERO)

        let res_1 = x.d1 - y.d1 - has_carry_0

        let (has_carry_1) = is_le(res_1 + 1, ZERO)

        let res_2 = x.d2 - y.d2 - has_carry_1

        let (has_carry_2) = is_le(res_2 + 1, ZERO)

        let res_3 = x.d3 - y.d3 - has_carry_2

        let (has_carry_3) = is_le(res_3 + 1, ZERO)

        let res_4 = x.d4 - y.d4 - has_carry_3

        let (has_carry_4) = is_le(res_4 + 1, ZERO)

        let res_5 = x.d5 - y.d5 - has_carry_4

        let (is_res_gte_zero) = is_nn(res_5)

        # Modulus on negative numbers
        let d0 = (res_0 + has_carry_0 * BASE) * is_res_gte_zero
        let d1 = (res_1 + has_carry_1 * BASE) * is_res_gte_zero
        let d2 = (res_2 + has_carry_2 * BASE) * is_res_gte_zero
        let d3 = (res_3 + has_carry_3 * BASE) * is_res_gte_zero
        let d4 = (res_4 + has_carry_4 * BASE) * is_res_gte_zero

        # Underflow  trunaction
        let trunacted_d5 = res_5 * is_res_gte_zero

        return (
            BigInt6(
            d0=d0,
            d1=d1,
            d2=d2,
            d3=d3,
            d4=d4,
            d5=trunacted_d5
            ))
    end

    func mul{range_check_ptr}(x : BigInt6, y : BigInt6) -> (product : BigInt12):
        alloc_locals

        let (c0 : felt, p0 : BigInt6) = mul_digit(x.d0, 0, y)
        let (c1 : felt, p1 : BigInt6) = mul_digit(x.d1, c0, y)
        let (c2 : felt, p2 : BigInt6) = mul_digit(x.d2, c1, y)
        let (c3 : felt, p3 : BigInt6) = mul_digit(x.d3, c2, y)
        let (c4 : felt, p4 : BigInt6) = mul_digit(x.d4, c3, y)
        let (c5 : felt, p5 : BigInt6) = mul_digit(x.d5, c4, y)

        let (product) = sum_products(p0, p1, p2, p3, p4, p5, c5)
        return (product)
    end

    # @dev algorithm is twice as efficent as multi-precision multiplication
    func square{range_check_ptr}(x : BigInt6) -> (product : BigInt12):
        alloc_locals

        # Multiply one digit by iteself
        let (r_0_0, d_0_0) = unsigned_div_rem(x.d0 * x.d0, BASE)
        # Multiply each subsequent digit combination twice (multiply by two)
        let (r_0_1, d_0_1) = unsigned_div_rem(2 * x.d0 * x.d1 + r_0_0, BASE)
        let (r_0_2, d_0_2) = unsigned_div_rem(2 * x.d0 * x.d2 + r_0_1, BASE)
        let (r_0_3, d_0_3) = unsigned_div_rem(2 * x.d0 * x.d3 + r_0_2, BASE)
        let (r_0_4, d_0_4) = unsigned_div_rem(2 * x.d0 * x.d4 + r_0_3, BASE)
        let (r6, d_0_5) = unsigned_div_rem(2 * x.d0 * x.d5 + r_0_4, BASE)

        let (r_1_1, d_1_1) = unsigned_div_rem(x.d1 * x.d1, BASE)
        let (r_1_2, d_1_2) = unsigned_div_rem(2 * x.d1 * x.d2 + r_1_1, BASE)
        let (r_1_3, d_1_3) = unsigned_div_rem(2 * x.d1 * x.d3 + r_1_2, BASE)
        let (r_1_4, d_1_4) = unsigned_div_rem(2 * x.d1 * x.d4 + r_1_3, BASE)
        let (r7, d_1_5) = unsigned_div_rem(2 * x.d1 * x.d5 + r_1_4, BASE)

        let (r_2_2, d_2_2) = unsigned_div_rem(x.d2 * x.d2, BASE)
        let (r_2_3, d_2_3) = unsigned_div_rem(2 * x.d2 * x.d3 + r_2_2, BASE)
        let (r_2_4, d_2_4) = unsigned_div_rem(2 * x.d2 * x.d4 + r_2_3, BASE)
        let (r8, d_2_5) = unsigned_div_rem(2 * x.d2 * x.d5 + r_2_4, BASE)

        let (r_3_3, d_3_3) = unsigned_div_rem(x.d3 * x.d3, BASE)
        let (r_3_4, d_3_4) = unsigned_div_rem(2 * x.d3 * x.d4 + r_3_3, BASE)
        let (r9, d_3_5) = unsigned_div_rem(2 * x.d3 * x.d5 + r_3_4, BASE)

        let (r_4_4, d_4_4) = unsigned_div_rem(x.d4 * x.d4, BASE)
        let (r10, d_4_5) = unsigned_div_rem(2 * x.d4 * x.d5 + r_4_4, BASE)

        let (r11, d_5_5) = unsigned_div_rem(x.d5 * x.d5, BASE)

        # add them together by their position in base 2*64
        let (c0, d0) = unsigned_div_rem(d_0_0, BASE)
        let (c1, d1) = unsigned_div_rem(d_0_1 + c0, BASE)
        let (c2, d2) = unsigned_div_rem(d_0_2 + d_1_1 + c1, BASE)
        let (c3, d3) = unsigned_div_rem(d_0_3 + d_1_2 + c2, BASE)
        let (c4, d4) = unsigned_div_rem(d_0_4 + d_1_3 + d_2_2 + c3, BASE)
        let (c5, d5) = unsigned_div_rem(d_0_5 + d_1_4 + d_2_3 + c4, BASE)
        let (c6, d6) = unsigned_div_rem(d_1_5 + d_2_4 + d_3_3 + r6 + c5, BASE)
        let (c7, d7) = unsigned_div_rem(d_2_5 + d_3_4 + r7 + c6, BASE)
        let (c8, d8) = unsigned_div_rem(d_3_5 + d_4_4 + r8 + c7, BASE)
        let (c9, d9) = unsigned_div_rem(d_4_5 + r9 + c8, BASE)
        let (c10, d10) = unsigned_div_rem(d_5_5 + r10 + c9, BASE)

        return (
            product=BigInt12(
            d0=d0, d1=d1, d2=d2, d3=d3, d4=d4, d5=d5, d6=d6, d7=d7, d8=d8, d9=d9, d10=d10, d11=c10 + r11
            ))
    end

    # @dev determines if x >= y
    # @dev returns 1 if true, 0 if false
    func ge{range_check_ptr}(x : BigInt6, y : BigInt6) -> (is_ge : felt):
        alloc_locals

        let (lead_limb_x : felt) = find_lead_limb_index(x)
        let (lead_limb_y : felt) = find_lead_limb_index(y)

        let (x_strictly_greater : felt) = is_nn(lead_limb_x - lead_limb_y - 1)
        let (y_strictly_greater : felt) = is_nn(lead_limb_y - lead_limb_x - 1)
        if x_strictly_greater == 1:
            return (1)
        end

        if y_strictly_greater == 1:
            return (0)
        end

        if lead_limb_x == 5:
            let (limb_5_gt : felt) = is_nn(x.d5 - y.d5 - 1)
            if limb_5_gt == 1:
                return (1)
            else:
                tempvar range_check_ptr = range_check_ptr
            end

            let (limb_5_lt : felt) = is_nn(y.d5 - x.d5 - 1)
            if limb_5_lt == 1:
                return (0)
            else:
                tempvar range_check_ptr = range_check_ptr
            end
        else:
            tempvar range_check_ptr = range_check_ptr
        end

        let (lead_limb_ge_4 : felt) = is_nn(lead_limb_x - 4)

        if lead_limb_ge_4 == 1:
            let (limb_4_gt : felt) = is_nn(x.d4 - y.d4 - 1)
            if limb_4_gt == 1:
                return (1)
            end

            let (limb_4_lt : felt) = is_nn(y.d4 - x.d4 - 1)
            if limb_4_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_3 : felt) = is_nn(lead_limb_x - 3)

        if lead_limb_ge_3 == 1:
            let (limb_3_gt : felt) = is_nn(x.d3 - y.d3 - 1)
            if limb_3_gt == 1:
                return (1)
            end

            let (limb_3_lt : felt) = is_nn(y.d3 - x.d3 - 1)
            if limb_3_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_2 : felt) = is_nn(lead_limb_x - 2)

        if lead_limb_ge_2 == 1:
            let (limb_2_gt : felt) = is_nn(x.d2 - y.d2 - 1)
            if limb_2_gt == 1:
                return (1)
            end

            let (limb_2_lt : felt) = is_nn(y.d2 - x.d2 - 1)
            if limb_2_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_1 : felt) = is_nn(lead_limb_x - 1)

        if lead_limb_ge_1 == 1:
            let (limb_1_gt : felt) = is_nn(x.d1 - y.d1 - 1)
            if limb_1_gt == 1:
                return (1)
            end

            let (limb_1_lt : felt) = is_nn(y.d1 - x.d1 - 1)
            if limb_1_lt == 1:
                return (0)
            end
        end

        let (limb_0_gt : felt) = is_nn(x.d0 - y.d0 - 1)
        if limb_0_gt == 1:
            return (1)
        end

        let (limb_0_lt : felt) = is_nn(y.d0 - x.d0 - 1)
        if limb_0_lt == 1:
            return (0)
        end

        return (1)
    end

    # @dev determines if x > y
    # @dev returns 1 if true, 0 if false
    func gt{range_check_ptr}(x : BigInt6, y : BigInt6) -> (is_gt : felt):
        alloc_locals

        let (lead_limb_x : felt) = find_lead_limb_index(x)
        let (lead_limb_y : felt) = find_lead_limb_index(y)

        let (x_strictly_greater : felt) = is_nn(lead_limb_x - lead_limb_y - 1)
        let (y_strictly_greater : felt) = is_nn(lead_limb_y - lead_limb_x - 1)

        if x_strictly_greater == 1:
            return (1)
        end

        if y_strictly_greater == 1:
            return (0)
        end

        if lead_limb_x == 5:
            let (limb_5_gt : felt) = is_nn(x.d5 - y.d5 - 1)
            if limb_5_gt == 1:
                return (1)
            else:
                tempvar range_check_ptr = range_check_ptr
            end

            let (limb_5_lt : felt) = is_nn(y.d5 - x.d5 - 1)
            if limb_5_lt == 1:
                return (0)
            else:
                tempvar range_check_ptr = range_check_ptr
            end
        else:
            tempvar range_check_ptr = range_check_ptr
        end

        let (lead_limb_ge_4 : felt) = is_nn(lead_limb_x - 4)

        if lead_limb_ge_4 == 1:
            let (limb_4_gt : felt) = is_nn(x.d4 - y.d4 - 1)
            if limb_4_gt == 1:
                return (1)
            end

            let (limb_4_lt : felt) = is_nn(y.d4 - x.d4 - 1)
            if limb_4_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_3 : felt) = is_nn(lead_limb_x - 3)

        if lead_limb_ge_3 == 1:
            let (limb_3_gt : felt) = is_nn(x.d3 - y.d3 - 1)
            if limb_3_gt == 1:
                return (1)
            end

            let (limb_3_lt : felt) = is_nn(y.d3 - x.d3 - 1)
            if limb_3_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_2 : felt) = is_nn(lead_limb_x - 2)

        if lead_limb_ge_2 == 1:
            let (limb_2_gt : felt) = is_nn(x.d2 - y.d2 - 1)
            if limb_2_gt == 1:
                return (1)
            end

            let (limb_2_lt : felt) = is_nn(y.d2 - x.d2 - 1)
            if limb_2_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_1 : felt) = is_nn(lead_limb_x - 1)

        if lead_limb_ge_1 == 1:
            let (limb_1_gt : felt) = is_nn(x.d1 - y.d1 - 1)
            if limb_1_gt == 1:
                return (1)
            end

            let (limb_1_lt : felt) = is_nn(y.d1 - x.d1 - 1)
            if limb_1_lt == 1:
                return (0)
            end
        end

        let (limb_0_gt : felt) = is_nn(x.d0 - y.d0 - 1)
        if limb_0_gt == 1:
            return (1)
        end

        let (limb_0_lt : felt) = is_nn(y.d0 - x.d0 - 1)
        if limb_0_lt == 1:
            return (0)
        end

        return (0)
    end

    # @dev only works for division where x and y are the same limbs. This happens to work well when paired with gt when performing modulus arithmetic.
    func div{range_check_ptr}(x : BigInt6, y : BigInt6) -> (q : BigInt6, r : BigInt6):
        alloc_locals

        # determine the leading digit of y, and x
        let (lead_limb_x : felt) = find_lead_limb_index(x)
        let (lead_limb_y : felt) = find_lead_limb_index(y)

        if lead_limb_x == lead_limb_y:
            let (r, q : felt) = divide_same_limb(x, y, 0)
            let q_normalized = BigInt6(d0=q, d1=0, d2=0, d3=0, d4=0, d5=0)
            return (q_normalized, r)
        end

        # while current bit of y > x, add one to quotient, sub lead bit from x

        # if lead bit index of y < x, then perform the following from x index to y index + 1
        # if xi == yt then qi-t-1 = base - 1, else qi-t-1 = floor(xi * base + xi-1) / yt
        # felt math loop to adjust assigned q1-t-1
        # sub lead bit from qi-t-1 * ybi-t-1
        # if x is negative add back one ybi-t-1 and minus 1 from qi-t-1

        # resulting x is the remainder

        let zero : BigInt6 = BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0)

        return (zero, zero)
    end
end

# @dev internal functions
func sum_products{range_check_ptr}(
        p0 : BigInt6, p1 : BigInt6, p2 : BigInt6, p3 : BigInt6, p4 : BigInt6, p5 : BigInt6,
        c : felt) -> (sum : BigInt12):
    let (sum_zero) = big_int_12_zero()

    let (c0, d0) = unsigned_div_rem(p0.d0, BASE)
    let (c1, d1) = unsigned_div_rem(p0.d1 + p1.d0 + c0, BASE)
    let (c2, d2) = unsigned_div_rem(p0.d2 + p1.d1 + p2.d0 + c1, BASE)
    let (c3, d3) = unsigned_div_rem(p0.d3 + p1.d2 + p2.d1 + p3.d0 + c2, BASE)
    let (c4, d4) = unsigned_div_rem(p0.d4 + p1.d3 + p2.d2 + p3.d1 + p4.d0 + c3, BASE)
    let (c5, d5) = unsigned_div_rem(p0.d5 + p1.d4 + p2.d3 + p3.d2 + p4.d1 + p5.d0 + c4, BASE)
    let (c6, d6) = unsigned_div_rem(p1.d5 + p2.d4 + p3.d3 + p4.d2 + p5.d1 + c5, BASE)
    let (c7, d7) = unsigned_div_rem(p2.d5 + p3.d4 + p4.d3 + p5.d2 + c6, BASE)
    let (c8, d8) = unsigned_div_rem(p3.d5 + p4.d4 + p5.d3 + c7, BASE)
    let (c9, d9) = unsigned_div_rem(p4.d5 + p5.d4 + c8, BASE)
    let (c10, d10) = unsigned_div_rem(p5.d5 + c9, BASE)

    return (
        sum=BigInt12(
        d0=d0, d1=d1, d2=d2, d3=d3, d4=d4, d5=d5, d6=d6, d7=d7, d8=d8, d9=d9, d10=d10, d11=c10 + c
        ))
end

func mul_digit{range_check_ptr}(x : felt, c : felt, y : BigInt6) -> (
        carry : felt, product : BigInt6):
    # TODO research if product(d0) > BASE then subtracting base will cost less gas
    let (r_0, d0) = unsigned_div_rem(x * y.d0, BASE)
    let (r_1, d1) = unsigned_div_rem((x * y.d1) + r_0, BASE)
    let (r_2, d2) = unsigned_div_rem((x * y.d2) + r_1, BASE)
    let (r_3, d3) = unsigned_div_rem((x * y.d3) + r_2, BASE)
    let (r_4, d4) = unsigned_div_rem((x * y.d4) + r_3, BASE)
    let (r_5, d5) = unsigned_div_rem((x * y.d5) + r_4 + c, BASE)

    return (carry=r_5, product=BigInt6(d0=d0, d1=d1, d2=d2, d3=d3, d4=d4, d5=d5))
end

# @dev uses is_not_zero, which assumes limb is non-negative
# @dev returns 0 index even if x is 0
func find_lead_limb_index{range_check_ptr}(x : BigInt6) -> (lead : felt):
    alloc_locals

    let (index_5_gt_0) = is_not_zero(x.d5)

    if index_5_gt_0 == 1:
        return (5)
    end

    let (index_4_gt_0) = is_not_zero(x.d4)

    if index_4_gt_0 == 1:
        return (4)
    end

    let (index_3_gt_0) = is_not_zero(x.d3)

    if index_3_gt_0 == 1:
        return (3)
    end

    let (index_2_gt_0) = is_not_zero(x.d2)

    if index_2_gt_0 == 1:
        return (2)
    end

    let (index_1_gt_0) = is_not_zero(x.d1)

    if index_1_gt_0 == 1:
        return (1)
    end

    return (0)
end

# @dev divide one BigInt6 by another BigInt6 that have the same maximum limb
# @dev the initial call should assign quotient to 0
# @dev does not check if y is 0
func divide_same_limb{range_check_ptr}(x : BigInt6, y : BigInt6, quotient : felt) -> (r : BigInt6, q : felt):
    let (y_gt_x) = multi_precision.gt(y, x)
    if y_gt_x == 1:
        return (x, quotient)
    end

    let (new_x : BigInt6) = multi_precision.sub(x, y)

    let (r, q) = divide_same_limb(new_x, y, quotient + 1)
    return (r, q)
end
