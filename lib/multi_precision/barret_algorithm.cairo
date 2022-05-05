
from lib.BigInt6 import BigInt6, BigInt12, BASE, big_int_12_zero, from_bigint12_to_bigint6
from starkware.cairo.common.math_cmp import is_le, is_nn, is_not_zero, is_nn_le
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin


# @albert_g reduces a BigInt12 modulo a BigInt6.
# @albert_g follows Chapter 14 of the Handbook of Applied Cryptography by Menezes et al., including the notation. Note `k=6` for us.
# @albert_g TODO: if the parameter `modulo` is fixed, then `mu` should be precomputed (e.g. hardcoded) as it
# is a fixed constant. At some point we should make a leaner version of this function by removing the argument
# `modulo` and removing the computation of `mu` (as both modulo and mu will be hardcoded in our applications)
func barret_reduction{range_check_ptr}(number : BigInt12, modulo : BigInt6) -> (
    remainder : BigInt6
):
    # This is only to match the notation of the book
    let x = number
    let m = modulo

    let mu = 0

    # Note that wath the `left_shift_limbs` function actually does is compute `floor(x/(BASE**shift))` in a supper efficient way
    let (q1) = left_shift_limbs(number=x, shift=5)
    let (q2) = multi_precision_mul_bigint12_by_bigint6(q1, m)
    let (q3) = left_shift_limbs(number=q2, shift=7)

    let (r1) = mod_by_power_of_base(x, 7)
    let (r2) = mod_by_power_of_base(q3 * m, 7)
    let r = r1 - r2

    let (final_r_bigint12) = _aux_fun_for_barret_reduction(r, m)
    let (final_r_bigint6) = from_bigint12_to_bigint6(final_r_bigint6)
    return (r)
end


func multi_precision_mul_bigint12_bigin6{range_check_ptr}(x : BigInt12, y : BigInt6) -> (product : BigInt12):
    alloc_locals

    let (c0 : felt, p0 : BigInt6) = mul_digit(x.d0, 0, y)
    let (c1 : felt, p1 : BigInt6) = mul_digit(x.d1, c0, y)
    let (c2 : felt, p2 : BigInt6) = mul_digit(x.d2, c1, y)
    let (c3 : felt, p3 : BigInt6) = mul_digit(x.d3, c2, y)
    let (c4 : felt, p4 : BigInt6) = mul_digit(x.d4, c3, y)
    let (c5 : felt, p5 : BigInt6) = mul_digit(x.d5, c4, y)

    let (product : BigInt12) = sum_products(p0, p1, p2, p3, p4, p5, c5)
    return (product)
end


func _aux_fun_for_barret_reduction(r : BigInt12, m : BigInt6) -> (new_r : BigInt12):
    if (is_nn_le(r, m - 1)) == 1:
        return (r)
    end
    let (new_r) = multi_precision_div(r, m)
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
    with_attr error_message(
            "`shift` should be >=0 and <=12. Provided shift = {shift}"):
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
