from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.fq import fq
from lib.curve import fq2_c0, fq2_c1, get_modulus

namespace fq2:
    struct FQ2:
        member e0 : Uint384
        member e1 : Uint384
    end

    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        # TODO: check why these alloc_locals need to be used
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

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : FQ2, b : FQ2) -> (product : FQ2):
        alloc_locals
        let (first_term : Uint384) = fq.mul(a.e0, b.e0)
        let (b_0_1 : Uint384) = fq.mul(a.e0, b.e1)
        let (b_1_0 : Uint384) = fq.mul(a.e1, b.e0)
        let (second_term : Uint384) = fq.add(b_0_1, b_1_0)
        let (third_term : Uint384) = fq.mul(a.e1, b.e1)

        # Using the irreducible polynomial x**2 + 1 as modulus, we get that
        # x**2 = -1, so the term `a.e1 * b.e1 * x**2` becomes
        # `- a.e1 * b.e1` (always reducing mod p). This way the first term of
        # the multiplicaiton is `a.e0 * b.e0 - a.e1 * b.e1`
        let (first_term) = fq.sub(first_term, third_term)

        return (FQ2(e0=first_term, e1=second_term))
    end
end
