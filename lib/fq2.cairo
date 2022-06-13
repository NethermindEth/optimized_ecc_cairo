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

    # TODO: due to how fq_lib.scalar is implemented, this only supports multiplication by scalars of at most 128 bits
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

    # The sqrt r of (a, b) in Fq2 can be found by writting r and x as  polynomials,
    # i.e. r = r_0 + r_1 x, (a,b)= a+bx
    # then wrting the equation (r_0 + r1 x)**2 = a + bx
    # and solving for r_0 and r_1 modulo the irreducible polynomial f that defines Fq2 (in our case f = x**2 + 1)
    # For this particular f we have, if ab != 0 (the other cases are easier)
    # r_1  = sqrt(-a + sqrt(a**2 + b**2))/2)
    # r_0 = b r_1^{-1} /2
    # If any of the sqrt in Fq in the formulas does not exists, then the sqrt of (a,b) in Fq2
    # Otherwise choosing any of the two possible sqrt each time yields a sqrt of (a, b) in Fq2
    # Note that the function `get_sqrt` from the library fq.cairo tells us
    # with security whether an element has a sqrt or not
    func get_square_root{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(element : FQ2) -> (
        bool : felt, sqrt : FQ2
    ):
        alloc_locals
        let a : Uint384 = element.e0
        let b : Uint384 = element.e1
        
        # TODO: create a dedicated eq function in fq.cairo (and probably use a FQ struct everywhere instead of Uint384)
        let (local is_a_zero) = uint384_lib.eq(a, Uint384(0,0,0))
        let (local is_b_zero) = uint384_lib.eq(b, Uint384(0,0,0))

        if is_a_zero == 1:
            if is_b_zero == 1:
                let (zero: FQ2) = get_zero()
                return (1, zero)
            else:
                let (zero : FQ2) = get_zero()
                # In this case there is no sqrt but we need to return an FQ2 as the second component regardless
                return (0, zero)
            end
        else:
            if is_b_zero == 1:
                let (bool, res : Uint384) = fq_lib.get_square_root(a)
                let sqrt  = FQ2(res, Uint384(0, 0, 0))
                return (bool, sqrt)
            else:
                let (a_squared : Uint384) = fq_lib.mul(a, a)
                let (b_squared : Uint384) = fq_lib.mul(b, b)
                let (a_squared_plus_b_squared : Uint384) = fq_lib.add(a_squared, b_squared)
                let (bool, sqrt_a_squared_plus_b_squared : Uint384) = fq_lib.get_square_root(a_squared_plus_b_squared)
                if bool == 0:
                    let (zero : FQ2) = get_zero()
                    # In this case there is no sqrt but we need to return an FQ2 as the second component regardless
                    return (0, zero)
                end
                let (minus_a_plus_sqrt : Uint384) = fq_lib.sub(sqrt_a_squared_plus_b_squared, a)
                let (two_inverse : Uint384) = fq_lib.inverse(Uint384(2, 0, 0))
                let (minus_a_plus_sqrt_div_2 : Uint384) = fq_lib.mul(minus_a_plus_sqrt, two_inverse)
                let (bool, r1 : Uint384) = fq_lib.get_square_root(minus_a_plus_sqrt_div_2)
                if bool == 0:
                    let (zero : FQ2) = get_zero()
                    return (0, zero)
                end
                let (twice_r1 : Uint384) = fq_lib.scalar_mul(2, r1)
                let (twice_r1_inverse : Uint384) = fq_lib.inverse(twice_r1)
                let (r0 : Uint384) = fq_lib.mul(b, twice_r1_inverse)
                return (1, FQ2(r0, r1))
            end
        end
    end

    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2) -> (res : FQ2):
        let (res) = mul(x, x)
        return (res)
    end

    func is_zero{range_check_ptr}(x : FQ2) -> (bool : felt):
        let (zero_fq2 : FQ2) = get_zero()
        let (is_x_zero) = eq(x, zero_fq2)
        return (is_x_zero)
    end

    # Not tested
    func get_zero() -> (zero : FQ2):
        let zero_fq2 = FQ2(Uint384(0, 0, 0), Uint384(0, 0, 0))
        return (zero_fq2)
    end

    # Not tested
    func get_one() -> (one : FQ2):
        let one_fq1 = FQ2(Uint384(1, 0, 0), Uint384(0, 0, 0))
        return (one_fq1)
    end

    # Not tested
    func mul_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        x : FQ2, y : FQ2, z : FQ2
    ) -> (res : FQ2):
        let (x_times_y : FQ2) = mul(x, y)
        let (res : FQ2) = mul(x_times_y, z)
        return (res)
    end

    # Not tested
    # Computes x - y - z
    func sub_three_terms{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        x : FQ2, y : FQ2, z : FQ2
    ) -> (res : FQ2):
        let (x_sub_y : FQ2) = sub(x, y)
        let (res : FQ2) = sub(x_sub_y, z)
        return (res)
    end
end
