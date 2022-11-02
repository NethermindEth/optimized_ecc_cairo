from lib.uint384 import Uint384, Uint384_expand, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic_new import field_arithmetic
from lib.curve_new import get_modulus, get_modulus_expand, get_r_squared, get_p_minus_one, get_p_minus_one_div_2, get_twice_p
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_not_zero, is_nn, is_le

const SHIFT = 2 ** 128;
const ALL_ONES = 2 ** 128 - 1;
const HALF_SHIFT = 2 ** 64;

namespace fq_lib {
    //s:587 rc:61
    func add{range_check_ptr}(x: Uint384, y: Uint384) -> (
        sum_mod: Uint384
    ) {
        let(p_expand:Uint384_expand)= get_modulus_expand();
        let (sum: Uint384) = field_arithmetic.add(x, y, p_expand);
        return (sum,);
    }

    //s:1174 rc:123
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

    //fuzz_runs=100, steps=μ: 786.08, Md: 685, min: 685, max: 1230, memory_holes=μ: 68.48, Md: 63, min: 63, max: 94                                    
    //range_check_builtin=μ: 64.36, Md: 54, min: 54, max: 110
    //This function checks whether unsigned x and y are already reduced modulo p.

    func sub1{range_check_ptr}(x: Uint384, y: Uint384) -> (
        difference: Uint384
    ) {
        alloc_locals;
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (p:Uint384) = get_modulus();
        local range_check_ptr = range_check_ptr;
        let (res1)= uint384_lib.lt(x, p);
        let (res2)= uint384_lib.lt(y, p);
        if (res1==0){
            let (_, x1: Uint384) = uint384_lib.unsigned_div_rem_expanded(x, p_expand);
            if (res2==0){
                let (_, y1: Uint384) = uint384_lib.unsigned_div_rem_expanded(y, p_expand);
                let (res) = field_arithmetic.sub_reduced_a_and_reduced_b(x1, y1, p_expand);
                return (res,);
            } else {
                let (res) = field_arithmetic.sub_reduced_a_and_reduced_b(x1, y, p_expand);
                return (res,);
            }
        } else {
            if (res2==0){
                let (_, y1: Uint384) = uint384_lib.unsigned_div_rem_expanded(y, p_expand);
                let (res) = field_arithmetic.sub_reduced_a_and_reduced_b(x, y1, p_expand);
                return (res,);
            } else {
                let (res) = field_arithmetic.sub_reduced_a_and_reduced_b(x, y, p_expand);
                return (res,);
            }
        }
    }
    
