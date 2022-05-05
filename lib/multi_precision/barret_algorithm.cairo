from lib.BigInt6 import (
    BigInt6,
    BigInt12,
    BASE,
    big_int_12_zero,
    from_bigint12_to_bigint6,
    from_bigint6_to_bigint12,
)
# from lib.multi_precision import mul_digit, sum_products
from starkware.cairo.common.math_cmp import is_le, is_nn, is_not_zero, is_nn_le
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin

from lib.multi_precision import multi_precision as mp

const ZERO = 0

# @albert_g reduces a BigInt12 modulo a BigInt6.
# @albert_g follows Chapter 14 of the Handbook of Applied Cryptography by Menezes et al., including the notation. Note `k=6` for us.
# @albert_g TODO: if the parameter `modulo` is fixed, then `mu` should be precomputed (e.g. hardcoded) as it
# is a fixed constant. At some point we should make a leaner version of this function by removing the argument
# `modulo` and removing the computation of `mu` (as both modulo and mu will be hardcoded in our applications)
func barret_reduction{range_check_ptr}(number : BigInt12, modulo : BigInt6) -> (
    remainder : BigInt6
):
    alloc_locals

    # This is only to match the notation of the book
    let x = number

    # This is to have `m` have the same type as `x`. Makes adapting all functions from `multi_precision_cairo.cairo` simpler. TODO: However we may want to keep `m` as a BigInt6 for efficiency purposes.
    let (m) = from_bigint6_to_bigint12(modulo)

    let mu = 0

    # Note that wath the `left_shift_limbs` function actually does is compute `floor(x/(BASE**shift))` in a supper efficient way
    let (q1) = left_shift_limbs(number=x, shift=5)
    
    #TODO: q2 can have more than 2k (i.e. 12) limbs. Need a BigInt18
    let (q2) = multi_precision_mul_bigint12(q1, m)
    let (local q3) = left_shift_limbs(number=q2, shift=7)

    let (r1) = mod_by_power_of_base(x, 7)
    
    #TODO: At this point `q3` and `m` have 6 limbs, convert them to BigInt6
    let (q3_times_m) = mp.multi_precision_mul(q3, m)
    let (r2) = mod_by_power_of_base(q3_times_m, 7)

    let (is_r1_le_r2) = multi_precision_ge_bigint12(r2, r1)
    if is_r1_le_r2 == 1:
        assert r1.d7 = r1.d7 + 1
    end

    let (r) = multi_precision_sub_bigint12(r1, r2)

    let (final_r_bigint12) = _aux_fun_for_barret_reduction(r, m)
    let (final_r_bigint6) = from_bigint12_to_bigint6(final_r_bigint12)
    return (final_r_bigint6)
end

func multi_precision_mul_bigint12{range_check_ptr}(x : BigInt12, y : BigInt12) -> (
    product : BigInt12
):
    # TODO: implement for BigInt12
    alloc_locals

    let (c0 : felt, p0 : BigInt12) = mul_digit_bigint12(x.d0, 0, y)
    let (c1 : felt, p1 : BigInt12) = mul_digit_bigint12(x.d1, c0, y)
    let (c2 : felt, p2 : BigInt12) = mul_digit_bigint12(x.d2, c1, y)
    let (c3 : felt, p3 : BigInt12) = mul_digit_bigint12(x.d3, c2, y)
    let (c4 : felt, p4 : BigInt12) = mul_digit_bigint12(x.d4, c3, y)
    let (c5 : felt, p5 : BigInt12) = mul_digit_bigint12(x.d5, c4, y)

    let (product : BigInt12) = sum_products_bigint12(p0, p1, p2, p3, p4, p5, c5)
    return (product)
end

func _aux_fun_for_barret_reduction(r : BigInt12, m : BigInt12) -> (new_r : BigInt12):
    let (aux_bool) = is_nn_le(r, m - 1)
    if aux_bool == 1:
        return (r)
    end
    let (new_r) = mp.multi_precision_sub(r, m)
    return _aux_fun_for_barret_reduction(new_r, m)
end

func mod_by_power_of_base(number : BigInt12, power : felt) -> (result : BigInt12):
    assert (is_nn_le(power, 11)) = 1

    if power == 0:
        let (result) = big_int_12_zero()
        return (result)
    end

    let result = new BigInt12()

    # NOTE: This could be a recursion, but perhaps it is more efficient
    # to hard code it like this.
    result.d0 = number.d0
    if power == 1:
        return (result)
    end

    result.d1 = number.d1
    if power == 2:
        return (result)
    end

    result.d2 = number.d2
    if power == 3:
        return (result)
    end

    result.d3 = number.d3
    if power == 4:
        return (result)
    end

    result.d4 = number.d4
    if power == 5:
        return (result)
    end

    result.d5 = number.d5
    if power == 6:
        return (result)
    end

    result.d6 = number.d6
    if power == 7:
        return (result)
    end

    result.d7 = number.d7
    if power == 8:
        return (result)
    end

    result.d8 = number.d8
    if power == 9:
        return (result)
    end

    result.d9 = number.d9
    if power == 10:
        return (result)
    end

    result.d10 = number.d10
    return (result)
