from starkware.cairo.common.bitwise import bitwise_and, bitwise_or, bitwise_xor
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math import assert_in_range, assert_le, assert_nn_le, assert_not_zero
from starkware.cairo.common.math_cmp import is_le
//from starkware.cairo.common.pow import pow
from starkware.cairo.common.registers import get_ap, get_fp_and_pc
// Import uint384 files (path may change in the future)
from lib.uint384 import uint384_lib, Uint384, Uint384_expand, SHIFT, HALF_SHIFT
from lib.uint384_extension import uint384_extension_lib, Uint768

// Functions for operating elements in a finite field F_p (i.e. modulo a prime p), with p of at most 384 bits

namespace field_arithmetic {
    // Computes (a + b) modulo p .
    func add{range_check_ptr}(a: Uint384, b: Uint384, p: Uint384_expand) -> (res: Uint384) {
        let (sum: Uint384, carry) = uint384_lib.add(a, b);
        let sum_with_carry: Uint768 = Uint768(sum.d0, sum.d1, sum.d2, carry, 0, 0);

        let (
            quotient: Uint768, remainder: Uint384
        ) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(sum_with_carry, p);
        return (remainder,);
    }

    // Computes (a - b) modulo p .
    // NOTE: Expects a and b to be reduced modulo p (i.e. between 0 and p-1). The function will revert if a > p.
    // NOTE: To reduce a, take the remainder of uint384_lin.unsigned_div_rem(a, p), and similarly for b.
    // @dev First it computes res =(a-b) mod p in a hint and then checks outside of the hint that res + b = a modulo p
    func sub_reduced_a_and_reduced_b{range_check_ptr}(a: Uint384, b: Uint384, p: Uint384_expand) -> (
        res: Uint384
    ) {
        alloc_locals;
        local res: Uint384;
        %{
            def split(num: int, num_bits_shift: int, length: int):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift
                return tuple(a)

            def pack(z, num_bits_shift: int) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def pack2(z, num_bits_shift: int) -> int:
                limbs = (z.b01, z.b23, z.b45)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            a = pack(ids.a, num_bits_shift = 128)
            b = pack(ids.b, num_bits_shift = 128)
            p = pack2(ids.p, num_bits_shift = 128)

            res = (a - b) % p


            res_split = split(res, num_bits_shift=128, length=3)

            ids.res.d0 = res_split[0]
            ids.res.d1 = res_split[1]
            ids.res.d2 = res_split[2]
        %}
        let (b_plus_res) = add(b, res, p);
        assert b_plus_res = a;
        return (res,);
    }

    // Computes a * b modulo p
    func mul{range_check_ptr}(a: Uint384, b: Uint384, p: Uint384_expand) -> (res: Uint384) {
        let (low: Uint384, high: Uint384) = uint384_lib.mul(a, b);
        let full_mul_result: Uint768 = Uint768(low.d0, low.d1, low.d2, high.d0, high.d1, high.d2);
        let (
            quotient: Uint768, remainder: Uint384
        ) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(full_mul_result, p);
        return (remainder,);
    }
    
    // Computes a * b modulo p
    func mul_expanded{range_check_ptr}(a: Uint384, b: Uint384_expand, p: Uint384_expand) -> (res: Uint384) {
        let (low: Uint384, high: Uint384) = uint384_lib.mul_expanded(a, b);
        let full_mul_result: Uint768 = Uint768(low.d0, low.d1, low.d2, high.d0, high.d1, high.d2);
        let (
            quotient: Uint768, remainder: Uint384
        ) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(full_mul_result, p);
        return (remainder,);
    }

    // Computes a**2 modulo p
    func square{range_check_ptr}(a: Uint384, p: Uint384_expand) -> (res: Uint384) {
        let (low: Uint384, high: Uint384) = uint384_lib.square(a);
        let full_mul_result: Uint768 = Uint768(low.d0, low.d1, low.d2, high.d0, high.d1, high.d2);
        let (
            quotient: Uint768, remainder: Uint384
        ) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(full_mul_result, p);
        return (remainder,);
    }

    // Computes a**3 modulo p
    func cube{range_check_ptr}(a: Uint384, p: Uint384_expand) -> (res: Uint384) {
        alloc_locals;
        let (a0, a1) = uint384_lib.split_64(a.d0);
        let (a2, a3) = uint384_lib.split_64(a.d1);
        let (a4, a5) = uint384_lib.split_64(a.d2);

	const HALF_SHIFT2 = 2*HALF_SHIFT;
	local A0 = a0*HALF_SHIFT2;
	local ad0_2 = a.d0*2;
	local a12 = a1 + a2*HALF_SHIFT;

        let (res0, carry) = uint384_lib.split_128(a0*(ad0_2 - a0));
        let (res2, carry) = uint384_lib.split_128(
	    a2*ad0_2 + a1*a1 + a3*A0 + carry,
        );
        let (res4, carry) = uint384_lib.split_128(
	    (a4*a.d0 + a3*a12)*2 + a2*a2 + a5*A0 + carry,
        );
        let (res6, carry) = uint384_lib.split_128(
	    (a5*a12 + a4*a.d1)*2 + a3*a3 + carry,
        );
        let (res8, carry) = uint384_lib.split_128(
	    a5*a3*2 + a4*(a4 + a5*HALF_SHIFT2) + carry
        );
        // let (res10, carry) = split_64(a5*a5 + carry)

        let full_square = Uint768(res0, res2, res4, res6, res8, a5*a5 + carry);
        let (_,rem) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(full_square, p);
	let a_exp = Uint384_expand(a0*HALF_SHIFT,a.d0,a12,a.d1,a3 + a4*HALF_SHIFT,a.d2,a5);
	return mul_expanded(rem,a_exp,p);
    }


