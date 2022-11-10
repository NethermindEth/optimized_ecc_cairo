from lib.uint384 import Uint384, Uint384_expand, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.fq_new import fq_lib
from lib.curve_new import fq2_c0, fq2_c1, get_modulus, get_modulus_expand, get_2_inverse, get_2_inverse_exp
from lib.field_arithmetic_new import field_arithmetic
from lib.uint384_vec import dot_by_uint64_vec12_mod, dot_by_uint64_vec23_mod

struct FQ12 {
    e0: Uint384,
    e1: Uint384,
    e2: Uint384,
    e3: Uint384,
    e4: Uint384,
    e5: Uint384,
    e6: Uint384,
    e7: Uint384,
    e8: Uint384,
    e9: Uint384,
    e10: Uint384,
    e11: Uint384,
}

// This library is implemented without recursvie calls, hardcoding and repeating code instead, for the sake of efficiency
const HALF_SHIFT = 2 ** 64;
namespace fq12_lib {
    // Verifies that the given field element is valid.
    func check{range_check_ptr}(x: FQ12) -> () {
        alloc_locals;
        let (field_modulus: Uint384) = get_modulus();
	
	uint384_lib.check(x.e0);
	let (is_valid) = uint384_lib.lt(x.e0, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e1);
	let (is_valid) = uint384_lib.lt(x.e1, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e2);
	let (is_valid) = uint384_lib.lt(x.e2, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e3);
	let (is_valid) = uint384_lib.lt(x.e3, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e4);
	let (is_valid) = uint384_lib.lt(x.e4, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e5);
	let (is_valid) = uint384_lib.lt(x.e5, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e6);
	let (is_valid) = uint384_lib.lt(x.e6, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e7);
	let (is_valid) = uint384_lib.lt(x.e7, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e8);
	let (is_valid) = uint384_lib.lt(x.e8, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e9);
	let (is_valid) = uint384_lib.lt(x.e9, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e10);
	let (is_valid) = uint384_lib.lt(x.e10, field_modulus);
	assert is_valid = 1;
	
	uint384_lib.check(x.e11);
	let (is_valid) = uint384_lib.lt(x.e11, field_modulus);
	assert is_valid = 1;

	return ();
    }
  
    // st=4963, mh=240, rc=540
    func add{range_check_ptr}(x: FQ12, y: FQ12) -> (sum_mod: FQ12) {
        // TODO: check why alloc_locals seems to be needed here
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (e0: Uint384) = field_arithmetic.add(x.e0, y.e0, p_expand);
        let (e1: Uint384) = field_arithmetic.add(x.e1, y.e1, p_expand);
        let (e2: Uint384) = field_arithmetic.add(x.e2, y.e2, p_expand);
        let (e3: Uint384) = field_arithmetic.add(x.e3, y.e3, p_expand);
        let (e4: Uint384) = field_arithmetic.add(x.e4, y.e4, p_expand);
        let (e5: Uint384) = field_arithmetic.add(x.e5, y.e5, p_expand);
        let (e6: Uint384) = field_arithmetic.add(x.e6, y.e6, p_expand);
        let (e7: Uint384) = field_arithmetic.add(x.e7, y.e7, p_expand);
        let (e8: Uint384) = field_arithmetic.add(x.e8, y.e8, p_expand);
        let (e9: Uint384) = field_arithmetic.add(x.e9, y.e9, p_expand);
        let (e10: Uint384) = field_arithmetic.add(x.e10, y.e10, p_expand);
        let (e11: Uint384) = field_arithmetic.add(x.e11, y.e11, p_expand);
        let res = FQ12(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11);
        return (res,);
    }

    //using sub1 instead of sub
    // st=6723, mh=996, rc=612
    func sub{range_check_ptr}(x: FQ12, y: FQ12) -> (sum_mod: FQ12) {
        alloc_locals;
        let (e0: Uint384) = fq_lib.sub1(x.e0, y.e0);
        let (e1: Uint384) = fq_lib.sub1(x.e1, y.e1);
        let (e2: Uint384) = fq_lib.sub1(x.e2, y.e2);
        let (e3: Uint384) = fq_lib.sub1(x.e3, y.e3);
        let (e4: Uint384) = fq_lib.sub1(x.e4, y.e4);
        let (e5: Uint384) = fq_lib.sub1(x.e5, y.e5);
        let (e6: Uint384) = fq_lib.sub1(x.e6, y.e6);
        let (e7: Uint384) = fq_lib.sub1(x.e7, y.e7);
        let (e8: Uint384) = fq_lib.sub1(x.e8, y.e8);
        let (e9: Uint384) = fq_lib.sub1(x.e9, y.e9);
        let (e10: Uint384) = fq_lib.sub1(x.e10, y.e10);
        let (e11: Uint384) = fq_lib.sub1(x.e11, y.e11);
        let res = FQ12(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11);
        return (res,);
    }

    //allows for only one expansion of the modulus into a Uint384_expand.
    // st=12367, mh=960, rc=1332
    func sub_2{range_check_ptr}(x: FQ12, y: FQ12) -> (sum_mod: FQ12) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (_, x_e0_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e0, p_expand);
        let (_, x_e1_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e1, p_expand);
        let (_, x_e2_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e2, p_expand);
        let (_, x_e3_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e3, p_expand);
        let (_, x_e4_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e4, p_expand);
        let (_, x_e5_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e5, p_expand);
        let (_, x_e6_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e6, p_expand);
        let (_, x_e7_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e7, p_expand);
        let (_, x_e8_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e8, p_expand);
        let (_, x_e9_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e9, p_expand);
        let (_, x_e10_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e10, p_expand);
        let (_, x_e11_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e11, p_expand);

        let (_, y_e0_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e0, p_expand);
        let (_, y_e1_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e1, p_expand);
        let (_, y_e2_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e2, p_expand);
        let (_, y_e3_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e3, p_expand);
        let (_, y_e4_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e4, p_expand);
        let (_, y_e5_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e5, p_expand);
        let (_, y_e6_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e6, p_expand);
        let (_, y_e7_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e7, p_expand);
        let (_, y_e8_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e8, p_expand);
        let (_, y_e9_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e9, p_expand);
        let (_, y_e10_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e10, p_expand);
        let (_, y_e11_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e11, p_expand);
        

