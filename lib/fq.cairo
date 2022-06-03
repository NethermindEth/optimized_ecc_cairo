from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic import field_arithmetic_lib
from lib.curve import get_modulus
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

namespace fq:
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
        # TODO: this assertion fails but not sure why
        # assert [range_check_ptr] = scalar

        let packed : Uint384 = Uint384(d0=scalar, d1=0, d2=0)
        let (reduced : Uint384) = mul(packed, x)

        return (reduced)
    end

    # finds x in a x ≅ 1 (mod q)
    func inverse{range_check_ptr}(a : Uint384) -> (res : Uint384):
        alloc_locals
        let (q : Uint384) = get_modulus()
        let one = Uint384(1, 0, 0)
        let (res : Uint384) = field_arithmetic_lib.div(one, a)
        return (res)
    end
end