    // Computes a * b^{-1} modulo p
    // NOTE: result is computed in a hint and verified outside the hind with a multiplicaiton
    // requires a < p, the function will revert otherwise
    // might give indeterminate answers if a=b=0
    func div{range_check_ptr}(a: Uint384, b: Uint384, p: Uint384_expand) -> (res: Uint384) {
        alloc_locals;
        local ans: Uint384;
        %{
            from starkware.python.math_utils import div_mod

            def split(num: int, num_bits_shift: int, length: int):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift
                return tuple(a)

            def pack(z, num_bits_shift: int) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def pack2(z, num_bits_shift: int) -> int:
                limbs = (z.b01, z.b23, z.b45)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            a = pack(ids.a, num_bits_shift = 128)
            b = pack(ids.b, num_bits_shift = 128)
            p = pack2(ids.p, num_bits_shift = 128)
            # For python3.8 and above the modular inverse can be computed as follows:
            # b_inverse_mod_p = pow(b, -1, p)
            # Instead we use the python3.7-friendly function div_mod from starkware.python.math_utils
            b_inverse_mod_p = div_mod(1, b, p)

            ans = (b_inverse_mod_p*a) %p
            ans_split = split(ans, num_bits_shift=128, length=3)

            ids.ans.d0 = ans_split[0]
            ids.ans.d1 = ans_split[1]
            ids.ans.d2 = ans_split[2]
        %}
        let (b_times_ans) = mul(b, ans, p);
        assert b_times_ans = a;

	let (is_valid) = uint384_lib.lt(ans, Uint384(p.b01,p.b23,p.b45));
        assert is_valid = 1;

        return (ans,);
    }

    // Computes (a**exp) % p. Uses the fast exponentiation algorithm, so it takes at most 384 squarings
    func pow_expanded{range_check_ptr}(a: Uint384_expand, exp: Uint384, p: Uint384_expand) -> (res: Uint384) {
        alloc_locals;
        let (is_exp_zero) = uint384_lib.eq(exp, Uint384(0, 0, 0));

        if (is_exp_zero == 1) {
            return (Uint384(1, 0, 0),);
        }

        let (is_exp_one) = uint384_lib.eq(exp, Uint384(1, 0, 0));
        if (is_exp_one == 1) {
	    let aa = Uint384(a.b01,a.b23,a.b45);
            // If exp = 1, it is possible that `a` is not reduced mod p,
            // so we check and reduce if necessary
	    let (is_a_lt_p) = uint384_lib.lt(aa, Uint384(p.b01,p.b23,p.b45));
            if (is_a_lt_p == 1) {
                return (aa,);
            } else {
                let (quotient, remainder) = uint384_lib.unsigned_div_rem_expanded(aa, p);
                return (remainder,);
            }
        }

        let (exp_div_2, rem) = uint384_lib.unsigned_div_rem2(exp);
        //let (is_remainder_zero) = uint384_lib.eq(remainder, Uint384(0, 0, 0));

        if (rem == 0) {
            // NOTE: Code is repeated in the if-else to avoid declaring res as a local variable
            let (res) = pow_expanded(a, exp_div_2, p);
	    let (res_sq) = square(res, p);
            return (res_sq,);
        } else {
            let (res) = pow_expanded(a, exp_div_2, p);
	    let (res_sq) = square(res, p);
            let (res_mul) = mul_expanded(res_sq, a, p);
            return (res_mul,);
        }
    }

    func pow{range_check_ptr}(a: Uint384, exp: Uint384, p: Uint384_expand) -> (res: Uint384) {
        let (a_exp) = uint384_lib.expand(a);
        return pow_expanded(a_exp,exp,p);
    }

    func _pow_loop{range_check_ptr}(a: Uint384_expand, val: Uint384, exp: felt, p: Uint384_expand, n) -> (res: Uint384) {
        alloc_locals;
        if (n==0) {
	  return (val,);
        }

        local carry: felt;
        %{
            exp2 = ids.exp*2
            ids.carry = 1 if exp2 >= ids.SHIFT else 0
        %}
        // Either 0 or 1
        assert carry * carry = carry;
        local e2 = exp*2 - carry * SHIFT;
        [range_check_ptr] = e2;
        let range_check_ptr = range_check_ptr + 1;
	
      
        let (val_sq) = square(val, p);
        local not_carry = 1 - carry;
        let a_cond=Uint384_expand(carry*a.B0 + not_carry*HALF_SHIFT, carry*a.b01 + not_carry,
				  carry*a.b12,carry*a.b23,carry*a.b34,carry*a.b45,carry*a.b5);
        let (v) = mul_expanded(val_sq, a_cond, p);

	return _pow_loop(a=a,val=v,exp=e2,p=p,n=n-1);
    }

