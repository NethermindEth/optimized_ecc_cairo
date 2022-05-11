# @dev Extensions of many of the functions from `multi_precision.cairo` in order to enable arithmetic with BigInt12 integers.
# @dev Some of these functions are only used within Barret's algorithm at the moment

from lib.BigInt6 import (
    BigInt12,
    BigInt6,
    from_bigint12_to_bigint6,
    from_bigint6_to_bigint12,
    BigInt18,
    BASE,
    big_int_12_zero,
)
from lib.multi_precision import multi_precision as mp
from lib.multi_precision import mul_digit
from starkware.cairo.common.math_cmp import is_le, is_nn, is_not_zero, is_nn_le
from starkware.cairo.common.math import unsigned_div_rem

const ZERO = 0

# Public namespace for BigInt12 multi_precision math
namespace multi_precision_bigint12:
    # @dev Multiplies a BigInt12 by a BigInt6. Used in Barret's algorithm
    func mul_bigint12_by_bigint6{range_check_ptr}(x : BigInt12, y : BigInt6) -> (
        product : BigInt18
    ):
        alloc_locals

        let (c0 : felt, p0 : BigInt6) = mul_digit(x.d0, 0, y)
        let (c1 : felt, p1 : BigInt6) = mul_digit(x.d1, c0, y)
        let (c2 : felt, p2 : BigInt6) = mul_digit(x.d2, c1, y)
        let (c3 : felt, p3 : BigInt6) = mul_digit(x.d3, c2, y)
        let (c4 : felt, p4 : BigInt6) = mul_digit(x.d4, c3, y)
        let (c5 : felt, p5 : BigInt6) = mul_digit(x.d5, c4, y)
        let (c6 : felt, p6 : BigInt6) = mul_digit(x.d6, c5, y)
        let (c7 : felt, p7 : BigInt6) = mul_digit(x.d7, c6, y)
        let (c8 : felt, p8 : BigInt6) = mul_digit(x.d8, c7, y)
        let (c9 : felt, p9 : BigInt6) = mul_digit(x.d9, c8, y)
        let (c10 : felt, p10 : BigInt6) = mul_digit(x.d10, c9, y)
        let (c11 : felt, p11 : BigInt6) = mul_digit(x.d11, c10, y)

        let (product : BigInt18) = sum_products_bigint12(
            p0, p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, c11
        )
        return (product)
    end

    # @dev Computes x - y, where x and y are BigInt12's
    func sub_bigint12{range_check_ptr}(x : BigInt12, y : BigInt12) -> (res : BigInt12):
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
        let (has_carry_5) = is_le(res_5 + 1, ZERO)

        let res_6 = x.d6 - y.d6 - has_carry_5
        let (has_carry_6) = is_le(res_6 + 1, ZERO)

        let res_7 = x.d7 - y.d7 - has_carry_6
        let (has_carry_7) = is_le(res_7 + 1, ZERO)

        let res_8 = x.d8 - y.d8 - has_carry_7
        let (has_carry_8) = is_le(res_8 + 1, ZERO)

        let res_9 = x.d9 - y.d9 - has_carry_8
        let (has_carry_9) = is_le(res_9 + 1, ZERO)

        let res_10 = x.d10 - y.d10 - has_carry_9
        let (has_carry_10) = is_le(res_10 + 1, ZERO)

        let res_11 = x.d11 - y.d11 - has_carry_10
        let (is_res_gte_zero) = is_nn(res_11)

        # Modulus on negative numbers
        let d0 = (res_0 + has_carry_0 * BASE) * is_res_gte_zero
        let d1 = (res_1 + has_carry_1 * BASE) * is_res_gte_zero
        let d2 = (res_2 + has_carry_2 * BASE) * is_res_gte_zero
        let d3 = (res_3 + has_carry_3 * BASE) * is_res_gte_zero
        let d4 = (res_4 + has_carry_4 * BASE) * is_res_gte_zero
        let d5 = (res_5 + has_carry_5 * BASE) * is_res_gte_zero
        let d6 = (res_6 + has_carry_6 * BASE) * is_res_gte_zero
        let d7 = (res_7 + has_carry_7 * BASE) * is_res_gte_zero
        let d8 = (res_8 + has_carry_8 * BASE) * is_res_gte_zero
        let d9 = (res_9 + has_carry_9 * BASE) * is_res_gte_zero
        let d10 = (res_10 + has_carry_10 * BASE) * is_res_gte_zero

        # Underflow  trunaction
        let trunacted_d11 = res_11 * is_res_gte_zero
        return (
            BigInt12(
            d0=d0,
            d1=d1,
            d2=d2,
            d3=d3,
            d4=d4,
            d5=d5, d6=d6, d7=d7, d8=d8, d9=d9, d10=d10,
            d11=trunacted_d11
            ),
        )
    end

    # @dev takes a BigInt12 with limbs d_0, ..., d_11 and returns the BigInt12 with limbs d_(power), ..., d_11, 0, ..., 0
    # @dev This is equivalent to computing `math.floor(number / BASE**power)
    # @albert_g NOTE: The function is written in this "hardcoded" form for efficiency (otherwise we could use recursion or pointers in some more elegant way TODO: check if we want to do the latter)
    func floor_divide_by_power_of_base_bigint12{range_check_ptr}(
        number : BigInt12, power : felt
    ) -> (shifted_number : BigInt12):
        with_attr error_message("`power` should be >=0 and <=12. Provided power = {power}"):
            let (bool) = is_nn_le(power, 12)
            assert bool = 1
        end

        with_attr error_message(
                "Exception encountered at function `floor_divide_by_power_of_base_bigint12`"):
            if power == 0:
                return (number)
            end

            if power == 12:
                let (all_zeros) = big_int_12_zero()
                return (all_zeros)
            end

            if power == 1:
                let shifted_number = BigInt12(
                    d0=number.d1,
                    d1=number.d2,
                    d2=number.d3,
                    d3=number.d4,
                    d4=number.d5,
                    d5=number.d6,
                    d6=number.d7,
                    d7=number.d8,
                    d8=number.d9,
                    d9=number.d10,
                    d10=number.d11,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 2:
                let shifted_number = BigInt12(
                    d0=number.d2,
                    d1=number.d3,
                    d2=number.d4,
                    d3=number.d5,
                    d4=number.d6,
                    d5=number.d7,
                    d6=number.d8,
                    d7=number.d9,
                    d8=number.d10,
                    d9=number.d11,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 3:
                let shifted_number = BigInt12(
                    d0=number.d3,
                    d1=number.d4,
                    d2=number.d5,
                    d3=number.d6,
                    d4=number.d7,
                    d5=number.d8,
                    d6=number.d9,
                    d7=number.d10,
                    d8=number.d11,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 4:
                let shifted_number = BigInt12(
                    d0=number.d4,
                    d1=number.d5,
                    d2=number.d6,
                    d3=number.d7,
                    d4=number.d8,
                    d5=number.d9,
                    d6=number.d10,
                    d7=number.d11,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 5:
                let shifted_number = BigInt12(
                    d0=number.d5,
                    d1=number.d6,
                    d2=number.d7,
                    d3=number.d8,
                    d4=number.d9,
                    d5=number.d10,
                    d6=number.d11,
                    d7=0,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 6:
                let shifted_number = BigInt12(
                    d0=number.d6,
                    d1=number.d7,
                    d2=number.d8,
                    d3=number.d9,
                    d4=number.d10,
                    d5=number.d11,
                    d6=0,
                    d7=0,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 7:
                let shifted_number = BigInt12(
                    d0=number.d7,
                    d1=number.d8,
                    d2=number.d9,
                    d3=number.d10,
                    d4=number.d11,
                    d5=0,
                    d6=0,
                    d7=0,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 8:
                let shifted_number = BigInt12(
                    d0=number.d8,
                    d1=number.d9,
                    d2=number.d10,
                    d3=number.d11,
                    d4=0,
                    d5=0,
                    d6=0,
                    d7=0,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 9:
                let shifted_number = BigInt12(
                    d0=number.d9,
                    d1=number.d10,
                    d2=number.d11,
                    d3=0,
                    d4=0,
                    d5=0,
                    d6=0,
                    d7=0,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 10:
                let shifted_number = BigInt12(
                    d0=number.d10,
                    d1=number.d11,
                    d2=0,
                    d3=0,
                    d4=0,
                    d5=0,
                    d6=0,
                    d7=0,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end

            # Case `power = 11`
            let shifted_number = BigInt12(
                d0=number.d11, d1=0, d2=0, d3=0, d4=0, d5=0, d6=0, d7=0, d8=0, d9=0, d10=0, d11=0
            )
        end
        return (shifted_number)
    end

    func are_eq_bigint12(num1 : BigInt12, num2 : BigInt12) -> (bool : felt):
        if num1.d11 != num2.d11:
            return (0)
        end
        if num1.d10 != num2.d10:
            return (0)
        end
        if num1.d9 != num2.d9:
            return (0)
        end
        if num1.d8 != num2.d8:
            return (0)
        end
        if num1.d7 != num2.d7:
            return (0)
        end
        if num1.d6 != num2.d6:
            return (0)
        end
        if num1.d5 != num2.d5:
            return (0)
        end
        if num1.d4 != num2.d4:
            return (0)
        end
        if num1.d3 != num2.d3:
            return (0)
        end
        if num1.d2 != num2.d2:
            return (0)
        end
        if num1.d1 != num2.d1:
            return (0)
        end
        if num1.d0 != num2.d0:
            return (0)
        end
        return (1)
    end

    # @dev determines if x >= y
    # @dev returns 1 if true, 0 if false
    func ge_bigint12{range_check_ptr}(x : BigInt12, y : BigInt12) -> (is_ge : felt):
        alloc_locals

        let (lead_limb_x : felt) = find_lead_limb_index_bigint12(x)
        let (lead_limb_y : felt) = find_lead_limb_index_bigint12(y)

        let (x_strictly_greater : felt) = is_nn(lead_limb_x - lead_limb_y - 1)
        let (y_strictly_greater : felt) = is_nn(lead_limb_y - lead_limb_x - 1)
        if x_strictly_greater == 1:
            return (1)
        end

        if y_strictly_greater == 1:
            return (0)
        end

        if lead_limb_x == 11:
            let (limb_11_gt : felt) = is_nn(x.d11 - y.d11 - 1)
            if limb_11_gt == 1:
                return (1)
            else:
                tempvar range_check_ptr = range_check_ptr
            end

            let (limb_11_lt : felt) = is_nn(y.d11 - x.d11 - 1)
            if limb_11_lt == 1:
                return (0)
            else:
                tempvar range_check_ptr = range_check_ptr
            end
        else:
            tempvar range_check_ptr = range_check_ptr
        end

        let (lead_limb_ge_10 : felt) = is_nn(lead_limb_x - 10)

        if lead_limb_ge_10 == 1:
            let (limb_10_gt : felt) = is_nn(x.d10 - y.d10 - 1)
            if limb_10_gt == 1:
                return (1)
            end

            let (limb_10_lt : felt) = is_nn(y.d10 - x.d10 - 1)
            if limb_10_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_9 : felt) = is_nn(lead_limb_x - 9)

        if lead_limb_ge_9 == 1:
            let (limb_9_gt : felt) = is_nn(x.d9 - y.d9 - 1)
            if limb_9_gt == 1:
                return (1)
            end

            let (limb_9_lt : felt) = is_nn(y.d9 - x.d9 - 1)
            if limb_9_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_8 : felt) = is_nn(lead_limb_x - 8)

        if lead_limb_ge_8 == 1:
            let (limb_8_gt : felt) = is_nn(x.d8 - y.d8 - 1)
            if limb_8_gt == 1:
                return (1)
            end

            let (limb_8_lt : felt) = is_nn(y.d8 - x.d8 - 1)
            if limb_8_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_7 : felt) = is_nn(lead_limb_x - 7)

        if lead_limb_ge_7 == 1:
            let (limb_7_gt : felt) = is_nn(x.d7 - y.d7 - 1)
            if limb_7_gt == 1:
                return (1)
            end

            let (limb_7_lt : felt) = is_nn(y.d7 - x.d7 - 1)
            if limb_7_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_6 : felt) = is_nn(lead_limb_x - 6)

        if lead_limb_ge_6 == 1:
            let (limb_6_gt : felt) = is_nn(x.d6 - y.d6 - 1)
            if limb_6_gt == 1:
                return (1)
            end

            let (limb_6_lt : felt) = is_nn(y.d6 - x.d6 - 1)
            if limb_6_lt == 1:
                return (0)
            end
        end

        let (lead_limb_ge_5 : felt) = is_nn(lead_limb_x - 5)

        if lead_limb_ge_5 == 1:
            let (limb_5_gt : felt) = is_nn(x.d5 - y.d5 - 1)
            if limb_5_gt == 1:
                return (1)
            end

            let (limb_5_lt : felt) = is_nn(y.d5 - x.d5 - 1)
            if limb_5_lt == 1:
                return (0)
            end
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

    # @dev This is an auxiliary function used in Barret's algorithm. Likely to be merged with `floor_divide_by_power_of_base_bigint12`
    func mult_by_power_of_base_bigint12{range_check_ptr}(number : BigInt12, power : felt) -> (
        shifted_number : BigInt12
    ):
        with_attr error_message("`power` should be >=0 and <=12. Provided power = {power}"):
            # @dev Placeholder requirement
            let (bool) = is_nn_le(power, 6)
            assert bool = 1
        end

        with_attr error_message(
                "Exception encountered at function `mult_by_power_of_base_bigint12`"):
            if power == 0:
                return (number)
            end

            if power == 6:
                let shifted_number = BigInt12(
                    d0=0,
                    d1=0,
                    d2=0,
                    d3=0,
                    d4=0,
                    d5=0,
                    d6=number.d0,
                    d7=number.d1,
                    d8=number.d2,
                    d9=number.d3,
                    d10=number.d4,
                    d11=number.d5,
                )
                return (shifted_number)
            end

            if power == 5:
                let shifted_number = BigInt12(
                    d0=0,
                    d1=0,
                    d2=0,
                    d3=0,
                    d4=0,
                    d5=number.d0,
                    d6=number.d1,
                    d7=number.d2,
                    d8=number.d3,
                    d9=number.d4,
                    d10=number.d5,
                    d11=0,
                )
                return (shifted_number)
            end

            if power == 4:
                let shifted_number = BigInt12(
                    d0=0,
                    d1=0,
                    d2=0,
                    d3=0,
                    d4=number.d0,
                    d5=number.d1,
                    d6=number.d2,
                    d7=number.d3,
                    d8=number.d4,
                    d9=number.d5,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end

            if power == 3:
                let shifted_number = BigInt12(
                    d0=0,
                    d1=0,
                    d2=0,
                    d3=number.d0,
                    d4=number.d1,
                    d5=number.d2,
                    d6=number.d3,
                    d7=number.d4,
                    d8=number.d5,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end

            if power == 2:
                let shifted_number = BigInt12(
                    d0=0,
                    d1=0,
                    d2=number.d0,
                    d3=number.d1,
                    d4=number.d2,
                    d5=number.d3,
                    d6=number.d4,
                    d7=number.d5,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            if power == 1:
                let shifted_number = BigInt12(
                    d0=0,
                    d1=number.d0,
                    d2=number.d1,
                    d3=number.d2,
                    d4=number.d3,
                    d5=number.d4,
                    d6=number.d5,
                    d7=0,
                    d8=0,
                    d9=0,
                    d10=0,
                    d11=0,
                )
                return (shifted_number)
            end
            return (number)
        end
    end

    # @dev Mods a BigInt12 by a power of BASE
    func mod_by_power_of_base_bigint12{range_check_ptr}(number : BigInt12, power : felt) -> (
        result : BigInt12
    ):
        let (is_power_nn_and_le_11) = is_nn_le(power, 11)
        assert is_power_nn_and_le_11 = 1
        

        if power == 0:
            let (result) = big_int_12_zero()
            return (result)
        end

        # NOTE: Hardcoded the cases for efficiency
        if power == 1:
            let result = BigInt12(d0 =number.d0, d1=0,  d2=0, d3=0,d4=0, d5=0, d6=0, d7=0, d8=0, d9=0,d10= 0, d11=0)
            return (result)
        end

        if power == 2:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=0, d3=0,d4=0, d5=0, d6=0, d7=0, d8=0, d9=0,d10= 0, d11=0)
            return (result)
        end

        if power == 3:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=0, d4=0, d5=0, d6=0, d7=0, d8=0, d9=0,d10= 0, d11=0)
            return (result)
        end

        if power == 4:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=0, d5=0, d6=0, d7=0, d8=0, d9=0,d10= 0, d11=0)
            return (result)
        end

        if power == 5:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=number.d4, d5=0, d6=0, d7=0, d8=0, d9=0,d10= 0, d11=0)
            return (result)
        end

        if power == 6:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=number.d4, d5=number.d5, d6=0, d7=0, d8=0, d9=0,d10= 0, d11=0)
            return (result)
        end

        if power == 7:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=number.d4, d5=number.d5, d6=number.d6, d7=0, d8=0, d9=0, d10=0, d11=0)
            return (result)
        end

        if power == 8:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=number.d4, d5=number.d5, d6=number.d5, d7=number.d7, d8=0, d9=0, d10=0, d11=0)
            return (result)
        end

        if power == 9:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=number.d4, d5=number.d5, d6=number.d5, d7=number.d7, d8=number.d8, d9=0, d10=0,d11= 0)
            return (result)
        end

        if power == 10:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=number.d4, d5=number.d5, d6=number.d5, d7=number.d7, d8=number.d8, d9=number.d9, d10=0, d11=0)
            return (result)
        end
        
        if power == 11:
            let result = BigInt12(d0 =number.d0, d1=number.d1, d2=number.d2, d3=number.d3, d4=number.d4, d5=number.d5, d6=number.d5, d7=number.d7, d8=number.d8, d9=number.d9, d10=number.d10, d11=0)
            return (result)
        end
        # power == 12: nothing changes
        return (number)
    end
