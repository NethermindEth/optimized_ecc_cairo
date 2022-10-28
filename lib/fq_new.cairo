from lib.uint384 import Uint384, Uint384_expand, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic_new import field_arithmetic
from lib.curve_new import get_modulus, get_modulus_expand, get_r_squared, get_p_minus_one, get_p_minus_one_div_2
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_not_zero, is_nn, is_le

const SHIFT = 2 ** 128;
const ALL_ONES = 2 ** 128 - 1;
const HALF_SHIFT = 2 ** 64;

namespace fq_lib {
    //s:563 rc:52
    func add{range_check_ptr}(x: Uint384, y: Uint384) -> (
        sum_mod: Uint384
    ) {
        let(p_expand:Uint384_expand)= get_modulus_expand();
        let (sum: Uint384) = field_arithmetic.add(x, y, p_expand);
        return (sum,);
    }

    //s:1114 rc:102
    func sub{range_check_ptr}(x: Uint384, y: Uint384) -> (
        difference: Uint384
    ) {
        alloc_locals;
        let (p_expand: Uint384_expand) = get_modulus_expand();

        // x and y need to be reduced modulo p
        // TODO: check that they are not already reduced before (more efficiency?)
        let (_, x1: Uint384) = uint384_lib.unsigned_div_rem_expanded(x, p_expand);
        let (_, y1: Uint384) = uint384_lib.unsigned_div_rem_expanded(y, p_expand);
        let (res) = field_arithmetic.sub_reduced_a_and_reduced_b(x1, y1, p_expand);
        return (res,);
    }

    //This function does not work, the range_check reference gets revoked. Why?
    func sub1{range_check_ptr}(x: Uint384, y: Uint384) -> (
        difference: Uint384
    ) {
        alloc_locals;
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (p:Uint384) = get_p_minus_one();
        local range_check_ptr = range_check_ptr;
        // x and y need to be reduced modulo p
        // TODO: check that they are not already reduced before (more efficiency?)
        // New: added the check that x and y are indeed already reduced mod p, this reduces the number of steps greatly when x and y are smaller than p
        let (res1)= uint384_lib.lt(x, p);
        let (res2)= uint384_lib.lt(y, p);
	local xx: Uint384;
        if (res1==0){
            let (_, x1: Uint384) = uint384_lib.unsigned_div_rem_expanded(x, p_expand);
	    assert xx = x1;
        }else{
	    assert xx = x;
	}

	local yy:Uint384;
        if (res2==0){
            let (_, y1: Uint384) = uint384_lib.unsigned_div_rem_expanded(y, p_expand);
	    assert yy = y1;
        }else{
	    assert yy = y;
	}
        let (res) = field_arithmetic.sub_reduced_a_and_reduced_b(xx, yy, p_expand);
        return (res,);
    }