    //s:769 rc:91
    func mul{range_check_ptr}(x: Uint384, y: Uint384) -> (
        product: Uint384
    ) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (res: Uint384) = field_arithmetic.mul(x, y, p_expand);
        return (res,);
    }

    //775 steps, 91 range_checks
    func square{range_check_ptr}(x: Uint384) -> (product: Uint384) {
        let (res: Uint384) = mul(x, x);
        return (res,);
    }

    // Best square: 704 steps, 82 range_checks
    func square2{range_check_ptr}(x: Uint384) -> (product: Uint384) {
        let (p_expand:Uint384_expand) = get_modulus_expand();
        let (res:Uint384) = field_arithmetic.square(x, p_expand);
        return (res,);
    }

    // NOTE: Scalar has to be at most than 2**128 - 1
    // 776 steps and 91 range_checks
    func scalar_mul{range_check_ptr}(scalar: felt, x: Uint384) -> (
        product: Uint384
    ) {
        let packed: Uint384 = Uint384(d0=scalar, d1=0, d2=0);
        let (reduced: Uint384) = mul(packed, x);

        return (reduced,);
    }

    //Actually a bit worse than scalar_mul: 785 steps, 91 range_checks
    func scalar_mul2{range_check_ptr}(scalar: felt, x:Uint384) -> (
        product: Uint384
    ) {
        let p_expand:Uint384_expand= get_modulus_expand();
        let packed: Uint384 = Uint384(d0=scalar, d1=0, d2=0);
        let packed_expand: Uint384_expand = uint384_lib.expand(packed);
        let (reduced:Uint384) = field_arithmetic.mul_expanded(x, packed_expand, p_expand);
        return(reduced,);
    }

    //Better version of scalar mul: 739 steps, 85 range_checks
    func scalar_mul3{range_check_ptr}(scalar: felt, x:Uint384) -> (
        product: Uint384
    ) {
        let p_expand:Uint384_expand= get_modulus_expand();
        let (low, high)=uint384_lib.split_64(scalar);
        let packed_expand: Uint384_expand = Uint384_expand(low*HALF_SHIFT, scalar, high, 0, 0, 0, 0);
        let (reduced:Uint384) = field_arithmetic.mul_expanded(x, packed_expand, p_expand);
        return(reduced,);
    }

    //Best version: uses mul_by_uint128: 663 steps, 79 range_checks
    func scalar_mul4{range_check_ptr}(scalar: felt, x:Uint384) -> (
        product: Uint384
    ) {
        let p_expand:Uint384_expand= get_modulus_expand();
        let (low: Uint384, high: felt) = uint384_lib.mul_by_uint128(x,scalar);
	let full_mul_result: Uint768 = Uint768(low.d0, low.d1, low.d2, high, 0, 0);
	let (
            quotient: Uint768, remainder: Uint384
        ) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(full_mul_result, p_expand);
        return(remainder,);
    }

    //assumes scalar < 2**64
    //643 steps, 76 range_checks
    func scalar64_mul{range_check_ptr}(scalar: felt, x:Uint384) -> (
        product: Uint384
    ) {
        let p_expand:Uint384_expand= get_modulus_expand();
        let (low: Uint384, high: felt) = uint384_lib.mul_by_uint64(x,scalar);
	let full_mul_result: Uint768 = Uint768(low.d0, low.d1, low.d2, high, 0, 0);
	let (
            quotient: Uint768, remainder: Uint384
        ) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384_expand(full_mul_result, p_expand);
        return(remainder,);
    }

    // Computes x*y^{-1}mod p. s:819, rc:92
    func div{range_check_ptr}(x:Uint384, y:Uint384) -> (
        division : Uint384
    ) {
        let p_expand:Uint384_expand = get_modulus_expand();
        let (result:Uint384) = field_arithmetic.div(x, y, p_expand);
        return (result,);
    } 

    // finds x in a x ≅ 1 (mod q). s:830, rc:92
    func inverse{range_check_ptr}(a:Uint384) -> (res: Uint384) {
        let (res:Uint384) = div(Uint384(1,0,0), a);    
        return (res,);
    }

    
    func pow{range_check_ptr}(x: Uint384, exponent: Uint384) -> (
        res: Uint384
    ) {
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
    // s:1489 rc:173
    func get_square_root{range_check_ptr}(x: Uint384) -> (
        success: felt, res: Uint384
    ) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        // 2 happens to be a generator
        let generator = Uint384(2, 0, 0);
        let (success, res: Uint384) = field_arithmetic.get_square_root(x, p_expand, generator);
        return (success, res);
    }

    // s:784 rc:91
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

    // s:2873 rc:334
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

    // s:617 rc:61
    func neg{range_check_ptr}(input: Uint384) -> (res: Uint384) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (res: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(Uint384(0,0,0), input, p_expand);
        return (res,);
    }

    // s:1511 rc:182
    func mul_three_terms{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (x_times_y: Uint384) = field_arithmetic.mul(x, y,p_expand);
        let (res: Uint384) = field_arithmetic.mul(x_times_y, z,p_expand);
        return (res,);
    }

    //s:2340, rc:246
    func sub_three_terms{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        let (x_sub_y: Uint384) = sub(x, y);
        let (res: Uint384) = sub(x_sub_y, z);
        return (res,);
    }

    //better, s:2032, rc:215
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

    //s:1265, rc:124
    func sub_three_terms2{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        let (y_plus_z:Uint384) = add(y,z);
        let (res:Uint384) = sub1(x, y_plus_z);
        return (res,);
    }

    //s:1356, rc:126
    func sub_three_terms3{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        let (x_sub_y: Uint384) = sub1(x, y);
        let (res: Uint384) = sub1(x_sub_y, z);
        return (res,);
    }

    //Best but assumes all inputs <p, can give wrong answers otherwise
    //also relies on 3*p<2**384
    //s:455, rc:40
    func sub_three_terms_no_input_check{range_check_ptr}(
        x: Uint384, y: Uint384, z: Uint384
    ) -> (res: Uint384) {
        let (p_expand: Uint384_expand) = get_modulus_expand();
        let (twice_p: Uint384) = get_twice_p();
	let (sum1: Uint384,_) = uint384_lib.add(x,twice_p);
	let (sum2: Uint384,_) = uint384_lib.add(y,z);
	// note that we must have sum1 > sum2
	let (diff: Uint384,_) = uint384_lib.sub(sum1,sum2);

	let (_,res: Uint384) = uint384_lib.unsigned_div_rem_expanded(diff,p_expand);
        return (res,);
    }
    

}