end

# @dev internal
func sum_products_bigint12{range_check_ptr}(
    p0 : BigInt6,
    p1 : BigInt6,
    p2 : BigInt6,
    p3 : BigInt6,
    p4 : BigInt6,
    p5 : BigInt6,
    p6 : BigInt6,
    p7 : BigInt6,
    p8 : BigInt6,
    p9 : BigInt6,
    p10 : BigInt6,
    p11 : BigInt6,
    c : felt,
) -> (sum : BigInt18):
    let (sum_zero) = big_int_12_zero()

    let (c0, d0) = unsigned_div_rem(p0.d0, BASE)
    let (c1, d1) = unsigned_div_rem(p0.d1 + p1.d0 + c0, BASE)
    let (c2, d2) = unsigned_div_rem(p0.d2 + p1.d1 + p2.d0 + c1, BASE)
    let (c3, d3) = unsigned_div_rem(p0.d3 + p1.d2 + p2.d1 + p3.d0 + c2, BASE)
    let (c4, d4) = unsigned_div_rem(p0.d4 + p1.d3 + p2.d2 + p3.d1 + p4.d0 + c3, BASE)
    let (c5, d5) = unsigned_div_rem(p0.d5 + p1.d4 + p2.d3 + p3.d2 + p4.d1 + p5.d0 + c4, BASE)
    let (c6, d6) = unsigned_div_rem(p1.d5 + p2.d4 + p3.d3 + p4.d2 + p5.d1 + p6.d0 + c5, BASE)
    let (c7, d7) = unsigned_div_rem(p2.d5 + p3.d4 + p4.d3 + p5.d2 + p6.d1 + p7.d0 + c6, BASE)
    let (c8, d8) = unsigned_div_rem(p3.d5 + p4.d4 + p5.d3 + p6.d2 + p7.d1 + p8.d0 + c7, BASE)
    let (c9, d9) = unsigned_div_rem(p4.d5 + p5.d4 + p6.d3 + p7.d2 + p8.d1 + p9.d0 + c8, BASE)
    let (c10, d10) = unsigned_div_rem(p5.d5 + p6.d4 + p7.d3 + p8.d2 + p9.d1 + p10.d0 + c9, BASE)
    let (c11, d11) = unsigned_div_rem(p6.d5 + p7.d4 + p8.d3 + p9.d2 + p10.d1 + p11.d0 + c10, BASE)
    let (c12, d12) = unsigned_div_rem(p7.d5 + p8.d4 + p9.d3 + p10.d2 + p11.d1 + c11, BASE)
    let (c13, d13) = unsigned_div_rem(p8.d5 + p9.d4 + p10.d3 + p11.d2 + c12, BASE)
    let (c14, d14) = unsigned_div_rem(p9.d5 + p10.d4 + p11.d3 + c13, BASE)
    let (c15, d15) = unsigned_div_rem(p10.d5 + p11.d4 + c14, BASE)
    let (c16, d16) = unsigned_div_rem(p11.d5 + c15, BASE)

    # TODO: does it need to continue? Should I use BigInt24 for more generality?
    return (
        sum=BigInt18(
        d0=d0, d1=d1, d2=d2, d3=d3, d4=d4, d5=d5, d6=d6, d7=d7, d8=d8, d9=d9, d10=d10, d11=d11, d12=d12, d13=d13, d14=d14, d15=d15, d16=d16, d17=c16 + c
        ),
    )
end

# @dev uses is_not_zero, which assumes limb is non-negative
# @dev returns 0 index even if x is 0
func find_lead_limb_index_bigint12{range_check_ptr}(x : BigInt12) -> (lead : felt):
    alloc_locals

    # NOTE: As in other spots, this could be done with recursion but probably it is more efficient as it is now

    let (index_11_gt_0) = is_not_zero(x.d11)
    if index_11_gt_0 == 1:
        return (11)
    end

    let (index_10_gt_0) = is_not_zero(x.d10)
    if index_10_gt_0 == 1:
        return (10)
    end

    let (index_9_gt_0) = is_not_zero(x.d9)
    if index_9_gt_0 == 1:
        return (9)
    end

    let (index_8_gt_0) = is_not_zero(x.d8)
    if index_8_gt_0 == 1:
        return (8)
    end

    let (index_7_gt_0) = is_not_zero(x.d7)
    if index_7_gt_0 == 1:
        return (7)
    end

    let (index_6_gt_0) = is_not_zero(x.d6)
    if index_6_gt_0 == 1:
        return (6)
    end

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