    //s:353, rc:28. Much better, even though we are not checking whether x and y are already reduced. 
    func sub2{range_check_ptr}(x: Uint384, y: Uint384) -> (
        difference: Uint384
    ) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (diff:Uint384,_) = uint384_lib.sub(x, y);
        let (_, res:Uint384) = uint384_lib.unsigned_div_rem_expanded(diff, p_expand);
        return(res,);
    }

    //s:745 rc:82
    func mul{range_check_ptr}(x: Uint384, y: Uint384) -> (
        product: Uint384
    ) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (res: Uint384) = field_arithmetic.mul(x, y, p_expand);
        return (res,);
    }

    //751 steps, 82 range_checks
    func square{range_check_ptr}(x: Uint384) -> (product: Uint384) {
        let (res: Uint384) = mul(x, x);
        return (res,);
    }

    // Best square: 680 steps, 73 range_checks
    func square2{range_check_ptr}(x: Uint384) -> (product: Uint384) {
        let (p_expand:Uint384_expand) = get_modulus_expand();
        let (res:Uint384) = field_arithmetic.square(x, p_expand);
        return (res,);
    }

    // NOTE: Scalar has to be at most than 2**128 - 1
    // 752 steps and 82 range_checks
    func scalar_mul{range_check_ptr}(scalar: felt, x: Uint384) -> (
        product: Uint384
    ) {
        // TODO: I want to check that scalar is at most 2**128
        // But I get an error if I do, even fi the scalar is less than 2**128. I think [range_check_ptr] is already filled?

        // assert [range_check_ptr] = scalar

        let packed: Uint384 = Uint384(d0=scalar, d1=0, d2=0);
        let (reduced: Uint384) = mul(packed, x);

        return (reduced,);
    }

    //Actually a bit worse than scalar_mul: 761 steps, 82 range_checks
    func scalar_mul2{range_check_ptr}(scalar: felt, x:Uint384) -> (
        product: Uint384
    ) {
        let p_expand:Uint384_expand= get_modulus_expand();
        let packed: Uint384 = Uint384(d0=scalar, d1=0, d2=0);
        let packed_expand: Uint384_expand = uint384_lib.expand(packed);
        let (reduced:Uint384) = field_arithmetic.mul_expanded(x, packed_expand, p_expand);
        return(reduced,);
    }

    //Best version of scalar mul: 716 steps, 76 range_checks
    // Managed to add the check scalar<2**128
    func scalar_mul3{range_check_ptr}(scalar: felt, x:Uint384) -> (
        product: Uint384
    ) {
        assert [range_check_ptr] = scalar;
        let p_expand:Uint384_expand= get_modulus_expand();
        let (low, high)=uint384_lib.split_64(scalar);
        let packed_expand: Uint384_expand = Uint384_expand(low*HALF_SHIFT, scalar, high, 0, 0, 0, 0);
        let (reduced:Uint384) = field_arithmetic.mul_expanded(x, packed_expand, p_expand);
        return(reduced,);
    }

    // Computes x*y^{-1}mod p. s:795, rc:83
    func div{range_check_ptr}(x:Uint384, y:Uint384) -> (
        division : Uint384
    ) {
        let p_expand:Uint384_expand = get_modulus_expand();
        let (result:Uint384) = field_arithmetic.div(x, y, p_expand);
        return (result,);
    } 

    // finds x in a x ≅ 1 (mod q). s:806, rc:83
    func inverse{range_check_ptr}(a:Uint384) -> (res: Uint384) {
        let (res:Uint384) = div(Uint384(1,0,0), a);    
        return (res,);
    }

    
    func pow{range_check_ptr}(x: Uint384, exponent: Uint384) -> (
        res: Uint384
    ) {
        //alloc_locals; is this alloc needed? I got it to work without
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (res: Uint384) = field_arithmetic.pow(x, exponent, p_expand);
        return (res,);
    }

    
    func pow_expanded{range_check_ptr}(x:Uint384, exponent: Uint384) -> (
        res:Uint384
    ) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (x_expand:Uint384_expand) = uint384_lib.expand(x);
        let (res:Uint384) = field_arithmetic.pow_expanded(x_expand, exponent, p_expand);
        return (res,);
    }

    // Finds a square of x in F_p, i.e. x ≅ y**2 (mod p) for some y
    // WARNING: Expects x to satisy 0 <= x < p-1
    func get_square_root{range_check_ptr}(x: Uint384) -> (
        success: felt, res: Uint384
    ) {
        //alloc_locals; Is this needed? Got it to work without
        let (p_expand: Uint384_expand) = get_modulus_expand();
        // 2 happens to be a generator
        let generator = Uint384(2, 0, 0);
        let (success, res: Uint384) = field_arithmetic.get_square_root(x, p_expand, generator);
        return (success, res);
    }

    func from_256_bits{range_check_ptr}(input: Uint256) -> (
        res: Uint384
    ) {
        alloc_locals;

        let (res: Uint384) = toMont(Uint384(d0=input.low, d1=input.high, d2=0));

        return (res,);
    }

    func toMont{range_check_ptr}(input: Uint384) -> (res: Uint384) {
        alloc_locals;

        let (r_squared: Uint384) = get_r_squared();

        let (res: Uint384) = mul(input, r_squared);

        return (res,);
    }

    func from_64_bytes{range_check_ptr}(a0: Uint256, a1: Uint256) -> (
        res: Uint384
    ) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (e0: Uint384) = from_256_bits(a0);
        let (e1: Uint384) = from_256_bits(a1);

        let r_mul_2_exp_256 = Uint384(
            d0=83443990817942453676606800841426240015,
            d1=179976616674212183434706501874187463630,
            d2=20718090071492759477555588592749303856,
        );

        let (e0_mul_f: Uint384) = field_arithmetic.mul(e0, r_mul_2_exp_256, p_expand);
        let (e1_final: Uint384) = field_arithmetic.add(e1, e0_mul_f, p_expand);
        return (e1_final,);
    }


    //This function seems incomplete.
    func is_quadratic_nonresidue{range_check_ptr}(a: Uint384) -> (
        is_quad_nonresidue: felt
    ) {
        let is_n_zero: felt = is_not_zero(a.d0 + a.d1 + a.d2);

        if (is_n_zero == 0) {
            return (1,);
        } else {
            return (0,);
        }
    }

    // @dev one is r mod p
    func one() -> (res: Uint384) {
        return (
            res=Uint384(
            d0=313635500375121084810881640338032885757,
            d1=159249536114007638540741953206796900538,
            d2=29193015012204308844271843190429379693),
        );
    }

    func zero() -> (res: Uint384) {
        return (res=Uint384(
            d0=0,
            d1=0,
            d2=0));
    }

    func neg{range_check_ptr}(input: Uint384) -> (res: Uint384) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (res: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(Uint384(0,0,0), input, p_expand);
        return (res,);
    }

    func mul_three_terms{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (x_times_y: Uint384) = field_arithmetic.mul(x, y,p_expand);
        let (res: Uint384) = field_arithmetic.mul(x_times_y, z,p_expand);
        return (res,);
    }

    //s:2220, rc:204
    func sub_three_terms{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        let (x_sub_y: Uint384) = sub(x, y);
        let (res: Uint384) = sub(x_sub_y, z);
        return (res,);
    }

    //better, s:1930, rc:179
    func sub_three_terms_new{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (_, x_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x, p_expand);
        let (_, y_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y, p_expand);
        let (_, z_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(z, p_expand);
        let (x_sub_y: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_red, y_red,p_expand);
        let (res: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_sub_y, z_red,p_expand);
        return (res,);
    }

    //s:912, rc:80, though we run in the same problems as sub2.
    func sub_three_terms2{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        let (y_plus_z:Uint384) = add(y,z);
        let (res:Uint384) = sub2(x, y_plus_z);
        return (res,);
    }

    //s:698, rc:56, though we run in the same problems as sub2.
    func sub_three_terms3{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        let (x_sub_y: Uint384) = sub2(x, y);
        let (res: Uint384) = sub2(x_sub_y, z);
        return (res,);
    }

    

}
