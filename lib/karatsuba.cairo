
from starkware.cairo.common.uint256 import Uint256, split_64, uint256_mul, HALF_SHIFT

# Multiplies two integers. Returns the result as two 256-bit integers (low and high parts).
#func uint256_mul{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
#    alloc_locals
#    let (a0, a1) = split_64(a.low)
#    let (a2, a3) = split_64(a.high)
#    let (b0, b1) = split_64(b.low)
#    let (b2, b3) = split_64(b.high)
#
#    let (res0, carry) = split_64(a0 * b0)
#    let (res1, carry) = split_64(a1 * b0 + a0 * b1 + carry)
#    let (res2, carry) = split_64(a2 * b0 + a1 * b1 + a0 * b2 + carry)
#    let (res3, carry) = split_64(a3 * b0 + a2 * b1 + a1 * b2 + a0 * b3 + carry)
#    let (res4, carry) = split_64(a3 * b1 + a2 * b2 + a1 * b3 + carry)
#    let (res5, carry) = split_64(a3 * b2 + a2 * b3 + carry)
#    let (res6, carry) = split_64(a3 * b3 + carry)
#
#    return (
#        low=Uint256(low=res0 + HALF_SHIFT * res1, high=res2 + HALF_SHIFT * res3),
#        high=Uint256(low=res4 + HALF_SHIFT * res5, high=res6 + HALF_SHIFT * carry),
#    )
#end

#cf assert_250_bit from starkware.cairo.common.math

