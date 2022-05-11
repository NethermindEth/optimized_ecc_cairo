from lib.BigInt6 import BigInt6, BigInt12, BASE, nondet_bigint6, big_int_6_zero
from lib.multi_precision import multi_precision
from lib.barret_algorithm import barret_reduction
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

# Default modulus is field modulus for bls12-381 elliptic curve.
# decimal p = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
const P0 = 13402431016077863595
const P1 = 2210141511517208575
const P2 = 7435674573564081700
const P3 = 7239337960414712511
const P4 = 5412103778470702295
const P5 = 1873798617647539866

# @dev modify the returned value of this function to adjust the modulus
# @dev modulus must be less than 2 ** (64 * 6)
func get_modulus{range_check_ptr}() -> (mod : BigInt6):
    return (mod=BigInt6(d0=P0, d1=P1, d2=P2, d3=P3, d4=P4, d5=P5))
end

namespace fq:
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
        sum_mod : BigInt6
    ):
        alloc_locals

        let (sum : BigInt6) = multi_precision.add(x, y)
        let (mod) = get_modulus()

        let (is_mod_gt_sum : felt) = multi_precision.gt(mod, sum)

        %{ print("sum d0 " + str(ids.sum.d0)) %}
        %{ print("sum d1 " + str(ids.sum.d1)) %}
        %{ print("sum d2 " + str(ids.sum.d2)) %}
        %{ print("sum d3 " + str(ids.sum.d3)) %}
        %{ print("sum d4 " + str(ids.sum.d4)) %}
        %{ print("sum d5 " + str(ids.sum.d5)) %}

        if is_mod_gt_sum == 1:
            %{ print("mod > sum") %}
            return (sum)
        end

        %{ print("mod < sum") %}
        let (_, sum_mod : BigInt6) = multi_precision.div(sum, mod)

        return (sum_mod)
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
        difference : BigInt6
    ):
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
        product : BigInt6
    ):
        let (res : BigInt12) = multi_precision.mul(x, y)
        let (reduced : BigInt6) = reduce(res)

        return (reduced)
    end


    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6) -> (product : BigInt6):
        let (res : BigInt12) = multi_precision.square(x)
        let (reduced : BigInt6) = reduce(res)

        return (reduced)
    end
    
    func reduce{range_check_ptr}(x : BigInt12) -> (reduced : BigInt6):
        let (res) = barret_reduction(x)
        return (res)
    end

end


# func reduce{range_check_ptr}(x : BigInt12) -> (reduced : BigInt6):
#     %{
#         modulus = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
#         limbs = ids.x.d0, ids.x.d1, ids.x.d2, ids.x.d3, ids.x.d4, ids.x.d5, ids.x.d6, ids.x.d7, ids.x.d8, ids.x.d9, ids.x.d10, ids.x.d11
#         packed = sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))
#         value = reduced = packed % modulus
#     %}
# 
#     let (reduced : BigInt6) = nondet_bigint6()
#     return (reduced)
# end

