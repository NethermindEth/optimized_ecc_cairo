from lib.BigInt6 import BigInt6, BigInt12, BASE
from lib.multi_precision import multi_precision_add, multi_precision_sub, multi_precision_ge

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

func multi_precision_modular_add{range_check_ptr}(x : BigInt6, y : BigInt6) -> (sum_mod : BigInt6):
    alloc_locals

    let (sum : BigInt6) = multi_precision_add(x, y)
    let (mod) = get_modulus()

    let (is_mod_gt_sum) = multi_precision_gt(modulus, sum)

    if is_mod_gt_sum == 1:
        return (sum)
    end

    let (_, sum_mod : BigInt6) = multi_precision_div(sum, mod)

    return (sum_mod)
end

func multi_precision_modular_sub{range_check_ptr}(x : BigInt6, y : BigInt6) -> (
        difference : BigInt6):
    alloc_locals

    let (x_gt_y : BigInt6) = multi_precision_gt(x, y)

    if x_gt_y == 1:
        let (difference : BigInt6) = multi_precision_sub(x, y)
        return (difference)
    end
    let (difference : BigInt6) = multi_precision_sub(y, x)
    return (difference)
end
