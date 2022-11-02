from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.fq_new import fq_lib
from lib.curve_new import fq2_c0, fq2_c1, get_modulus

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

    //changed scalar mul to allow for only one expansion of the modulus into a Uint384_expand, updated range_check_ptr
    func scalar_mul{range_check_ptr}(x: felt, y: FQ12) -> (
        product: FQ12
    ) {
        alloc_locals;
        assert [range_check_ptr] = x;
        let range_check_ptr = range_check_ptr + 1;
        let p_expand:Uint384_expand= get_modulus_expand();
        let (low, high)=uint384_lib.split_64(x);
        let (packed_expand: Uint384_expand) = Uint384_expand(low*HALF_SHIFT, scalar, high, 0, 0, 0, 0);
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


    //changed mul so that it would only expand the modulus once. 
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

    func square{range_check_ptr}(a: FQ12) -> (square: FQ12) {
        alloc_locals;
        let (p_expand:Uint384_expand) = get_modulus_expand();
        // d0
        let (d0: Uint384) = field_arithmetic.square(a.e0, a.e0, p_expand);

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
    let (local twice_coeff_to_reduce: Uint384) = fq_lib.scalar_mul4(2, coeff_to_reduce);
    let (first_coef: Uint384) = fq_lib.sub1(first_coef, twice_coeff_to_reduce);
    let (second_coef: Uint384) = fq_lib.add(second_coef, twice_coeff_to_reduce);
    return (first_coef, second_coef);
}
