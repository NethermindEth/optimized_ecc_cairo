# @dev Functions for Barret's reduction algorithm
# @dev Incomplete documentation for now since it is likely there will be significant changes to this code soon

from starkware.cairo.common.math_cmp import is_le, is_nn, is_not_zero, is_nn_le
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.bitwise import bitwise_and
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from lib.BigInt6 import BigInt12, BigInt6, BigInt18, from_bigint12_to_bigint6, from_bigint6_to_bigint12, big_int_12_zero
from lib.multi_precision import multi_precision as mp
from lib.multi_precision_bigint12 import multi_precision_bigint12 as mp12, find_lead_limb_index_bigint12

const ZERO = 0

# @dev reduces a BigInt12 modulo the field modulus of the BLS12-384 elliptic curve (a BigInt6)
# @dev follows Chapter 14 of the Handbook of Applied Cryptography by Menezes et al., including the notation. Note `k=6` for us.
# @dev NOTE: In future work, this could be adapted so that it can mod any BigInt12 by a BigInt6
# @dev NOTE: Since the modulus is fixed, this implementation takes some shortcuts with respect to the Handbook reference
func barret_reduction{range_check_ptr}(number : BigInt12) -> (
    remainder : BigInt6
):
    alloc_locals
    # This is only to match the notation of the book
    let x_bigint12 = number
    # This is the field modulus of the BLS12-384 elliptic curve
    with_attr error_message("A"):
        let m_bigint6 = BigInt6(d0=13402431016077863595, d1=2210141511517208575, d2=7435674573564081700, d3=7239337960414712511, d4=5412103778470702295, 1873798617647539866)
        let (m_bigint12) = from_bigint6_to_bigint12(m_bigint6)

        let mu_div_b_power5 = BigInt6(d0=15579590430509924352, d1=9, d2=0, d3=0, d4=0, d5=0)  # = 181600287093895888896
    end
    with_attr error_message("B"):

        let (q1_bigint12) = get_q1(x_bigint12)
        let (q3_bigint12) = get_q3(q1_bigint12, mu_div_b_power5, m_bigint6)
    end
    with_attr error_message("B1"):
        let (local r1_bigint12 : BigInt12) = get_r1(x_bigint12)
    end
    with_attr error_message("B2"):
        let (r1_bigint6) = from_bigint12_to_bigint6(r1_bigint12)
    end
    with_attr error_message("B3"):
        
        let (r2_bigint12) = get_r2(q3_bigint12, m_bigint6)
    end
    with_attr error_message("C"):
        let (is_r1_le_r2) = mp12.ge_bigint12(r2_bigint12, r1_bigint12)
        if is_r1_le_r2 == 1:
            let new_r1_bigint12 : BigInt12 = BigInt12(
                d0=r1_bigint12.d0,
                d1=r1_bigint12.d1,
                d2=r1_bigint12.d2,
                d3=r1_bigint12.d3,
                d4=r1_bigint12.d4,
                d5=r1_bigint12.d5,
                d6=r1_bigint12.d6,
                d7=r1_bigint12.d7 + 1,
                d8=r1_bigint12.d8,
                d9=r1_bigint12.d9,
                d10=r1_bigint12.d10,
                d11=r1_bigint12.d11,
            )
            let (r_bigint12) = mp12.sub_bigint12(new_r1_bigint12, r2_bigint12)
            let (local final_r_bigint12) = _aux_fun_for_barret_reduction_bigint12(
                r_bigint12, m_bigint12
            )
            let (final_r_bigint6) = from_bigint12_to_bigint6(final_r_bigint12)
        else:
            let (r_bigint12) = mp12.sub_bigint12(r1_bigint12, r2_bigint12)
            let (local final_r_bigint12) = _aux_fun_for_barret_reduction_bigint12(
                r_bigint12, m_bigint12
            )
            let (final_r_bigint6) = from_bigint12_to_bigint6(final_r_bigint12)
        end
    end
    return (final_r_bigint6)
end

func get_q1{range_check_ptr}(x_bigint12 : BigInt12) -> (q1_bigint12 : BigInt12):
    let (q1_bigint12) = mp12.floor_divide_by_power_of_base_bigint12(number=x_bigint12, power=5)
    return (q1_bigint12)
end

func get_r1{range_check_ptr}(x_bigint12 : BigInt12) -> (r1_bigint12 : BigInt12):
    let (r1_bigint12) = mp12.mod_by_power_of_base_bigint12(x_bigint12, 7)
    return (r1_bigint12)
end

func get_r2{range_check_ptr}(q3_bigint12 : BigInt12, m_bigint6 : BigInt6) -> (
    r2_bigint12 : BigInt12
):
    let (q3_times_m_bigint18) = mp12.mul_bigint12_by_bigint6(
        q3_bigint12, m_bigint6
    )
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

func get_q3{range_check_ptr}(
    q1_bigint12 : BigInt12, mu_div_b_power5 : BigInt6, m_bigint6 : BigInt6
) -> (q3_bigint12 : BigInt12):
    let (q2_bigint18) = mp12.mul_bigint12_by_bigint6(q1_bigint12, mu_div_b_power5)

    # Below we are computing `math.floor(q2_bigint18/ b**2)`
    # NOTE: some math shows that `q2_bigint18` needs at most 14 limbs. Hence the result of the computation uses at most 7 limbs (in particular, it is a coincidence that we are dividing by b**7 and that we end up with 7 nonzero limbs).
    let q3_bigint12 = BigInt12(
        d0=q2_bigint18.d2,
        d1=q2_bigint18.d3,
        d2=q2_bigint18.d4,
        d3=q2_bigint18.d5,
        d4=q2_bigint18.d6,
        d5=q2_bigint18.d7,
        d6=q2_bigint18.d8,
        d7=q2_bigint18.d9,
        d8=0,
        d9=0,
        d10=0,
        d11=0,
    )
    return (q3_bigint12)
end

func _aux_fun_for_barret_reduction_bigint12{range_check_ptr}(r : BigInt12, m : BigInt12) -> (
    new_r : BigInt12
):
    alloc_locals
    tempvar r : BigInt12 = r
    # For our applications we have `m=4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787`.
    # For a general m here we have to use recursion (expensive). For this fixed m we can "hard-code" the recursion calls, as I've done here

    check_r_le_m:
    let (is_r_leq_than_m) = mp12.ge_bigint12(m, r)
    if is_r_leq_than_m == 1:
        let (is_m_equal_to_r) = mp12.are_eq_bigint12(r, m)
        if is_m_equal_to_r == 1:
            let (zeros) = big_int_12_zero()
            return (new_r=zeros)
        end
        return (new_r=r)
    end

    let (lead_limb_index_r) = find_lead_limb_index_bigint12(r)
    let lead_limb_index_m = 6  # m=field_modulus
    let (limb_m_le_limb_r) = is_le(lead_limb_index_m + 1, lead_limb_index_r)
    if limb_m_le_limb_r == 1:
        let limb_delta = lead_limb_index_r - lead_limb_index_m
        let (int_to_subtract) = mp12.mult_by_power_of_base_bigint12(m, limb_delta - 1)
        let (res) = mp12.sub_bigint12(r, int_to_subtract)
        tempvar r = res
    else:
        let (res) = mp12.sub_bigint12(r, m)
        tempvar r = res
    end
    jmp check_r_le_m

    # TODO: If `m` is known beforehand (as is the case for us: m = prime_field_modulus), then we can bound the needed number of iterations (i.e. jumps to `check_r_le_m`), and hence we can "hardcode" the iterations
end
