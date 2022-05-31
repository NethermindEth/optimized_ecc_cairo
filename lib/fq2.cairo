from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.BigInt6 import BigInt6, BigInt12
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.fq import fq_lib
from lib.multi_precision import multi_precision as mp
from lib.multi_precision_bigint12 import multi_precision_bigint12 as mp_12
from lib.curve import fq2_c0, fq2_c1, get_modulus

struct FQ2:
    member e0 : Uint384
    member e1 : Uint384
end

namespace fq2_lib:
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        # TODO: check why these alloc_locals need to be used
        alloc_locals
        let (e0 : Uint384) = fq_lib.add(x.e0, y.e0)
        let (e1 : Uint384) = fq_lib.add(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        alloc_locals
        let (e0 : Uint384) = fq_lib.sub(x.e0, y.e0)
        let (e1 : Uint384) = fq_lib.sub(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ2) -> (
        product : FQ2
    ):
        alloc_locals
        let (e0 : Uint384) = fq_lib.scalar_mul(x, y.e0)
        let (e1 : Uint384) = fq_lib.scalar_mul(x, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : FQ2, b : FQ2) -> (product : FQ2):
        alloc_locals
        let (first_term : Uint384) = fq_lib.mul(a.e0, b.e0)
        let (b_0_1 : Uint384) = fq_lib.mul(a.e0, b.e1)
        let (b_1_0 : Uint384) = fq_lib.mul(a.e1, b.e0)
        let (second_term : Uint384) = fq_lib.add(b_0_1, b_1_0)
        let (third_term : Uint384) = fq_lib.mul(a.e1, b.e1)

        # Using the irreducible polynomial x**2 + 1 as modulus, we get that
        # x**2 = -1, so the term `a.e1 * b.e1 * x**2` becomes
        # `- a.e1 * b.e1` (always reducing mod p). This way the first term of
        # the multiplicaiton is `a.e0 * b.e0 - a.e1 * b.e1`
        let (first_term) = fq_lib.sub(first_term, third_term)

        return (FQ2(e0=first_term, e1=second_term))
    end
    
    # Find b such that b*a = 1 in FQ2
    # First the inverse is computed in a hint, and then verified in Cairo
    func get_inverse(a: FQ2) -> (inverse: FQ2):
        alloc_locals
        local a_inverse : Uint384
        %{
            def pack(z, num_bits_shift: int) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))
            
            e0 = pack(ids.a.e0)
            eq = pack(ids.a.e1)
            
            if e0 != 0:
                e0_inv = pow(e0, -1, field_modulus)
                new_e0 = pow(e0 + (e1**2) * e0_inv, -1, field_modulus)
                new_e1 = ( -b * pow(a**2 + b**2, -1, field_modulus) ) % field_modulus   
            else:
                new_e0 = 0
                new_e1 = pow(-e1, -1, field_modulus)
            
            ids.a_inverse.e0 = new_e0
            ids.a_inverse.e1 = new_e1
        %}
        
        let (a_inverse_times_a: FQ2) = mul(a_inverse, a)
        let (one: FQ2) = get_one()
        let (is_one) = eq(a_inverse_times_a, one)
        assert is_one = 1
        return (a_inverse)
    end

    # TODO: test
    func eq(x : FQ2, y : FQ2) -> (bool : felt):
        let (is_e0_eq) = uint384_lib.eq(x.e0, y.e0)
        if is_e0_eq == 0:
            return (0)
        end
        let (is_e1_eq) = uint384_lib.eq(x.e1, y.e1)
        if is_e1_eq == 0:
            return (0)
        end
        return (1)
    end

    # TODO: test
    func is_zero{}(x : FQ2) -> (bool : felt):
        let (zero_fq2 : FQ2) = get_zero()
        let (is_x_zero) = eq(x, zero_fq2)
        return (is_x_zero)
    end

    # TODO: test
    func get_zero() -> (zero : FQ2):
        let zero_fq2 = FQ2(Uint384(0, 0, 0), Uint384(0, 0, 0))
        return (zero_fq2)
    end

    # TODO: test
    func get_one() -> (one : FQ2):
        let one_fq1 = FQ2(Uint384(1, 0, 0), Uint384(0, 0, 0))
        return (one_fq1)
    end

    # TODO: test
    func mul_three_terms(x : FQ2, y : FQ2, z : FQ2) -> (res : FQ2):
        let (x_times_y : FQ2) = mul(x, y)
        let (res : FQ2) = mul(x_times_y, z)
        return (res)
    end

    # TODO: test
    # Computes x - y - z
    func sub_three_terms(x : FQ2, y : FQ2, z : FQ2) -> (res : FQ2):
        let (x_times_y : FQ2) = sub(x, y)
        let (res : FQ2) = sub(x_times_y, z)
        return (res)
    end
end
