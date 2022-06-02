from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math_cmp import is_not_zero
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
            product : FQ2):
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
    # The formulas for the inverse come from writing a = e0 + e1 x and a_inverse = d0 + d1x,
    # multiplying these modulo the irreducible polynomial x**2 + 1, and then solving for
    # d0 and d1
    func inv{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : FQ2) -> (inverse : FQ2):
        alloc_locals
        local a_inverse : FQ2
        let (field_modulus : Uint384) = get_modulus()
        %{
            def split(num: int, num_bits_shift : int = 128, length: int = 3):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift 
                return tuple(a)
                
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            e0 = pack(ids.a.e0)
            e1 = pack(ids.a.e1)
            field_modulus = pack(ids.field_modulus)

            if e0 != 0:
                e0_inv = pow(e0, -1, field_modulus)
                new_e0 = pow(e0 + (e1**2) * e0_inv, -1, field_modulus)
                new_e1 = ( -e1 * pow(e0**2 + e1**2, -1, field_modulus) ) % field_modulus   
            else:
                new_e0 = 0
                new_e1 = pow(-e1, -1, field_modulus)

            new_e0_split = split(new_e0)
            new_e1_split = split(new_e1)

            ids.a_inverse.e0.d0 = new_e0_split[0]
            ids.a_inverse.e0.d1 = new_e0_split[1]
            ids.a_inverse.e0.d2 = new_e0_split[2]

            ids.a_inverse.e1.d0 = new_e1_split[0]
            ids.a_inverse.e1.d1 = new_e1_split[1]
            ids.a_inverse.e1.d2 = new_e1_split[2]
        %}

        let (a_inverse_times_a : FQ2) = mul(a_inverse, a)
        let (one : FQ2) = get_one()
        let (is_one) = eq(a_inverse_times_a, one)
        assert is_one = 1
        return (a_inverse)
    end

    # TODO: test
    func eq{range_check_ptr}(x : FQ2, y : FQ2) -> (bool : felt):
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
    func is_zero{range_check_ptr}(x : FQ2) -> (bool : felt):
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
    func mul_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
            x : FQ2, y : FQ2, z : FQ2) -> (res : FQ2):
        let (x_times_y : FQ2) = mul(x, y)
        let (res : FQ2) = mul(x_times_y, z)
        return (res)
    end

    # TODO: test
    # Computes x - y - z
    func sub_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
            x : FQ2, y : FQ2, z : FQ2) -> (res : FQ2):
        let (x_times_y : FQ2) = sub(x, y)
        let (res : FQ2) = sub(x_times_y, z)
        return (res)
    end

    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : FQ2) -> (product : FQ2):
        alloc_locals

        let (t_0 : Uint384) = fq_lib.add(a.e0, a.e1)
        let (t_1 : Uint384) = fq_lib.sub(a.e0, a.e1)
        let (t_2 : Uint384) = fq_lib.scalar_mul(2, a.e0)

        let (c_0 : Uint384) = fq_lib.mul(t_0, t_1)
        let (c_1 : Uint384) = fq_lib.mul(t_2, a.e1)

        return (product=FQ2(e0=c_0, e1=c_1))
    end

    func check_is_not_zero{range_check_ptr}(a : FQ2) -> (is_zero : felt):
        let (res) = is_not_zero(a.e0.d0 + a.e0.d1 + a.e0.d2 + a.e1.d0 + a.e1.d1 + a.e1.d2)
        return (res)
    end

    func is_quadratic_nonresidue{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : FQ2) -> (
            is_quad_nonresidue : felt):
        alloc_locals

        let (c0 : Uint384) = fq_lib.mul(a.e0, a.e0)
        let (c1 : Uint384) = fq_lib.mul(a.e1, a.e1)
        let (c3 : Uint384) = fq_lib.add(c0, c1)

        let (is_quad_nonresidue : felt) = fq_lib.is_square(c3)

        return (is_quad_nonresidue)
    end

    func sqrt{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : FQ2) -> (res : FQ2):
        return (a)
    end

    func one{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}() -> (res : FQ2):
        return (
            res=FQ2(e0=Uint384(
                d0=313635500375121084810881640338032885757,
                d1=159249536114007638540741953206796900538,
                d2=29193015012204308844271843190429379693),
            e1=Uint384(
                d0=0,
                d1=0,
                d2=0)))
    end
end
