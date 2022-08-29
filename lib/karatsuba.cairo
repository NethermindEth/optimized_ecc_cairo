#%builtins range_check

from starkware.cairo.common.uint256 import Uint256, split_64, uint256_mul, uint256_check, HALF_SHIFT, SHIFT
from starkware.cairo.common.math import unsigned_div_rem as frem

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

    func uint256_mul{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let (a0, a1) = split_64(a.low)
        let (a2, a3) = split_64(a.high)
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        let (res0, carry) = split_64(a0 * b0)
        let (res1, carry) = split_64(a1 * b0 + a0 * b1 + carry)
        let (res2, carry) = split_64(a2 * b0 + a1 * b1 + a0 * b2 + carry)
        let (res3, carry) = split_64(a3 * b0 + a2 * b1 + a1 * b2 + a0 * b3 + carry)
        let (res4, carry) = split_64(a3 * b1 + a2 * b2 + a1 * b3 + carry)
        let (res5, carry) = split_64(a3 * b2 + a2 * b3 + carry)
        #let (res6, carry) = split_64(a3 * b3 + carry)

        return (
            low=Uint256(low=res0 + HALF_SHIFT * res1, high=res2 + HALF_SHIFT * res3),
            #high=Uint256(low=res4 + HALF_SHIFT * res5, high=res6 + HALF_SHIFT * carry),
            high=Uint256(low=res4 + HALF_SHIFT * res5, high=a3 * b3 + carry),
        )
    end

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


    # Splits a field element in the range [0, 2^224) to its low 128-bit and high 96-bit parts.
    func split_128{range_check_ptr}(a : felt) -> (low : felt, high : felt):
        alloc_locals
        const UPPER_BOUND = 2 ** 224
        const HIGH_BOUND = UPPER_BOUND / SHIFT
        local low : felt
        local high : felt

        %{
            ids.low = ids.a & ((1<<128) - 1)
            ids.high = ids.a >> 128
        %}
        assert a = low + high * SHIFT
        assert [range_check_ptr + 0] = high
        assert [range_check_ptr + 1] = HIGH_BOUND - 1 - high
        assert [range_check_ptr + 2] = low
        let range_check_ptr = range_check_ptr + 3
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

    func uint256_mul_c{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let (a0, a1) = split_64(a.low)
        let (a2, a3) = split_64(a.high)
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        let (res0, carry) = split_128(a0 * b0 + (a1 * b0 + a0 * b1)*HALF_SHIFT)
        let (res2, carry) = split_128(
            a2 * b0 + a1 * b1 + a0 * b2 + (a3 * b0 + a2 * b1 + a1 * b2 + a0 * b3)*HALF_SHIFT + carry
        )
        let (res4, carry) = split_128(a3 * b1 + a2 * b2 + a1 * b3 + (a3 * b2 + a2 * b3)*HALF_SHIFT + carry)
        #let (res6, carry) = split_64(a3 * b3 + carry)

        return (
            low=Uint256(low=res0, high=res2),
            #high=Uint256(low=res4 + HALF_SHIFT * res5, high=res6 + HALF_SHIFT * carry),
            high=Uint256(low=res4, high=a3 * b3 + carry),
        )
    end

    func unit128_mul_kar_split(x0 : felt, x1 : felt, y0 : felt, y1 : felt) -> (z0 : felt, z1 : felt, z2 : felt):
        alloc_locals
        local z0 = x0*y0
        local z2 = x1*y1
        local z1 = (x1 + x0)*(y1 + y0) - z2 - z0
        return (z0,z1,z2)
    end

    func unit128_mul_split(x0 : felt, x1 : felt, y0 : felt, y1 : felt) -> (z0 : felt, z1 : felt, z2 : felt):
        return (x0*y0, x1*y0+y1*x0, x1*y1)
    end

    func uint256_mul_kar{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let (a0, a1) = split_64(a.low)
        let (a2, a3) = split_64(a.high)
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        let (z0, z1, z2) = unit128_mul_split(a0,a1,b0,b1)
        let (z4, z5, z6) = unit128_mul_split(a2,a3,b2,b3)
        let (w2, w3, w4) = unit128_mul_split(a0 + a2,a1 + a3,b0 + b2,b1 + b3)

        let (res0, carry) = split_64(z0)
        let (res1, carry) = split_64(z1 + carry)
        let (res2, carry) = split_64(z2 + w2 - z0 - z4 + carry)
        let (res3, carry) = split_64(w3 - z1 - z5 + carry)
        let (res4, carry) = split_64(z4 + w4 - z2 - z6 + carry)
        let (res5, carry) = split_64(z5 + carry)
        #let (res6, carry) = split_64(z6 + carry)

        return (
            low=Uint256(low=res0 + HALF_SHIFT * res1, high=res2 + HALF_SHIFT * res3),
            #high=Uint256(low=res4 + HALF_SHIFT * res5, high=res6 + HALF_SHIFT * carry),
            high=Uint256(low=res4 + HALF_SHIFT * res5, high=z6 + carry),
        )
    end

    func uint256_mul_kar_b{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let a0 = a.low
        let a2 = a.high
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        local z0 = a0*b0
        local z1 = a0*b1
        local z4 = a2*b2
        local z5 = a2*b3
        local w2 = (a0 + a2)*(b0 + b2)
        local w3 = (a0 + a2)*(b1 + b3)

        let (res0, carry) = split_64(z0)
        let (res1, carry) = split_64(z1 + carry)
        let (res2, carry) = split_64b(w2 - z0 - z4 + carry)
        let (res3, carry) = split_64b(w3 - z1 - z5 + carry)
        let (res4, carry) = split_64b(z4 + carry)
        let (res5, carry) = split_64(z5 + carry)
        #let (res6, carry) = split_64(carry)

        return (
            low=Uint256(low=res0 + HALF_SHIFT * res1, high=res2 + HALF_SHIFT * res3),
            high=Uint256(low=res4 + HALF_SHIFT * res5, high=carry),
        )
    end

    func uint256_mul_kar_c{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        let (a0, a1) = split_64(a.low)
        let (a2, a3) = split_64(a.high)
        let (b0, b1) = split_64(b.low)
        let (b2, b3) = split_64(b.high)

        let (z0, z1, z2) = unit128_mul_split(a0,a1,b0,b1)
        local Z0 = z0 + HALF_SHIFT * z1
        let (z4, z5, z6) = unit128_mul_split(a2,a3,b2,b3)
        local Z4 = z4 + HALF_SHIFT * z5
        let (w2, w3, w4) = unit128_mul_split(a0 + a2,a1 + a3,b0 + b2,b1 + b3)
        local W2 = w2 + HALF_SHIFT * w3

        let (res0, carry) = split_128(Z0)
        let (res2, carry) = split_128(z2 + W2 - Z0 - Z4 + carry)
        let (res4, carry) = split_128(Z4 + w4 - z2 - z6 + carry)
        #let (res6, carry) = split_64(z6 + carry)

        return (
            low=Uint256(low=res0, high=res2),
            #high=Uint256(low=res4 + HALF_SHIFT * res5, high=res6 + HALF_SHIFT * carry),
            high=Uint256(low=res4, high=z6 + carry),
        )
    end
    
    func assert_div{range_check_ptr}(value, div) -> ():
        let q = [range_check_ptr]
        let range_check_ptr = range_check_ptr + 1
        %{
            from starkware.cairo.common.math_utils import assert_integer
            assert_integer(ids.div)
            assert 0 < ids.div <= PRIME // range_check_builtin.bound, \
               f'div={hex(ids.div)} is out of the valid range.'
            ids.q, r = divmod(ids.value, ids.div)
            assert r == 0
        %}

        assert value = q * div
        return ()
    end

    func uint256_mul_mont{range_check_ptr}(a : Uint256, b : Uint256) -> (low : Uint256, high : Uint256):
        alloc_locals
        const B0_1 = SHIFT
        const B0_2 = SHIFT**2
        const B0_3 = SHIFT**3

        const FAC1 = 2**118
        const B1_1 = 0
        const B1_2 = 0
        const B1_3 = 0
        
        const FAC2 = 332306998946228968225951765070086143
        #apparantly we can't create arrays of consts for some reason
        const B2_1 = 1024
        const B2_2 = 1048576
        const B2_3 = 1073741824
        
        const FAC3 = 332306998946228968225951765070086141
        const B3_1 = 3072
        const B3_2 = 9437184
        const B3_3 = 28991029248
        
        local low : Uint256
        local high : Uint256
        %{
            from utils import split, pack
            #exec(open('utils.py').read()) #horible kludge, fix when we have a good name space
            #a=pack(ids.a) #that this doesn't work is a flaw in Cairo
            a=pack((ids.a.low,ids.a.high))
            #b=pack(ids.b) #that this doesn't work is a flaw in Cairo
            b=pack((ids.b.low,ids.b.high))

            (ids.low.low,ids.low.high,ids.high.low,ids.high.high) = split(a*b, length=4)
        %}

        uint256_check(low)
        uint256_check(high)

        assert (a.low + a.high*B0_1)*(b.low + b.high*B0_1) = (low.low + low.high*B0_1 + high.low*B0_2 + high.high*B0_3)

        let (_,va) = frem(a.low,FAC1)
        let (_,vb) = frem(b.low,FAC1)
        assert_div(low.low + FAC1**2 - va*vb,FAC1)
        
        let (_,va) = frem(a.low + a.high*B2_1,FAC2)
        let (_,vb) = frem(b.low + b.high*B2_1,FAC2)
        assert_div(low.low + low.high*B2_1 + high.low*B2_2 + high.high*B2_3 + FAC2**2 - va*vb,FAC2)

        let (_,va) = frem(a.low + a.high*B3_1,FAC3)
        let (_,vb) = frem(b.low + b.high*B3_1,FAC3)
        assert_div(low.low + low.high*B3_1 + high.low*B3_2 + high.high*B3_3 + FAC3**2 - va*vb,FAC3)

        return(low,high)
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

    #let (z0,z1) = karatsuba.uint256_mul(a,b)
    #let (z0,z1) = karatsuba.uint256_mul_b(a,b)
    #let (z0,z1) = karatsuba.uint256_mul_c(a,b)
    #let (z0,z1) = karatsuba.uint256_mul_kar(a,b)
    #let (z0,z1) = karatsuba.uint256_mul_kar_b(a,b)
    #let (z0,z1) = karatsuba.uint256_mul_kar_c(a,b)
    let (z0,z1) = karatsuba.uint256_mul_mont(a,b)

    assert z0=ab_l
    assert z1=ab_h

    return ()
end

#cairo-compile lib/karatsuba.cairo --output kar_compiled.json
#cairo-run   --program=kar_compiled.json --print_output   --print_info --relocate_prints --layout=small
