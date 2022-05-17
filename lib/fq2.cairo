from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.BigInt6 import BigInt6, BigInt12
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.fq import fq
from lib.multi_precision import multi_precision as mp
from lib.multi_precision_bigint12 import multi_precision_bigint12 as mp_12
from lib.curve import fq2_c0, fq2_c1, get_modulus

namespace fq2:
    struct FQ2:
        member e0 : Uint384
        member e1 : Uint384
    end

    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        alloc_locals

        let (e0 : Uint384) = fq.add(x.e0, y.e0)
        let (e1 : Uint384) = fq.add(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        alloc_locals

        let (e0 : Uint384) = fq.sub(x.e0, y.e0)
        let (e1 : Uint384) = fq.sub(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ2) -> (
            product : FQ2):
        alloc_locals

        let (e0 : Uint384) = fq.scalar_mul(x, y.e0)
        let (e1 : Uint384) = fq.scalar_mul(x, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    # https://github.com/ethereum/py_ecc/blob/master/py_ecc/fields/optimized_field_elements.py#L284
    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (product : FQ2):
        alloc_locals
        let (first_term_low : Uint384, first_term_high : Uint384) = uint384_lib.mul(x.e0, y.e0)

        let (b_0_1_low : Uint384, b_0_1_high : Uint384) = uint384_lib.mul(x.e0, y.e1)
        let (b_1_0_low : Uint384, b_1_0_high : Uint384) = uint384_lib.mul(x.e1, y.e0)
        let (second_term_low : Uint384, _) = uint384_lib.add(b_0_1_low, b_0_1_low)
        let (second_term_high : Uint384, _) = uint384_lib.add(b_0_1_high, b_0_1_high)

        let (third_term_low : Uint384, third_term_high : Uint384) = uint384_lib.mul(x.e1, y.e1)

        let (third_term_mul_coeff_0_low : Uint384, _) = uint384_lib.mul(
            Uint384(d0=fq2_c0, d1=0, d2=0), third_term_low)
        let (third_term_mul_coeff_0_high : Uint384, _) = uint384_lib.mul(
            Uint384(d0=fq2_c0, d1=0, d2=0), third_term_high)

        let (third_term_mul_coeff_1_low : Uint384, _) = uint384_lib.mul(
            Uint384(d0=fq2_c1, d1=0, d2=0), third_term_low)
        let (third_term_mul_coeff_1_high : Uint384, _) = uint384_lib.mul(
            Uint384(d0=fq2_c1, d1=0, d2=0), third_term_high)

        let (unreduced_e0_low : Uint384) = uint384_lib.sub(
            first_term_low, third_term_mul_coeff_0_low)
        let (unreduced_e0_high : Uint384) = uint384_lib.sub(
            first_term_high, third_term_mul_coeff_0_high)

        let (unreduced_e1_low : Uint384) = uint384_lib.sub(
            second_term_low, third_term_mul_coeff_1_low)
        let (unreduced_e1_high : Uint384) = uint384_lib.sub(
            second_term_high, third_term_mul_coeff_1_high)

        let (mod : Uint384) = get_modulus()

        let (_, e0 : Uint384) = uint384_extension_lib.unsigned_div_rem_768_bits_by_uint384(
            Uint768(d0=unreduced_e0_low.d0, d1=unreduced_e0_low.d1, d2=unreduced_e0_low.d2, d3=unreduced_e0_high.d0, d4=unreduced_e0_high.d1, d5=unreduced_e0_high.d2),
            mod)

        let (_, e1 : Uint384) = uint384_extension_lib.unsigned_div_rem_768_bits_by_uint384(
            Uint768(d0=unreduced_e1_low.d0, d1=unreduced_e1_low.d1, d2=unreduced_e1_low.d2, d3=unreduced_e1_high.d0, d4=unreduced_e1_high.d1, d5=unreduced_e1_high.d2),
            mod)

        return (FQ2(e0=e0, e1=e1))
    end
end