namespace karatsuba:

    func assert_160_bit{range_check_ptr}(value):
        const UPPER_BOUND = 2 ** 160
        const SHIFT = 2 ** 128
        const HIGH_BOUND = UPPER_BOUND / SHIFT

        let low = [range_check_ptr]
        let high = [range_check_ptr + 1]

        %{
            from starkware.cairo.common.math_utils import as_int

            # Correctness check.
            value = as_int(ids.value, PRIME) % PRIME
            assert value < ids.UPPER_BOUND, f'{value} is outside of the range [0, 2**160).'

            # Calculation for the assertion.
            ids.high, ids.low = divmod(ids.value, ids.SHIFT)
        %}

        assert [range_check_ptr + 2] = HIGH_BOUND - 1 - high

        # The assert below guarantees that
        #   value = high * SHIFT + low <= (HIGH_BOUND - 1) * SHIFT + 2**128 - 1 =
        #   HIGH_BOUND * SHIFT - SHIFT + SHIFT - 1 = 2**160 - 1.
        assert value = high * SHIFT + low

        let range_check_ptr = range_check_ptr + 3
        return ()
    end


    # Splits a field element in the range [0, 2^224) to its low 64-bit and high 160-bit parts.
    func split_64b{range_check_ptr}(a : felt) -> (low : felt, high : felt):
        alloc_locals
        local low : felt
        local high : felt

        %{
            ids.low = ids.a & ((1<<64) - 1)
            ids.high = ids.a >> 64
        %}
        assert a = low + high * HALF_SHIFT
        assert [range_check_ptr + 0] = low
        assert [range_check_ptr + 1] = HALF_SHIFT - 1 - low
        let range_check_ptr = range_check_ptr + 2
        assert_160_bit(high)
        return (low, high)
    end


    # Multiplies two integers. Returns the result as two 256-bit integers (low and high parts).
    func uint256_mul_b{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let a0 = a.low
        let a2 = a.high
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        let (res0, carry) = split_64(a0 * b0)
        let (res1, carry) = split_64(a0 * b1 + carry)
        let (res2, carry) = split_64b(a2 * b0 + a0 * b2 + carry)
        let (res3, carry) = split_64b(a2 * b1 + a0 * b3 + carry)
        let (res4, carry) = split_64b(a2 * b2 + carry)
        let (res5, carry) = split_64(a2 * b3 + carry)
        #let (res6, carry) = split_64(carry)

        return (
            low=Uint256(low=res0 + HALF_SHIFT * res1, high=res2 + HALF_SHIFT * res3),
            high=Uint256(low=res4 + HALF_SHIFT * res5, high=carry),
        )
    end


    func unit128_mul_kar_split(x0 : felt, x1 : felt, y0 : felt, y1 : felt) -> (z0 : felt, z1 : felt, z2 : felt):
        alloc_locals
        let z0 = x0*y0
        let z2 = x1*y1
        let z1 = (x1 + x0)*(y1 + y0) - z2 - z0
        return (z0,z1,z2)
    end

    func uint256_mul_kar{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let (a0, a1) = split_64(a.low)
        let (a2, a3) = split_64(a.high)
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        let (z0, z1, z2) = unit128_mul_kar_split(a0,a1,b0,b1)
        let (z4, z5, z6) = unit128_mul_kar_split(a2,a3,b2,b3)
        let (w2, w3, w4) = unit128_mul_kar_split(a0 + a2,a1 + a3,b0 + b2,b1 + b3)

        let (res0, carry) = split_64(z0)
        let (res1, carry) = split_64(z1 + carry)
        let (res2, carry) = split_64(z2 + w2 - z0 - z4 + carry)
        let (res3, carry) = split_64(w3 - z1 - z5 + carry)
        let (res4, carry) = split_64(z4 + w4 - z2 - z6 + carry)
        let (res5, carry) = split_64(z5 + carry)
        let (res6, carry) = split_64(z6 + carry)

        return (
            low=Uint256(low=res0 + HALF_SHIFT * res1, high=res2 + HALF_SHIFT * res3),
            high=Uint256(low=res4 + HALF_SHIFT * res5, high=res6 + HALF_SHIFT * carry),
        )
    end

    func uint256_mul_kar_b{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let a0 = a.low
        let a2 = a.high
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        let z0 = a0*b0
        let z1 = a0*b1
        let z4 = a2*b2
        let z5 = a2*b3
        let w2 = (a0 + a2)*(b0 + b2)
        let w3 = (a0 + a2)*(b1 + b3)

        let (res0, carry) = split_64(z0)
        let (res1, carry) = split_64(z1 + carry)
        let (res2, carry) = split_64b(w2 - z0 - z4 + carry)
        let (res3, carry) = split_64b(w3 - z1 - z5 + carry)
        let (res4, carry) = split_64b(z4 + carry)
        let (res5, carry) = split_64(z5 + carry)
        #let (res6, carry) = split_64(z6 + carry)

        return (
            low=Uint256(low=res0 + HALF_SHIFT * res1, high=res2 + HALF_SHIFT * res3),
            high=Uint256(low=res4 + HALF_SHIFT * res5, high=carry),
        )
    end

end

func main{range_check_ptr}():
    alloc_locals


    local a : Uint256
    local b : Uint256

    local ab_l : Uint256
    local ab_h : Uint256
    
    %{
        import random
        ids.a.low = random.randint(0,2**128)
        #ids.a.low = 2**128-1
        ids.a.high = random.randint(0,2**128)
        #ids.a.high = 2**128-1
        print(ids.a.high,ids.a.low)
        a=ids.a.high*2**128 + ids.a.low
        ids.b.low = random.randint(0,2**128)
        #ids.b.low = 2**128-1
        ids.b.high = random.randint(0,2**128)
        #ids.b.high = 2**128-1
        print(ids.b.high,ids.b.low)
        b=ids.b.high*2**128 + ids.b.low
        ab=a*b
        ids.ab_l.low=ab%(2**128)
        ab=ab//(2**128)
        ids.ab_l.high=ab%(2**128)
        ab=ab//(2**128)
        ids.ab_h.low=ab%(2**128)
        ab=ab//(2**128)
        ids.ab_h.high=ab
    %}

    #let (z0,z1) = uint256_mul(a,b)
    #let (z0,z1) = uint256_mul_b(a,b)
    #let (z0,z1) = uint256_mul_kar(a,b)
    let (z0,z1) = karatsuba.uint256_mul_kar_b(a,b)

    assert z0=ab_l
    assert z1=ab_h

    return ()
end