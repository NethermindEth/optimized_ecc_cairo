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

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (product : FQ2):
        alloc_locals
        let (first_term : Uint384) = fq.mul(x.e0, y.e0)
        let (b_0_1 : Uint384) = fq.mul(x.e0, y.e1)
        let (b_1_0 : Uint384) = fq.mul(x.e1, y.e0)
        let (second_term : Uint384) = fq.add(b_0_1, b_1_0)
        let (third_term : Uint384) = fq.mul(x.e1, y.e1)
        
        # Using the irreducible polynomial x**2 + 1 as modulus, we get that
        # x**2 = -1, so the multiplication term `x.e1 * y.e1 * x**2` becomes
        # `- x.e1 * y.e1` (always reducing mod p). This way the first term of
        # the multiplicaiton is `x.e0 * y.e0 - x.e1 * y.e1`
        let (first_term) = fq.sub(first_term, third_term)
        
        return (FQ2(e0=first_term, e1=second_term))
    end
end
