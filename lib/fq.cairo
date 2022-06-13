from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic import field_arithmetic_lib
from lib.curve import get_modulus, get_r_squared, get_p_minus_one_div_2
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_not_zero

namespace fq_lib:
    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            sum_mod : Uint384):
        let (q : Uint384) = get_modulus()
        let (sum : Uint384) = field_arithmetic_lib.add(x, y, q)
        return (sum)
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            difference : Uint384):
        alloc_locals
        let (local q : Uint384) = get_modulus()
        local range_check_ptr = range_check_ptr

        # x and y need to be reduced modulo p
        # TODO: check that they are not already reduced before (more efficiency?)
        let (_, x : Uint384) = uint384_lib.unsigned_div_rem(x, q)
        let (_, y : Uint384) = uint384_lib.unsigned_div_rem(y, q)

        let (res) = field_arithmetic_lib.sub_reduced_a_and_reduced_b(x, y, q)
        return (res)
    end

    func mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, y : Uint384) -> (
            product : Uint384):
        let (q : Uint384) = get_modulus()
        let (res : Uint384) = field_arithmetic_lib.mul(x, y, q)
        return (res)
    end

    func square{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (product : Uint384):
        let (res : Uint384) = mul(x, x)
        return (res)
    end

    # NOTE: Scalar has to be at most than 2**128 - 1
    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(scalar : felt, x : Uint384) -> (
            product : Uint384):
        # TODO: I want to check that scalar is at most 2**128
        # But I get an error if I do, even fi the scalar is less than 2**128. I think [range_check_ptr] is already filled?

        # assert [range_check_ptr] = scalar

        let packed : Uint384 = Uint384(d0=scalar, d1=0, d2=0)
        let (reduced : Uint384) = mul(packed, x)

        return (reduced)
    end

    # TODO: in field_arithmetic we implement first the function a/x mod p. Make consistent
    # finds x in a x ≅ 1 (mod q)
    func inverse{range_check_ptr}(a : Uint384) -> (res : Uint384):
        alloc_locals
        let (q : Uint384) = get_modulus()
        let one = Uint384(1, 0, 0)
        let (res : Uint384) = field_arithmetic_lib.div(one, a, q)
        return (res)
    end

    func pow{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384, exponent : Uint384) -> (
            res : Uint384):
        alloc_locals
        let (q : Uint384) = get_modulus()
        let (res : Uint384) = field_arithmetic_lib.pow(x, exponent, q)
        %{ print("done") %}
        return (res)
    end

    # checks if x is a square in F_q, i.e. x ≅ y**2 (mod q) for some y
    func is_square_non_optimized{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (
            bool : felt):
        alloc_locals
        let (p : Uint384) = get_modulus()
        let (p_minus_one_div_2 : Uint384) = get_p_minus_one_div_2()
        let (res) = field_arithmetic_lib.is_square_non_optimized(x, p, p_minus_one_div_2)
        return (res)
    end

    # Finds a square of x in F_p, i.e. x ≅ y**2 (mod p) for some y
    # WARNING: Expects x to satisy 0 <= x < p-1
    func get_square_root{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : Uint384) -> (
            success : felt, res : Uint384):
        alloc_locals
        let (p : Uint384) = get_modulus()
        # 2 happens to be a generator
        let generator = Uint384(2, 0, 0)
        let (success, res : Uint384) = field_arithmetic_lib.get_square_root(x, p, generator)
        return (success, res)
    end

    func from_256_bits{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(input : Uint256) -> (
            res : Uint384):
        alloc_locals

        let (res : Uint384) = toMont(Uint384(d0=input.low, d1=input.high, d2=0))

        return (res)
    end

    func toMont{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(input : Uint384) -> (res : Uint384):
        alloc_locals

        let (r_squared : Uint384) = get_r_squared()

        let (res : Uint384) = mul(input, r_squared)

        return (res)
    end

    func from_64_bytes{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
            a0 : Uint256, a1 : Uint256) -> (res : Uint384):
        alloc_locals

        let (e0 : Uint384) = from_256_bits(a0)
        let (e1 : Uint384) = from_256_bits(a1)

        let r_mul_2_exp_256 = Uint384(
            d0=83443990817942453676606800841426240015,
            d1=179976616674212183434706501874187463630,
            d2=20718090071492759477555588592749303856)

        let (e0_mul_f : Uint384) = mul(e0, r_mul_2_exp_256)
        let (e1_final : Uint384) = add(e1, e0_mul_f)
        return (e1_final)
    end

    func is_quadratic_nonresidue{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(a : Uint384) -> (
            is_quad_nonresidue : felt):
        let (is_n_zero : felt) = is_not_zero(a.d0 + a.d1 + a.d2)

        if is_n_zero == 0:
            return (1)
        else:
            return (0)
        end
    end

    # @dev one is r mod p
    func one() -> (res : Uint384):
        return (
            res=Uint384(
            d0=313635500375121084810881640338032885757,
            d1=159249536114007638540741953206796900538,
            d2=29193015012204308844271843190429379693))
    end

    func zero() -> (res : Uint384):
        return (res=Uint384(
            d0=0,
            d1=0,
            d2=0))
    end
end
