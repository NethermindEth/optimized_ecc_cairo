from lib.BigInt6 import (
    BigInt6,
    BigInt12,
    BigInt18,
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
    let x_bigint12 = number
    let (m_bigint6) = modulo
    let (m_bigint12) = from_bigint6_to_bigint12(modulo)

    let mu = 0

    let (q1_bigint12) = get_q1(x_bigint12)
    let (local q3_bigint12) = get_q3(q1_bigint12, mu, m_bigint6)
    let (r1_bigint12) = get_r1(x_bigint12)
    let (r1_bigint6) = from_bigint12_to_bigint6(r1_bigint6)
    let (r2_bigint12) = get_r2(q3_bigint12, m_bigint6)

    let (is_r1_le_r2) = multi_precision_ge_bigint12(r2_bigint12, r1_bigint12)
    if is_r1_le_r2 == 1:
        assert r1_bigint12.d7 = r1_bigint12.d7 + 1
    end
    let (r_bigint12) = multi_precision_sub_bigint12(r1_bigint12, r2_bigint12)
    let (final_r_bigint12) = _aux_fun_for_barret_reduction_bigint12(r_bigint12, m_bigint12)
    let (final_r_bigint6) = from_bigint12_to_bigint6(final_r_bigint12)
    return (final_r_bigint6)
end

func get_q1(x_bigint12 : BigInt12) -> (q1_bigint12 : BigInt12):
    let (q1_bigint12) = floor_divide_by_power_of_base_bigint12(number=x_bigint12, power=5)
    return (q1_bigint12)
end

func get_r1(x_bigint12 : BigInt12) -> (r1_bigint12 : BigInt12):
    let (r1_bigint12) = mod_by_power_of_base_bigint12(x_bigint12, 7)
    return (r1_bigint12)
end

func get_r2(q3_bigint12, m_bigint6) -> (r2_bigint12 : BigInt12):
    let (q3_times_m_bigint18) = multi_precision_mul_bigint12_by_bigint6(q3_bigint12, m_bigint6)
    # Now we mod `q3_times_m_bigint18` by b**7
    let r2_bigint12 = BigInt12(
        d0=q3_times_m_bigint18.d0,
        d1=q3_times_m_bigint18.d1,
        d2=q3_times_m_bigint18.d2,
        d3=q3_times_m_bigint18.d3,
        d4=q3_times_m_bigint18.d4,
        d5=q3_times_m_bigint18.d5,
        d6=q3_times_m_bigint18.d6,
        d7=0,
        d8=0,
        d9=0,
        d10=0,
        d11=0,
    )
    return (r2_bigint12)
end

func get_q3(q1_bigint12 : BigInt12, mu : BigInt12, m_bigint6 : BigInt6) -> (q3_bigint12 : BigInt12):
    # q3 = math.floor(q1 * mu / b^{k+1})
    # TODO: is there some more specialized way to do this
    # We need up to 18 limbs here because we know that m has only the first 6 nonzero limbs
    let (q2_bigint18) = multi_precision_mul_bigint12_by_bigint6(q1_bigint12, m_bigint6)
    # Here we are computing `math.floor(q2_bigint18/ b**7)`
    # NOTE: some math shows that `q2_bigint18` needs at most 14 limbs. Hence the result of the computation uses at most 7 limbs (in particular, it is a coincidence that we are dividing by b**7 and that we end up with 7 nonzero limbs).
    let (q3_bigint12) = BigInt12(
        d0=q2_bigint18.d7,
        d1=q2_bigint18.d8,
        d2=q2_bigint18.d9,
        d3=q2_bigint18.d10,
        d4=q2_bigint18.d11,
        d5=q2_bigint18.d12,
        d6=q2_bigint18.d13,
        d7=q2_bigint18.d14,
        d8=0,
        d9=0,
        d10=0,
        d11=0,
    )
    return (q3_bigint12)
end

func _aux_fun_for_barret_reduction_bigint12(r : BigInt12, m : BigInt12) -> (new_r : BigInt12):
    let (is_r_less_than_m) = is_nn_le(r, m - 1)
    if is_r_less_than_m == 1:
        return (r)
    end
    let (new_r) = multi_precision_sub_bigint12(r, m)
    return _aux_fun_for_barret_reduction_bigint12(new_r, m)
end

func multi_precision_mul_bigint12_by_bigint6{range_check_ptr}(x : BigInt12, y : BigInt6) -> (
    product : BigInt18
):
    # TODO: modify
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

func mod_by_power_of_base_bigint12(number : BigInt12, power : felt) -> (result : BigInt12):
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

# @albert_g takes a BigInt12 with limbs d_0, ..., d_11 and returns the BigInt12 with limbs d_(power), ..., d_11, 0, ..., 0
# @albert_g NOTE: The function could be written much more succintly with using recursion calls. Instead I wrote it in this "hardcoded" form for efficiency (I understand that nested recursion is quite expensive)
func floor_divide_by_power_of_base_bigint12(number : BigInt12, power : felt) -> (
    shifted_number : BigInt12
):
    with_attr error_message("`power` should be >=0 and <=12. Provided power = {power}"):
        let (bool) = is_nn_le(power, 12)
        assert bool = 1
    end

    if power == 0:
        return (number)
    end

    # Initialize the final BigInt12
    let shifted_number = big_int_12_zero()
    if power == 12:
        return (shifted_number)
    end

    let (number_memory_location_plus_shift) = number + power

    assert shifted_number.d0 = [number_memory_location_plus_shift]
    if power == 11:
        return (shifted_number)
    end

    assert shifted_number.d1 = [number_memory_location_plus_shift + 1]
    if power == 10:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 2]
    if power == 9:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 3]
    if power == 8:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 4]
    if power == 7:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 5]
    if power == 6:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 6]
    if power == 5:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 7]
    if power == 4:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 8]
    if power == 3:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 9]
    if power == 2:
        return (shifted_number)
    end

    assert shifted_number.d2 = [number_memory_location_plus_shift + 10]
    if power == 1:
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
    # TODO: adapt to BigInt12

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
    # TODO: adapt to BigInt12

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
    # TODO: adapt to BigInt12

    # TODO research if product(d0) > BASE then subtracting base will cost less gas
    let (r_0, d0) = unsigned_div_rem(x * y.d0, BASE)
    let (r_1, d1) = unsigned_div_rem((x * y.d1) + r_0, BASE)
    let (r_2, d2) = unsigned_div_rem((x * y.d2) + r_1, BASE)
    let (r_3, d3) = unsigned_div_rem((x * y.d3) + r_2, BASE)
    let (r_4, d4) = unsigned_div_rem((x * y.d4) + r_3, BASE)
    let (r_5, d5) = unsigned_div_rem((x * y.d5) + r_4 + c, BASE)

    return (carry=r_5, product=BigInt12(d0=d0, d1=d1, d2=d2, d3=d3, d4=d4, d5=d5))
end