    // Computes (a**exp) % p. Uses the fast exponentiation algorithm, so it takes at most 384 squarings
    // uses no conditionals in inputs
    func pow_expanded_no_cond{range_check_ptr}(a: Uint384_expand, exp: Uint384, p: Uint384_expand) -> (res: Uint384) {

      let val = Uint384(1,0,0);
      
      let (val)=_pow_loop(a=a,val=val,exp=exp.d2,p=p,n=128);
      let (val)=_pow_loop(a=a,val=val,exp=exp.d1,p=p,n=128);
      let (val)=_pow_loop(a=a,val=val,exp=exp.d0,p=p,n=128);

      return (val,);
    }

    func hiding_pow{range_check_ptr}(a: Uint384, exp: Uint384, p: Uint384_expand) -> (res: Uint384) {
        let (a_exp) = uint384_lib.expand(a);
        return pow_expanded_no_cond(a_exp,exp,p);
    }

    // Finds a square of x in F_p, i.e. x ≅ y**2 (mod p) for some y
    // To do so, the following is done in a hint:
    // 0. Assume x is not  0 mod p
    // 1. Check if x is a square, if yes, find a square root r of it
    // 2. If (and only if not), then gx *is* a square (for g a generator of F_p^*), so find a square root r of it
    // 3. Check in Cairo that r**2 = x (mod p) or r**2 = gx (mod p), respectively
    // NOTE: The function assumes that 0 <= x < p
    func get_square_root{range_check_ptr}(
        x: Uint384, p: Uint384_expand, generator: Uint384
    ) -> (success: felt, res: Uint384) {
        alloc_locals;

        // TODO: Create an equality function within field_arithmetic to avoid overflow bugs
        let (is_zero) = uint384_lib.eq(x, Uint384(0, 0, 0));
        if (is_zero == 1) {
            return (1, Uint384(0, 0, 0));
        }

        local success_x: felt;
        local sqrt_x: Uint384;
        local sqrt_gx: Uint384;

        // Compute square roots in a hint
        %{
            from starkware.python.math_utils import is_quad_residue, sqrt

            def split(num: int, num_bits_shift: int = 128, length: int = 3):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift
                return tuple(a)

            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def pack2(z, num_bits_shift: int = 128) -> int:
                limbs = (z.b01, z.b23, z.b45)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))


            generator = pack(ids.generator)
            x = pack(ids.x)
            p = pack2(ids.p)

            success_x = is_quad_residue(x, p)
            root_x = sqrt(x, p) if success_x else None

            success_gx = is_quad_residue(generator*x, p)
            root_gx = sqrt(generator*x, p) if success_gx else None

            # Check that one is 0 and the other is 1
            if x != 0:
                assert success_x + success_gx ==1

            # `None` means that no root was found, but we need to transform these into a felt no matter what
            if root_x == None:
                root_x = 0
            if root_gx == None:
                root_gx = 0
            ids.success_x = int(success_x)
            split_root_x = split(root_x)
            split_root_gx = split(root_gx)
            ids.sqrt_x.d0 = split_root_x[0]
            ids.sqrt_x.d1 = split_root_x[1]
            ids.sqrt_x.d2 = split_root_x[2]
            ids.sqrt_gx.d0 = split_root_gx[0]
            ids.sqrt_gx.d1 = split_root_gx[1]
            ids.sqrt_gx.d2 = split_root_gx[2]
        %}

        // Verify that the values computed in the hint are what they are supposed to be
        let (gx: Uint384) = mul(generator, x, p);
        if (success_x == 1) {
            let (sqrt_x_squared: Uint384) = square(sqrt_x, p);
            // Note these checks may fail if the input x does not satisfy 0<= x < p
            // TODO: Create a equality function within field_arithmetic to avoid overflow bugs
	    assert x = sqrt_x_squared;
            return (1, sqrt_x);
        } else {
            // In this case success_gx = 1
            let (sqrt_gx_squared: Uint384) = square(sqrt_gx, p);
	    assert gx = sqrt_gx_squared;
            // No square roots were found
            // Note that Uint384(0, 0, 0) is not a square root here, but something needs to be returned
            return (0, Uint384(0, 0, 0));
        }

    }

    // TODO: not tested
    // TODO: We should create a struct `FQ` to represent Uint384's reduced modulo p
    // RIght now thid function expects a and be to be between 0 and p-1
    func eq(a: Uint384, b: Uint384) -> (res: felt) {
        let (is_a_eq_b) = uint384_lib.eq(a, b);
        return (is_a_eq_b,);
    }

    // TODO: not tested
    func is_zero(a: Uint384) -> (bool: felt) {
        let (is_a_zero) = uint384_lib.is_zero(a);
        if (is_a_zero == 1) {
            return (1,);
        } else {
            return (0,);
        }
    }
}
