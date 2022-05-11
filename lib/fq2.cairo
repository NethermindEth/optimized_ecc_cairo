from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.BigInt6 import BigInt6
from lib.fq import fq
from lib.multi_precision import multi_precision as mp
from lib.multi_precision_bigint12 import multi_precision_bigint12 as mp_12
from lib.curve import fq2_c0, fq2_c1

namespace fq2:
    struct FQ2:
        member e0 : BigInt6
        member e1 : BigInt6
    end

    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        alloc_locals

        let (e0 : BigInt6) = fq.add(x.e0, y.e0)
        let (e1 : BigInt6) = fq.add(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        alloc_locals

        let (e0 : BigInt6) = fq.sub(x.e0, y.e0)
        let (e1 : BigInt6) = fq.sub(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ2) -> (
            product : FQ2):
        alloc_locals

        let (e0 : BigInt6) = fq.scalar_mul(x, y.e0)
        let (e1 : BigInt6) = fq.scalar_mul(x, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (product : FQ2):
        let (first_term : BigInt12) = mp.mul(x.e0, y.e0)

        let (b_0_1 : BigInt12) = mp.mul(x.e0, y.e1)
        let (b_1_0 : BigInt12) = mp.mul(x.e1, y.e0)
        let (second_term : BigInt12) = mp_12.add_bigint12(b_0_1, b_1_0)

        let (third_term : BigInt12) = mp.mul(x.e1, y.e1)

        let (third_term_mul_coeff_0 : BigInt12) = mp_12.scalar_mul(fq2_c0, third_term)
        let (third_term_mul_coeff_1 : BigInt12) = mp_12.scalar_mul(fq2_c1, third_term)

        let (unreduced_e0 : BigInt12) = mp_12.sub_bigint12(first_term, third_term_mul_coeff_0)
        let (unreduced_e1 : BigInt12) = mp_12.sub_bigint12(second_term, third_term_mul_coeff_1)

        let (e0) = fq.reduce(unreduced_e0)
        let (e1) = fq.reduce(unreduced_e1)
        return (FQ2=(e0=e0, e1=e1))
    end
end