        let (e0: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e0_red, y_e0_red, p_expand);
        let (e1: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e1_red, y_e1_red, p_expand);
        let (e2: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e2_red, y_e2_red, p_expand);
        let (e3: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e3_red, y_e3_red, p_expand);
        let (e4: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e4_red, y_e4_red, p_expand);
        let (e5: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e5_red, y_e5_red, p_expand);
        let (e6: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e6_red, y_e6_red, p_expand);
        let (e7: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e7_red, y_e7_red, p_expand);
        let (e8: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e8_red, y_e8_red, p_expand);
        let (e9: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e9_red, y_e9_red, p_expand);
        let (e10: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e10_red, y_e10_red, p_expand);
        let (e11: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e11_red, y_e11_red, p_expand);
        let res = FQ12(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11);
        return (res,);
    }

    //assumes all components are < p
    // st=5671, mh=480, rc=588
    func sub_3{range_check_ptr}(x: FQ12, y: FQ12) -> (sum_mod: FQ12) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (e0: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e0, y.e0, p_expand);
        let (e1: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e1, y.e1, p_expand);
        let (e2: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e2, y.e2, p_expand);
        let (e3: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e3, y.e3, p_expand);
        let (e4: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e4, y.e4, p_expand);
        let (e5: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e5, y.e5, p_expand);
        let (e6: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e6, y.e6, p_expand);
        let (e7: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e7, y.e7, p_expand);
        let (e8: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e8, y.e8, p_expand);
        let (e9: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e9, y.e9, p_expand);
        let (e10: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e10, y.e10, p_expand);
        let (e11: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x.e11, y.e11, p_expand);
        let res = FQ12(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11);
        return (res,);
    }

    //changed scalar mul to allow for only one expansion of the modulus into a Uint384_expand, updated range_check_ptr
    //assumes x<2**128
    // st=8502, mh=240, rc=987
    func scalar_mul{range_check_ptr}(x: felt, y: FQ12) -> (
        product: FQ12
    ) {
        alloc_locals;
        let (p_expand:Uint384_expand)= get_modulus_expand();
        let (low, high)=uint384_lib.split_64(x);
        let packed_expand: Uint384_expand = Uint384_expand(low*HALF_SHIFT, x, high, 0, 0, 0, 0);
        let (e0: Uint384) = field_arithmetic.mul_expanded(y.e0, packed_expand, p_expand);
        let (e1: Uint384) = field_arithmetic.mul_expanded(y.e1, packed_expand, p_expand);
        let (e2: Uint384) = field_arithmetic.mul_expanded(y.e2, packed_expand, p_expand);
        let (e3: Uint384) = field_arithmetic.mul_expanded(y.e3, packed_expand, p_expand);
        let (e4: Uint384) = field_arithmetic.mul_expanded(y.e4, packed_expand, p_expand);
        let (e5: Uint384) = field_arithmetic.mul_expanded(y.e5, packed_expand, p_expand);
        let (e6: Uint384) = field_arithmetic.mul_expanded(y.e6, packed_expand, p_expand);
        let (e7: Uint384) = field_arithmetic.mul_expanded(y.e7, packed_expand, p_expand);
        let (e8: Uint384) = field_arithmetic.mul_expanded(y.e8, packed_expand, p_expand);
        let (e9: Uint384) = field_arithmetic.mul_expanded(y.e9, packed_expand, p_expand);
        let (e10: Uint384) = field_arithmetic.mul_expanded(y.e10, packed_expand, p_expand);
        let (e11: Uint384) = field_arithmetic.mul_expanded(y.e11, packed_expand, p_expand);
        let res = FQ12(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11);
        return (res,);
    }
    
    //changed scalar mul to allow for only one expansion of the modulus into a Uint384_expand, updated range_check_ptr
    //assumes x<2**128
    // st=6032, mh=240, rc=756
    func scalar_mul2{range_check_ptr}(x: felt, y: FQ12) -> (
        product: FQ12
    ) {
        alloc_locals;
        let (p_expand:Uint384_expand)= get_modulus_expand();
        let (e0: Uint384) = field_arithmetic.mul_by_uint128(y.e0, x, p_expand);
        let (e1: Uint384) = field_arithmetic.mul_by_uint128(y.e1, x, p_expand);
        let (e2: Uint384) = field_arithmetic.mul_by_uint128(y.e2, x, p_expand);
        let (e3: Uint384) = field_arithmetic.mul_by_uint128(y.e3, x, p_expand);
        let (e4: Uint384) = field_arithmetic.mul_by_uint128(y.e4, x, p_expand);
        let (e5: Uint384) = field_arithmetic.mul_by_uint128(y.e5, x, p_expand);
        let (e6: Uint384) = field_arithmetic.mul_by_uint128(y.e6, x, p_expand);
        let (e7: Uint384) = field_arithmetic.mul_by_uint128(y.e7, x, p_expand);
        let (e8: Uint384) = field_arithmetic.mul_by_uint128(y.e8, x, p_expand);
        let (e9: Uint384) = field_arithmetic.mul_by_uint128(y.e9, x, p_expand);
        let (e10: Uint384) = field_arithmetic.mul_by_uint128(y.e10, x, p_expand);
        let (e11: Uint384) = field_arithmetic.mul_by_uint128(y.e11, x, p_expand);
        let res = FQ12(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11);
        return (res,);
    }


    //changed mul so that it would only expand the modulus once. 
    // st=166935, mh=6180, rc=19836
    func mul{range_check_ptr}(a: FQ12, b: FQ12) -> (product: FQ12) {
        alloc_locals;
        let (p_expand:Uint384_expand) = get_modulus_expand();
        // d0
        let (d0: Uint384) = field_arithmetic.mul(a.e0, b.e0, p_expand);

        // d1
        let (b_0_1: Uint384) = field_arithmetic.mul(a.e0, b.e1, p_expand);
        let (b_1_0: Uint384) = field_arithmetic.mul(a.e1, b.e0, p_expand);
        let (d1: Uint384) = field_arithmetic.add(b_0_1, b_1_0, p_expand);

        // d2
        let (b_0_2: Uint384) = field_arithmetic.mul(a.e0, b.e2, p_expand);
        let (b_1_1: Uint384) = field_arithmetic.mul(a.e1, b.e1, p_expand);
        let (b_2_0: Uint384) = field_arithmetic.mul(a.e2, b.e0, p_expand);
        let (d2: Uint384) = field_arithmetic.add(b_0_2, b_1_1, p_expand);
        let (d2: Uint384) = field_arithmetic.add(d2, b_2_0, p_expand);

        // d3
        let (b_0_3: Uint384) = field_arithmetic.mul(a.e0, b.e3, p_expand);
        let (b_1_2: Uint384) = field_arithmetic.mul(a.e1, b.e2, p_expand);
        let (b_2_1: Uint384) = field_arithmetic.mul(a.e2, b.e1, p_expand);
        let (b_3_0: Uint384) = field_arithmetic.mul(a.e3, b.e0, p_expand);
        let (d3: Uint384) = field_arithmetic.add(b_0_3, b_1_2, p_expand);
        let (d3: Uint384) = field_arithmetic.add(d3, b_2_1, p_expand);
        let (d3: Uint384) = field_arithmetic.add(d3, b_3_0, p_expand);

        // d4
        let (b_0_4: Uint384) = field_arithmetic.mul(a.e0, b.e4, p_expand);
        let (b_1_3: Uint384) = field_arithmetic.mul(a.e1, b.e3, p_expand);
        let (b_2_2: Uint384) = field_arithmetic.mul(a.e2, b.e2, p_expand);
        let (b_3_1: Uint384) = field_arithmetic.mul(a.e3, b.e1, p_expand);
        let (b_4_0: Uint384) = field_arithmetic.mul(a.e4, b.e0, p_expand);
        let (d4: Uint384) = field_arithmetic.add(b_0_4, b_1_3, p_expand);
        let (d4: Uint384) = field_arithmetic.add(d4, b_2_2, p_expand);
        let (d4: Uint384) = field_arithmetic.add(d4, b_3_1, p_expand);
        let (d4: Uint384) = field_arithmetic.add(d4, b_4_0, p_expand);

        // d5
        let (b_0_5: Uint384) = field_arithmetic.mul(a.e0, b.e5, p_expand);
        let (b_1_4: Uint384) = field_arithmetic.mul(a.e1, b.e4, p_expand);
        let (b_2_3: Uint384) = field_arithmetic.mul(a.e2, b.e3, p_expand);
        let (b_3_2: Uint384) = field_arithmetic.mul(a.e3, b.e2, p_expand);
        let (b_4_1: Uint384) = field_arithmetic.mul(a.e4, b.e1, p_expand);
        let (b_5_0: Uint384) = field_arithmetic.mul(a.e5, b.e0, p_expand);
        let (d5: Uint384) = field_arithmetic.add(b_0_5, b_1_4, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_2_3, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_3_2, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_4_1, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_5_0, p_expand);

        // d6
        let (b_0_6: Uint384) = field_arithmetic.mul(a.e0, b.e6, p_expand);
        let (b_1_5: Uint384) = field_arithmetic.mul(a.e1, b.e5, p_expand);
        let (b_2_4: Uint384) = field_arithmetic.mul(a.e2, b.e4, p_expand);
        let (b_3_3: Uint384) = field_arithmetic.mul(a.e3, b.e3, p_expand);
        let (b_4_2: Uint384) = field_arithmetic.mul(a.e4, b.e2, p_expand);
        let (b_5_1: Uint384) = field_arithmetic.mul(a.e5, b.e1, p_expand);
        let (b_6_0: Uint384) = field_arithmetic.mul(a.e6, b.e0, p_expand);
        let (d6: Uint384) = field_arithmetic.add(b_0_6, b_1_5, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_2_4, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_3_3, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_4_2, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_5_1, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_6_0, p_expand);

        // d7
        let (b_0_7: Uint384) = field_arithmetic.mul(a.e0, b.e7, p_expand);
        let (b_1_6: Uint384) = field_arithmetic.mul(a.e1, b.e6, p_expand);
        let (b_2_5: Uint384) = field_arithmetic.mul(a.e2, b.e5, p_expand);
        let (b_3_4: Uint384) = field_arithmetic.mul(a.e3, b.e4, p_expand);
        let (b_4_3: Uint384) = field_arithmetic.mul(a.e4, b.e3, p_expand);
        let (b_5_2: Uint384) = field_arithmetic.mul(a.e5, b.e2, p_expand);
        let (b_6_1: Uint384) = field_arithmetic.mul(a.e6, b.e1, p_expand);
        let (b_7_0: Uint384) = field_arithmetic.mul(a.e7, b.e0, p_expand);
        let (d7: Uint384) = field_arithmetic.add(b_0_7, b_1_6, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_2_5, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_3_4, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_4_3, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_5_2, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_6_1, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_7_0, p_expand);

        // d8
        let (b_0_8: Uint384) = field_arithmetic.mul(a.e0, b.e8, p_expand);
        let (b_1_7: Uint384) = field_arithmetic.mul(a.e1, b.e7, p_expand);
        let (b_2_6: Uint384) = field_arithmetic.mul(a.e2, b.e6, p_expand);
        let (b_3_5: Uint384) = field_arithmetic.mul(a.e3, b.e5, p_expand);
        let (b_4_4: Uint384) = field_arithmetic.mul(a.e4, b.e4, p_expand);
        let (b_5_3: Uint384) = field_arithmetic.mul(a.e5, b.e3, p_expand);
        let (b_6_2: Uint384) = field_arithmetic.mul(a.e6, b.e2, p_expand);
        let (b_7_1: Uint384) = field_arithmetic.mul(a.e7, b.e1, p_expand);
        let (b_8_0: Uint384) = field_arithmetic.mul(a.e8, b.e0, p_expand);
        let (d8: Uint384) = field_arithmetic.add(b_0_8, b_1_7, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_2_6, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_3_5, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_4_4, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_5_3, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_6_2, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_7_1, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_8_0, p_expand);

        // d9
        let (b_0_9: Uint384) = field_arithmetic.mul(a.e0, b.e9, p_expand);
        let (b_1_8: Uint384) = field_arithmetic.mul(a.e1, b.e8, p_expand);
        let (b_2_7: Uint384) = field_arithmetic.mul(a.e2, b.e7, p_expand);
        let (b_3_6: Uint384) = field_arithmetic.mul(a.e3, b.e6, p_expand);
        let (b_4_5: Uint384) = field_arithmetic.mul(a.e4, b.e5, p_expand);
        let (b_5_4: Uint384) = field_arithmetic.mul(a.e5, b.e4, p_expand);
        let (b_6_3: Uint384) = field_arithmetic.mul(a.e6, b.e3, p_expand);
        let (b_7_2: Uint384) = field_arithmetic.mul(a.e7, b.e2, p_expand);
        let (b_8_1: Uint384) = field_arithmetic.mul(a.e8, b.e1, p_expand);
        let (b_9_0: Uint384) = field_arithmetic.mul(a.e9, b.e0, p_expand);
        let (d9: Uint384) = field_arithmetic.add(b_0_9, b_1_8, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_2_7, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_3_6, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_4_5, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_5_4, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_6_3, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_7_2, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_8_1, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_9_0, p_expand);

        // d10
        let (b_0_10: Uint384) = field_arithmetic.mul(a.e0, b.e10, p_expand);
        let (b_1_9: Uint384) = field_arithmetic.mul(a.e1, b.e9, p_expand);
        let (b_2_8: Uint384) = field_arithmetic.mul(a.e2, b.e8, p_expand);
        let (b_3_7: Uint384) = field_arithmetic.mul(a.e3, b.e7, p_expand);
        let (b_4_6: Uint384) = field_arithmetic.mul(a.e4, b.e6, p_expand);
        let (b_5_5: Uint384) = field_arithmetic.mul(a.e5, b.e5, p_expand);
        let (b_6_4: Uint384) = field_arithmetic.mul(a.e6, b.e4, p_expand);
        let (b_7_3: Uint384) = field_arithmetic.mul(a.e7, b.e3, p_expand);
        let (b_8_2: Uint384) = field_arithmetic.mul(a.e8, b.e2, p_expand);
        let (b_9_1: Uint384) = field_arithmetic.mul(a.e9, b.e1, p_expand);
        let (b_10_0: Uint384) = field_arithmetic.mul(a.e10, b.e0, p_expand);
        let (d10: Uint384) = field_arithmetic.add(b_0_10, b_1_9, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_2_8, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_3_7, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_4_6, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_5_5, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_6_4, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_7_3, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_8_2, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_9_1, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_10_0, p_expand);

        // d11
        let (b_0_11: Uint384) = field_arithmetic.mul(a.e0, b.e11, p_expand);
        let (b_1_10: Uint384) = field_arithmetic.mul(a.e1, b.e10, p_expand);
        let (b_2_9: Uint384) = field_arithmetic.mul(a.e2, b.e9, p_expand);
        let (b_3_8: Uint384) = field_arithmetic.mul(a.e3, b.e8, p_expand);
        let (b_4_7: Uint384) = field_arithmetic.mul(a.e4, b.e7, p_expand);
        let (b_5_6: Uint384) = field_arithmetic.mul(a.e5, b.e6, p_expand);
        let (b_6_5: Uint384) = field_arithmetic.mul(a.e6, b.e5, p_expand);
        let (b_7_4: Uint384) = field_arithmetic.mul(a.e7, b.e4, p_expand);
        let (b_8_3: Uint384) = field_arithmetic.mul(a.e8, b.e3, p_expand);
        let (b_9_2: Uint384) = field_arithmetic.mul(a.e9, b.e2, p_expand);
        let (b_10_1: Uint384) = field_arithmetic.mul(a.e10, b.e1, p_expand);
        let (b_11_0: Uint384) = field_arithmetic.mul(a.e11, b.e0, p_expand);
        let (d11: Uint384) = field_arithmetic.add(b_0_11, b_1_10, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_2_9, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_3_8, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_4_7, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_5_6, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_6_5, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_7_4, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_8_3, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_9_2, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_10_1, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_11_0, p_expand);

        // d12
        let (b_1_11: Uint384) = field_arithmetic.mul(a.e1, b.e11, p_expand);
        let (b_2_10: Uint384) = field_arithmetic.mul(a.e2, b.e10, p_expand);
        let (b_3_9: Uint384) = field_arithmetic.mul(a.e3, b.e9, p_expand);
        let (b_4_8: Uint384) = field_arithmetic.mul(a.e4, b.e8, p_expand);
        let (b_5_7: Uint384) = field_arithmetic.mul(a.e5, b.e7, p_expand);
        let (b_6_6: Uint384) = field_arithmetic.mul(a.e6, b.e6, p_expand);
        let (b_7_5: Uint384) = field_arithmetic.mul(a.e7, b.e5, p_expand);
        let (b_8_4: Uint384) = field_arithmetic.mul(a.e8, b.e4, p_expand);
        let (b_9_3: Uint384) = field_arithmetic.mul(a.e9, b.e3, p_expand);
        let (b_10_2: Uint384) = field_arithmetic.mul(a.e10, b.e2, p_expand);
        let (b_11_1: Uint384) = field_arithmetic.mul(a.e11, b.e1, p_expand);
        let (d12: Uint384) = field_arithmetic.add(b_1_11, b_2_10, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_3_9, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_4_8, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_5_7, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_6_6, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_7_5, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_8_4, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_9_3, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_10_2, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_11_1, p_expand);

        // d13
        let (b_2_11: Uint384) = field_arithmetic.mul(a.e2, b.e11, p_expand);
        let (b_3_10: Uint384) = field_arithmetic.mul(a.e3, b.e10, p_expand);
        let (b_4_9: Uint384) = field_arithmetic.mul(a.e4, b.e9, p_expand);
        let (b_5_8: Uint384) = field_arithmetic.mul(a.e5, b.e8, p_expand);
        let (b_6_7: Uint384) = field_arithmetic.mul(a.e6, b.e7, p_expand);
        let (b_7_6: Uint384) = field_arithmetic.mul(a.e7, b.e6, p_expand);
        let (b_8_5: Uint384) = field_arithmetic.mul(a.e8, b.e5, p_expand);
        let (b_9_4: Uint384) = field_arithmetic.mul(a.e9, b.e4, p_expand);
        let (b_10_3: Uint384) = field_arithmetic.mul(a.e10, b.e3, p_expand);
        let (b_11_2: Uint384) = field_arithmetic.mul(a.e11, b.e2, p_expand);
        let (d13: Uint384) = field_arithmetic.add(b_2_11, b_3_10, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_4_9, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_5_8, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_6_7, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_7_6, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_8_5, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_9_4, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_10_3, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_11_2, p_expand);

        // d14
        let (b_3_11: Uint384) = field_arithmetic.mul(a.e3, b.e11, p_expand);
        let (b_4_10: Uint384) = field_arithmetic.mul(a.e4, b.e10, p_expand);
        let (b_5_9: Uint384) = field_arithmetic.mul(a.e5, b.e9, p_expand);
        let (b_6_8: Uint384) = field_arithmetic.mul(a.e6, b.e8, p_expand);
        let (b_7_7: Uint384) = field_arithmetic.mul(a.e7, b.e7, p_expand);
        let (b_8_6: Uint384) = field_arithmetic.mul(a.e8, b.e6, p_expand);
        let (b_9_5: Uint384) = field_arithmetic.mul(a.e9, b.e5, p_expand);
        let (b_10_4: Uint384) = field_arithmetic.mul(a.e10, b.e4, p_expand);
        let (b_11_3: Uint384) = field_arithmetic.mul(a.e11, b.e3, p_expand);
        let (d14: Uint384) = field_arithmetic.add(b_3_11, b_4_10, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_5_9, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_6_8, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_7_7, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_8_6, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_9_5, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_10_4, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_11_3, p_expand);

        // d15
        let (b_4_11: Uint384) = field_arithmetic.mul(a.e4, b.e11, p_expand);
        let (b_5_10: Uint384) = field_arithmetic.mul(a.e5, b.e10, p_expand);
        let (b_6_9: Uint384) = field_arithmetic.mul(a.e6, b.e9, p_expand);
        let (b_7_8: Uint384) = field_arithmetic.mul(a.e7, b.e8, p_expand);
        let (b_8_7: Uint384) = field_arithmetic.mul(a.e8, b.e7, p_expand);
        let (b_9_6: Uint384) = field_arithmetic.mul(a.e9, b.e6, p_expand);
        let (b_10_5: Uint384) = field_arithmetic.mul(a.e10, b.e5, p_expand);
        let (b_11_4: Uint384) = field_arithmetic.mul(a.e11, b.e4, p_expand);
        let (d15: Uint384) = field_arithmetic.add(b_4_11, b_5_10, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_6_9, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_7_8, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_8_7, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_9_6, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_10_5, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_11_4, p_expand);

        // d16
        let (b_5_11: Uint384) = field_arithmetic.mul(a.e5, b.e11, p_expand);
        let (b_6_10: Uint384) = field_arithmetic.mul(a.e6, b.e10, p_expand);
        let (b_7_9: Uint384) = field_arithmetic.mul(a.e7, b.e9, p_expand);
        let (b_8_8: Uint384) = field_arithmetic.mul(a.e8, b.e8, p_expand);
        let (b_9_7: Uint384) = field_arithmetic.mul(a.e9, b.e7, p_expand);
        let (b_10_6: Uint384) = field_arithmetic.mul(a.e10, b.e6, p_expand);
        let (b_11_5: Uint384) = field_arithmetic.mul(a.e11, b.e5, p_expand);
        let (d16: Uint384) = field_arithmetic.add(b_5_11, b_6_10, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_7_9, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_8_8, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_9_7, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_10_6, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_11_5, p_expand);

        // d17
        let (b_6_11: Uint384) = field_arithmetic.mul(a.e6, b.e11, p_expand);
        let (b_7_10: Uint384) = field_arithmetic.mul(a.e7, b.e10, p_expand);
        let (b_8_9: Uint384) = field_arithmetic.mul(a.e8, b.e9, p_expand);
        let (b_9_8: Uint384) = field_arithmetic.mul(a.e9, b.e8, p_expand);
        let (b_10_7: Uint384) = field_arithmetic.mul(a.e10, b.e7, p_expand);
        let (b_11_6: Uint384) = field_arithmetic.mul(a.e11, b.e6, p_expand);
        let (d17: Uint384) = field_arithmetic.add(b_6_11, b_7_10, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_8_9, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_9_8, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_10_7, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_11_6, p_expand);

        // d18
        let (b_7_11: Uint384) = field_arithmetic.mul(a.e7, b.e11, p_expand);
        let (b_8_10: Uint384) = field_arithmetic.mul(a.e8, b.e10, p_expand);
        let (b_9_9: Uint384) = field_arithmetic.mul(a.e9, b.e9, p_expand);
        let (b_10_8: Uint384) = field_arithmetic.mul(a.e10, b.e8, p_expand);
        let (b_11_7: Uint384) = field_arithmetic.mul(a.e11, b.e7, p_expand);
        let (d18: Uint384) = field_arithmetic.add(b_7_11, b_8_10, p_expand);
        let (d18: Uint384) = field_arithmetic.add(d18, b_9_9, p_expand);
        let (d18: Uint384) = field_arithmetic.add(d18, b_10_8, p_expand);
        let (d18: Uint384) = field_arithmetic.add(d18, b_11_7, p_expand);

        // d19
        let (b_8_11: Uint384) = field_arithmetic.mul(a.e8, b.e11, p_expand);
        let (b_9_10: Uint384) = field_arithmetic.mul(a.e9, b.e10, p_expand);
        let (b_10_9: Uint384) = field_arithmetic.mul(a.e10, b.e9, p_expand);
        let (b_11_8: Uint384) = field_arithmetic.mul(a.e11, b.e8, p_expand);
        let (d19: Uint384) = field_arithmetic.add(b_8_11, b_9_10, p_expand);
        let (d19: Uint384) = field_arithmetic.add(d19, b_10_9, p_expand);
        let (d19: Uint384) = field_arithmetic.add(d19, b_11_8, p_expand);

        // d20
        let (b_9_11: Uint384) = field_arithmetic.mul(a.e9, b.e11, p_expand);
        let (b_10_10: Uint384) = field_arithmetic.mul(a.e10, b.e10, p_expand);
        let (b_11_9: Uint384) = field_arithmetic.mul(a.e11, b.e9, p_expand);
        let (d20: Uint384) = field_arithmetic.add(b_9_11, b_10_10, p_expand);
        let (d20: Uint384) = field_arithmetic.add(d20, b_11_9, p_expand);

        // d21
        let (b_10_11: Uint384) = field_arithmetic.mul(a.e10, b.e11, p_expand);
        let (b_11_10: Uint384) = field_arithmetic.mul(a.e11, b.e10, p_expand);
        let (d21: Uint384) = field_arithmetic.add(b_10_11, b_11_10, p_expand);

        // d22
        let (d22: Uint384) = field_arithmetic.mul(a.e11, b.e11, p_expand);

        // Reducing the results modulo the irreducible polynomial
        // Note that the order in which _aux_polynomial_reduction is called is important here
        let (d10: Uint384, d16: Uint384) = _aux_polynomial_reduction(d22, d10, d16);
        let (d9: Uint384, d15: Uint384) = _aux_polynomial_reduction(d21, d9, d15);
        let (d8: Uint384, d14: Uint384) = _aux_polynomial_reduction(d20, d8, d14);
        let (d7: Uint384, d13: Uint384) = _aux_polynomial_reduction(d19, d7, d13);
        let (d6: Uint384, d12: Uint384) = _aux_polynomial_reduction(d18, d6, d12);
        let (d5: Uint384, d11: Uint384) = _aux_polynomial_reduction(d17, d5, d11);
        let (d4: Uint384, d10: Uint384) = _aux_polynomial_reduction(d16, d4, d10);
        let (d3: Uint384, d9: Uint384) = _aux_polynomial_reduction(d15, d3, d9);
        let (d2: Uint384, d8: Uint384) = _aux_polynomial_reduction(d14, d2, d8);
        let (d1: Uint384, d7: Uint384) = _aux_polynomial_reduction(d13, d1, d7);
        let (d0: Uint384, d6: Uint384) = _aux_polynomial_reduction(d12, d0, d6);

        return (FQ12(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11),);
    }

    // since 9*p < 2**384 we can add up to 9 elements before needing to reduce
    // also expanded the components of b
    // st=125775, mh=4280, rc=14372
    func mul_2{range_check_ptr}(a: FQ12, b: FQ12) -> (product: FQ12) {
        alloc_locals;
        let (p_expand:Uint384_expand) = get_modulus_expand();

	let (b_e0:Uint384_expand) = uint384_lib.expand(b.e0);
	let (b_e1:Uint384_expand) = uint384_lib.expand(b.e1);
	let (b_e2:Uint384_expand) = uint384_lib.expand(b.e2);
	let (b_e3:Uint384_expand) = uint384_lib.expand(b.e3);
	let (b_e4:Uint384_expand) = uint384_lib.expand(b.e4);
	let (b_e5:Uint384_expand) = uint384_lib.expand(b.e5);
	let (b_e6:Uint384_expand) = uint384_lib.expand(b.e6);
	let (b_e7:Uint384_expand) = uint384_lib.expand(b.e7);
	let (b_e8:Uint384_expand) = uint384_lib.expand(b.e8);
	let (b_e9:Uint384_expand) = uint384_lib.expand(b.e9);
	let (b_e10:Uint384_expand) = uint384_lib.expand(b.e10);
	let (b_e11:Uint384_expand) = uint384_lib.expand(b.e11);
	
        // d0
        let (d0: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e0, p_expand);

        // d1
        let (b_0_1: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e1, p_expand);
        let (b_1_0: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e0, p_expand);
        let (d1: Uint384,_) = uint384_lib.add(b_0_1, b_1_0);
	let (_,d1: Uint384) = uint384_lib.unsigned_div_rem_expanded(d1, p_expand);

        // d2
        let (b_0_2: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e2, p_expand);
        let (b_1_1: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e1, p_expand);
        let (b_2_0: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e0, p_expand);
        let (d2: Uint384,_) = uint384_lib.add(b_0_2, b_1_1);
        let (d2: Uint384,_) = uint384_lib.add(d2, b_2_0);
	let (_,d2: Uint384) = uint384_lib.unsigned_div_rem_expanded(d2, p_expand);

        // d3
        let (b_0_3: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e3, p_expand);
        let (b_1_2: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e2, p_expand);
        let (b_2_1: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e1, p_expand);
        let (b_3_0: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e0, p_expand);
        let (d3: Uint384,_) = uint384_lib.add(b_0_3, b_1_2);
        let (d3: Uint384,_) = uint384_lib.add(d3, b_2_1);
        let (d3: Uint384,_) = uint384_lib.add(d3, b_3_0);
	let (_,d3: Uint384) = uint384_lib.unsigned_div_rem_expanded(d3, p_expand);

        // d4
        let (b_0_4: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e4, p_expand);
        let (b_1_3: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e3, p_expand);
        let (b_2_2: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e2, p_expand);
        let (b_3_1: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e1, p_expand);
        let (b_4_0: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e0, p_expand);
        let (d4: Uint384,_) = uint384_lib.add(b_0_4, b_1_3);
        let (d4: Uint384,_) = uint384_lib.add(d4, b_2_2);
        let (d4: Uint384,_) = uint384_lib.add(d4, b_3_1);
        let (d4: Uint384,_) = uint384_lib.add(d4, b_4_0);
	let (_,d4: Uint384) = uint384_lib.unsigned_div_rem_expanded(d4, p_expand);

        // d5
        let (b_0_5: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e5, p_expand);
        let (b_1_4: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e4, p_expand);
        let (b_2_3: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e3, p_expand);
        let (b_3_2: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e2, p_expand);
        let (b_4_1: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e1, p_expand);
        let (b_5_0: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e0, p_expand);
        let (d5: Uint384,_) = uint384_lib.add(b_0_5, b_1_4);
        let (d5: Uint384,_) = uint384_lib.add(d5, b_2_3);
        let (d5: Uint384,_) = uint384_lib.add(d5, b_3_2);
        let (d5: Uint384,_) = uint384_lib.add(d5, b_4_1);
        let (d5: Uint384,_) = uint384_lib.add(d5, b_5_0);
	let (_,d5: Uint384) = uint384_lib.unsigned_div_rem_expanded(d5, p_expand);

        // d6
        let (b_0_6: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e6, p_expand);
        let (b_1_5: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e5, p_expand);
        let (b_2_4: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e4, p_expand);
        let (b_3_3: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e3, p_expand);
        let (b_4_2: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e2, p_expand);
        let (b_5_1: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e1, p_expand);
        let (b_6_0: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e0, p_expand);
        let (d6: Uint384,_) = uint384_lib.add(b_0_6, b_1_5);
        let (d6: Uint384,_) = uint384_lib.add(d6, b_2_4);
        let (d6: Uint384,_) = uint384_lib.add(d6, b_3_3);
        let (d6: Uint384,_) = uint384_lib.add(d6, b_4_2);
        let (d6: Uint384,_) = uint384_lib.add(d6, b_5_1);
        let (d6: Uint384,_) = uint384_lib.add(d6, b_6_0);
	let (_,d6: Uint384) = uint384_lib.unsigned_div_rem_expanded(d6, p_expand);

        // d7
        let (b_0_7: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e7, p_expand);
        let (b_1_6: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e6, p_expand);
        let (b_2_5: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e5, p_expand);
        let (b_3_4: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e4, p_expand);
        let (b_4_3: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e3, p_expand);
        let (b_5_2: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e2, p_expand);
        let (b_6_1: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e1, p_expand);
        let (b_7_0: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e0, p_expand);
        let (d7: Uint384,_) = uint384_lib.add(b_0_7, b_1_6);
        let (d7: Uint384,_) = uint384_lib.add(d7, b_2_5);
        let (d7: Uint384,_) = uint384_lib.add(d7, b_3_4);
        let (d7: Uint384,_) = uint384_lib.add(d7, b_4_3);
        let (d7: Uint384,_) = uint384_lib.add(d7, b_5_2);
        let (d7: Uint384,_) = uint384_lib.add(d7, b_6_1);
        let (d7: Uint384,_) = uint384_lib.add(d7, b_7_0);
	let (_,d7: Uint384) = uint384_lib.unsigned_div_rem_expanded(d7, p_expand);

        // d8
        let (b_0_8: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e8, p_expand);
        let (b_1_7: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e7, p_expand);
        let (b_2_6: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e6, p_expand);
        let (b_3_5: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e5, p_expand);
        let (b_4_4: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e4, p_expand);
        let (b_5_3: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e3, p_expand);
        let (b_6_2: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e2, p_expand);
        let (b_7_1: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e1, p_expand);
        let (b_8_0: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e0, p_expand);
        let (d8: Uint384,_) = uint384_lib.add(b_0_8, b_1_7);
        let (d8: Uint384,_) = uint384_lib.add(d8, b_2_6);
        let (d8: Uint384,_) = uint384_lib.add(d8, b_3_5);
        let (d8: Uint384,_) = uint384_lib.add(d8, b_4_4);
        let (d8: Uint384,_) = uint384_lib.add(d8, b_5_3);
        let (d8: Uint384,_) = uint384_lib.add(d8, b_6_2);
        let (d8: Uint384,_) = uint384_lib.add(d8, b_7_1);
        let (d8: Uint384,_) = uint384_lib.add(d8, b_8_0);
	let (_,d8: Uint384) = uint384_lib.unsigned_div_rem_expanded(d8, p_expand);

        // d9
        let (b_0_9: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e9, p_expand);
        let (b_1_8: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e8, p_expand);
        let (b_2_7: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e7, p_expand);
        let (b_3_6: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e6, p_expand);
        let (b_4_5: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e5, p_expand);
        let (b_5_4: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e4, p_expand);
        let (b_6_3: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e3, p_expand);
        let (b_7_2: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e2, p_expand);
        let (b_8_1: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e1, p_expand);
        let (b_9_0: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e0, p_expand);
        let (d9: Uint384,_) = uint384_lib.add(b_0_9, b_1_8);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_2_7);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_3_6);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_4_5);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_5_4);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_6_3);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_7_2);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_8_1);
	let (_,d9: Uint384) = uint384_lib.unsigned_div_rem_expanded(d9, p_expand);
        let (d9: Uint384,_) = uint384_lib.add(d9, b_9_0);
	let (_,d9: Uint384) = uint384_lib.unsigned_div_rem_expanded(d9, p_expand);

        // d10
        let (b_0_10: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e10, p_expand);
        let (b_1_9: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e9, p_expand);
        let (b_2_8: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e8, p_expand);
        let (b_3_7: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e7, p_expand);
        let (b_4_6: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e6, p_expand);
        let (b_5_5: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e5, p_expand);
        let (b_6_4: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e4, p_expand);
        let (b_7_3: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e3, p_expand);
        let (b_8_2: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e2, p_expand);
        let (b_9_1: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e1, p_expand);
        let (b_10_0: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e0, p_expand);
        let (d10: Uint384,_) = uint384_lib.add(b_0_10, b_1_9);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_2_8);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_3_7);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_4_6);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_5_5);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_6_4);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_7_3);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_8_2);
	let (_,d10: Uint384) = uint384_lib.unsigned_div_rem_expanded(d10, p_expand);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_9_1);
        let (d10: Uint384,_) = uint384_lib.add(d10, b_10_0);
	let (_,d10: Uint384) = uint384_lib.unsigned_div_rem_expanded(d10, p_expand);

        // d11
        let (b_0_11: Uint384) = field_arithmetic.mul_expanded(a.e0, b_e11, p_expand);
        let (b_1_10: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e10, p_expand);
        let (b_2_9: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e9, p_expand);
        let (b_3_8: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e8, p_expand);
        let (b_4_7: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e7, p_expand);
        let (b_5_6: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e6, p_expand);
        let (b_6_5: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e5, p_expand);
        let (b_7_4: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e4, p_expand);
        let (b_8_3: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e3, p_expand);
        let (b_9_2: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e2, p_expand);
        let (b_10_1: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e1, p_expand);
        let (b_11_0: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e0, p_expand);
        let (d11: Uint384,_) = uint384_lib.add(b_0_11, b_1_10);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_2_9);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_3_8);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_4_7);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_5_6);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_6_5);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_7_4);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_8_3);
	let (_,d11: Uint384) = uint384_lib.unsigned_div_rem_expanded(d11, p_expand);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_9_2);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_10_1);
        let (d11: Uint384,_) = uint384_lib.add(d11, b_11_0);
	let (_,d11: Uint384) = uint384_lib.unsigned_div_rem_expanded(d11, p_expand);

        // d12
        let (b_1_11: Uint384) = field_arithmetic.mul_expanded(a.e1, b_e11, p_expand);
        let (b_2_10: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e10, p_expand);
        let (b_3_9: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e9, p_expand);
        let (b_4_8: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e8, p_expand);
        let (b_5_7: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e7, p_expand);
        let (b_6_6: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e6, p_expand);
        let (b_7_5: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e5, p_expand);
        let (b_8_4: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e4, p_expand);
        let (b_9_3: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e3, p_expand);
        let (b_10_2: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e2, p_expand);
        let (b_11_1: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e1, p_expand);
        let (d12: Uint384,_) = uint384_lib.add(b_1_11, b_2_10);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_3_9);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_4_8);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_5_7);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_6_6);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_7_5);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_8_4);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_9_3);
	let (_,d12: Uint384) = uint384_lib.unsigned_div_rem_expanded(d12, p_expand);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_10_2);
        let (d12: Uint384,_) = uint384_lib.add(d12, b_11_1);
	let (_,d12: Uint384) = uint384_lib.unsigned_div_rem_expanded(d12, p_expand);

        // d13
        let (b_2_11: Uint384) = field_arithmetic.mul_expanded(a.e2, b_e11, p_expand);
        let (b_3_10: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e10, p_expand);
        let (b_4_9: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e9, p_expand);
        let (b_5_8: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e8, p_expand);
        let (b_6_7: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e7, p_expand);
        let (b_7_6: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e6, p_expand);
        let (b_8_5: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e5, p_expand);
        let (b_9_4: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e4, p_expand);
        let (b_10_3: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e3, p_expand);
        let (b_11_2: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e2, p_expand);
        let (d13: Uint384,_) = uint384_lib.add(b_2_11, b_3_10);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_4_9);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_5_8);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_6_7);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_7_6);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_8_5);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_9_4);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_10_3);
	let (_,d13: Uint384) = uint384_lib.unsigned_div_rem_expanded(d13, p_expand);
        let (d13: Uint384,_) = uint384_lib.add(d13, b_11_2);
	let (_,d13: Uint384) = uint384_lib.unsigned_div_rem_expanded(d13, p_expand);

        // d14
        let (b_3_11: Uint384) = field_arithmetic.mul_expanded(a.e3, b_e11, p_expand);
        let (b_4_10: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e10, p_expand);
        let (b_5_9: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e9, p_expand);
        let (b_6_8: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e8, p_expand);
        let (b_7_7: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e7, p_expand);
        let (b_8_6: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e6, p_expand);
        let (b_9_5: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e5, p_expand);
        let (b_10_4: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e4, p_expand);
        let (b_11_3: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e3, p_expand);
        let (d14: Uint384,_) = uint384_lib.add(b_3_11, b_4_10);
        let (d14: Uint384,_) = uint384_lib.add(d14, b_5_9);
        let (d14: Uint384,_) = uint384_lib.add(d14, b_6_8);
        let (d14: Uint384,_) = uint384_lib.add(d14, b_7_7);
        let (d14: Uint384,_) = uint384_lib.add(d14, b_8_6);
        let (d14: Uint384,_) = uint384_lib.add(d14, b_9_5);
        let (d14: Uint384,_) = uint384_lib.add(d14, b_10_4);
        let (d14: Uint384,_) = uint384_lib.add(d14, b_11_3);
	let (_,d14: Uint384) = uint384_lib.unsigned_div_rem_expanded(d14, p_expand);

        // d15
        let (b_4_11: Uint384) = field_arithmetic.mul_expanded(a.e4, b_e11, p_expand);
        let (b_5_10: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e10, p_expand);
        let (b_6_9: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e9, p_expand);
        let (b_7_8: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e8, p_expand);
        let (b_8_7: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e7, p_expand);
        let (b_9_6: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e6, p_expand);
        let (b_10_5: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e5, p_expand);
        let (b_11_4: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e4, p_expand);
        let (d15: Uint384,_) = uint384_lib.add(b_4_11, b_5_10);
        let (d15: Uint384,_) = uint384_lib.add(d15, b_6_9);
        let (d15: Uint384,_) = uint384_lib.add(d15, b_7_8);
        let (d15: Uint384,_) = uint384_lib.add(d15, b_8_7);
        let (d15: Uint384,_) = uint384_lib.add(d15, b_9_6);
        let (d15: Uint384,_) = uint384_lib.add(d15, b_10_5);
        let (d15: Uint384,_) = uint384_lib.add(d15, b_11_4);
	let (_,d15: Uint384) = uint384_lib.unsigned_div_rem_expanded(d15, p_expand);

        // d16
        let (b_5_11: Uint384) = field_arithmetic.mul_expanded(a.e5, b_e11, p_expand);
        let (b_6_10: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e10, p_expand);
        let (b_7_9: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e9, p_expand);
        let (b_8_8: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e8, p_expand);
        let (b_9_7: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e7, p_expand);
        let (b_10_6: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e6, p_expand);
        let (b_11_5: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e5, p_expand);
        let (d16: Uint384,_) = uint384_lib.add(b_5_11, b_6_10);
        let (d16: Uint384,_) = uint384_lib.add(d16, b_7_9);
        let (d16: Uint384,_) = uint384_lib.add(d16, b_8_8);
        let (d16: Uint384,_) = uint384_lib.add(d16, b_9_7);
        let (d16: Uint384,_) = uint384_lib.add(d16, b_10_6);
        let (d16: Uint384,_) = uint384_lib.add(d16, b_11_5);
	let (_,d16: Uint384) = uint384_lib.unsigned_div_rem_expanded(d16, p_expand);

        // d17
        let (b_6_11: Uint384) = field_arithmetic.mul_expanded(a.e6, b_e11, p_expand);
        let (b_7_10: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e10, p_expand);
        let (b_8_9: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e9, p_expand);
        let (b_9_8: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e8, p_expand);
        let (b_10_7: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e7, p_expand);
        let (b_11_6: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e6, p_expand);
        let (d17: Uint384,_) = uint384_lib.add(b_6_11, b_7_10);
        let (d17: Uint384,_) = uint384_lib.add(d17, b_8_9);
        let (d17: Uint384,_) = uint384_lib.add(d17, b_9_8);
        let (d17: Uint384,_) = uint384_lib.add(d17, b_10_7);
        let (d17: Uint384,_) = uint384_lib.add(d17, b_11_6);
	let (_,d17: Uint384) = uint384_lib.unsigned_div_rem_expanded(d17, p_expand);

        // d18
        let (b_7_11: Uint384) = field_arithmetic.mul_expanded(a.e7, b_e11, p_expand);
        let (b_8_10: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e10, p_expand);
        let (b_9_9: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e9, p_expand);
        let (b_10_8: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e8, p_expand);
        let (b_11_7: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e7, p_expand);
        let (d18: Uint384,_) = uint384_lib.add(b_7_11, b_8_10);
        let (d18: Uint384,_) = uint384_lib.add(d18, b_9_9);
        let (d18: Uint384,_) = uint384_lib.add(d18, b_10_8);
        let (d18: Uint384,_) = uint384_lib.add(d18, b_11_7);
	let (_,d18: Uint384) = uint384_lib.unsigned_div_rem_expanded(d18, p_expand);

        // d19
        let (b_8_11: Uint384) = field_arithmetic.mul_expanded(a.e8, b_e11, p_expand);
        let (b_9_10: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e10, p_expand);
        let (b_10_9: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e9, p_expand);
        let (b_11_8: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e8, p_expand);
        let (d19: Uint384,_) = uint384_lib.add(b_8_11, b_9_10);
        let (d19: Uint384,_) = uint384_lib.add(d19, b_10_9);
        let (d19: Uint384,_) = uint384_lib.add(d19, b_11_8);
	let (_,d19: Uint384) = uint384_lib.unsigned_div_rem_expanded(d19, p_expand);

        // d20
        let (b_9_11: Uint384) = field_arithmetic.mul_expanded(a.e9, b_e11, p_expand);
        let (b_10_10: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e10, p_expand);
        let (b_11_9: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e9, p_expand);
        let (d20: Uint384,_) = uint384_lib.add(b_9_11, b_10_10);
        let (d20: Uint384,_) = uint384_lib.add(d20, b_11_9);
	let (_,d20: Uint384) = uint384_lib.unsigned_div_rem_expanded(d20, p_expand);

        // d21
        let (b_10_11: Uint384) = field_arithmetic.mul_expanded(a.e10, b_e11, p_expand);
        let (b_11_10: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e10, p_expand);
        let (d21: Uint384,_) = uint384_lib.add(b_10_11, b_11_10);
	let (_,d21: Uint384) = uint384_lib.unsigned_div_rem_expanded(d21, p_expand);

        // d22
        let (d22: Uint384) = field_arithmetic.mul_expanded(a.e11, b_e11, p_expand);

        // Reducing the results modulo the irreducible polynomial
        // Note that the order in which _aux_polynomial_reduction is called is important here
        let (d10: Uint384, d16: Uint384) = _aux_polynomial_reduction(d22, d10, d16);
        let (d9: Uint384, d15: Uint384) = _aux_polynomial_reduction(d21, d9, d15);
        let (d8: Uint384, d14: Uint384) = _aux_polynomial_reduction(d20, d8, d14);
        let (d7: Uint384, d13: Uint384) = _aux_polynomial_reduction(d19, d7, d13);
        let (d6: Uint384, d12: Uint384) = _aux_polynomial_reduction(d18, d6, d12);
        let (d5: Uint384, d11: Uint384) = _aux_polynomial_reduction(d17, d5, d11);
        let (d4: Uint384, d10: Uint384) = _aux_polynomial_reduction(d16, d4, d10);
        let (d3: Uint384, d9: Uint384) = _aux_polynomial_reduction(d15, d3, d9);
        let (d2: Uint384, d8: Uint384) = _aux_polynomial_reduction(d14, d2, d8);
        let (d1: Uint384, d7: Uint384) = _aux_polynomial_reduction(d13, d1, d7);
        let (d0: Uint384, d6: Uint384) = _aux_polynomial_reduction(d12, d0, d6);

        return (FQ12(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11),);
    }

    // Toom-Cook 12
    // st=70836, mh=3060, rc=6685
    func mul_TC_12{range_check_ptr}(a: FQ12, b: FQ12) -> (product: FQ12) {
        alloc_locals;
	local d0: Uint384;
	local d1: Uint384;
	local d2: Uint384;
	local d3: Uint384;
	local d4: Uint384;
	local d5: Uint384;
	local d6: Uint384;
	local d7: Uint384;
	local d8: Uint384;
	local d9: Uint384;
	local d10: Uint384;
	local d11: Uint384;
	local d12: Uint384;
	local d13: Uint384;
	local d14: Uint384;
	local d15: Uint384;
	local d16: Uint384;
	local d17: Uint384;
	local d18: Uint384;
	local d19: Uint384;
	local d20: Uint384;
	local d21: Uint384;
	local d22: Uint384;
        let (p_expand:Uint384_expand) = get_modulus_expand();
	%{
            p = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
            
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def split(num: int, num_bits_shift: int = 128, length: int = 3):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift
                return tuple(a)

            def pack_FQ12(z):
                limbs = (z.e0, z.e1, z.e2, z.e3, z.e4, z.e5, z.e6, z.e7, z.e8, z.e9, z.e10, z.e11)
                ans = [pack(limb) for limb in limbs]
                return tuple(ans)

            #quadratic, but this is python
            def mult_poly12(a,b):
                return tuple([sum(a[j]*b[i-j] for j in range(max(0,i - 11),min(i + 1,12))) % p for i in range(23)])

            def split2(v, num: int):
                n=split(num)
                v.d0=n[0]
                v.d1=n[1]
                v.d2=n[2]

            a = pack_FQ12(ids.a)
            b = pack_FQ12(ids.b)
            d = mult_poly12(a,b)
            
            split2(ids.d0,d[0])
            split2(ids.d1,d[1])
            split2(ids.d2,d[2])
            split2(ids.d3,d[3])
            split2(ids.d4,d[4])
            split2(ids.d5,d[5])
            split2(ids.d6,d[6])
            split2(ids.d7,d[7])
            split2(ids.d8,d[8])
            split2(ids.d9,d[9])
            split2(ids.d10,d[10])
            split2(ids.d11,d[11])
            split2(ids.d12,d[12])
            split2(ids.d13,d[13])
            split2(ids.d14,d[14])
            split2(ids.d15,d[15])
            split2(ids.d16,d[16])
            split2(ids.d17,d[17])
            split2(ids.d18,d[18])
            split2(ids.d19,d[19])
            split2(ids.d20,d[20])
            split2(ids.d21,d[21])
            split2(ids.d22,d[22])
	%}
        fq_lib.check(d0);
        fq_lib.check(d1);
        fq_lib.check(d2);
        fq_lib.check(d3);
        fq_lib.check(d4);
        fq_lib.check(d5);
        fq_lib.check(d6);
        fq_lib.check(d7);
        fq_lib.check(d8);
        fq_lib.check(d9);
        fq_lib.check(d10);
        fq_lib.check(d11);
        fq_lib.check(d12);
        fq_lib.check(d13);
        fq_lib.check(d14);
        fq_lib.check(d15);
        fq_lib.check(d16);
        fq_lib.check(d17);
        fq_lib.check(d18);
        fq_lib.check(d19);
        fq_lib.check(d20);
        fq_lib.check(d21);
        fq_lib.check(d22);

	let av01 = a.e0;
	let av10 = a.e11;
	let (av11) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,1,
					     a.e2,1,
					     a.e3,1,
					     a.e4,1,
					     a.e5,1,
					     a.e6,1,
					     a.e7,1,
					     a.e8,1,
					     a.e9,1,
					     a.e10,1,
					     a.e11,1,
					     p_expand);
	let (av21) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,2,
					     a.e2,2**2,
					     a.e3,2**3,
					     a.e4,2**4,
					     a.e5,2**5,
					     a.e6,2**6,
					     a.e7,2**7,
					     a.e8,2**8,
					     a.e9,2**9,
					     a.e10,2**10,
					     a.e11,2**11,
					     p_expand);
	let (av12) = dot_by_uint64_vec12_mod(a.e0,2**11,
					     a.e1,2**10,
					     a.e2,2**9,
					     a.e3,2**8,
					     a.e4,2**7,
					     a.e5,2**6,
					     a.e6,2**5,
					     a.e7,2**4,
					     a.e8,2**3,
					     a.e9,2**2,
					     a.e10,2,
					     a.e11,1,
					     p_expand);
	let (av31) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,3,
					     a.e2,3**2,
					     a.e3,3**3,
					     a.e4,3**4,
					     a.e5,3**5,
					     a.e6,3**6,
					     a.e7,3**7,
					     a.e8,3**8,
					     a.e9,3**9,
					     a.e10,3**10,
					     a.e11,3**11,
					     p_expand);
	let (av13) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,3**10,
					     a.e2,3**9,
					     a.e3,3**8,
					     a.e4,3**7,
					     a.e5,3**6,
					     a.e6,3**5,
					     a.e7,3**4,
					     a.e8,3**3,
					     a.e9,3**2,
					     a.e10,3,
					     a.e11,1,
					     p_expand);
	let (av32) = dot_by_uint64_vec12_mod(a.e0,2**11,
					     a.e1,3*2**10,
					     a.e2,3**2*2**9,
					     a.e3,3**3*2**8,
					     a.e4,3**4*2**7,
					     a.e5,3**5*2**6,
					     a.e6,3**6*2**5,
					     a.e7,3**7*2**4,
					     a.e8,3**8*2**3,
					     a.e9,3**9*2**2,
					     a.e10,3**10*2,
					     a.e11,3**11,
					     p_expand);
	let (av23) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,2*3**10,
					     a.e2,2**2*3**9,
					     a.e3,2**3*3**8,
					     a.e4,2**4*3**7,
					     a.e5,2**5*3**6,
					     a.e6,2**6*3**5,
					     a.e7,2**7*3**4,
					     a.e8,2**8*3**3,
					     a.e9,2**9*3**2,
					     a.e10,2**10*3,
					     a.e11,2**11,
					     p_expand);
	let (av41) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,4,
					     a.e2,4**2,
					     a.e3,4**3,
					     a.e4,4**4,
					     a.e5,4**5,
					     a.e6,4**6,
					     a.e7,4**7,
					     a.e8,4**8,
					     a.e9,4**9,
					     a.e10,4**10,
					     a.e11,4**11,
					     p_expand);
	let (av14) = dot_by_uint64_vec12_mod(a.e0,4**11,
					     a.e1,4**10,
					     a.e2,4**9,
					     a.e3,4**8,
					     a.e4,4**7,
					     a.e5,4**6,
					     a.e6,4**5,
					     a.e7,4**4,
					     a.e8,4**3,
					     a.e9,4**2,
					     a.e10,4,
					     a.e11,1,
					     p_expand);
	let (av43) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,4*3**10,
					     a.e2,4**2*3**9,
					     a.e3,4**3*3**8,
					     a.e4,4**4*3**7,
					     a.e5,4**5*3**6,
					     a.e6,4**6*3**5,
					     a.e7,4**7*3**4,
					     a.e8,4**8*3**3,
					     a.e9,4**9*3**2,
					     a.e10,4**10*3,
					     a.e11,4**11,
					     p_expand);
	let (av34) = dot_by_uint64_vec12_mod(a.e0,4**11,
					     a.e1,3*4**10,
					     a.e2,3**2*4**9,
					     a.e3,3**3*4**8,
					     a.e4,3**4*4**7,
					     a.e5,3**5*4**6,
					     a.e6,3**6*4**5,
					     a.e7,3**7*4**4,
					     a.e8,3**8*4**3,
					     a.e9,3**9*4**2,
					     a.e10,3**10*4,
					     a.e11,3**11,
					     p_expand);
	let (av51) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,5,
					     a.e2,5**2,
					     a.e3,5**3,
					     a.e4,5**4,
					     a.e5,5**5,
					     a.e6,5**6,
					     a.e7,5**7,
					     a.e8,5**8,
					     a.e9,5**9,
					     a.e10,5**10,
					     a.e11,5**11,
					     p_expand);
	let (av15) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,5**10,
					     a.e2,5**9,
					     a.e3,5**8,
					     a.e4,5**7,
					     a.e5,5**6,
					     a.e6,5**5,
					     a.e7,5**4,
					     a.e8,5**3,
					     a.e9,5**2,
					     a.e10,5,
					     a.e11,1,
					     p_expand);
	let (av52) = dot_by_uint64_vec12_mod(a.e0,2**11,
					     a.e1,5*2**10,
					     a.e2,5**2*2**9,
					     a.e3,5**3*2**8,
					     a.e4,5**4*2**7,
					     a.e5,5**5*2**6,
					     a.e6,5**6*2**5,
					     a.e7,5**7*2**4,
					     a.e8,5**8*2**3,
					     a.e9,5**9*2**2,
					     a.e10,5**10*2,
					     a.e11,5**11,
					     p_expand);
	let (av25) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,2*5**10,
					     a.e2,2**2*5**9,
					     a.e3,2**3*5**8,
					     a.e4,2**4*5**7,
					     a.e5,2**5*5**6,
					     a.e6,2**6*5**5,
					     a.e7,2**7*5**4,
					     a.e8,2**8*5**3,
					     a.e9,2**9*5**2,
					     a.e10,2**10*5,
					     a.e11,2**11,
					     p_expand);
	let (av53) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,5*3**10,
					     a.e2,5**2*3**9,
					     a.e3,5**3*3**8,
					     a.e4,5**4*3**7,
					     a.e5,5**5*3**6,
					     a.e6,5**6*3**5,
					     a.e7,5**7*3**4,
					     a.e8,5**8*3**3,
					     a.e9,5**9*3**2,
					     a.e10,5**10*3,
					     a.e11,5**11,
					     p_expand);
	let (av35) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,3*5**10,
					     a.e2,3**2*5**9,
					     a.e3,3**3*5**8,
					     a.e4,3**4*5**7,
					     a.e5,3**5*5**6,
					     a.e6,3**6*5**5,
					     a.e7,3**7*5**4,
					     a.e8,3**8*5**3,
					     a.e9,3**9*5**2,
					     a.e10,3**10*5,
					     a.e11,3**11,
					     p_expand);
	let (av54) = dot_by_uint64_vec12_mod(a.e0,4**11,
					     a.e1,5*4**10,
					     a.e2,5**2*4**9,
					     a.e3,5**3*4**8,
					     a.e4,5**4*4**7,
					     a.e5,5**5*4**6,
					     a.e6,5**6*4**5,
					     a.e7,5**7*4**4,
					     a.e8,5**8*4**3,
					     a.e9,5**9*4**2,
					     a.e10,5**10*4,
					     a.e11,5**11,
					     p_expand);
	let (av45) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,4*5**10,
					     a.e2,4**2*5**9,
					     a.e3,4**3*5**8,
					     a.e4,4**4*5**7,
					     a.e5,4**5*5**6,
					     a.e6,4**6*5**5,
					     a.e7,4**7*5**4,
					     a.e8,4**8*5**3,
					     a.e9,4**9*5**2,
					     a.e10,4**10*5,
					     a.e11,4**11,
					     p_expand);
	let (av61) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,6,
					     a.e2,6**2,
					     a.e3,6**3,
					     a.e4,6**4,
					     a.e5,6**5,
					     a.e6,6**6,
					     a.e7,6**7,
					     a.e8,6**8,
					     a.e9,6**9,
					     a.e10,6**10,
					     a.e11,6**11,
					     p_expand);
	let (av16) = dot_by_uint64_vec12_mod(a.e0,6**11,
					     a.e1,6**10,
					     a.e2,6**9,
					     a.e3,6**8,
					     a.e4,6**7,
					     a.e5,6**6,
					     a.e6,6**5,
					     a.e7,6**4,
					     a.e8,6**3,
					     a.e9,6**2,
					     a.e10,6,
					     a.e11,1,
					     p_expand);

	let bv01 = b.e0;
	let bv10 = b.e11;
	let (bv11) = dot_by_uint64_vec12_mod(b.e0,1,
					     b.e1,1,
					     b.e2,1,
					     b.e3,1,
					     b.e4,1,
					     b.e5,1,
					     b.e6,1,
					     b.e7,1,
					     b.e8,1,
					     b.e9,1,
					     b.e10,1,
					     b.e11,1,
					     p_expand);
	let (bv21) = dot_by_uint64_vec12_mod(b.e0,1,
					     b.e1,2,
					     b.e2,2**2,
					     b.e3,2**3,
					     b.e4,2**4,
					     b.e5,2**5,
					     b.e6,2**6,
					     b.e7,2**7,
					     b.e8,2**8,
					     b.e9,2**9,
					     b.e10,2**10,
					     b.e11,2**11,
					     p_expand);
	let (bv12) = dot_by_uint64_vec12_mod(b.e0,2**11,
					     b.e1,2**10,
					     b.e2,2**9,
					     b.e3,2**8,
					     b.e4,2**7,
					     b.e5,2**6,
					     b.e6,2**5,
					     b.e7,2**4,
					     b.e8,2**3,
					     b.e9,2**2,
					     b.e10,2,
					     b.e11,1,
					     p_expand);
	let (bv31) = dot_by_uint64_vec12_mod(b.e0,1,
					     b.e1,3,
					     b.e2,3**2,
					     b.e3,3**3,
					     b.e4,3**4,
					     b.e5,3**5,
					     b.e6,3**6,
					     b.e7,3**7,
					     b.e8,3**8,
					     b.e9,3**9,
					     b.e10,3**10,
					     b.e11,3**11,
					     p_expand);
	let (bv13) = dot_by_uint64_vec12_mod(b.e0,3**11,
					     b.e1,3**10,
					     b.e2,3**9,
					     b.e3,3**8,
					     b.e4,3**7,
					     b.e5,3**6,
					     b.e6,3**5,
					     b.e7,3**4,
					     b.e8,3**3,
					     b.e9,3**2,
					     b.e10,3,
					     b.e11,1,
					     p_expand);
	let (bv32) = dot_by_uint64_vec12_mod(b.e0,2**11,
					     b.e1,3*2**10,
					     b.e2,3**2*2**9,
					     b.e3,3**3*2**8,
					     b.e4,3**4*2**7,
					     b.e5,3**5*2**6,
					     b.e6,3**6*2**5,
					     b.e7,3**7*2**4,
					     b.e8,3**8*2**3,
					     b.e9,3**9*2**2,
					     b.e10,3**10*2,
					     b.e11,3**11,
					     p_expand);
	let (bv23) = dot_by_uint64_vec12_mod(b.e0,3**11,
					     b.e1,2*3**10,
					     b.e2,2**2*3**9,
					     b.e3,2**3*3**8,
					     b.e4,2**4*3**7,
					     b.e5,2**5*3**6,
					     b.e6,2**6*3**5,
					     b.e7,2**7*3**4,
					     b.e8,2**8*3**3,
					     b.e9,2**9*3**2,
					     b.e10,2**10*3,
					     b.e11,2**11,
					     p_expand);
	let (bv41) = dot_by_uint64_vec12_mod(b.e0,1,
					     b.e1,4,
					     b.e2,4**2,
					     b.e3,4**3,
					     b.e4,4**4,
					     b.e5,4**5,
					     b.e6,4**6,
					     b.e7,4**7,
					     b.e8,4**8,
					     b.e9,4**9,
					     b.e10,4**10,
					     b.e11,4**11,
					     p_expand);
	let (bv14) = dot_by_uint64_vec12_mod(b.e0,4**11,
					     b.e1,4**10,
					     b.e2,4**9,
					     b.e3,4**8,
					     b.e4,4**7,
					     b.e5,4**6,
					     b.e6,4**5,
					     b.e7,4**4,
					     b.e8,4**3,
					     b.e9,4**2,
					     b.e10,4,
					     b.e11,1,
					     p_expand);
	let (bv43) = dot_by_uint64_vec12_mod(b.e0,3**11,
					     b.e1,4*3**10,
					     b.e2,4**2*3**9,
					     b.e3,4**3*3**8,
					     b.e4,4**4*3**7,
					     b.e5,4**5*3**6,
					     b.e6,4**6*3**5,
					     b.e7,4**7*3**4,
					     b.e8,4**8*3**3,
					     b.e9,4**9*3**2,
					     b.e10,4**10*3,
					     b.e11,4**11,
					     p_expand);
	let (bv34) = dot_by_uint64_vec12_mod(b.e0,4**11,
					     b.e1,3*4**10,
					     b.e2,3**2*4**9,
					     b.e3,3**3*4**8,
					     b.e4,3**4*4**7,
					     b.e5,3**5*4**6,
					     b.e6,3**6*4**5,
					     b.e7,3**7*4**4,
					     b.e8,3**8*4**3,
					     b.e9,3**9*4**2,
					     b.e10,3**10*4,
					     b.e11,3**11,
					     p_expand);
	let (bv51) = dot_by_uint64_vec12_mod(b.e0,1,
					     b.e1,5,
					     b.e2,5**2,
					     b.e3,5**3,
					     b.e4,5**4,
					     b.e5,5**5,
					     b.e6,5**6,
					     b.e7,5**7,
					     b.e8,5**8,
					     b.e9,5**9,
					     b.e10,5**10,
					     b.e11,5**11,
					     p_expand);
	let (bv15) = dot_by_uint64_vec12_mod(b.e0,5**11,
					     b.e1,5**10,
					     b.e2,5**9,
					     b.e3,5**8,
					     b.e4,5**7,
					     b.e5,5**6,
					     b.e6,5**5,
					     b.e7,5**4,
					     b.e8,5**3,
					     b.e9,5**2,
					     b.e10,5,
					     b.e11,1,
					     p_expand);
	let (bv52) = dot_by_uint64_vec12_mod(b.e0,2**11,
					     b.e1,5*2**10,
					     b.e2,5**2*2**9,
					     b.e3,5**3*2**8,
					     b.e4,5**4*2**7,
					     b.e5,5**5*2**6,
					     b.e6,5**6*2**5,
					     b.e7,5**7*2**4,
					     b.e8,5**8*2**3,
					     b.e9,5**9*2**2,
					     b.e10,5**10*2,
					     b.e11,5**11,
					     p_expand);
	let (bv25) = dot_by_uint64_vec12_mod(b.e0,5**11,
					     b.e1,2*5**10,
					     b.e2,2**2*5**9,
					     b.e3,2**3*5**8,
					     b.e4,2**4*5**7,
					     b.e5,2**5*5**6,
					     b.e6,2**6*5**5,
					     b.e7,2**7*5**4,
					     b.e8,2**8*5**3,
					     b.e9,2**9*5**2,
					     b.e10,2**10*5,
					     b.e11,2**11,
					     p_expand);
	let (bv53) = dot_by_uint64_vec12_mod(b.e0,3**11,
					     b.e1,5*3**10,
					     b.e2,5**2*3**9,
					     b.e3,5**3*3**8,
					     b.e4,5**4*3**7,
					     b.e5,5**5*3**6,
					     b.e6,5**6*3**5,
					     b.e7,5**7*3**4,
					     b.e8,5**8*3**3,
					     b.e9,5**9*3**2,
					     b.e10,5**10*3,
					     b.e11,5**11,
					     p_expand);
	let (bv35) = dot_by_uint64_vec12_mod(b.e0,5**11,
					     b.e1,3*5**10,
					     b.e2,3**2*5**9,
					     b.e3,3**3*5**8,
					     b.e4,3**4*5**7,
					     b.e5,3**5*5**6,
					     b.e6,3**6*5**5,
					     b.e7,3**7*5**4,
					     b.e8,3**8*5**3,
					     b.e9,3**9*5**2,
					     b.e10,3**10*5,
					     b.e11,3**11,
					     p_expand);
	let (bv54) = dot_by_uint64_vec12_mod(b.e0,4**11,
					     b.e1,5*4**10,
					     b.e2,5**2*4**9,
					     b.e3,5**3*4**8,
					     b.e4,5**4*4**7,
					     b.e5,5**5*4**6,
					     b.e6,5**6*4**5,
					     b.e7,5**7*4**4,
					     b.e8,5**8*4**3,
					     b.e9,5**9*4**2,
					     b.e10,5**10*4,
					     b.e11,5**11,
					     p_expand);
	let (bv45) = dot_by_uint64_vec12_mod(b.e0,5**11,
					     b.e1,4*5**10,
					     b.e2,4**2*5**9,
					     b.e3,4**3*5**8,
					     b.e4,4**4*5**7,
					     b.e5,4**5*5**6,
					     b.e6,4**6*5**5,
					     b.e7,4**7*5**4,
					     b.e8,4**8*5**3,
					     b.e9,4**9*5**2,
					     b.e10,4**10*5,
					     b.e11,4**11,
					     p_expand);
	let (bv61) = dot_by_uint64_vec12_mod(b.e0,1,
					     b.e1,6,
					     b.e2,6**2,
					     b.e3,6**3,
					     b.e4,6**4,
					     b.e5,6**5,
					     b.e6,6**6,
					     b.e7,6**7,
					     b.e8,6**8,
					     b.e9,6**9,
					     b.e10,6**10,
					     b.e11,6**11,
					     p_expand);
	let (bv16) = dot_by_uint64_vec12_mod(b.e0,6**11,
					     b.e1,6**10,
					     b.e2,6**9,
					     b.e3,6**8,
					     b.e4,6**7,
					     b.e5,6**6,
					     b.e6,6**5,
					     b.e7,6**4,
					     b.e8,6**3,
					     b.e9,6**2,
					     b.e10,6,
					     b.e11,1,
					     p_expand);
        
	let dv01 = d0;
	let dv10 = d22;
	let (dv11) = dot_by_uint64_vec23_mod(d0,1,
					     d1,1,
					     d2,1,
					     d3,1,
					     d4,1,
					     d5,1,
					     d6,1,
					     d7,1,
					     d8,1,
					     d9,1,
					     d10,1,
					     d11,1,
					     d12,1,
					     d13,1,
					     d14,1,
					     d15,1,
					     d16,1,
					     d17,1,
					     d18,1,
					     d19,1,
					     d20,1,
					     d21,1,
					     d22,1,
					     p_expand);
	let (dv21) = dot_by_uint64_vec23_mod(d0,1,
					     d1,2,
					     d2,2**2,
					     d3,2**3,
					     d4,2**4,
					     d5,2**5,
					     d6,2**6,
					     d7,2**7,
					     d8,2**8,
					     d9,2**9,
					     d10,2**10,
					     d11,2**11,
					     d12,2**12,
					     d13,2**13,
					     d14,2**14,
					     d15,2**15,
					     d16,2**16,
					     d17,2**17,
					     d18,2**18,
					     d19,2**19,
					     d20,2**20,
					     d21,2**21,
					     d22,2**22,
					     p_expand);
	let (dv12) = dot_by_uint64_vec23_mod(d0,2**22,
					     d1,2**21,
					     d2,2**20,
					     d3,2**19,
					     d4,2**18,
					     d5,2**17,
					     d6,2**16,
					     d7,2**15,
					     d8,2**14,
					     d9,2**13,
					     d10,2**12,
					     d11,2**11,
					     d12,2**10,
					     d13,2**9,
					     d14,2**8,
					     d15,2**7,
					     d16,2**6,
					     d17,2**5,
					     d18,2**4,
					     d19,2**3,
					     d20,2**2,
					     d21,2,
					     d22,1,
					     p_expand);
	let (dv31) = dot_by_uint64_vec23_mod(d0,1,
					     d1,3,
					     d2,3**2,
					     d3,3**3,
					     d4,3**4,
					     d5,3**5,
					     d6,3**6,
					     d7,3**7,
					     d8,3**8,
					     d9,3**9,
					     d10,3**10,
					     d11,3**11,
					     d12,3**12,
					     d13,3**13,
					     d14,3**14,
					     d15,3**15,
					     d16,3**16,
					     d17,3**17,
					     d18,3**18,
					     d19,3**19,
					     d20,3**20,
					     d21,3**21,
					     d22,3**22,
					     p_expand);
	let (dv13) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,3**21,
					     d2,3**20,
					     d3,3**19,
					     d4,3**18,
					     d5,3**17,
					     d6,3**16,
					     d7,3**15,
					     d8,3**14,
					     d9,3**13,
					     d10,3**12,
					     d11,3**11,
					     d12,3**10,
					     d13,3**9,
					     d14,3**8,
					     d15,3**7,
					     d16,3**6,
					     d17,3**5,
					     d18,3**4,
					     d19,3**3,
					     d20,3**2,
					     d21,3,
					     d22,1,
					     p_expand);
	let (dv32) = dot_by_uint64_vec23_mod(d0,2**22,
					     d1,3*2**21,
					     d2,3**2*2**20,
					     d3,3**3*2**19,
					     d4,3**4*2**18,
					     d5,3**5*2**17,
					     d6,3**6*2**16,
					     d7,3**7*2**15,
					     d8,3**8*2**14,
					     d9,3**9*2**13,
					     d10,3**10*2**12,
					     d11,3**11*2**11,
					     d12,3**12*2**10,
					     d13,3**13*2**9,
					     d14,3**14*2**8,
					     d15,3**15*2**7,
					     d16,3**16*2**6,
					     d17,3**17*2**5,
					     d18,3**18*2**4,
					     d19,3**19*2**3,
					     d20,3**20*2**2,
					     d21,3**21*2,
					     d22,3**22,
					     p_expand);
	let (dv23) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,2*3**21,
					     d2,2**2*3**20,
					     d3,2**3*3**19,
					     d4,2**4*3**18,
					     d5,2**5*3**17,
					     d6,2**6*3**16,
					     d7,2**7*3**15,
					     d8,2**8*3**14,
					     d9,2**9*3**13,
					     d10,2**10*3**12,
					     d11,2**11*3**11,
					     d12,2**12*3**10,
					     d13,2**13*3**9,
					     d14,2**14*3**8,
					     d15,2**15*3**7,
					     d16,2**16*3**6,
					     d17,2**17*3**5,
					     d18,2**18*3**4,
					     d19,2**19*3**3,
					     d20,2**20*3**2,
					     d21,2**21*3,
					     d22,2**22,
					     p_expand);
	let (dv41) = dot_by_uint64_vec23_mod(d0,1,
					     d1,4,
					     d2,4**2,
					     d3,4**3,
					     d4,4**4,
					     d5,4**5,
					     d6,4**6,
					     d7,4**7,
					     d8,4**8,
					     d9,4**9,
					     d10,4**10,
					     d11,4**11,
					     d12,4**12,
					     d13,4**13,
					     d14,4**14,
					     d15,4**15,
					     d16,4**16,
					     d17,4**17,
					     d18,4**18,
					     d19,4**19,
					     d20,4**20,
					     d21,4**21,
					     d22,4**22,
					     p_expand);
	let (dv14) = dot_by_uint64_vec23_mod(d0,4**22,
					     d1,4**21,
					     d2,4**20,
					     d3,4**19,
					     d4,4**18,
					     d5,4**17,
					     d6,4**16,
					     d7,4**15,
					     d8,4**14,
					     d9,4**13,
					     d10,4**12,
					     d11,4**11,
					     d12,4**10,
					     d13,4**9,
					     d14,4**8,
					     d15,4**7,
					     d16,4**6,
					     d17,4**5,
					     d18,4**4,
					     d19,4**3,
					     d20,4**2,
					     d21,4,
					     d22,1,
					     p_expand);
	let (dv43) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,4*3**21,
					     d2,4**2*3**20,
					     d3,4**3*3**19,
					     d4,4**4*3**18,
					     d5,4**5*3**17,
					     d6,4**6*3**16,
					     d7,4**7*3**15,
					     d8,4**8*3**14,
					     d9,4**9*3**13,
					     d10,4**10*3**12,
					     d11,4**11*3**11,
					     d12,4**12*3**10,
					     d13,4**13*3**9,
					     d14,4**14*3**8,
					     d15,4**15*3**7,
					     d16,4**16*3**6,
					     d17,4**17*3**5,
					     d18,4**18*3**4,
					     d19,4**19*3**3,
					     d20,4**20*3**2,
					     d21,4**21*3,
					     d22,4**22,
					     p_expand);
	let (dv34) = dot_by_uint64_vec23_mod(d0,4**22,
					     d1,3*4**21,
					     d2,3**2*4**20,
					     d3,3**3*4**19,
					     d4,3**4*4**18,
					     d5,3**5*4**17,
					     d6,3**6*4**16,
					     d7,3**7*4**15,
					     d8,3**8*4**14,
					     d9,3**9*4**13,
					     d10,3**10*4**12,
					     d11,3**11*4**11,
					     d12,3**12*4**10,
					     d13,3**13*4**9,
					     d14,3**14*4**8,
					     d15,3**15*4**7,
					     d16,3**16*4**6,
					     d17,3**17*4**5,
					     d18,3**18*4**4,
					     d19,3**19*4**3,
					     d20,3**20*4**2,
					     d21,3**21*4,
					     d22,3**22,
					     p_expand);
	let (dv51) = dot_by_uint64_vec23_mod(d0,1,
					     d1,5,
					     d2,5**2,
					     d3,5**3,
					     d4,5**4,
					     d5,5**5,
					     d6,5**6,
					     d7,5**7,
					     d8,5**8,
					     d9,5**9,
					     d10,5**10,
					     d11,5**11,
					     d12,5**12,
					     d13,5**13,
					     d14,5**14,
					     d15,5**15,
					     d16,5**16,
					     d17,5**17,
					     d18,5**18,
					     d19,5**19,
					     d20,5**20,
					     d21,5**21,
					     d22,5**22,
					     p_expand);
	let (dv15) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,5**21,
					     d2,5**20,
					     d3,5**19,
					     d4,5**18,
					     d5,5**17,
					     d6,5**16,
					     d7,5**15,
					     d8,5**14,
					     d9,5**13,
					     d10,5**12,
					     d11,5**11,
					     d12,5**10,
					     d13,5**9,
					     d14,5**8,
					     d15,5**7,
					     d16,5**6,
					     d17,5**5,
					     d18,5**4,
					     d19,5**3,
					     d20,5**2,
					     d21,5,
					     d22,1,
					     p_expand);
	let (dv52) = dot_by_uint64_vec23_mod(d0,2**22,
					     d1,5*2**21,
					     d2,5**2*2**20,
					     d3,5**3*2**19,
					     d4,5**4*2**18,
					     d5,5**5*2**17,
					     d6,5**6*2**16,
					     d7,5**7*2**15,
					     d8,5**8*2**14,
					     d9,5**9*2**13,
					     d10,5**10*2**12,
					     d11,5**11*2**11,
					     d12,5**12*2**10,
					     d13,5**13*2**9,
					     d14,5**14*2**8,
					     d15,5**15*2**7,
					     d16,5**16*2**6,
					     d17,5**17*2**5,
					     d18,5**18*2**4,
					     d19,5**19*2**3,
					     d20,5**20*2**2,
					     d21,5**21*2,
					     d22,5**22,
					     p_expand);
	let (dv25) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,2*5**21,
					     d2,2**2*5**20,
					     d3,2**3*5**19,
					     d4,2**4*5**18,
					     d5,2**5*5**17,
					     d6,2**6*5**16,
					     d7,2**7*5**15,
					     d8,2**8*5**14,
					     d9,2**9*5**13,
					     d10,2**10*5**12,
					     d11,2**11*5**11,
					     d12,2**12*5**10,
					     d13,2**13*5**9,
					     d14,2**14*5**8,
					     d15,2**15*5**7,
					     d16,2**16*5**6,
					     d17,2**17*5**5,
					     d18,2**18*5**4,
					     d19,2**19*5**3,
					     d20,2**20*5**2,
					     d21,2**21*5,
					     d22,2**22,
					     p_expand);
	let (dv53) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,5*3**21,
					     d2,5**2*3**20,
					     d3,5**3*3**19,
					     d4,5**4*3**18,
					     d5,5**5*3**17,
					     d6,5**6*3**16,
					     d7,5**7*3**15,
					     d8,5**8*3**14,
					     d9,5**9*3**13,
					     d10,5**10*3**12,
					     d11,5**11*3**11,
					     d12,5**12*3**10,
					     d13,5**13*3**9,
					     d14,5**14*3**8,
					     d15,5**15*3**7,
					     d16,5**16*3**6,
					     d17,5**17*3**5,
					     d18,5**18*3**4,
					     d19,5**19*3**3,
					     d20,5**20*3**2,
					     d21,5**21*3,
					     d22,5**22,
					     p_expand);
	let (dv35) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,3*5**21,
					     d2,3**2*5**20,
					     d3,3**3*5**19,
					     d4,3**4*5**18,
					     d5,3**5*5**17,
					     d6,3**6*5**16,
					     d7,3**7*5**15,
					     d8,3**8*5**14,
					     d9,3**9*5**13,
					     d10,3**10*5**12,
					     d11,3**11*5**11,
					     d12,3**12*5**10,
					     d13,3**13*5**9,
					     d14,3**14*5**8,
					     d15,3**15*5**7,
					     d16,3**16*5**6,
					     d17,3**17*5**5,
					     d18,3**18*5**4,
					     d19,3**19*5**3,
					     d20,3**20*5**2,
					     d21,3**21*5,
					     d22,3**22,
					     p_expand);
	let (dv54) = dot_by_uint64_vec23_mod(d0,4**22,
					     d1,5*4**21,
					     d2,5**2*4**20,
					     d3,5**3*4**19,
					     d4,5**4*4**18,
					     d5,5**5*4**17,
					     d6,5**6*4**16,
					     d7,5**7*4**15,
					     d8,5**8*4**14,
					     d9,5**9*4**13,
					     d10,5**10*4**12,
					     d11,5**11*4**11,
					     d12,5**12*4**10,
					     d13,5**13*4**9,
					     d14,5**14*4**8,
					     d15,5**15*4**7,
					     d16,5**16*4**6,
					     d17,5**17*4**5,
					     d18,5**18*4**4,
					     d19,5**19*4**3,
					     d20,5**20*4**2,
					     d21,5**21*4,
					     d22,5**22,
					     p_expand);
	let (dv45) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,4*5**21,
					     d2,4**2*5**20,
					     d3,4**3*5**19,
					     d4,4**4*5**18,
					     d5,4**5*5**17,
					     d6,4**6*5**16,
					     d7,4**7*5**15,
					     d8,4**8*5**14,
					     d9,4**9*5**13,
					     d10,4**10*5**12,
					     d11,4**11*5**11,
					     d12,4**12*5**10,
					     d13,4**13*5**9,
					     d14,4**14*5**8,
					     d15,4**15*5**7,
					     d16,4**16*5**6,
					     d17,4**17*5**5,
					     d18,4**18*5**4,
					     d19,4**19*5**3,
					     d20,4**20*5**2,
					     d21,4**21*5,
					     d22,4**22,
					     p_expand);
	let (dv61) = dot_by_uint64_vec23_mod(d0,1,
					     d1,6,
					     d2,6**2,
					     d3,6**3,
					     d4,6**4,
					     d5,6**5,
					     d6,6**6,
					     d7,6**7,
					     d8,6**8,
					     d9,6**9,
					     d10,6**10,
					     d11,6**11,
					     d12,6**12,
					     d13,6**13,
					     d14,6**14,
					     d15,6**15,
					     d16,6**16,
					     d17,6**17,
					     d18,6**18,
					     d19,6**19,
					     d20,6**20,
					     d21,6**21,
					     d22,6**22,
					     p_expand);
	let (dv16) = dot_by_uint64_vec23_mod(d0,6**22,
					     d1,6**21,
					     d2,6**20,
					     d3,6**19,
					     d4,6**18,
					     d5,6**17,
					     d6,6**16,
					     d7,6**15,
					     d8,6**14,
					     d9,6**13,
					     d10,6**12,
					     d11,6**11,
					     d12,6**10,
					     d13,6**9,
					     d14,6**8,
					     d15,6**7,
					     d16,6**6,
					     d17,6**5,
					     d18,6**4,
					     d19,6**3,
					     d20,6**2,
					     d21,6,
					     d22,1,
					     p_expand);
        

        let (dv01b)=fq_lib.mul(av01,bv01);
        assert dv01 = dv01b;
        let (dv10b)=fq_lib.mul(av10,bv10);
        assert dv10 = dv10b;
        let (dv11b)=fq_lib.mul(av11,bv11);
        assert dv11 = dv11b;
        let (dv21b)=fq_lib.mul(av21,bv21);
        assert dv21 = dv21b;
        let (dv12b)=fq_lib.mul(av12,bv12);
        assert dv12 = dv12b;
        let (dv31b)=fq_lib.mul(av31,bv31);
        assert dv31 = dv31b;
        let (dv13b)=fq_lib.mul(av13,bv13);
        assert dv13 = dv13b;
        let (dv32b)=fq_lib.mul(av32,bv32);
        assert dv32 = dv32b;
        let (dv23b)=fq_lib.mul(av23,bv23);
        assert dv23 = dv23b;
        let (dv41b)=fq_lib.mul(av41,bv41);
        assert dv41 = dv41b;
        let (dv14b)=fq_lib.mul(av14,bv14);
        assert dv14 = dv14b;
        let (dv43b)=fq_lib.mul(av43,bv43);
        assert dv43 = dv43b;
        let (dv34b)=fq_lib.mul(av34,bv34);
        assert dv34 = dv34b;
        let (dv51b)=fq_lib.mul(av51,bv51);
        assert dv51 = dv51b;
        let (dv15b)=fq_lib.mul(av15,bv15);
        assert dv15 = dv15b;
        let (dv52b)=fq_lib.mul(av52,bv52);
        assert dv52 = dv52b;
        let (dv25b)=fq_lib.mul(av25,bv25);
        assert dv25 = dv25b;
        let (dv53b)=fq_lib.mul(av53,bv53);
        assert dv53 = dv53b;
        let (dv35b)=fq_lib.mul(av35,bv35);
        assert dv35 = dv35b;
        let (dv54b)=fq_lib.mul(av54,bv54);
        assert dv54 = dv54b;
        let (dv45b)=fq_lib.mul(av45,bv45);
        assert dv45 = dv45b;
        let (dv61b)=fq_lib.mul(av61,bv61);
        assert dv61 = dv61b;
        let (dv16b)=fq_lib.mul(av16,bv16);
        assert dv16 = dv16b;
	
        // Reducing the results modulo the irreducible polynomial
        // Note that the order in which _aux_polynomial_reduction is called is important here
        let (d10: Uint384, d16: Uint384) = _aux_polynomial_reduction(d22, d10, d16);
        let (d9: Uint384, d15: Uint384) = _aux_polynomial_reduction(d21, d9, d15);
        let (d8: Uint384, d14: Uint384) = _aux_polynomial_reduction(d20, d8, d14);
        let (d7: Uint384, d13: Uint384) = _aux_polynomial_reduction(d19, d7, d13);
        let (d6: Uint384, d12: Uint384) = _aux_polynomial_reduction(d18, d6, d12);
        let (d5: Uint384, d11: Uint384) = _aux_polynomial_reduction(d17, d5, d11);
        let (d4: Uint384, d10: Uint384) = _aux_polynomial_reduction(d16, d4, d10);
        let (d3: Uint384, d9: Uint384) = _aux_polynomial_reduction(d15, d3, d9);
        let (d2: Uint384, d8: Uint384) = _aux_polynomial_reduction(d14, d2, d8);
        let (d1: Uint384, d7: Uint384) = _aux_polynomial_reduction(d13, d1, d7);
        let (d0: Uint384, d6: Uint384) = _aux_polynomial_reduction(d12, d0, d6);

        return (FQ12(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11),);
    }

    // st=166155, mh=6180, rc=19728
    func square{range_check_ptr}(a: FQ12) -> (square: FQ12) {
        alloc_locals;
        let (p_expand:Uint384_expand) = get_modulus_expand();
        // d0
        let (d0: Uint384) = field_arithmetic.square(a.e0, p_expand);

        // d1
        let (b_0_1: Uint384) = field_arithmetic.mul(a.e0, a.e1, p_expand);
        let (b_1_0: Uint384) = field_arithmetic.mul(a.e1, a.e0, p_expand);
        let (d1: Uint384) = field_arithmetic.add(b_0_1, b_1_0, p_expand);

        // d2
        let (b_0_2: Uint384) = field_arithmetic.mul(a.e0, a.e2, p_expand);
        let (b_1_1: Uint384) = field_arithmetic.square(a.e1, p_expand);
        let (b_2_0: Uint384) = field_arithmetic.mul(a.e2, a.e0, p_expand);
        let (d2: Uint384) = field_arithmetic.add(b_0_2, b_1_1, p_expand);
        let (d2: Uint384) = field_arithmetic.add(d2, b_2_0, p_expand);

        // d3
        let (b_0_3: Uint384) = field_arithmetic.mul(a.e0, a.e3, p_expand);
        let (b_1_2: Uint384) = field_arithmetic.mul(a.e1, a.e2, p_expand);
        let (b_2_1: Uint384) = field_arithmetic.mul(a.e2, a.e1, p_expand);
        let (b_3_0: Uint384) = field_arithmetic.mul(a.e3, a.e0, p_expand);
        let (d3: Uint384) = field_arithmetic.add(b_0_3, b_1_2, p_expand);
        let (d3: Uint384) = field_arithmetic.add(d3, b_2_1, p_expand);
        let (d3: Uint384) = field_arithmetic.add(d3, b_3_0, p_expand);

        // d4
        let (b_0_4: Uint384) = field_arithmetic.mul(a.e0, a.e4, p_expand);
        let (b_1_3: Uint384) = field_arithmetic.mul(a.e1, a.e3, p_expand);
        let (b_2_2: Uint384) = field_arithmetic.square(a.e2, p_expand);
        let (b_3_1: Uint384) = field_arithmetic.mul(a.e3, a.e1, p_expand);
        let (b_4_0: Uint384) = field_arithmetic.mul(a.e4, a.e0, p_expand);
        let (d4: Uint384) = field_arithmetic.add(b_0_4, b_1_3, p_expand);
        let (d4: Uint384) = field_arithmetic.add(d4, b_2_2, p_expand);
        let (d4: Uint384) = field_arithmetic.add(d4, b_3_1, p_expand);
        let (d4: Uint384) = field_arithmetic.add(d4, b_4_0, p_expand);

        // d5
        let (b_0_5: Uint384) = field_arithmetic.mul(a.e0, a.e5, p_expand);
        let (b_1_4: Uint384) = field_arithmetic.mul(a.e1, a.e4, p_expand);
        let (b_2_3: Uint384) = field_arithmetic.mul(a.e2, a.e3, p_expand);
        let (b_3_2: Uint384) = field_arithmetic.mul(a.e3, a.e2, p_expand);
        let (b_4_1: Uint384) = field_arithmetic.mul(a.e4, a.e1, p_expand);
        let (b_5_0: Uint384) = field_arithmetic.mul(a.e5, a.e0, p_expand);
        let (d5: Uint384) = field_arithmetic.add(b_0_5, b_1_4, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_2_3, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_3_2, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_4_1, p_expand);
        let (d5: Uint384) = field_arithmetic.add(d5, b_5_0, p_expand);

        // d6
        let (b_0_6: Uint384) = field_arithmetic.mul(a.e0, a.e6, p_expand);
        let (b_1_5: Uint384) = field_arithmetic.mul(a.e1, a.e5, p_expand);
        let (b_2_4: Uint384) = field_arithmetic.mul(a.e2, a.e4, p_expand);
        let (b_3_3: Uint384) = field_arithmetic.square(a.e3, p_expand);
        let (b_4_2: Uint384) = field_arithmetic.mul(a.e4, a.e2, p_expand);
        let (b_5_1: Uint384) = field_arithmetic.mul(a.e5, a.e1, p_expand);
        let (b_6_0: Uint384) = field_arithmetic.mul(a.e6, a.e0, p_expand);
        let (d6: Uint384) = field_arithmetic.add(b_0_6, b_1_5, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_2_4, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_3_3, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_4_2, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_5_1, p_expand);
        let (d6: Uint384) = field_arithmetic.add(d6, b_6_0, p_expand);

        // d7
        let (b_0_7: Uint384) = field_arithmetic.mul(a.e0, a.e7, p_expand);
        let (b_1_6: Uint384) = field_arithmetic.mul(a.e1, a.e6, p_expand);
        let (b_2_5: Uint384) = field_arithmetic.mul(a.e2, a.e5, p_expand);
        let (b_3_4: Uint384) = field_arithmetic.mul(a.e3, a.e4, p_expand);
        let (b_4_3: Uint384) = field_arithmetic.mul(a.e4, a.e3, p_expand);
        let (b_5_2: Uint384) = field_arithmetic.mul(a.e5, a.e2, p_expand);
        let (b_6_1: Uint384) = field_arithmetic.mul(a.e6, a.e1, p_expand);
        let (b_7_0: Uint384) = field_arithmetic.mul(a.e7, a.e0, p_expand);
        let (d7: Uint384) = field_arithmetic.add(b_0_7, b_1_6, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_2_5, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_3_4, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_4_3, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_5_2, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_6_1, p_expand);
        let (d7: Uint384) = field_arithmetic.add(d7, b_7_0, p_expand);

        // d8
        let (b_0_8: Uint384) = field_arithmetic.mul(a.e0, a.e8, p_expand);
        let (b_1_7: Uint384) = field_arithmetic.mul(a.e1, a.e7, p_expand);
        let (b_2_6: Uint384) = field_arithmetic.mul(a.e2, a.e6, p_expand);
        let (b_3_5: Uint384) = field_arithmetic.mul(a.e3, a.e5, p_expand);
        let (b_4_4: Uint384) = field_arithmetic.square(a.e4, p_expand);
        let (b_5_3: Uint384) = field_arithmetic.mul(a.e5, a.e3, p_expand);
        let (b_6_2: Uint384) = field_arithmetic.mul(a.e6, a.e2, p_expand);
        let (b_7_1: Uint384) = field_arithmetic.mul(a.e7, a.e1, p_expand);
        let (b_8_0: Uint384) = field_arithmetic.mul(a.e8, a.e0, p_expand);
        let (d8: Uint384) = field_arithmetic.add(b_0_8, b_1_7, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_2_6, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_3_5, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_4_4, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_5_3, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_6_2, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_7_1, p_expand);
        let (d8: Uint384) = field_arithmetic.add(d8, b_8_0, p_expand);

        // d9
        let (b_0_9: Uint384) = field_arithmetic.mul(a.e0, a.e9, p_expand);
        let (b_1_8: Uint384) = field_arithmetic.mul(a.e1, a.e8, p_expand);
        let (b_2_7: Uint384) = field_arithmetic.mul(a.e2, a.e7, p_expand);
        let (b_3_6: Uint384) = field_arithmetic.mul(a.e3, a.e6, p_expand);
        let (b_4_5: Uint384) = field_arithmetic.mul(a.e4, a.e5, p_expand);
        let (b_5_4: Uint384) = field_arithmetic.mul(a.e5, a.e4, p_expand);
        let (b_6_3: Uint384) = field_arithmetic.mul(a.e6, a.e3, p_expand);
        let (b_7_2: Uint384) = field_arithmetic.mul(a.e7, a.e2, p_expand);
        let (b_8_1: Uint384) = field_arithmetic.mul(a.e8, a.e1, p_expand);
        let (b_9_0: Uint384) = field_arithmetic.mul(a.e9, a.e0, p_expand);
        let (d9: Uint384) = field_arithmetic.add(b_0_9, b_1_8, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_2_7, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_3_6, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_4_5, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_5_4, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_6_3, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_7_2, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_8_1, p_expand);
        let (d9: Uint384) = field_arithmetic.add(d9, b_9_0, p_expand);

        // d10
        let (b_0_10: Uint384) = field_arithmetic.mul(a.e0, a.e10, p_expand);
        let (b_1_9: Uint384) = field_arithmetic.mul(a.e1, a.e9, p_expand);
        let (b_2_8: Uint384) = field_arithmetic.mul(a.e2, a.e8, p_expand);
        let (b_3_7: Uint384) = field_arithmetic.mul(a.e3, a.e7, p_expand);
        let (b_4_6: Uint384) = field_arithmetic.mul(a.e4, a.e6, p_expand);
        let (b_5_5: Uint384) = field_arithmetic.square(a.e5, p_expand);
        let (b_6_4: Uint384) = field_arithmetic.mul(a.e6, a.e4, p_expand);
        let (b_7_3: Uint384) = field_arithmetic.mul(a.e7, a.e3, p_expand);
        let (b_8_2: Uint384) = field_arithmetic.mul(a.e8, a.e2, p_expand);
        let (b_9_1: Uint384) = field_arithmetic.mul(a.e9, a.e1, p_expand);
        let (b_10_0: Uint384) = field_arithmetic.mul(a.e10, a.e0, p_expand);
        let (d10: Uint384) = field_arithmetic.add(b_0_10, b_1_9, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_2_8, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_3_7, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_4_6, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_5_5, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_6_4, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_7_3, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_8_2, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_9_1, p_expand);
        let (d10: Uint384) = field_arithmetic.add(d10, b_10_0, p_expand);

        // d11
        let (b_0_11: Uint384) = field_arithmetic.mul(a.e0, a.e11, p_expand);
        let (b_1_10: Uint384) = field_arithmetic.mul(a.e1, a.e10, p_expand);
        let (b_2_9: Uint384) = field_arithmetic.mul(a.e2, a.e9, p_expand);
        let (b_3_8: Uint384) = field_arithmetic.mul(a.e3, a.e8, p_expand);
        let (b_4_7: Uint384) = field_arithmetic.mul(a.e4, a.e7, p_expand);
        let (b_5_6: Uint384) = field_arithmetic.mul(a.e5, a.e6, p_expand);
        let (b_6_5: Uint384) = field_arithmetic.mul(a.e6, a.e5, p_expand);
        let (b_7_4: Uint384) = field_arithmetic.mul(a.e7, a.e4, p_expand);
        let (b_8_3: Uint384) = field_arithmetic.mul(a.e8, a.e3, p_expand);
        let (b_9_2: Uint384) = field_arithmetic.mul(a.e9, a.e2, p_expand);
        let (b_10_1: Uint384) = field_arithmetic.mul(a.e10, a.e1, p_expand);
        let (b_11_0: Uint384) = field_arithmetic.mul(a.e11, a.e0, p_expand);
        let (d11: Uint384) = field_arithmetic.add(b_0_11, b_1_10, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_2_9, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_3_8, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_4_7, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_5_6, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_6_5, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_7_4, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_8_3, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_9_2, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_10_1, p_expand);
        let (d11: Uint384) = field_arithmetic.add(d11, b_11_0, p_expand);

        // d12
        let (b_1_11: Uint384) = field_arithmetic.mul(a.e1, a.e11, p_expand);
        let (b_2_10: Uint384) = field_arithmetic.mul(a.e2, a.e10, p_expand);
        let (b_3_9: Uint384) = field_arithmetic.mul(a.e3, a.e9, p_expand);
        let (b_4_8: Uint384) = field_arithmetic.mul(a.e4, a.e8, p_expand);
        let (b_5_7: Uint384) = field_arithmetic.mul(a.e5, a.e7, p_expand);
        let (b_6_6: Uint384) = field_arithmetic.square(a.e6, p_expand);
        let (b_7_5: Uint384) = field_arithmetic.mul(a.e7, a.e5, p_expand);
        let (b_8_4: Uint384) = field_arithmetic.mul(a.e8, a.e4, p_expand);
        let (b_9_3: Uint384) = field_arithmetic.mul(a.e9, a.e3, p_expand);
        let (b_10_2: Uint384) = field_arithmetic.mul(a.e10, a.e2, p_expand);
        let (b_11_1: Uint384) = field_arithmetic.mul(a.e11, a.e1, p_expand);
        let (d12: Uint384) = field_arithmetic.add(b_1_11, b_2_10, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_3_9, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_4_8, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_5_7, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_6_6, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_7_5, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_8_4, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_9_3, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_10_2, p_expand);
        let (d12: Uint384) = field_arithmetic.add(d12, b_11_1, p_expand);

        // d13
        let (b_2_11: Uint384) = field_arithmetic.mul(a.e2, a.e11, p_expand);
        let (b_3_10: Uint384) = field_arithmetic.mul(a.e3, a.e10, p_expand);
        let (b_4_9: Uint384) = field_arithmetic.mul(a.e4, a.e9, p_expand);
        let (b_5_8: Uint384) = field_arithmetic.mul(a.e5, a.e8, p_expand);
        let (b_6_7: Uint384) = field_arithmetic.mul(a.e6, a.e7, p_expand);
        let (b_7_6: Uint384) = field_arithmetic.mul(a.e7, a.e6, p_expand);
        let (b_8_5: Uint384) = field_arithmetic.mul(a.e8, a.e5, p_expand);
        let (b_9_4: Uint384) = field_arithmetic.mul(a.e9, a.e4, p_expand);
        let (b_10_3: Uint384) = field_arithmetic.mul(a.e10, a.e3, p_expand);
        let (b_11_2: Uint384) = field_arithmetic.mul(a.e11, a.e2, p_expand);
        let (d13: Uint384) = field_arithmetic.add(b_2_11, b_3_10, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_4_9, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_5_8, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_6_7, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_7_6, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_8_5, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_9_4, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_10_3, p_expand);
        let (d13: Uint384) = field_arithmetic.add(d13, b_11_2, p_expand);

        // d14
        let (b_3_11: Uint384) = field_arithmetic.mul(a.e3, a.e11, p_expand);
        let (b_4_10: Uint384) = field_arithmetic.mul(a.e4, a.e10, p_expand);
        let (b_5_9: Uint384) = field_arithmetic.mul(a.e5, a.e9, p_expand);
        let (b_6_8: Uint384) = field_arithmetic.mul(a.e6, a.e8, p_expand);
        let (b_7_7: Uint384) = field_arithmetic.square(a.e7, p_expand);
        let (b_8_6: Uint384) = field_arithmetic.mul(a.e8, a.e6, p_expand);
        let (b_9_5: Uint384) = field_arithmetic.mul(a.e9, a.e5, p_expand);
        let (b_10_4: Uint384) = field_arithmetic.mul(a.e10, a.e4, p_expand);
        let (b_11_3: Uint384) = field_arithmetic.mul(a.e11, a.e3, p_expand);
        let (d14: Uint384) = field_arithmetic.add(b_3_11, b_4_10, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_5_9, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_6_8, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_7_7, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_8_6, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_9_5, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_10_4, p_expand);
        let (d14: Uint384) = field_arithmetic.add(d14, b_11_3, p_expand);

        // d15
        let (b_4_11: Uint384) = field_arithmetic.mul(a.e4, a.e11, p_expand);
        let (b_5_10: Uint384) = field_arithmetic.mul(a.e5, a.e10, p_expand);
        let (b_6_9: Uint384) = field_arithmetic.mul(a.e6, a.e9, p_expand);
        let (b_7_8: Uint384) = field_arithmetic.mul(a.e7, a.e8, p_expand);
        let (b_8_7: Uint384) = field_arithmetic.mul(a.e8, a.e7, p_expand);
        let (b_9_6: Uint384) = field_arithmetic.mul(a.e9, a.e6, p_expand);
        let (b_10_5: Uint384) = field_arithmetic.mul(a.e10, a.e5, p_expand);
        let (b_11_4: Uint384) = field_arithmetic.mul(a.e11, a.e4, p_expand);
        let (d15: Uint384) = field_arithmetic.add(b_4_11, b_5_10, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_6_9, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_7_8, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_8_7, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_9_6, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_10_5, p_expand);
        let (d15: Uint384) = field_arithmetic.add(d15, b_11_4, p_expand);

        // d16
        let (b_5_11: Uint384) = field_arithmetic.mul(a.e5, a.e11, p_expand);
        let (b_6_10: Uint384) = field_arithmetic.mul(a.e6, a.e10, p_expand);
        let (b_7_9: Uint384) = field_arithmetic.mul(a.e7, a.e9, p_expand);
        let (b_8_8: Uint384) = field_arithmetic.square(a.e8, p_expand);
        let (b_9_7: Uint384) = field_arithmetic.mul(a.e9, a.e7, p_expand);
        let (b_10_6: Uint384) = field_arithmetic.mul(a.e10, a.e6, p_expand);
        let (b_11_5: Uint384) = field_arithmetic.mul(a.e11, a.e5, p_expand);
        let (d16: Uint384) = field_arithmetic.add(b_5_11, b_6_10, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_7_9, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_8_8, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_9_7, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_10_6, p_expand);
        let (d16: Uint384) = field_arithmetic.add(d16, b_11_5, p_expand);

        // d17
        let (b_6_11: Uint384) = field_arithmetic.mul(a.e6, a.e11, p_expand);
        let (b_7_10: Uint384) = field_arithmetic.mul(a.e7, a.e10, p_expand);
        let (b_8_9: Uint384) = field_arithmetic.mul(a.e8, a.e9, p_expand);
        let (b_9_8: Uint384) = field_arithmetic.mul(a.e9, a.e8, p_expand);
        let (b_10_7: Uint384) = field_arithmetic.mul(a.e10, a.e7, p_expand);
        let (b_11_6: Uint384) = field_arithmetic.mul(a.e11, a.e6, p_expand);
        let (d17: Uint384) = field_arithmetic.add(b_6_11, b_7_10, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_8_9, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_9_8, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_10_7, p_expand);
        let (d17: Uint384) = field_arithmetic.add(d17, b_11_6, p_expand);

        // d18
        let (b_7_11: Uint384) = field_arithmetic.mul(a.e7, a.e11, p_expand);
        let (b_8_10: Uint384) = field_arithmetic.mul(a.e8, a.e10, p_expand);
        let (b_9_9: Uint384) = field_arithmetic.square(a.e9, p_expand);
        let (b_10_8: Uint384) = field_arithmetic.mul(a.e10, a.e8, p_expand);
        let (b_11_7: Uint384) = field_arithmetic.mul(a.e11, a.e7, p_expand);
        let (d18: Uint384) = field_arithmetic.add(b_7_11, b_8_10, p_expand);
        let (d18: Uint384) = field_arithmetic.add(d18, b_9_9, p_expand);
        let (d18: Uint384) = field_arithmetic.add(d18, b_10_8, p_expand);
        let (d18: Uint384) = field_arithmetic.add(d18, b_11_7, p_expand);

        // d19
        let (b_8_11: Uint384) = field_arithmetic.mul(a.e8, a.e11, p_expand);
        let (b_9_10: Uint384) = field_arithmetic.mul(a.e9, a.e10, p_expand);
        let (b_10_9: Uint384) = field_arithmetic.mul(a.e10, a.e9, p_expand);
        let (b_11_8: Uint384) = field_arithmetic.mul(a.e11, a.e8, p_expand);
        let (d19: Uint384) = field_arithmetic.add(b_8_11, b_9_10, p_expand);
        let (d19: Uint384) = field_arithmetic.add(d19, b_10_9, p_expand);
        let (d19: Uint384) = field_arithmetic.add(d19, b_11_8, p_expand);

        // d20
        let (b_9_11: Uint384) = field_arithmetic.mul(a.e9, a.e11, p_expand);
        let (b_10_10: Uint384) = field_arithmetic.square(a.e10, p_expand);
        let (b_11_9: Uint384) = field_arithmetic.mul(a.e11, a.e9, p_expand);
        let (d20: Uint384) = field_arithmetic.add(b_9_11, b_10_10, p_expand);
        let (d20: Uint384) = field_arithmetic.add(d20, b_11_9, p_expand);

        // d21
        let (b_10_11: Uint384) = field_arithmetic.mul(a.e10, a.e11, p_expand);
        let (b_11_10: Uint384) = field_arithmetic.mul(a.e11, a.e10, p_expand);
        let (d21: Uint384) = field_arithmetic.add(b_10_11, b_11_10, p_expand);

        // d22
        let (d22: Uint384) = field_arithmetic.square(a.e11, p_expand);

        // Reducing the results modulo the irreducible polynomial
        // Note that the order in which _aux_polynomial_reduction is called is important here
        let (d10: Uint384, d16: Uint384) = _aux_polynomial_reduction(d22, d10, d16);
        let (d9: Uint384, d15: Uint384) = _aux_polynomial_reduction(d21, d9, d15);
        let (d8: Uint384, d14: Uint384) = _aux_polynomial_reduction(d20, d8, d14);
        let (d7: Uint384, d13: Uint384) = _aux_polynomial_reduction(d19, d7, d13);
        let (d6: Uint384, d12: Uint384) = _aux_polynomial_reduction(d18, d6, d12);
        let (d5: Uint384, d11: Uint384) = _aux_polynomial_reduction(d17, d5, d11);
        let (d4: Uint384, d10: Uint384) = _aux_polynomial_reduction(d16, d4, d10);
        let (d3: Uint384, d9: Uint384) = _aux_polynomial_reduction(d15, d3, d9);
        let (d2: Uint384, d8: Uint384) = _aux_polynomial_reduction(d14, d2, d8);
        let (d1: Uint384, d7: Uint384) = _aux_polynomial_reduction(d13, d1, d7);
        let (d0: Uint384, d6: Uint384) = _aux_polynomial_reduction(d12, d0, d6);

        return (FQ12(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11),);
    }
    
    // square function derived from mul_2, since squaring is slightly more efficient than mul_expand, though the improvement should be small.
    // st=125511, mh=4280, rc=14372
    func square_2{range_check_ptr}(a: FQ12) -> (product: FQ12) {
        alloc_locals;
        let (p_expand:Uint384_expand) = get_modulus_expand();

	let (a_e0:Uint384_expand) = uint384_lib.expand(a.e0);
	let (a_e1:Uint384_expand) = uint384_lib.expand(a.e1);
	let (a_e2:Uint384_expand) = uint384_lib.expand(a.e2);
	let (a_e3:Uint384_expand) = uint384_lib.expand(a.e3);
	let (a_e4:Uint384_expand) = uint384_lib.expand(a.e4);
	let (a_e5:Uint384_expand) = uint384_lib.expand(a.e5);
	let (a_e6:Uint384_expand) = uint384_lib.expand(a.e6);
	let (a_e7:Uint384_expand) = uint384_lib.expand(a.e7);
	let (a_e8:Uint384_expand) = uint384_lib.expand(a.e8);
	let (a_e9:Uint384_expand) = uint384_lib.expand(a.e9);
	let (a_e10:Uint384_expand) = uint384_lib.expand(a.e10);
	let (a_e11:Uint384_expand) = uint384_lib.expand(a.e11);
	
        // d0
        let (d0: Uint384) = field_arithmetic.square(a.e0, p_expand);

        // d1
        let (a_0_1: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e1, p_expand);
        let (a_1_0: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e0, p_expand);
        let (d1: Uint384,_) = uint384_lib.add(a_0_1, a_1_0);
	let (_,d1: Uint384) = uint384_lib.unsigned_div_rem_expanded(d1, p_expand);

        // d2
        let (a_0_2: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e2, p_expand);
        let (a_1_1: Uint384) = field_arithmetic.square(a.e1, p_expand);
        let (a_2_0: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e0, p_expand);
        let (d2: Uint384,_) = uint384_lib.add(a_0_2, a_1_1);
        let (d2: Uint384,_) = uint384_lib.add(d2, a_2_0);
	let (_,d2: Uint384) = uint384_lib.unsigned_div_rem_expanded(d2, p_expand);

        // d3
        let (a_0_3: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e3, p_expand);
        let (a_1_2: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e2, p_expand);
        let (a_2_1: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e1, p_expand);
        let (a_3_0: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e0, p_expand);
        let (d3: Uint384,_) = uint384_lib.add(a_0_3, a_1_2);
        let (d3: Uint384,_) = uint384_lib.add(d3, a_2_1);
        let (d3: Uint384,_) = uint384_lib.add(d3, a_3_0);
	let (_,d3: Uint384) = uint384_lib.unsigned_div_rem_expanded(d3, p_expand);

        // d4
        let (a_0_4: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e4, p_expand);
        let (a_1_3: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e3, p_expand);
        let (a_2_2: Uint384) = field_arithmetic.square(a.e2, p_expand);
        let (a_3_1: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e1, p_expand);
        let (a_4_0: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e0, p_expand);
        let (d4: Uint384,_) = uint384_lib.add(a_0_4, a_1_3);
        let (d4: Uint384,_) = uint384_lib.add(d4, a_2_2);
        let (d4: Uint384,_) = uint384_lib.add(d4, a_3_1);
        let (d4: Uint384,_) = uint384_lib.add(d4, a_4_0);
	let (_,d4: Uint384) = uint384_lib.unsigned_div_rem_expanded(d4, p_expand);

        // d5
        let (a_0_5: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e5, p_expand);
        let (a_1_4: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e4, p_expand);
        let (a_2_3: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e3, p_expand);
        let (a_3_2: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e2, p_expand);
        let (a_4_1: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e1, p_expand);
        let (a_5_0: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e0, p_expand);
        let (d5: Uint384,_) = uint384_lib.add(a_0_5, a_1_4);
        let (d5: Uint384,_) = uint384_lib.add(d5, a_2_3);
        let (d5: Uint384,_) = uint384_lib.add(d5, a_3_2);
        let (d5: Uint384,_) = uint384_lib.add(d5, a_4_1);
        let (d5: Uint384,_) = uint384_lib.add(d5, a_5_0);
	let (_,d5: Uint384) = uint384_lib.unsigned_div_rem_expanded(d5, p_expand);

        // d6
        let (a_0_6: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e6, p_expand);
        let (a_1_5: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e5, p_expand);
        let (a_2_4: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e4, p_expand);
        let (a_3_3: Uint384) = field_arithmetic.square(a.e3, p_expand);
        let (a_4_2: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e2, p_expand);
        let (a_5_1: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e1, p_expand);
        let (a_6_0: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e0, p_expand);
        let (d6: Uint384,_) = uint384_lib.add(a_0_6, a_1_5);
        let (d6: Uint384,_) = uint384_lib.add(d6, a_2_4);
        let (d6: Uint384,_) = uint384_lib.add(d6, a_3_3);
        let (d6: Uint384,_) = uint384_lib.add(d6, a_4_2);
        let (d6: Uint384,_) = uint384_lib.add(d6, a_5_1);
        let (d6: Uint384,_) = uint384_lib.add(d6, a_6_0);
	let (_,d6: Uint384) = uint384_lib.unsigned_div_rem_expanded(d6, p_expand);

        // d7
        let (a_0_7: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e7, p_expand);
        let (a_1_6: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e6, p_expand);
        let (a_2_5: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e5, p_expand);
        let (a_3_4: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e4, p_expand);
        let (a_4_3: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e3, p_expand);
        let (a_5_2: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e2, p_expand);
        let (a_6_1: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e1, p_expand);
        let (a_7_0: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e0, p_expand);
        let (d7: Uint384,_) = uint384_lib.add(a_0_7, a_1_6);
        let (d7: Uint384,_) = uint384_lib.add(d7, a_2_5);
        let (d7: Uint384,_) = uint384_lib.add(d7, a_3_4);
        let (d7: Uint384,_) = uint384_lib.add(d7, a_4_3);
        let (d7: Uint384,_) = uint384_lib.add(d7, a_5_2);
        let (d7: Uint384,_) = uint384_lib.add(d7, a_6_1);
        let (d7: Uint384,_) = uint384_lib.add(d7, a_7_0);
	let (_,d7: Uint384) = uint384_lib.unsigned_div_rem_expanded(d7, p_expand);

        // d8
        let (a_0_8: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e8, p_expand);
        let (a_1_7: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e7, p_expand);
        let (a_2_6: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e6, p_expand);
        let (a_3_5: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e5, p_expand);
        let (a_4_4: Uint384) = field_arithmetic.square(a.e4, p_expand);
        let (a_5_3: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e3, p_expand);
        let (a_6_2: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e2, p_expand);
        let (a_7_1: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e1, p_expand);
        let (a_8_0: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e0, p_expand);
        let (d8: Uint384,_) = uint384_lib.add(a_0_8, a_1_7);
        let (d8: Uint384,_) = uint384_lib.add(d8, a_2_6);
        let (d8: Uint384,_) = uint384_lib.add(d8, a_3_5);
        let (d8: Uint384,_) = uint384_lib.add(d8, a_4_4);
        let (d8: Uint384,_) = uint384_lib.add(d8, a_5_3);
        let (d8: Uint384,_) = uint384_lib.add(d8, a_6_2);
        let (d8: Uint384,_) = uint384_lib.add(d8, a_7_1);
        let (d8: Uint384,_) = uint384_lib.add(d8, a_8_0);
	let (_,d8: Uint384) = uint384_lib.unsigned_div_rem_expanded(d8, p_expand);

        // d9
        let (a_0_9: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e9, p_expand);
        let (a_1_8: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e8, p_expand);
        let (a_2_7: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e7, p_expand);
        let (a_3_6: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e6, p_expand);
        let (a_4_5: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e5, p_expand);
        let (a_5_4: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e4, p_expand);
        let (a_6_3: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e3, p_expand);
        let (a_7_2: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e2, p_expand);
        let (a_8_1: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e1, p_expand);
        let (a_9_0: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e0, p_expand);
        let (d9: Uint384,_) = uint384_lib.add(a_0_9, a_1_8);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_2_7);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_3_6);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_4_5);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_5_4);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_6_3);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_7_2);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_8_1);
	let (_,d9: Uint384) = uint384_lib.unsigned_div_rem_expanded(d9, p_expand);
        let (d9: Uint384,_) = uint384_lib.add(d9, a_9_0);
	let (_,d9: Uint384) = uint384_lib.unsigned_div_rem_expanded(d9, p_expand);

        // d10
        let (a_0_10: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e10, p_expand);
        let (a_1_9: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e9, p_expand);
        let (a_2_8: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e8, p_expand);
        let (a_3_7: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e7, p_expand);
        let (a_4_6: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e6, p_expand);
        let (a_5_5: Uint384) = field_arithmetic.square(a.e5, p_expand);
        let (a_6_4: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e4, p_expand);
        let (a_7_3: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e3, p_expand);
        let (a_8_2: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e2, p_expand);
        let (a_9_1: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e1, p_expand);
        let (a_10_0: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e0, p_expand);
        let (d10: Uint384,_) = uint384_lib.add(a_0_10, a_1_9);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_2_8);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_3_7);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_4_6);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_5_5);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_6_4);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_7_3);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_8_2);
	let (_,d10: Uint384) = uint384_lib.unsigned_div_rem_expanded(d10, p_expand);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_9_1);
        let (d10: Uint384,_) = uint384_lib.add(d10, a_10_0);
	let (_,d10: Uint384) = uint384_lib.unsigned_div_rem_expanded(d10, p_expand);

        // d11
        let (a_0_11: Uint384) = field_arithmetic.mul_expanded(a.e0, a_e11, p_expand);
        let (a_1_10: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e10, p_expand);
        let (a_2_9: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e9, p_expand);
        let (a_3_8: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e8, p_expand);
        let (a_4_7: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e7, p_expand);
        let (a_5_6: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e6, p_expand);
        let (a_6_5: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e5, p_expand);
        let (a_7_4: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e4, p_expand);
        let (a_8_3: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e3, p_expand);
        let (a_9_2: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e2, p_expand);
        let (a_10_1: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e1, p_expand);
        let (a_11_0: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e0, p_expand);
        let (d11: Uint384,_) = uint384_lib.add(a_0_11, a_1_10);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_2_9);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_3_8);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_4_7);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_5_6);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_6_5);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_7_4);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_8_3);
	let (_,d11: Uint384) = uint384_lib.unsigned_div_rem_expanded(d11, p_expand);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_9_2);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_10_1);
        let (d11: Uint384,_) = uint384_lib.add(d11, a_11_0);
	let (_,d11: Uint384) = uint384_lib.unsigned_div_rem_expanded(d11, p_expand);

        // d12
        let (a_1_11: Uint384) = field_arithmetic.mul_expanded(a.e1, a_e11, p_expand);
        let (a_2_10: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e10, p_expand);
        let (a_3_9: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e9, p_expand);
        let (a_4_8: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e8, p_expand);
        let (a_5_7: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e7, p_expand);
        let (a_6_6: Uint384) = field_arithmetic.square(a.e6, p_expand);
        let (a_7_5: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e5, p_expand);
        let (a_8_4: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e4, p_expand);
        let (a_9_3: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e3, p_expand);
        let (a_10_2: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e2, p_expand);
        let (a_11_1: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e1, p_expand);
        let (d12: Uint384,_) = uint384_lib.add(a_1_11, a_2_10);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_3_9);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_4_8);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_5_7);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_6_6);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_7_5);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_8_4);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_9_3);
	let (_,d12: Uint384) = uint384_lib.unsigned_div_rem_expanded(d12, p_expand);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_10_2);
        let (d12: Uint384,_) = uint384_lib.add(d12, a_11_1);
	let (_,d12: Uint384) = uint384_lib.unsigned_div_rem_expanded(d12, p_expand);

        // d13
        let (a_2_11: Uint384) = field_arithmetic.mul_expanded(a.e2, a_e11, p_expand);
        let (a_3_10: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e10, p_expand);
        let (a_4_9: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e9, p_expand);
        let (a_5_8: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e8, p_expand);
        let (a_6_7: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e7, p_expand);
        let (a_7_6: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e6, p_expand);
        let (a_8_5: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e5, p_expand);
        let (a_9_4: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e4, p_expand);
        let (a_10_3: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e3, p_expand);
        let (a_11_2: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e2, p_expand);
        let (d13: Uint384,_) = uint384_lib.add(a_2_11, a_3_10);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_4_9);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_5_8);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_6_7);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_7_6);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_8_5);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_9_4);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_10_3);
	let (_,d13: Uint384) = uint384_lib.unsigned_div_rem_expanded(d13, p_expand);
        let (d13: Uint384,_) = uint384_lib.add(d13, a_11_2);
	let (_,d13: Uint384) = uint384_lib.unsigned_div_rem_expanded(d13, p_expand);

        // d14
        let (a_3_11: Uint384) = field_arithmetic.mul_expanded(a.e3, a_e11, p_expand);
        let (a_4_10: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e10, p_expand);
        let (a_5_9: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e9, p_expand);
        let (a_6_8: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e8, p_expand);
        let (a_7_7: Uint384) = field_arithmetic.square(a.e7, p_expand);
        let (a_8_6: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e6, p_expand);
        let (a_9_5: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e5, p_expand);
        let (a_10_4: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e4, p_expand);
        let (a_11_3: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e3, p_expand);
        let (d14: Uint384,_) = uint384_lib.add(a_3_11, a_4_10);
        let (d14: Uint384,_) = uint384_lib.add(d14, a_5_9);
        let (d14: Uint384,_) = uint384_lib.add(d14, a_6_8);
        let (d14: Uint384,_) = uint384_lib.add(d14, a_7_7);
        let (d14: Uint384,_) = uint384_lib.add(d14, a_8_6);
        let (d14: Uint384,_) = uint384_lib.add(d14, a_9_5);
        let (d14: Uint384,_) = uint384_lib.add(d14, a_10_4);
        let (d14: Uint384,_) = uint384_lib.add(d14, a_11_3);
	let (_,d14: Uint384) = uint384_lib.unsigned_div_rem_expanded(d14, p_expand);

        // d15
        let (a_4_11: Uint384) = field_arithmetic.mul_expanded(a.e4, a_e11, p_expand);
        let (a_5_10: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e10, p_expand);
        let (a_6_9: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e9, p_expand);
        let (a_7_8: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e8, p_expand);
        let (a_8_7: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e7, p_expand);
        let (a_9_6: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e6, p_expand);
        let (a_10_5: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e5, p_expand);
        let (a_11_4: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e4, p_expand);
        let (d15: Uint384,_) = uint384_lib.add(a_4_11, a_5_10);
        let (d15: Uint384,_) = uint384_lib.add(d15, a_6_9);
        let (d15: Uint384,_) = uint384_lib.add(d15, a_7_8);
        let (d15: Uint384,_) = uint384_lib.add(d15, a_8_7);
        let (d15: Uint384,_) = uint384_lib.add(d15, a_9_6);
        let (d15: Uint384,_) = uint384_lib.add(d15, a_10_5);
        let (d15: Uint384,_) = uint384_lib.add(d15, a_11_4);
	let (_,d15: Uint384) = uint384_lib.unsigned_div_rem_expanded(d15, p_expand);

        // d16
        let (a_5_11: Uint384) = field_arithmetic.mul_expanded(a.e5, a_e11, p_expand);
        let (a_6_10: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e10, p_expand);
        let (a_7_9: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e9, p_expand);
        let (a_8_8: Uint384) = field_arithmetic.square(a.e8, p_expand);
        let (a_9_7: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e7, p_expand);
        let (a_10_6: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e6, p_expand);
        let (a_11_5: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e5, p_expand);
        let (d16: Uint384,_) = uint384_lib.add(a_5_11, a_6_10);
        let (d16: Uint384,_) = uint384_lib.add(d16, a_7_9);
        let (d16: Uint384,_) = uint384_lib.add(d16, a_8_8);
        let (d16: Uint384,_) = uint384_lib.add(d16, a_9_7);
        let (d16: Uint384,_) = uint384_lib.add(d16, a_10_6);
        let (d16: Uint384,_) = uint384_lib.add(d16, a_11_5);
	let (_,d16: Uint384) = uint384_lib.unsigned_div_rem_expanded(d16, p_expand);

        // d17
        let (a_6_11: Uint384) = field_arithmetic.mul_expanded(a.e6, a_e11, p_expand);
        let (a_7_10: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e10, p_expand);
        let (a_8_9: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e9, p_expand);
        let (a_9_8: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e8, p_expand);
        let (a_10_7: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e7, p_expand);
        let (a_11_6: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e6, p_expand);
        let (d17: Uint384,_) = uint384_lib.add(a_6_11, a_7_10);
        let (d17: Uint384,_) = uint384_lib.add(d17, a_8_9);
        let (d17: Uint384,_) = uint384_lib.add(d17, a_9_8);
        let (d17: Uint384,_) = uint384_lib.add(d17, a_10_7);
        let (d17: Uint384,_) = uint384_lib.add(d17, a_11_6);
	let (_,d17: Uint384) = uint384_lib.unsigned_div_rem_expanded(d17, p_expand);

        // d18
        let (a_7_11: Uint384) = field_arithmetic.mul_expanded(a.e7, a_e11, p_expand);
        let (a_8_10: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e10, p_expand);
        let (a_9_9: Uint384) = field_arithmetic.square(a.e9, p_expand);
        let (a_10_8: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e8, p_expand);
        let (a_11_7: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e7, p_expand);
        let (d18: Uint384,_) = uint384_lib.add(a_7_11, a_8_10);
        let (d18: Uint384,_) = uint384_lib.add(d18, a_9_9);
        let (d18: Uint384,_) = uint384_lib.add(d18, a_10_8);
        let (d18: Uint384,_) = uint384_lib.add(d18, a_11_7);
	let (_,d18: Uint384) = uint384_lib.unsigned_div_rem_expanded(d18, p_expand);

        // d19
        let (a_8_11: Uint384) = field_arithmetic.mul_expanded(a.e8, a_e11, p_expand);
        let (a_9_10: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e10, p_expand);
        let (a_10_9: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e9, p_expand);
        let (a_11_8: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e8, p_expand);
        let (d19: Uint384,_) = uint384_lib.add(a_8_11, a_9_10);
        let (d19: Uint384,_) = uint384_lib.add(d19, a_10_9);
        let (d19: Uint384,_) = uint384_lib.add(d19, a_11_8);
	let (_,d19: Uint384) = uint384_lib.unsigned_div_rem_expanded(d19, p_expand);

        // d20
        let (a_9_11: Uint384) = field_arithmetic.mul_expanded(a.e9, a_e11, p_expand);
        let (a_10_10: Uint384) = field_arithmetic.square(a.e10, p_expand);
        let (a_11_9: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e9, p_expand);
        let (d20: Uint384,_) = uint384_lib.add(a_9_11, a_10_10);
        let (d20: Uint384,_) = uint384_lib.add(d20, a_11_9);
	let (_,d20: Uint384) = uint384_lib.unsigned_div_rem_expanded(d20, p_expand);

        // d21
        let (a_10_11: Uint384) = field_arithmetic.mul_expanded(a.e10, a_e11, p_expand);
        let (a_11_10: Uint384) = field_arithmetic.mul_expanded(a.e11, a_e10, p_expand);
        let (d21: Uint384,_) = uint384_lib.add(a_10_11, a_11_10);
	let (_,d21: Uint384) = uint384_lib.unsigned_div_rem_expanded(d21, p_expand);

        // d22
        let (d22: Uint384) = field_arithmetic.square(a.e11, p_expand);

        // Reducing the results modulo the irreducible polynomial
        // Note that the order in which _aux_polynomial_reduction is called is important here
        let (d10: Uint384, d16: Uint384) = _aux_polynomial_reduction(d22, d10, d16);
        let (d9: Uint384, d15: Uint384) = _aux_polynomial_reduction(d21, d9, d15);
        let (d8: Uint384, d14: Uint384) = _aux_polynomial_reduction(d20, d8, d14);
        let (d7: Uint384, d13: Uint384) = _aux_polynomial_reduction(d19, d7, d13);
        let (d6: Uint384, d12: Uint384) = _aux_polynomial_reduction(d18, d6, d12);
        let (d5: Uint384, d11: Uint384) = _aux_polynomial_reduction(d17, d5, d11);
        let (d4: Uint384, d10: Uint384) = _aux_polynomial_reduction(d16, d4, d10);
        let (d3: Uint384, d9: Uint384) = _aux_polynomial_reduction(d15, d3, d9);
        let (d2: Uint384, d8: Uint384) = _aux_polynomial_reduction(d14, d2, d8);
        let (d1: Uint384, d7: Uint384) = _aux_polynomial_reduction(d13, d1, d7);
        let (d0: Uint384, d6: Uint384) = _aux_polynomial_reduction(d12, d0, d6);

        return (FQ12(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11),);
    }

    // Toom-Cook 12
    // st=57293, mh=2640, rc=5407
    func square_TC_12{range_check_ptr}(a: FQ12) -> (product: FQ12) {
        alloc_locals;
	local d0: Uint384;
	local d1: Uint384;
	local d2: Uint384;
	local d3: Uint384;
	local d4: Uint384;
	local d5: Uint384;
	local d6: Uint384;
	local d7: Uint384;
	local d8: Uint384;
	local d9: Uint384;
	local d10: Uint384;
	local d11: Uint384;
	local d12: Uint384;
	local d13: Uint384;
	local d14: Uint384;
	local d15: Uint384;
	local d16: Uint384;
	local d17: Uint384;
	local d18: Uint384;
	local d19: Uint384;
	local d20: Uint384;
	local d21: Uint384;
	local d22: Uint384;
        let (p_expand:Uint384_expand) = get_modulus_expand();
	%{
            p = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
            
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def split(num: int, num_bits_shift: int = 128, length: int = 3):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift
                return tuple(a)

            def pack_FQ12(z):
                limbs = (z.e0, z.e1, z.e2, z.e3, z.e4, z.e5, z.e6, z.e7, z.e8, z.e9, z.e10, z.e11)
                ans = [pack(limb) for limb in limbs]
                return tuple(ans)

            #quadratic, but this is python
            def mult_poly12(a,b):
                return tuple([sum(a[j]*b[i-j] for j in range(max(0,i - 11),min(i + 1,12))) % p for i in range(23)])

            def split2(v, num: int):
                n=split(num)
                v.d0=n[0]
                v.d1=n[1]
                v.d2=n[2]

            a = pack_FQ12(ids.a)
            d = mult_poly12(a,a)
            
            split2(ids.d0,d[0])
            split2(ids.d1,d[1])
            split2(ids.d2,d[2])
            split2(ids.d3,d[3])
            split2(ids.d4,d[4])
            split2(ids.d5,d[5])
            split2(ids.d6,d[6])
            split2(ids.d7,d[7])
            split2(ids.d8,d[8])
            split2(ids.d9,d[9])
            split2(ids.d10,d[10])
            split2(ids.d11,d[11])
            split2(ids.d12,d[12])
            split2(ids.d13,d[13])
            split2(ids.d14,d[14])
            split2(ids.d15,d[15])
            split2(ids.d16,d[16])
            split2(ids.d17,d[17])
            split2(ids.d18,d[18])
            split2(ids.d19,d[19])
            split2(ids.d20,d[20])
            split2(ids.d21,d[21])
            split2(ids.d22,d[22])
	%}
        fq_lib.check(d0);
        fq_lib.check(d1);
        fq_lib.check(d2);
        fq_lib.check(d3);
        fq_lib.check(d4);
        fq_lib.check(d5);
        fq_lib.check(d6);
        fq_lib.check(d7);
        fq_lib.check(d8);
        fq_lib.check(d9);
        fq_lib.check(d10);
        fq_lib.check(d11);
        fq_lib.check(d12);
        fq_lib.check(d13);
        fq_lib.check(d14);
        fq_lib.check(d15);
        fq_lib.check(d16);
        fq_lib.check(d17);
        fq_lib.check(d18);
        fq_lib.check(d19);
        fq_lib.check(d20);
        fq_lib.check(d21);
        fq_lib.check(d22);

	let av01 = a.e0;
	let av10 = a.e11;
	let (av11) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,1,
					     a.e2,1,
					     a.e3,1,
					     a.e4,1,
					     a.e5,1,
					     a.e6,1,
					     a.e7,1,
					     a.e8,1,
					     a.e9,1,
					     a.e10,1,
					     a.e11,1,
					     p_expand);
	let (av21) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,2,
					     a.e2,2**2,
					     a.e3,2**3,
					     a.e4,2**4,
					     a.e5,2**5,
					     a.e6,2**6,
					     a.e7,2**7,
					     a.e8,2**8,
					     a.e9,2**9,
					     a.e10,2**10,
					     a.e11,2**11,
					     p_expand);
	let (av12) = dot_by_uint64_vec12_mod(a.e0,2**11,
					     a.e1,2**10,
					     a.e2,2**9,
					     a.e3,2**8,
					     a.e4,2**7,
					     a.e5,2**6,
					     a.e6,2**5,
					     a.e7,2**4,
					     a.e8,2**3,
					     a.e9,2**2,
					     a.e10,2,
					     a.e11,1,
					     p_expand);
	let (av31) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,3,
					     a.e2,3**2,
					     a.e3,3**3,
					     a.e4,3**4,
					     a.e5,3**5,
					     a.e6,3**6,
					     a.e7,3**7,
					     a.e8,3**8,
					     a.e9,3**9,
					     a.e10,3**10,
					     a.e11,3**11,
					     p_expand);
	let (av13) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,3**10,
					     a.e2,3**9,
					     a.e3,3**8,
					     a.e4,3**7,
					     a.e5,3**6,
					     a.e6,3**5,
					     a.e7,3**4,
					     a.e8,3**3,
					     a.e9,3**2,
					     a.e10,3,
					     a.e11,1,
					     p_expand);
	let (av32) = dot_by_uint64_vec12_mod(a.e0,2**11,
					     a.e1,3*2**10,
					     a.e2,3**2*2**9,
					     a.e3,3**3*2**8,
					     a.e4,3**4*2**7,
					     a.e5,3**5*2**6,
					     a.e6,3**6*2**5,
					     a.e7,3**7*2**4,
					     a.e8,3**8*2**3,
					     a.e9,3**9*2**2,
					     a.e10,3**10*2,
					     a.e11,3**11,
					     p_expand);
	let (av23) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,2*3**10,
					     a.e2,2**2*3**9,
					     a.e3,2**3*3**8,
					     a.e4,2**4*3**7,
					     a.e5,2**5*3**6,
					     a.e6,2**6*3**5,
					     a.e7,2**7*3**4,
					     a.e8,2**8*3**3,
					     a.e9,2**9*3**2,
					     a.e10,2**10*3,
					     a.e11,2**11,
					     p_expand);
	let (av41) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,4,
					     a.e2,4**2,
					     a.e3,4**3,
					     a.e4,4**4,
					     a.e5,4**5,
					     a.e6,4**6,
					     a.e7,4**7,
					     a.e8,4**8,
					     a.e9,4**9,
					     a.e10,4**10,
					     a.e11,4**11,
					     p_expand);
	let (av14) = dot_by_uint64_vec12_mod(a.e0,4**11,
					     a.e1,4**10,
					     a.e2,4**9,
					     a.e3,4**8,
					     a.e4,4**7,
					     a.e5,4**6,
					     a.e6,4**5,
					     a.e7,4**4,
					     a.e8,4**3,
					     a.e9,4**2,
					     a.e10,4,
					     a.e11,1,
					     p_expand);
	let (av43) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,4*3**10,
					     a.e2,4**2*3**9,
					     a.e3,4**3*3**8,
					     a.e4,4**4*3**7,
					     a.e5,4**5*3**6,
					     a.e6,4**6*3**5,
					     a.e7,4**7*3**4,
					     a.e8,4**8*3**3,
					     a.e9,4**9*3**2,
					     a.e10,4**10*3,
					     a.e11,4**11,
					     p_expand);
	let (av34) = dot_by_uint64_vec12_mod(a.e0,4**11,
					     a.e1,3*4**10,
					     a.e2,3**2*4**9,
					     a.e3,3**3*4**8,
					     a.e4,3**4*4**7,
					     a.e5,3**5*4**6,
					     a.e6,3**6*4**5,
					     a.e7,3**7*4**4,
					     a.e8,3**8*4**3,
					     a.e9,3**9*4**2,
					     a.e10,3**10*4,
					     a.e11,3**11,
					     p_expand);
	let (av51) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,5,
					     a.e2,5**2,
					     a.e3,5**3,
					     a.e4,5**4,
					     a.e5,5**5,
					     a.e6,5**6,
					     a.e7,5**7,
					     a.e8,5**8,
					     a.e9,5**9,
					     a.e10,5**10,
					     a.e11,5**11,
					     p_expand);
	let (av15) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,5**10,
					     a.e2,5**9,
					     a.e3,5**8,
					     a.e4,5**7,
					     a.e5,5**6,
					     a.e6,5**5,
					     a.e7,5**4,
					     a.e8,5**3,
					     a.e9,5**2,
					     a.e10,5,
					     a.e11,1,
					     p_expand);
	let (av52) = dot_by_uint64_vec12_mod(a.e0,2**11,
					     a.e1,5*2**10,
					     a.e2,5**2*2**9,
					     a.e3,5**3*2**8,
					     a.e4,5**4*2**7,
					     a.e5,5**5*2**6,
					     a.e6,5**6*2**5,
					     a.e7,5**7*2**4,
					     a.e8,5**8*2**3,
					     a.e9,5**9*2**2,
					     a.e10,5**10*2,
					     a.e11,5**11,
					     p_expand);
	let (av25) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,2*5**10,
					     a.e2,2**2*5**9,
					     a.e3,2**3*5**8,
					     a.e4,2**4*5**7,
					     a.e5,2**5*5**6,
					     a.e6,2**6*5**5,
					     a.e7,2**7*5**4,
					     a.e8,2**8*5**3,
					     a.e9,2**9*5**2,
					     a.e10,2**10*5,
					     a.e11,2**11,
					     p_expand);
	let (av53) = dot_by_uint64_vec12_mod(a.e0,3**11,
					     a.e1,5*3**10,
					     a.e2,5**2*3**9,
					     a.e3,5**3*3**8,
					     a.e4,5**4*3**7,
					     a.e5,5**5*3**6,
					     a.e6,5**6*3**5,
					     a.e7,5**7*3**4,
					     a.e8,5**8*3**3,
					     a.e9,5**9*3**2,
					     a.e10,5**10*3,
					     a.e11,5**11,
					     p_expand);
	let (av35) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,3*5**10,
					     a.e2,3**2*5**9,
					     a.e3,3**3*5**8,
					     a.e4,3**4*5**7,
					     a.e5,3**5*5**6,
					     a.e6,3**6*5**5,
					     a.e7,3**7*5**4,
					     a.e8,3**8*5**3,
					     a.e9,3**9*5**2,
					     a.e10,3**10*5,
					     a.e11,3**11,
					     p_expand);
	let (av54) = dot_by_uint64_vec12_mod(a.e0,4**11,
					     a.e1,5*4**10,
					     a.e2,5**2*4**9,
					     a.e3,5**3*4**8,
					     a.e4,5**4*4**7,
					     a.e5,5**5*4**6,
					     a.e6,5**6*4**5,
					     a.e7,5**7*4**4,
					     a.e8,5**8*4**3,
					     a.e9,5**9*4**2,
					     a.e10,5**10*4,
					     a.e11,5**11,
					     p_expand);
	let (av45) = dot_by_uint64_vec12_mod(a.e0,5**11,
					     a.e1,4*5**10,
					     a.e2,4**2*5**9,
					     a.e3,4**3*5**8,
					     a.e4,4**4*5**7,
					     a.e5,4**5*5**6,
					     a.e6,4**6*5**5,
					     a.e7,4**7*5**4,
					     a.e8,4**8*5**3,
					     a.e9,4**9*5**2,
					     a.e10,4**10*5,
					     a.e11,4**11,
					     p_expand);
	let (av61) = dot_by_uint64_vec12_mod(a.e0,1,
					     a.e1,6,
					     a.e2,6**2,
					     a.e3,6**3,
					     a.e4,6**4,
					     a.e5,6**5,
					     a.e6,6**6,
					     a.e7,6**7,
					     a.e8,6**8,
					     a.e9,6**9,
					     a.e10,6**10,
					     a.e11,6**11,
					     p_expand);
	let (av16) = dot_by_uint64_vec12_mod(a.e0,6**11,
					     a.e1,6**10,
					     a.e2,6**9,
					     a.e3,6**8,
					     a.e4,6**7,
					     a.e5,6**6,
					     a.e6,6**5,
					     a.e7,6**4,
					     a.e8,6**3,
					     a.e9,6**2,
					     a.e10,6,
					     a.e11,1,
					     p_expand);

	let dv01 = d0;
	let dv10 = d22;
	let (dv11) = dot_by_uint64_vec23_mod(d0,1,
					     d1,1,
					     d2,1,
					     d3,1,
					     d4,1,
					     d5,1,
					     d6,1,
					     d7,1,
					     d8,1,
					     d9,1,
					     d10,1,
					     d11,1,
					     d12,1,
					     d13,1,
					     d14,1,
					     d15,1,
					     d16,1,
					     d17,1,
					     d18,1,
					     d19,1,
					     d20,1,
					     d21,1,
					     d22,1,
					     p_expand);
	let (dv21) = dot_by_uint64_vec23_mod(d0,1,
					     d1,2,
					     d2,2**2,
					     d3,2**3,
					     d4,2**4,
					     d5,2**5,
					     d6,2**6,
					     d7,2**7,
					     d8,2**8,
					     d9,2**9,
					     d10,2**10,
					     d11,2**11,
					     d12,2**12,
					     d13,2**13,
					     d14,2**14,
					     d15,2**15,
					     d16,2**16,
					     d17,2**17,
					     d18,2**18,
					     d19,2**19,
					     d20,2**20,
					     d21,2**21,
					     d22,2**22,
					     p_expand);
	let (dv12) = dot_by_uint64_vec23_mod(d0,2**22,
					     d1,2**21,
					     d2,2**20,
					     d3,2**19,
					     d4,2**18,
					     d5,2**17,
					     d6,2**16,
					     d7,2**15,
					     d8,2**14,
					     d9,2**13,
					     d10,2**12,
					     d11,2**11,
					     d12,2**10,
					     d13,2**9,
					     d14,2**8,
					     d15,2**7,
					     d16,2**6,
					     d17,2**5,
					     d18,2**4,
					     d19,2**3,
					     d20,2**2,
					     d21,2,
					     d22,1,
					     p_expand);
	let (dv31) = dot_by_uint64_vec23_mod(d0,1,
					     d1,3,
					     d2,3**2,
					     d3,3**3,
					     d4,3**4,
					     d5,3**5,
					     d6,3**6,
					     d7,3**7,
					     d8,3**8,
					     d9,3**9,
					     d10,3**10,
					     d11,3**11,
					     d12,3**12,
					     d13,3**13,
					     d14,3**14,
					     d15,3**15,
					     d16,3**16,
					     d17,3**17,
					     d18,3**18,
					     d19,3**19,
					     d20,3**20,
					     d21,3**21,
					     d22,3**22,
					     p_expand);
	let (dv13) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,3**21,
					     d2,3**20,
					     d3,3**19,
					     d4,3**18,
					     d5,3**17,
					     d6,3**16,
					     d7,3**15,
					     d8,3**14,
					     d9,3**13,
					     d10,3**12,
					     d11,3**11,
					     d12,3**10,
					     d13,3**9,
					     d14,3**8,
					     d15,3**7,
					     d16,3**6,
					     d17,3**5,
					     d18,3**4,
					     d19,3**3,
					     d20,3**2,
					     d21,3,
					     d22,1,
					     p_expand);
	let (dv32) = dot_by_uint64_vec23_mod(d0,2**22,
					     d1,3*2**21,
					     d2,3**2*2**20,
					     d3,3**3*2**19,
					     d4,3**4*2**18,
					     d5,3**5*2**17,
					     d6,3**6*2**16,
					     d7,3**7*2**15,
					     d8,3**8*2**14,
					     d9,3**9*2**13,
					     d10,3**10*2**12,
					     d11,3**11*2**11,
					     d12,3**12*2**10,
					     d13,3**13*2**9,
					     d14,3**14*2**8,
					     d15,3**15*2**7,
					     d16,3**16*2**6,
					     d17,3**17*2**5,
					     d18,3**18*2**4,
					     d19,3**19*2**3,
					     d20,3**20*2**2,
					     d21,3**21*2,
					     d22,3**22,
					     p_expand);
	let (dv23) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,2*3**21,
					     d2,2**2*3**20,
					     d3,2**3*3**19,
					     d4,2**4*3**18,
					     d5,2**5*3**17,
					     d6,2**6*3**16,
					     d7,2**7*3**15,
					     d8,2**8*3**14,
					     d9,2**9*3**13,
					     d10,2**10*3**12,
					     d11,2**11*3**11,
					     d12,2**12*3**10,
					     d13,2**13*3**9,
					     d14,2**14*3**8,
					     d15,2**15*3**7,
					     d16,2**16*3**6,
					     d17,2**17*3**5,
					     d18,2**18*3**4,
					     d19,2**19*3**3,
					     d20,2**20*3**2,
					     d21,2**21*3,
					     d22,2**22,
					     p_expand);
	let (dv41) = dot_by_uint64_vec23_mod(d0,1,
					     d1,4,
					     d2,4**2,
					     d3,4**3,
					     d4,4**4,
					     d5,4**5,
					     d6,4**6,
					     d7,4**7,
					     d8,4**8,
					     d9,4**9,
					     d10,4**10,
					     d11,4**11,
					     d12,4**12,
					     d13,4**13,
					     d14,4**14,
					     d15,4**15,
					     d16,4**16,
					     d17,4**17,
					     d18,4**18,
					     d19,4**19,
					     d20,4**20,
					     d21,4**21,
					     d22,4**22,
					     p_expand);
	let (dv14) = dot_by_uint64_vec23_mod(d0,4**22,
					     d1,4**21,
					     d2,4**20,
					     d3,4**19,
					     d4,4**18,
					     d5,4**17,
					     d6,4**16,
					     d7,4**15,
					     d8,4**14,
					     d9,4**13,
					     d10,4**12,
					     d11,4**11,
					     d12,4**10,
					     d13,4**9,
					     d14,4**8,
					     d15,4**7,
					     d16,4**6,
					     d17,4**5,
					     d18,4**4,
					     d19,4**3,
					     d20,4**2,
					     d21,4,
					     d22,1,
					     p_expand);
	let (dv43) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,4*3**21,
					     d2,4**2*3**20,
					     d3,4**3*3**19,
					     d4,4**4*3**18,
					     d5,4**5*3**17,
					     d6,4**6*3**16,
					     d7,4**7*3**15,
					     d8,4**8*3**14,
					     d9,4**9*3**13,
					     d10,4**10*3**12,
					     d11,4**11*3**11,
					     d12,4**12*3**10,
					     d13,4**13*3**9,
					     d14,4**14*3**8,
					     d15,4**15*3**7,
					     d16,4**16*3**6,
					     d17,4**17*3**5,
					     d18,4**18*3**4,
					     d19,4**19*3**3,
					     d20,4**20*3**2,
					     d21,4**21*3,
					     d22,4**22,
					     p_expand);
	let (dv34) = dot_by_uint64_vec23_mod(d0,4**22,
					     d1,3*4**21,
					     d2,3**2*4**20,
					     d3,3**3*4**19,
					     d4,3**4*4**18,
					     d5,3**5*4**17,
					     d6,3**6*4**16,
					     d7,3**7*4**15,
					     d8,3**8*4**14,
					     d9,3**9*4**13,
					     d10,3**10*4**12,
					     d11,3**11*4**11,
					     d12,3**12*4**10,
					     d13,3**13*4**9,
					     d14,3**14*4**8,
					     d15,3**15*4**7,
					     d16,3**16*4**6,
					     d17,3**17*4**5,
					     d18,3**18*4**4,
					     d19,3**19*4**3,
					     d20,3**20*4**2,
					     d21,3**21*4,
					     d22,3**22,
					     p_expand);
	let (dv51) = dot_by_uint64_vec23_mod(d0,1,
					     d1,5,
					     d2,5**2,
					     d3,5**3,
					     d4,5**4,
					     d5,5**5,
					     d6,5**6,
					     d7,5**7,
					     d8,5**8,
					     d9,5**9,
					     d10,5**10,
					     d11,5**11,
					     d12,5**12,
					     d13,5**13,
					     d14,5**14,
					     d15,5**15,
					     d16,5**16,
					     d17,5**17,
					     d18,5**18,
					     d19,5**19,
					     d20,5**20,
					     d21,5**21,
					     d22,5**22,
					     p_expand);
	let (dv15) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,5**21,
					     d2,5**20,
					     d3,5**19,
					     d4,5**18,
					     d5,5**17,
					     d6,5**16,
					     d7,5**15,
					     d8,5**14,
					     d9,5**13,
					     d10,5**12,
					     d11,5**11,
					     d12,5**10,
					     d13,5**9,
					     d14,5**8,
					     d15,5**7,
					     d16,5**6,
					     d17,5**5,
					     d18,5**4,
					     d19,5**3,
					     d20,5**2,
					     d21,5,
					     d22,1,
					     p_expand);
	let (dv52) = dot_by_uint64_vec23_mod(d0,2**22,
					     d1,5*2**21,
					     d2,5**2*2**20,
					     d3,5**3*2**19,
					     d4,5**4*2**18,
					     d5,5**5*2**17,
					     d6,5**6*2**16,
					     d7,5**7*2**15,
					     d8,5**8*2**14,
					     d9,5**9*2**13,
					     d10,5**10*2**12,
					     d11,5**11*2**11,
					     d12,5**12*2**10,
					     d13,5**13*2**9,
					     d14,5**14*2**8,
					     d15,5**15*2**7,
					     d16,5**16*2**6,
					     d17,5**17*2**5,
					     d18,5**18*2**4,
					     d19,5**19*2**3,
					     d20,5**20*2**2,
					     d21,5**21*2,
					     d22,5**22,
					     p_expand);
	let (dv25) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,2*5**21,
					     d2,2**2*5**20,
					     d3,2**3*5**19,
					     d4,2**4*5**18,
					     d5,2**5*5**17,
					     d6,2**6*5**16,
					     d7,2**7*5**15,
					     d8,2**8*5**14,
					     d9,2**9*5**13,
					     d10,2**10*5**12,
					     d11,2**11*5**11,
					     d12,2**12*5**10,
					     d13,2**13*5**9,
					     d14,2**14*5**8,
					     d15,2**15*5**7,
					     d16,2**16*5**6,
					     d17,2**17*5**5,
					     d18,2**18*5**4,
					     d19,2**19*5**3,
					     d20,2**20*5**2,
					     d21,2**21*5,
					     d22,2**22,
					     p_expand);
	let (dv53) = dot_by_uint64_vec23_mod(d0,3**22,
					     d1,5*3**21,
					     d2,5**2*3**20,
					     d3,5**3*3**19,
					     d4,5**4*3**18,
					     d5,5**5*3**17,
					     d6,5**6*3**16,
					     d7,5**7*3**15,
					     d8,5**8*3**14,
					     d9,5**9*3**13,
					     d10,5**10*3**12,
					     d11,5**11*3**11,
					     d12,5**12*3**10,
					     d13,5**13*3**9,
					     d14,5**14*3**8,
					     d15,5**15*3**7,
					     d16,5**16*3**6,
					     d17,5**17*3**5,
					     d18,5**18*3**4,
					     d19,5**19*3**3,
					     d20,5**20*3**2,
					     d21,5**21*3,
					     d22,5**22,
					     p_expand);
	let (dv35) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,3*5**21,
					     d2,3**2*5**20,
					     d3,3**3*5**19,
					     d4,3**4*5**18,
					     d5,3**5*5**17,
					     d6,3**6*5**16,
					     d7,3**7*5**15,
					     d8,3**8*5**14,
					     d9,3**9*5**13,
					     d10,3**10*5**12,
					     d11,3**11*5**11,
					     d12,3**12*5**10,
					     d13,3**13*5**9,
					     d14,3**14*5**8,
					     d15,3**15*5**7,
					     d16,3**16*5**6,
					     d17,3**17*5**5,
					     d18,3**18*5**4,
					     d19,3**19*5**3,
					     d20,3**20*5**2,
					     d21,3**21*5,
					     d22,3**22,
					     p_expand);
	let (dv54) = dot_by_uint64_vec23_mod(d0,4**22,
					     d1,5*4**21,
					     d2,5**2*4**20,
					     d3,5**3*4**19,
					     d4,5**4*4**18,
					     d5,5**5*4**17,
					     d6,5**6*4**16,
					     d7,5**7*4**15,
					     d8,5**8*4**14,
					     d9,5**9*4**13,
					     d10,5**10*4**12,
					     d11,5**11*4**11,
					     d12,5**12*4**10,
					     d13,5**13*4**9,
					     d14,5**14*4**8,
					     d15,5**15*4**7,
					     d16,5**16*4**6,
					     d17,5**17*4**5,
					     d18,5**18*4**4,
					     d19,5**19*4**3,
					     d20,5**20*4**2,
					     d21,5**21*4,
					     d22,5**22,
					     p_expand);
	let (dv45) = dot_by_uint64_vec23_mod(d0,5**22,
					     d1,4*5**21,
					     d2,4**2*5**20,
					     d3,4**3*5**19,
					     d4,4**4*5**18,
					     d5,4**5*5**17,
					     d6,4**6*5**16,
					     d7,4**7*5**15,
					     d8,4**8*5**14,
					     d9,4**9*5**13,
					     d10,4**10*5**12,
					     d11,4**11*5**11,
					     d12,4**12*5**10,
					     d13,4**13*5**9,
					     d14,4**14*5**8,
					     d15,4**15*5**7,
					     d16,4**16*5**6,
					     d17,4**17*5**5,
					     d18,4**18*5**4,
					     d19,4**19*5**3,
					     d20,4**20*5**2,
					     d21,4**21*5,
					     d22,4**22,
					     p_expand);
	let (dv61) = dot_by_uint64_vec23_mod(d0,1,
					     d1,6,
					     d2,6**2,
					     d3,6**3,
					     d4,6**4,
					     d5,6**5,
					     d6,6**6,
					     d7,6**7,
					     d8,6**8,
					     d9,6**9,
					     d10,6**10,
					     d11,6**11,
					     d12,6**12,
					     d13,6**13,
					     d14,6**14,
					     d15,6**15,
					     d16,6**16,
					     d17,6**17,
					     d18,6**18,
					     d19,6**19,
					     d20,6**20,
					     d21,6**21,
					     d22,6**22,
					     p_expand);
	let (dv16) = dot_by_uint64_vec23_mod(d0,6**22,
					     d1,6**21,
					     d2,6**20,
					     d3,6**19,
					     d4,6**18,
					     d5,6**17,
					     d6,6**16,
					     d7,6**15,
					     d8,6**14,
					     d9,6**13,
					     d10,6**12,
					     d11,6**11,
					     d12,6**10,
					     d13,6**9,
					     d14,6**8,
					     d15,6**7,
					     d16,6**6,
					     d17,6**5,
					     d18,6**4,
					     d19,6**3,
					     d20,6**2,
					     d21,6,
					     d22,1,
					     p_expand);
        

        let (dv01b)=fq_lib.square2(av01);
        assert dv01 = dv01b;
        let (dv10b)=fq_lib.square2(av10);
        assert dv10 = dv10b;
        let (dv11b)=fq_lib.square2(av11);
        assert dv11 = dv11b;
        let (dv21b)=fq_lib.square2(av21);
        assert dv21 = dv21b;
        let (dv12b)=fq_lib.square2(av12);
        assert dv12 = dv12b;
        let (dv31b)=fq_lib.square2(av31);
        assert dv31 = dv31b;
        let (dv13b)=fq_lib.square2(av13);
        assert dv13 = dv13b;
        let (dv32b)=fq_lib.square2(av32);
        assert dv32 = dv32b;
        let (dv23b)=fq_lib.square2(av23);
        assert dv23 = dv23b;
        let (dv41b)=fq_lib.square2(av41);
        assert dv41 = dv41b;
        let (dv14b)=fq_lib.square2(av14);
        assert dv14 = dv14b;
        let (dv43b)=fq_lib.square2(av43);
        assert dv43 = dv43b;
        let (dv34b)=fq_lib.square2(av34);
        assert dv34 = dv34b;
        let (dv51b)=fq_lib.square2(av51);
        assert dv51 = dv51b;
        let (dv15b)=fq_lib.square2(av15);
        assert dv15 = dv15b;
        let (dv52b)=fq_lib.square2(av52);
        assert dv52 = dv52b;
        let (dv25b)=fq_lib.square2(av25);
        assert dv25 = dv25b;
        let (dv53b)=fq_lib.square2(av53);
        assert dv53 = dv53b;
        let (dv35b)=fq_lib.square2(av35);
        assert dv35 = dv35b;
        let (dv54b)=fq_lib.square2(av54);
        assert dv54 = dv54b;
        let (dv45b)=fq_lib.square2(av45);
        assert dv45 = dv45b;
        let (dv61b)=fq_lib.square2(av61);
        assert dv61 = dv61b;
        let (dv16b)=fq_lib.square2(av16);
        assert dv16 = dv16b;
	
        // Reducing the results modulo the irreducible polynomial
        // Note that the order in which _aux_polynomial_reduction is called is important here
        let (d10: Uint384, d16: Uint384) = _aux_polynomial_reduction(d22, d10, d16);
        let (d9: Uint384, d15: Uint384) = _aux_polynomial_reduction(d21, d9, d15);
        let (d8: Uint384, d14: Uint384) = _aux_polynomial_reduction(d20, d8, d14);
        let (d7: Uint384, d13: Uint384) = _aux_polynomial_reduction(d19, d7, d13);
        let (d6: Uint384, d12: Uint384) = _aux_polynomial_reduction(d18, d6, d12);
        let (d5: Uint384, d11: Uint384) = _aux_polynomial_reduction(d17, d5, d11);
        let (d4: Uint384, d10: Uint384) = _aux_polynomial_reduction(d16, d4, d10);
        let (d3: Uint384, d9: Uint384) = _aux_polynomial_reduction(d15, d3, d9);
        let (d2: Uint384, d8: Uint384) = _aux_polynomial_reduction(d14, d2, d8);
        let (d1: Uint384, d7: Uint384) = _aux_polynomial_reduction(d13, d1, d7);
        let (d0: Uint384, d6: Uint384) = _aux_polynomial_reduction(d12, d0, d6);

        return (FQ12(d0, d1, d2, d3, d4, d5, d6, d7, d8, d9, d10, d11),);
    }

    func eq{range_check_ptr}(x: FQ12, y: FQ12) -> (bool: felt) {
        let (is_e0_eq) = uint384_lib.eq(x.e0, y.e0);
        if (is_e0_eq == 0) {
            return (0,);
        }
        let (is_e1_eq) = uint384_lib.eq(x.e1, y.e1);
        if (is_e1_eq == 0) {
            return (0,);
        }
        let (is_e2_eq) = uint384_lib.eq(x.e2, y.e2);
        if (is_e2_eq == 0) {
            return (0,);
        }
        let (is_e3_eq) = uint384_lib.eq(x.e3, y.e3);
        if (is_e3_eq == 0) {
            return (0,);
        }
        let (is_e4_eq) = uint384_lib.eq(x.e4, y.e4);
        if (is_e4_eq == 0) {
            return (0,);
        }
        let (is_e5_eq) = uint384_lib.eq(x.e5, y.e5);
        if (is_e5_eq == 0) {
            return (0,);
        }
        let (is_e6_eq) = uint384_lib.eq(x.e6, y.e6);
        if (is_e6_eq == 0) {
            return (0,);
        }
        let (is_e7_eq) = uint384_lib.eq(x.e7, y.e7);
        if (is_e7_eq == 0) {
            return (0,);
        }
        let (is_e8_eq) = uint384_lib.eq(x.e8, y.e8);
        if (is_e8_eq == 0) {
            return (0,);
        }
        let (is_e9_eq) = uint384_lib.eq(x.e9, y.e9);
        if (is_e9_eq == 0) {
            return (0,);
        }
        let (is_e10_eq) = uint384_lib.eq(x.e10, y.e10);
        if (is_e10_eq == 0) {
            return (0,);
        }
        let (is_e11_eq) = uint384_lib.eq(x.e11, y.e11);
        if (is_e11_eq == 0) {
            return (0,);
        }
        return (1,);
    }

    func zero() -> (zero: FQ12) {
        return (
            zero=FQ12(
            e0=Uint384(d0=0, d1=0, d2=0),
            e1=Uint384(d0=0, d1=0, d2=0),
            e2=Uint384(d0=0, d1=0, d2=0),
            e3=Uint384(d0=0, d1=0, d2=0),
            e4=Uint384(d0=0, d1=0, d2=0),
            e5=Uint384(d0=0, d1=0, d2=0),
            e6=Uint384(d0=0, d1=0, d2=0),
            e7=Uint384(d0=0, d1=0, d2=0),
            e8=Uint384(d0=0, d1=0, d2=0),
            e9=Uint384(d0=0, d1=0, d2=0),
            e10=Uint384(d0=0, d1=0, d2=0),
            e11=Uint384(d0=0, d1=0, d2=0)),
        );
    }

    func one() -> (zero: FQ12) {
        return (
            zero=FQ12(
            e0=Uint384(d0=1, d1=0, d2=0),
            e1=Uint384(d0=0, d1=0, d2=0),
            e2=Uint384(d0=0, d1=0, d2=0),
            e3=Uint384(d0=0, d1=0, d2=0),
            e4=Uint384(d0=0, d1=0, d2=0),
            e5=Uint384(d0=0, d1=0, d2=0),
            e6=Uint384(d0=0, d1=0, d2=0),
            e7=Uint384(d0=0, d1=0, d2=0),
            e8=Uint384(d0=0, d1=0, d2=0),
            e9=Uint384(d0=0, d1=0, d2=0),
            e10=Uint384(d0=0, d1=0, d2=0),
            e11=Uint384(d0=0, d1=0, d2=0)),
        );
    }

    // small utility to turn 128 bit number to an fq12
    // do not input number >= 128 bits
    func bit_128_to_fq12(input: felt) -> (res: FQ12) {
        return (
            res=FQ12(
            e0=Uint384(d0=input, d1=0, d2=0),
            e1=Uint384(d0=0, d1=0, d2=0),
            e2=Uint384(d0=0, d1=0, d2=0),
            e3=Uint384(d0=0, d1=0, d2=0),
            e4=Uint384(d0=0, d1=0, d2=0),
            e5=Uint384(d0=0, d1=0, d2=0),
            e6=Uint384(d0=0, d1=0, d2=0),
            e7=Uint384(d0=0, d1=0, d2=0),
            e8=Uint384(d0=0, d1=0, d2=0),
            e9=Uint384(d0=0, d1=0, d2=0),
            e10=Uint384(d0=0, d1=0, d2=0),
            e11=Uint384(d0=0, d1=0, d2=0)),
        );
    }
    
    
    // scalar mul by Uint384
    // st=8550, mh=240, rc=993
    func scalar_mul_uint384{range_check_ptr}(x: Uint384, y: FQ12) -> (
        product: FQ12
    ) {
        alloc_locals;
        let (p_expand:Uint384_expand)= get_modulus_expand();
        let (x_expand:Uint384_expand)= uint384_lib.expand(x);
        let (e0: Uint384) = field_arithmetic.mul_expanded(y.e0, x_expand, p_expand);
        let (e1: Uint384) = field_arithmetic.mul_expanded(y.e1, x_expand, p_expand);
        let (e2: Uint384) = field_arithmetic.mul_expanded(y.e2, x_expand, p_expand);
        let (e3: Uint384) = field_arithmetic.mul_expanded(y.e3, x_expand, p_expand);
        let (e4: Uint384) = field_arithmetic.mul_expanded(y.e4, x_expand, p_expand);
        let (e5: Uint384) = field_arithmetic.mul_expanded(y.e5, x_expand, p_expand);
        let (e6: Uint384) = field_arithmetic.mul_expanded(y.e6, x_expand, p_expand);
        let (e7: Uint384) = field_arithmetic.mul_expanded(y.e7, x_expand, p_expand);
        let (e8: Uint384) = field_arithmetic.mul_expanded(y.e8, x_expand, p_expand);
        let (e9: Uint384) = field_arithmetic.mul_expanded(y.e9, x_expand, p_expand);
        let (e10: Uint384) = field_arithmetic.mul_expanded(y.e10, x_expand, p_expand);
        let (e11: Uint384) = field_arithmetic.mul_expanded(y.e11, x_expand, p_expand);
        let res = FQ12(e0, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11);
        return (res,);
    }

    // TODO: test
    // TODO: Should the exponent go further than 768 bits?
    // Computes (a**exp). Uses the fast exponentiation algorithm
    // pow(a,0) is now 1
    func pow{range_check_ptr}(a: FQ12, exp: Uint768) -> (res: FQ12) {
        alloc_locals;
        let (is_exp_zero) = uint384_extension_lib.eq(exp, Uint768(0, 0, 0, 0, 0, 0));

        if (is_exp_zero == 1) {
            let (one_fq12: FQ12) = one();
            return (one_fq12,);
        }

        let (is_exp_one) = uint384_extension_lib.eq(exp, Uint768(1, 0, 0, 0, 0, 0));
        if (is_exp_one == 1) {
            return (a,);
        }

        let (exp_div_2, remainder) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384(
            exp, Uint384(2, 0, 0)
        );
        let (is_remainder_zero) = uint384_lib.eq(remainder, Uint384(0, 0, 0));

        if (is_remainder_zero == 1) {
            // NOTE: Code is repeated in the if-else to avoid declaring a_squared as a local variable
            let (a_squared: FQ12) = square(a);
            let (res: FQ12) = pow(a_squared, exp_div_2);
            return (res,);
        } else {
            let (a_squared: FQ12) = square(a);
            let (res: FQ12) = pow(a_squared, exp_div_2);
            let (res_mul: FQ12) = mul(a, res);
            return (res_mul,);
        }
    }

    // Finds and FQ12 x such that a * x = 1
    func inverse{range_check_ptr}(a: FQ12) -> (res: FQ12) {
        alloc_locals;

        let (one_fq12: FQ12) = one();
        let (is_a_one) = eq(a, one_fq12);
        if (is_a_one == 1) {
            return (a,);
        }

        local a_inverse: FQ12;
        let (field_modulus: Uint384) = get_modulus();

        %{
            print("findme0")
            def split(num: int, num_bits_shift : int = 128, length: int = 3):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift 
                return tuple(a)

            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            # TODO: Do this with a loop?
            e0 = pack(ids.a.e0)
            e1 = pack(ids.a.e1)
            e2 = pack(ids.a.e2)
            e3 = pack(ids.a.e3)
            e4 = pack(ids.a.e4)
            e5 = pack(ids.a.e5)
            e6 = pack(ids.a.e6)
            e7 = pack(ids.a.e7)
            e8 = pack(ids.a.e8)
            e9 = pack(ids.a.e9)
            e10 = pack(ids.a.e10)
            e11 = pack(ids.a.e11)
            coeffs_of_a = [e0, e1 , e2, e3, e4, e5, e6, e7, e8, e9, e10, e11]
            print("findme1")
            field_modulus = pack(ids.field_modulus)

            print("findme2")
            # Adapted from py_ecc: TODO: add link


            # Utility methods for polynomial math
            # Given the list of the coefficients of a polynomial p, 
            # finds the degree of p
            def deg(list_of_polynomial_coefficients):
                d = len(list_of_polynomial_coefficients) - 1
                while list_of_polynomial_coefficients[d] == 0 and d:
                    d -= 1
                return d
                
            # Computes the division without residue of a polynomial a by another polynomial b
            # a and b are given as lists of coefficients
            def optimized_poly_rounded_div(a, b):
                dega = deg(a)
                degb = deg(b)
                temp = [x for x in a]
                o = [0 for x in a]
                for i in range(dega - degb, -1, -1):
                    o[i] = int(o[i] + temp[degb + i] * pow(int(b[degb]), -1, field_modulus))
                    for c in range(degb + 1):
                        temp[c + i] = (temp[c + i] - o[c])
                return [x % field_modulus for x in o[:deg(o) + 1]]


            # Extended euclidean algorithm used to find the modular inverse
            # of a polynomial given as a list of coefficients.
            # Returns the inverse as a list of coefficients
            def inv(coeffs_of_a):
                lm, hm = [1] + [0] * 12, [0] * 13
                low, high = (
                    coeffs_of_a + [0],
                    [2, 0, 0, 0, 0, 0, -2, 0, 0, 0, 0, 0] + [1] # modulus coefficients
                )
                print("findme21")

                while deg(low):
                    print("findme22")
                    r = optimized_poly_rounded_div(high, low)
                    r += [0] * (13 - len(r))
                    nm = [x for x in hm]
                    new = [x for x in high]
                    for i in range(13):
                        for j in range(13 - i):
                            nm[i + j] -= lm[i] * int(r[j])
                            new[i + j] -= low[i] * r[j]
                    nm = [x % field_modulus for x in nm]
                    new = [int(x) % field_modulus for x in new]
                    lm, low, hm, high = nm, new, lm, low
                print("findme23", low)
                if low[0] % field_modulus == 0:
                    inverse_of_low0 = 1
                else:
                    inverse_of_low0 = pow(low[0], -1, field_modulus) 
                print("findme24")
                return [(coeff*inverse_of_low0) % field_modulus for coeff in lm[:12]]
                
            res = inv(coeffs_of_a)    
            print("findme3", res)
            res = [split(coeff) for coeff in res]

            ids.a_inverse.e0.d0 = res[0][0]
            ids.a_inverse.e0.d1 = res[0][1]
            ids.a_inverse.e0.d2 = res[0][2]

            ids.a_inverse.e1.d0 = res[1][0]
            ids.a_inverse.e1.d1 = res[1][1]
            ids.a_inverse.e1.d2 = res[1][2]

            ids.a_inverse.e2.d0 = res[2][0]
            ids.a_inverse.e2.d1 = res[2][1]
            ids.a_inverse.e2.d2 = res[2][2]

            ids.a_inverse.e3.d0 = res[3][0]
            ids.a_inverse.e3.d1 = res[3][1]
            ids.a_inverse.e3.d2 = res[3][2]

            ids.a_inverse.e4.d0 = res[4][0]
            ids.a_inverse.e4.d1 = res[4][1]
            ids.a_inverse.e4.d2 = res[4][2]

            ids.a_inverse.e5.d0 = res[5][0]
            ids.a_inverse.e5.d1 = res[5][1]
            ids.a_inverse.e5.d2 = res[5][2]

            ids.a_inverse.e6.d0 = res[6][0]
            ids.a_inverse.e6.d1 = res[6][1]
            ids.a_inverse.e6.d2 = res[6][2]

            ids.a_inverse.e7.d0 = res[7][0]
            ids.a_inverse.e7.d1 = res[7][1]
            ids.a_inverse.e7.d2 = res[7][2]

            ids.a_inverse.e8.d0 = res[8][0]
            ids.a_inverse.e8.d1 = res[8][1]
            ids.a_inverse.e8.d2 = res[8][2]

            ids.a_inverse.e9.d0 = res[9][0]
            ids.a_inverse.e9.d1 = res[9][1]
            ids.a_inverse.e9.d2 = res[9][2]

            ids.a_inverse.e10.d0 = res[10][0]
            ids.a_inverse.e10.d1 = res[10][1]
            ids.a_inverse.e10.d2 = res[10][2]

            ids.a_inverse.e11.d0 = res[11][0]
            ids.a_inverse.e11.d1 = res[11][1]
            ids.a_inverse.e11.d2 = res[11][2]
            print("findme4")
        %}
	check(a_inverse);

        let (a_inverse_times_a: FQ12) = mul(a_inverse, a);
        let (one_fq12: FQ12) = one();
        let (is_one) = eq(a_inverse_times_a, one_fq12);
        assert is_one = 1;
        return (a_inverse,);
    }

    func mul_three_terms{range_check_ptr}(
        x: FQ12, y: FQ12, z: FQ12
    ) -> (res: FQ12) {
        let (x_times_y: FQ12) = mul(x, y);
        let (res: FQ12) = mul(x_times_y, z);
        return (res,);
    }
}


func _aux_polynomial_reduction{range_check_ptr}(
    coeff_to_reduce: Uint384, first_coef: Uint384, second_coef: Uint384
) -> (new_first_coef: Uint384, new_second_coef: Uint384) {
    // TODO: some way to avoid using local variables? (to improve efficiency)
    alloc_locals;
    let (p_expand:Uint384_expand)=get_modulus_expand();
    let (twice_coeff_to_reduce: Uint384) = fq_lib.add_no_input_check(coeff_to_reduce,coeff_to_reduce);
    let (first_coef: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(first_coef, twice_coeff_to_reduce, p_expand);
    let (second_coef: Uint384) = fq_lib.add_no_input_check(second_coef, twice_coeff_to_reduce);
    return (first_coef, second_coef);
}