end

# @albert_g takes a BigInt12 with limbs d_0, ..., d_11 and returns the BigInt12 with limbs d_(shift), ..., d_11, 0, ..., 0
# @albert_g NOTE: The function could be written much more succintly with using recursion calls. Instead I wrote it in this "hardcoded" form for efficiency (I understand that nested recursion is quite expensive)
func left_shift_limbs(number : BigInt12, shift : felt) -> (shifted_number : BigInt12):
    with_attr error_message("`shift` should be >=0 and <=12. Provided shift = {shift}"):
        let (bool) = is_nn_le(shift, 12)
        assert bool = 1
    end

    if shift == 0:
        return (number)
    end

    # Initialize the final BigInt12
    let shifted_number = big_int_12_zero()
    if shift == 12:
        return (shifted_number)
    end

    let (number_memory_location_plus_shift) = number + shift

    assert shifted_number.d0 = [number_memory_location_plus_shift]
    if shift == 11:
        return (shifted_number)
    end

    assert shifted_number.d1 = [number_memory_location_plus_shift + 1]
    if shift == 10:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 2]
    if shift == 9:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 3]
    if shift == 8:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 4]
    if shift == 7:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 5]
    if shift == 6:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 6]
    if shift == 5:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 7]
    if shift == 4:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 8]
    if shift == 3:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 9]
    if shift == 2:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 10]
    if shift == 1:
        return (shifted_number)
    end
end

func multi_precision_sub_bigint12{range_check_ptr}(x : BigInt12, y : BigInt12) -> (res : BigInt12):
    # TODO: implement for BigInt12

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
        BigInt12(
        d0=d0,
        d1=d1,
        d2=d2,
        d3=d3,
        d4=d4,
        d5=trunacted_d5
        )
    )
end

# @dev determines if x >= y
# @dev returns 1 if true, 0 if false
func multi_precision_ge_bigint12{range_check_ptr}(x : BigInt12, y : BigInt12) -> (is_ge : felt):
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

    if lead_limb_x == 5:
        let (limb_5_ge : felt) = is_nn(x.d5 - y.d5)
        return (limb_5_ge)
    end

    if lead_limb_x == 4:
        let (limb_4_ge : felt) = is_nn(x.d4 - y.d4)
        return (limb_4_ge)
    end

    if lead_limb_x == 3:
        let (limb_3_ge : felt) = is_nn(x.d3 - y.d3)
        return (limb_3_ge)
    end

    if lead_limb_x == 2:
        let (limb_2_ge : felt) = is_nn(x.d2 - y.d2)
        return (limb_2_ge)
    end

    if lead_limb_x == 1:
        let (limb_1_ge : felt) = is_nn(x.d1 - y.d1)
        return (limb_1_ge)
    end

    if lead_limb_x == 0:
        let (limb_0_ge : felt) = is_nn(x.d0 - y.d0)
        return (limb_0_ge)
    end

    return (1)
end

# @dev uses is_not_zero, which assumes limb is non-negative
# @dev returns 0 index even if x is 0
func find_lead_limb_index_bigint12{range_check_ptr}(x : BigInt12) -> (lead : felt):
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

func mul_digit_bigint12{range_check_ptr}(x : felt, c : felt, y : BigInt12) -> (
    carry : felt, product : BigInt12
):
    # TODO research if product(d0) > BASE then subtracting base will cost less gas
    let (r_0, d0) = unsigned_div_rem(x * y.d0, BASE)
    let (r_1, d1) = unsigned_div_rem((x * y.d1) + r_0, BASE)
    let (r_2, d2) = unsigned_div_rem((x * y.d2) + r_1, BASE)
    let (r_3, d3) = unsigned_div_rem((x * y.d3) + r_2, BASE)
    let (r_4, d4) = unsigned_div_rem((x * y.d4) + r_3, BASE)
    let (r_5, d5) = unsigned_div_rem((x * y.d5) + r_4 + c, BASE)

    return (carry=r_5, product=BigInt12(d0=d0, d1=d1, d2=d2, d3=d3, d4=d4, d5=d5))
end
