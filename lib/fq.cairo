from lib.BigInt6 import (
    BigInt6, BigInt12, BASE, nondet_bigint6, big_int_6_zero, big_int_6_one,
    from_bigint6_to_bigint12, is_equal)
from lib.multi_precision import multi_precision
from lib.curve import get_modulus
from lib.barret_algorithm import barret_reduction
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

namespace fq:
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
            sum_mod : BigInt6):
        alloc_locals

        let (sum : BigInt6) = multi_precision.add(x, y)
        let (mod) = get_modulus()

        let (is_mod_gt_sum : felt) = multi_precision.gt(mod, sum)

        if is_mod_gt_sum == 1:
            return (sum)
        end

        let (_, sum_mod : BigInt6) = multi_precision.div(sum, mod)

        return (sum_mod)
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
            difference : BigInt6):
        alloc_locals

        let (x_ge_y : felt) = multi_precision.ge(x, y)

        if x_ge_y == 1:
            let (difference : BigInt6) = multi_precision.sub(x, y)
            return (difference)
        end

        let (mod) = get_modulus()
        let (difference : BigInt6) = multi_precision.sub(y, x)
        let (mod_difference : BigInt6) = multi_precision.sub(mod, difference)
        return (mod_difference)
    end

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
            product : BigInt6):
        let (res : BigInt12) = multi_precision.mul(x, y)
        let (reduced : BigInt6) = reduce(res)

        return (reduced)
    end

    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6) -> (product : BigInt6):
        let (res : BigInt12) = multi_precision.square(x)
        let (reduced : BigInt6) = reduce(res)

        return (reduced)
    end

    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar : felt, x : BigInt6) -> (
            product : BigInt6):
        alloc_locals
        let res : BigInt6 = BigInt6(
            d0=scalar * x.d0,
            d1=scalar * x.d1,
            d2=scalar * x.d2,
            d3=scalar * x.d3,
            d4=scalar * x.d4,
            d5=scalar * x.d5)

        let (reduced : BigInt6) = reduce_bigint6(res)

        return (reduced)
    end

    # finds x in a x ≅ 1 (mod m)
    func inverse{range_check_ptr}(a : BigInt6, m : BigInt6) -> (res : BigInt6):
        alloc_locals

        if a == 0:
            return (BigInt6(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0))
        end

        let (x : BigInt6) = big_int_6_zero()
        let (y : BigInt6) = big_int_6_one()

        let (inv : BigInt6) = inverse_inner(a, m, x, y)

        return (inv)
    end

    func reduce{range_check_ptr}(x : BigInt12) -> (reduced : BigInt6):
        %{
            modulus = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
            limbs = ids.x.d0, ids.x.d1, ids.x.d2, ids.x.d3, ids.x.d4, ids.x.d5, ids.x.d6, ids.x.d7, ids.x.d8, ids.x.d9, ids.x.d10, ids.x.d11
            packed = sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))
            value = reduced = packed % modulus
        %}

        let (reduced : BigInt6) = nondet_bigint6()
        return (reduced)
    end
end

func reduce_bigint6{range_check_ptr}(x : BigInt6) -> (reduced : BigInt6):
    %{
        modulus = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
        limbs = ids.x.d0, ids.x.d1, ids.x.d2, ids.x.d3, ids.x.d4, ids.x.d5
        packed = sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))
        value = reduced = packed % modulus
    %}

    let (reduced : BigInt6) = nondet_bigint6()
    return (reduced)
end

func inverse_inner{range_check_ptr}(a : BigInt6, m : BigInt6, x : BigInt6, y : BigInt6) -> (
        res : BigInt6):
    alloc_locals

    let (one : BigInt6) = big_int_6_one()

    let (a_eq_one : felt) = is_equal(a, one)
    if a_eq_one == 1:
        return (x)
    end

    let (q : BigInt6, _) = multi_precision.div(a, m)
    let (a_as_bigint12 : BigInt12) = from_bigint6_to_bigint12(a)
    let (a_mod_m : BigInt6) = fq.reduce(a_as_bigint12)

    let (q_mul_y : BigInt12) = multi_precision.mul(q, y)
    let (new_y : BigInt6) = multi_precision.sub(x, q_mul_y)

    let (res : BigInt6) = inverse_inner(m, a_mod_m, m, new_y)
    return (res)
end
