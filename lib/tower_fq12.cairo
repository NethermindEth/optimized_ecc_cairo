from lib.uint384 import Uint384, Uint384_expand, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic_new import field_arithmetic
from lib.curve_new import get_modulus, get_modulus_expand, get_r_squared, get_p_minus_one, get_p_minus_one_div_2, get_twice_p
from lib.fq_new import fq_lib
from lib.fq2_new import FQ2, fq2_lib
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
from starkware.cairo.common.math_cmp import is_not_zero, is_nn, is_le

//This file implements F_{p^12} as a tower of extensions of degree 2, 3 and 2 respectively.
//The successive extensions can be described as follows:
//F_{p^2} ~ F_p[X]/(X^2+1) ~ F_p[u] this is FQ2 as we have it
//F_{p^6} ~ F_{p^2}[Y]/(Y^3-(u+1)) ~ F_{p^2}[v]
//F_{p^12} ~ F_{p^6}[Z]/(Z^2-v) ~ F_{p^6}[w]

struct FQ6 {
    f0: FQ2,
    f1: FQ2,
    f2: FQ2,
}

struct FQ12 {
    g0: FQ6,
    g1: FQ6,
}

namespace fq12_lib{
    
    //We need to be able to add, substract and multiply FQ6 elements. Start with addition.
    func add_fq6{range_check_ptr}(x:FQ6, y:FQ6)->(sum:FQ6){
        let (p_expand:Uint384_expand) = get_modulus_expand();
        let (a0: Uint384) = field_arithmetic.add(x.f0.e0, y.f0.e0, p_expand);
        let (a1: Uint384) = field_arithmetic.add(x.f0.e1, y.f0.e1, p_expand);
        let (a2: Uint384) = field_arithmetic.add(x.f1.e0, y.f1.e0, p_expand);
        let (a3: Uint384) = field_arithmetic.add(x.f1.e1, y.f1.e1, p_expand);
        let (a4: Uint384) = field_arithmetic.add(x.f2.e0, y.f2.e0, p_expand);
        let (a5: Uint384) = field_arithmetic.add(x.f2.e1, y.f2.e1, p_expand);
        return(sum=FQ6(FQ2(a0, a1), FQ2(a2,a3), FQ2(a4, a5)),);
    }

    //will write it in a way that we don't expand the modulus many times at some later point.
    func sub_fq6{range_check_ptr}(x:FQ6, y:FQ6)->(sub:FQ6){
        let (f0: FQ2) =  fq2_lib.sub(x.f0, y.f0);
        let (f1: FQ2) =  fq2_lib.sub(x.f1, y.f1);
        let (f2: FQ2) =  fq2_lib.sub(x.f2, y.f2);
        return (sub = FQ6(f0,f1,f2),);
    }
    
    //Computes x-y-z
    func sub_three_terms_fq6{range_check_ptr}(x:FQ6, y:FQ6, z:FQ6)->(sub:FQ6){
        let (addzy: FQ6) = add_fq6(y, z);
        let (sub3 : FQ6) = sub_fq6(x, addzy);
        return (sub = sub3,);
    }

    //We use Toom-Cook3 for multiplication in FQ6
    func mul_fq6{range_check_ptr}(x:FQ6, y:FQ6)->(prod:FQ6){

    }

    //Implement multiplication as a form of applying Karatsuba by using TC3 over FQ6, and using 
    //the particularity of multiplication by v in FQ6, and by (u+1) in FQ2. 
    func mul_fq12{range_check_ptr}(x:FQ12, y:FQ12)->(prod:FQ12){
        let (mul_g0 : FQ6) = mul_fq6(x.g0, y.g0);
        let (mul_g1 : FQ6) = mul_fq6(x.g1, y.g1);
        let (x_g0_plus_g1:FQ6) = add_fq6(x.g0, x.g1);
        let (y_g0_plus_g1:FQ6) = add_fq6(y.g0, y.g1);
        let (mul_g0_plus_g1 : FQ6) = mul_fq6(x_g0_plus_g1, y_g0_plus_g1);

        //we obtain the second term as in Karatsuba
        let (second_term : fQ6) = sub_three_terms_fq6(mul_g0_plus_g1, mul_g0, mul_g1);

        //The multiplication can be seen as (xg0+xg1 w)(yg0+yg1 w) = (xg0*yg0+ v*xg1*yg1) + w (xg0*yg1+xg1*yg0)
        //We have now computed the second term, as well as xg0*yg0 and xg1*yg1
        //We are missing v*xg1*yg1. The effect of multiplying an FQ6 element of the form c1+c2v+c3v^2 by v is 
        //given by (c1, c2, c3) -> ((u+1)c3 ,c1, c2). Now the effect of multiplying the FQ2 element c3 = d1+d2*u by (u+1)
        //is given by (d1, d2)--> (d1 - d2, d1 + d2). 

        //d1-d2
        let (first_coeff_mul_by_u: Uint384) = fq2_lib.sub(mul_g1.f2.e0, mul_g1.f2.e1);
        //d1+d2
        let (second_coeff_mul_by_u: Uint384) = fq2_lib.add(mul_g1.f2.e0, mul_g1.f2.e1);

        //(c1, c2, c3) -> ((u+1)c3 ,c1, c2)
        let (first_coeff_mul_by_v: FQ2) =  FQ2(first_coeff_mul_by_u, second_coeff_mul_by_u);
        let (v_times_mul_g1 : FQ6) = FQ6(first_coeff_mul_by_v, mul_g1.f0, mul_g1.f1);

        //we now have the first term as well
        let (first_term : FQ6) = add_fq6(mul_g0, v_times_mul_g1);
        return(prod=FQ12(first_term, second_term),);
    }

    //will write it in a way that we don't expand the modulus twice at some later point.
    func add_fq12{range_check_ptr}(x:FQ12, y:FQ12)->(sum:FQ12){
        let (g0:FQ6) = add_fq6(x.g0, y.g0);
        let (g1:FQ6) = add_fq6(x.g1, y.g1);
        return (sum = FQ12(g0,g1),);
    }

}