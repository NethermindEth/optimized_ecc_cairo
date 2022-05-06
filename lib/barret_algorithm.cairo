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

    let (is_r1_le_r2) = mp.multi_precision_ge_bigint12(r2_bigint12, r1_bigint12)
    if is_r1_le_r2 == 1:
        assert r1_bigint12.d7 = r1_bigint12.d7 + 1
    end
    let (r_bigint12) = mp.multi_precision_sub_bigint12(r1_bigint12, r2_bigint12)
    let (final_r_bigint12) = _aux_fun_for_barret_reduction_bigint12(r_bigint12, m_bigint12)
    let (final_r_bigint6) = from_bigint12_to_bigint6(final_r_bigint12)
    return (final_r_bigint6)
end

func get_q1(x_bigint12 : BigInt12) -> (q1_bigint12 : BigInt12):
    let (q1_bigint12) = mp.floor_divide_by_power_of_base_bigint12(number=x_bigint12, power=5)
    return (q1_bigint12)
end

func get_r1(x_bigint12 : BigInt12) -> (r1_bigint12 : BigInt12):
    let (r1_bigint12) = mp.mod_by_power_of_base_bigint12(x_bigint12, 7)
    return (r1_bigint12)
end

func get_r2(q3_bigint12, m_bigint6) -> (r2_bigint12 : BigInt12):
    let (q3_times_m_bigint18) = mp.multi_precision_mul_bigint12_by_bigint6(q3_bigint12, m_bigint6)
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
    let (q2_bigint18) = mp.multi_precision_mul_bigint12_by_bigint6(q1_bigint12, m_bigint6)
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
    let (new_r) = mp.multi_precision_sub_bigint12(r, m)
    return _aux_fun_for_barret_reduction_bigint12(new_r, m)
end
