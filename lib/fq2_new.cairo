from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.math_cmp import is_not_zero
from starkware.cairo.common.bitwise import bitwise_and, bitwise_or
from lib.uint384 import Uint384, Uint384_expand, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from lib.field_arithmetic_new import field_arithmetic
from lib.fq_new import fq_lib
from lib.curve_new import fq2_c0, fq2_c1, get_modulus, get_modulus_expand, get_2_inverse, get_2_inverse_exp

struct FQ2 {
    e0: Uint384,
    e1: Uint384,
}

namespace fq2_lib {
    // steps=1167, memory_holes=40, range_check_builtin=122
    func add{range_check_ptr}(x: FQ2, y: FQ2) -> (sum_mod: FQ2) {
        // TODO: check why these alloc_locals need to be used
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (e0: Uint384) = field_arithmetic.add(x.e0, y.e0, p_expand);
        let (e1: Uint384) = field_arithmetic.add(x.e1, y.e1, p_expand);

        return (FQ2(e0=e0, e1=e1),);
    }

    // steps=2401, memory_holes=160, range_check_builtin=254
    func sub{range_check_ptr}(x: FQ2, y: FQ2) -> (sum_mod: FQ2) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (_, x_e0_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e0, p_expand);
        let (_, x_e1_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(x.e1, p_expand);
        let (_, y_e0_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e0, p_expand);
        let (_, y_e1_red: Uint384) = uint384_lib.unsigned_div_rem_expanded(y.e1, p_expand);
        let (e0: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e0_red, y_e0_red, p_expand);
        let (e1: Uint384) = field_arithmetic.sub_reduced_a_and_reduced_b(x_e1_red, y_e1_red, p_expand);
        return (FQ2(e0=e0, e1=e1),);
    }

    // Multiplies an element of FQ2 by an element of FQ
    // steps=1510, memory_holes=40, range_check_builtin=173
    func scalar_mul{range_check_ptr}(x: Uint384, y: FQ2) -> (
        product: FQ2
    ) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
	let (x_exp) = uint384_lib.expand(x);
        let (e0: Uint384) = field_arithmetic.mul_expanded(y.e0, x_exp, p_expand);
        let (e1: Uint384) = field_arithmetic.mul_expanded(y.e1, x_exp, p_expand);

        return (FQ2(e0=e0, e1=e1),);
    }

    // steps=3951, memory_holes=140, range_check_builtin=463
    func mul{range_check_ptr}(a: FQ2, b: FQ2) -> (product: FQ2) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (first_term: Uint384) = field_arithmetic.mul(a.e0, b.e0 , p_expand);
        let (b_0_1: Uint384) = field_arithmetic.mul(a.e0, b.e1, p_expand);
        let (b_1_0: Uint384) = field_arithmetic.mul(a.e1, b.e0, p_expand);
        let (second_term: Uint384) = fq_lib.add_no_input_check(b_0_1, b_1_0);
        let (third_term: Uint384) = field_arithmetic.mul(a.e1, b.e1,p_expand);

        // Using the irreducible polynomial x**2 + 1 as modulus, we get that
        // x**2 = -1, so the term `a.e1 * b.e1 * x**2` becomes
        // `- a.e1 * b.e1` (always reducing mod p). This way the first term of
        // the multiplicaiton is `a.e0 * b.e0 - a.e1 * b.e1`
        
        //here I think we can assume first_term and third_term are reduced
        let (first_term) = field_arithmetic.sub_reduced_a_and_reduced_b(first_term, third_term, p_expand);

        return (FQ2(e0=first_term, e1=second_term),);
    }

    // Uses Karatsuba multiplication
    // steps=3391, memory_holes=120, range_check_builtin=384
    func mul_kar{range_check_ptr}(a: FQ2, b: FQ2) -> (product: FQ2) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (first_term: Uint384) = field_arithmetic.mul(a.e0, b.e0, p_expand);
        let (third_term: Uint384) = field_arithmetic.mul(a.e1, b.e1, p_expand);

	let (sum_a: Uint384,_) = uint384_lib.add(a.e0,a.e1);
	let (sum_b: Uint384,_) = uint384_lib.add(b.e0,b.e1);
	let (second_term: Uint384) = field_arithmetic.mul(sum_a, sum_b, p_expand);

	//field_arithmetic.mul always returns reduced values
	let (second_term: Uint384) = fq_lib.sub_three_terms_no_input_check(second_term,first_term,third_term);
	
        let (first_term) = field_arithmetic.sub_reduced_a_and_reduced_b(first_term, third_term, p_expand);

        return (FQ2(e0=first_term, e1=second_term),);
    }

    // Find b such that b*a = 1 in FQ2
    // First the inverse is computed in a hint, and then verified in Cairo
    // The formulas for the inverse come from writing a = e0 + e1 x and a_inverse = d0 + d1x,
    // multiplying these modulo the irreducible polynomial x**2 + 1, and then solving for
    // d0 and d1
    //s: 4061 rc: 471 mh: 180
    func inv{range_check_ptr}(a: FQ2) -> (inverse: FQ2) {
        alloc_locals;
        local a_inverse: FQ2;
        let (field_modulus: Uint384) = get_modulus();
        %{
            def split(num: int, num_bits_shift : int = 128, length: int = 3):
                a = []
                for _ in range(length):
                    a.append( num & ((1 << num_bits_shift) - 1) )
                    num = num >> num_bits_shift 
                return tuple(a)
                
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (z.d0, z.d1, z.d2)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            e0 = pack(ids.a.e0)
            e1 = pack(ids.a.e1)
            field_modulus = pack(ids.field_modulus)

            if e0 != 0:
                e0_inv = pow(e0, -1, field_modulus)
                new_e0 = pow(e0 + (e1**2) * e0_inv, -1, field_modulus)
                new_e1 = ( -e1 * pow(e0**2 + e1**2, -1, field_modulus) ) % field_modulus   
            else:
                new_e0 = 0
                new_e1 = pow(-e1, -1, field_modulus)

            new_e0_split = split(new_e0)
            new_e1_split = split(new_e1)

            ids.a_inverse.e0.d0 = new_e0_split[0]
            ids.a_inverse.e0.d1 = new_e0_split[1]
            ids.a_inverse.e0.d2 = new_e0_split[2]

            ids.a_inverse.e1.d0 = new_e1_split[0]
            ids.a_inverse.e1.d1 = new_e1_split[1]
            ids.a_inverse.e1.d2 = new_e1_split[2]
        %}
	uint384_lib.check(a_inverse.e0);
	let (is_valid) = uint384_lib.lt(a_inverse.e0, field_modulus);
	assert is_valid = 1;
	uint384_lib.check(a_inverse.e1);
	let (is_valid) = uint384_lib.lt(a_inverse.e1, field_modulus);
	assert is_valid = 1;


        let (a_inverse_times_a: FQ2) = mul(a_inverse, a);
        let (one: FQ2) = get_one();
	assert a_inverse_times_a = one;
        return (a_inverse,);
    }

    
    func eq{range_check_ptr}(x: FQ2, y: FQ2) -> (bool: felt) {
        let (is_e0_eq) = uint384_lib.eq(x.e0, y.e0);
        if (is_e0_eq == 0) {
            return (0,);
        }
        let (is_e1_eq) = uint384_lib.eq(x.e1, y.e1);
        if (is_e1_eq == 0) {
            return (0,);
        }
        return (1,);
    }


    // NOTE/TODO: Not tested. However it is tested implicitly by the test of square_root_division_fq2

    // The sqrt r of (a, b) in Fq2 can be found by writting r and x as  polynomials,
    // i.e. r = r_0 + r_1 x, (a,b)= a+bx
    // then wrting the equation (r_0 + r1 x)**2 = a + bx
    // and solving for r_0 and r_1 modulo the irreducible polynomial f that defines Fq2 (in our case f = x**2 + 1)
    // For this particular f we have, if ab != 0 (the other cases are easier)
    // r_1  = sqrt(-a + sqrt(a**2 + b**2))/2)
    // r_0 = b r_1^{-1} /2
    // If any of the sqrt in Fq in the formulas does not exists, then the sqrt of (a,b) in Fq2 does not exist
    // Otherwise choosing any of the two possible sqrt each time yields a sqrt of (a, b) in Fq2
    // Note that the function `get_sqrt` from the library fq.cairo tells us
    // with security whether an element has a sqrt or not

    //NOTE: This function is wrong. It says that if a=0 but b is non zero, then there are no square roots. 
    //But (1+X)^2=2X in F_p[X]/(X^2+1). 
    func get_square_root{range_check_ptr}(element: FQ2) -> (
        bool: felt, sqrt: FQ2
    ) {
        alloc_locals;
        let a: Uint384 = element.e0;
        let b: Uint384 = element.e1;

        // TODO: create a dedicated eq function in fq.cairo (and probably use a FQ struct everywhere instead of Uint384)

        let (local is_a_zero) = uint384_lib.eq(a, Uint384(0, 0, 0));
        let (local is_b_zero) = uint384_lib.eq(b, Uint384(0, 0, 0));

        %{
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (limb for limb in z)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def packFQP(z):
                z = [[z.e0.d0, z.e0.d1, z.e0.d2], [z.e1.d0, z.e1.d1, z.e1.d2]]
                return tuple(pack(z_component) for z_component in z)

            print("is_a_and_b_zero", ids.is_a_zero, ids.is_b_zero)
        %}

        if (is_a_zero == 1) {
	    if (is_b_zero == 1) {
                let (zero: FQ2) = get_zero();
                return (1, zero);
            } else {
                let (zero: FQ2) = get_zero();
                // In this case there is no sqrt but we need to return an FQ2 as the second component regardless
                return (0, zero);
            }
        } else {
	    if (is_b_zero == 1) {
                let (bool, res: Uint384) = fq_lib.get_square_root(a);
                let sqrt = FQ2(res, Uint384(0, 0, 0));
                %{
                    def pack(z, num_bits_shift: int = 128) -> int:
                        limbs = (limb for limb in z)
                        return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))
                        
                    # print("sqrt", pack([ids.sqrt.e0.d0,ids.sqrt.e0.d1,ids.sqrt.e0.d2]), pack([ids.sqrt.e1.d0,ids.sqrt.e1.d1,ids.sqrt.e1.d2]))
                    #print("sqrt", ids.sqrt.e0.d0, ids.sqrt.e0.d1, ids.sqrt.e0.d2, ids.sqrt.e1.d0,ids.sqrt.e1.d1,ids.sqrt.e1.d2)
                    print("sqrt", ids.res.d0, ids.res.d1, ids.res.d2)
                %}

                return (bool, sqrt);
            } else {
                let (a_squared: Uint384) = fq_lib.mul(a, a);
                let (b_squared: Uint384) = fq_lib.mul(b, b);
                let (a_squared_plus_b_squared: Uint384) = fq_lib.add_no_input_check(a_squared, b_squared);
                let (bool, sqrt_a_squared_plus_b_squared: Uint384) = fq_lib.get_square_root(
                    a_squared_plus_b_squared
                );
                if (bool == 0) {
                    let (zero: FQ2) = get_zero();
                    // In this case there is no sqrt but we need to return an FQ2 as the second component regardless
                    return (0, zero);
                }
                let (minus_a_plus_sqrt: Uint384) = fq_lib.sub(sqrt_a_squared_plus_b_squared, a);
                let (local two_inverse: Uint384) = fq_lib.inverse(Uint384(2, 0, 0));
                let (minus_a_plus_sqrt_div_2: Uint384) = fq_lib.mul(minus_a_plus_sqrt, two_inverse);
                let (bool, r1: Uint384) = fq_lib.get_square_root(minus_a_plus_sqrt_div_2);
                if (bool == 1) {
                    let (twice_r1: Uint384) = fq_lib.scalar_mul(2, r1);
                    let (twice_r1_inverse: Uint384) = fq_lib.inverse(twice_r1);
                    let (r0: Uint384) = fq_lib.mul(b, twice_r1_inverse);
                    return (1, FQ2(r0, r1));
                } else {
                    let (minus_sqrt: Uint384) = fq_lib.sub(
                        Uint384(0, 0, 0), sqrt_a_squared_plus_b_squared
                    );
                    let (minus_a_minus_sqrt: Uint384) = fq_lib.sub(minus_sqrt, a);
                    let (minus_a_minus_sqrt_div_2: Uint384) = fq_lib.mul(
                        minus_a_minus_sqrt, two_inverse
                    );
                    let (bool, r1: Uint384) = fq_lib.get_square_root(minus_a_minus_sqrt_div_2);
                    if (bool == 1) {
                        let (twice_r1: Uint384) = fq_lib.scalar_mul(2, r1);
                        let (twice_r1_inverse: Uint384) = fq_lib.inverse(twice_r1);
                        let (r0: Uint384) = fq_lib.mul(b, twice_r1_inverse);
                        return (1, FQ2(r0, r1));
                    } else {
                        let (zero: FQ2) = get_zero();
                        return (0, zero);
                    }
                }
            }
        }
    }

    //This function tries to solve the problems from the previous function. Mainly whenever a=0 or b=0 then a square root exists.
    //Important remarks: both -1 and 2 are quadratic nonresidues modulo p.
    //For r0, r1 in F_p, we have (r0+r1X)^2=(r0^2-r1^2)+2r0r1 X, and we equate that to a+bX to find its square root.

    //If b=0, then either r0=0 or r1=0, i.e. a=r0^2 or a=-r1^2. Since -1 is not a square, every a in F_p is 
    //either a square, or the opposite of a square. Hence a always has a square root in F_{p^2}: if it is a square 
    //it is given by its square root in F_p,if it is not, then -a is, and again we find its square root s in F_p, the square root of a in F_{p^2}
    //is then given by sX. 

    //If a=0, then either r0=r1 or r0=-r1, i.e. b=2r0^2 or b=-2r0^2. Here -2 is a square modulo p, but 2 is not.
    //So again either b is a square in F_p and we find its square root s, the square root of bX in F_{p^2} is then given by 2^{-1}(s - s X) ;
    //or 2^{-1}b is, we find its square root s in F_p and the square root of bX in F_{p^2} is given by s + s X. 

    //If ab is non zero, we use the same method we were using.
    //This function assumes a and b are already reduced modulo p.
    //TODO write a function that uses a hint instead.

    // steps=2300, memory_holes=114, range_check_builtin=259
    func get_square_root_new{range_check_ptr}(element: FQ2) -> (
        bool: felt, sqrt: FQ2
    ) {
        alloc_locals;
        let a: Uint384 = element.e0;
        let b: Uint384 = element.e1;

        // TODO: create a dedicated eq function in fq.cairo (and probably use a FQ struct everywhere instead of Uint384)

        let (local is_a_zero) = uint384_lib.eq(a, Uint384(0, 0, 0));
        let (local is_b_zero) = uint384_lib.eq(b, Uint384(0, 0, 0));

        %{
            def pack(z, num_bits_shift: int = 128) -> int:
                limbs = (limb for limb in z)
                return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

            def packFQP(z):
                z = [[z.e0.d0, z.e0.d1, z.e0.d2], [z.e1.d0, z.e1.d1, z.e1.d2]]
                return tuple(pack(z_component) for z_component in z)

            print("is_a_and_b_zero", ids.is_a_zero, ids.is_b_zero)
        %}

        if (is_a_zero == 1) {
            if (is_b_zero == 1) {
                let (zero: FQ2) = get_zero();
                return (1, zero);
            } else {
                let (local two_inverse: Uint384_expand) = get_2_inverse_exp();
                let (p_expand:Uint384_expand) = get_modulus_expand();
                let (b_div_2:Uint384)= field_arithmetic.mul_expanded(b,two_inverse, p_expand);
                let (bool:felt, sqrt_b_div_2:Uint384)=field_arithmetic.get_square_root(b_div_2, p_expand, Uint384(2,0,0));
                if (bool==1){
                    return(bool=1, sqrt=FQ2(sqrt_b_div_2,sqrt_b_div_2));
                } else {
                    let (minus_b_div_2) = fq_lib.sub1(Uint384(0,0,0), b_div_2);
                    let (_, sqrt_minus_b_div_2:Uint384)=field_arithmetic.get_square_root(minus_b_div_2, p_expand, Uint384(2,0,0));
                    let (minus_sqrt_minus_b_div_2:Uint384)=fq_lib.sub1(Uint384(0,0,0), sqrt_minus_b_div_2);
                    return(bool=1, sqrt=FQ2(sqrt_minus_b_div_2, minus_sqrt_minus_b_div_2));
                }
            }
        } else {
            let (p_expand:Uint384_expand) = get_modulus_expand();
            if (is_b_zero == 1) {
                let (bool, sqrt_a: Uint384) = field_arithmetic.get_square_root(a, p_expand, Uint384(2,0,0));
                if(bool==1){
                   return(bool=1, sqrt=FQ2(sqrt_a, Uint384(0,0,0))); 
                }else{
                   let(minus_a:Uint384)=fq_lib.sub1(Uint384(0,0,0),a);
                   let( _ , sqrt_minus_a:Uint384)= field_arithmetic.get_square_root(minus_a, p_expand, Uint384(2,0,0));
                   return(bool=1, sqrt=FQ2(Uint384(0,0,0),sqrt_minus_a));
                }
            } else {
                let (a_squared: Uint384) = field_arithmetic.square(a, p_expand);
                let (b_squared: Uint384) = field_arithmetic.square(b, p_expand);
                let (a_squared_plus_b_squared: Uint384) = fq_lib.add_no_input_check(a_squared, b_squared);
                let (bool, sqrt_a_squared_plus_b_squared: Uint384) = field_arithmetic.get_square_root(
                    a_squared_plus_b_squared, p_expand, Uint384(2,0,0)
                );
                if (bool == 0) {
                    let (zero: FQ2) = get_zero();
                    // In this case there is no sqrt but we need to return an FQ2 as the second component regardless
                    return (0, zero);
                } else {
                    let (minus_a_plus_sqrt: Uint384) = fq_lib.sub1(sqrt_a_squared_plus_b_squared, a);
                    let (local two_inverse: Uint384_expand) = get_2_inverse_exp();
                    let (minus_a_plus_sqrt_div_2: Uint384) = field_arithmetic.mul_expanded(minus_a_plus_sqrt, two_inverse, p_expand);
                    let (bool, r1: Uint384) = field_arithmetic.get_square_root(minus_a_plus_sqrt_div_2, p_expand, Uint384(2,0,0));
                    if (bool == 1) {
                        let (twice_r1: Uint384) = fq_lib.add_no_input_check(r1, r1);
                        let (twice_r1_inverse: Uint384) = fq_lib.inverse(twice_r1);
                        let (r0: Uint384) = field_arithmetic.mul(b, twice_r1_inverse, p_expand);
                        return (1, FQ2(r0, r1));
                    } else {
                        let (minus_sqrt: Uint384) = fq_lib.sub1(
                        Uint384(0, 0, 0), sqrt_a_squared_plus_b_squared
                        );
                        let (minus_a_minus_sqrt: Uint384) = fq_lib.sub1(minus_sqrt, a);
                        let (minus_a_minus_sqrt_div_2: Uint384) = field_arithmetic.mul_expanded(
                        minus_a_minus_sqrt, two_inverse, p_expand
                        );
                        let (bool, r1: Uint384) = field_arithmetic.get_square_root(minus_a_minus_sqrt_div_2, p_expand, Uint384(2,0,0));
                        if (bool == 1) {
                            let (twice_r1: Uint384) = fq_lib.add_no_input_check(r1, r1);
                            let (twice_r1_inverse: Uint384) = fq_lib.inverse(twice_r1);
                            let (r0: Uint384) = field_arithmetic.mul(b, twice_r1_inverse, p_expand);
                            return (1, FQ2(r0, r1));
                        } else {
                            let (zero: FQ2) = get_zero();
                            return (0, zero);
                        }
                    }
                }
            }
        }
    }

    // steps=3960, memory_holes=140, range_check_builtin=463
    func square{range_check_ptr}(x: FQ2) -> (res: FQ2) {
        let (res) = mul(x, x);
        return (res,);
    }

    //best square :  steps=3083, memory_holes=120, range_check_builtin=354
    func square_new{range_check_ptr}(x:FQ2) -> (res:FQ2) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (r0_squared: Uint384) = field_arithmetic.square(x.e0, p_expand);
        let (r1_squared: Uint384) = field_arithmetic.square(x.e1, p_expand);
        let (first_term:Uint384)=field_arithmetic.sub_reduced_a_and_reduced_b(r0_squared,r1_squared,p_expand);
        let (r0r1:Uint384)=field_arithmetic.mul(x.e0, x.e1, p_expand);
        let (second_term:Uint384)=fq_lib.add_no_input_check(r0r1,r0r1);
        return (FQ2(e0=first_term, e1=second_term),);
    }

    // Uses Karatsuba multiplication
    // better square : steps=3161, memory_holes=120, range_check_builtin=354
    func square_kar{range_check_ptr}(a: FQ2) -> (product: FQ2) {
        alloc_locals;
        let (p_expand:Uint384_expand)=get_modulus_expand();
        let (first_term: Uint384) = field_arithmetic.square(a.e0, p_expand);
        let (third_term: Uint384) = field_arithmetic.square(a.e1, p_expand);

	let (sum_a: Uint384,_) = uint384_lib.add(a.e0,a.e1);
	let (second_term: Uint384) = field_arithmetic.square(sum_a, p_expand);

	//field_arithmetic.mul always returns reduced values
	let (second_term: Uint384) = fq_lib.sub_three_terms_no_input_check(second_term,first_term,third_term);
	
        let (first_term) = field_arithmetic.sub_reduced_a_and_reduced_b(first_term, third_term, p_expand);

        return (FQ2(e0=first_term, e1=second_term),);
    }

    func is_zero{range_check_ptr}(x: FQ2) -> (bool: felt) {
        let (zero_fq2: FQ2) = get_zero();
        let (is_x_zero) = eq(x, zero_fq2);
        return (is_x_zero,);
    }

    
    func get_zero() -> (zero: FQ2) {
        let zero_fq2 = FQ2(Uint384(0, 0, 0), Uint384(0, 0, 0));
        return (zero_fq2,);
    }

    
    func get_one() -> (one: FQ2) {
        let one_fq1 = FQ2(Uint384(1, 0, 0), Uint384(0, 0, 0));
        return (one_fq1,);
    }

    // Not tested
    func mul_three_terms{range_check_ptr}(x: FQ2, y: FQ2, z: FQ2) -> (
        res: FQ2
    ) {
        let (x_times_y: FQ2) = mul_kar(x, y);
        let (res: FQ2) = mul_kar(x_times_y, z);
        return (res,);
    }

    // Not tested
    // Computes x - y - z
    func sub_three_terms{range_check_ptr}(x: FQ2, y: FQ2, z: FQ2) -> (
        res: FQ2
    ) {
        let (x_sub_y: FQ2) = sub(x, y);
        let (res: FQ2) = sub(x_sub_y, z);
        return (res,);
    }

    // TODO: test
    // Computes x - y - z
    func add_three_terms{range_check_ptr}(x: FQ2, y: FQ2, z: FQ2) -> (
        res: FQ2
    ) {
        let (x_times_y: FQ2) = add(x, y);
        let (res: FQ2) = add(x_times_y, z);
        return (res,);
    }

    // steps=10861, memory_holes=419, range_check_builtin=1226
    func pow{range_check_ptr}(a: FQ2, exp: Uint768) -> (res: FQ2) {
        let o: FQ2 = FQ2(e0=Uint384(d0=1, d1=0, d2=0), e1=Uint384(d0=0, d1=0, d2=0));
        let (res: FQ2) = pow_inner(a, exp, o);
        return (res,);
    }

    //I think this is assuming that a is a valid element of F^{p^2}
    func pow_inner{range_check_ptr}(a: FQ2, exp: Uint768, o: FQ2) -> (
        res: FQ2
    ) {
        alloc_locals;

        let (is_exp_zero: felt) = uint384_extension_lib.eq(
            a=exp, b=Uint768(d0=0, d1=0, d2=0, d3=0, d4=0, d5=0)
        );

        if (is_exp_zero == 1) {
            return (o,);
        }
        let (exp_div_2: Uint768, rem) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384(
            a=exp, div=Uint384(d0=2, d1=0, d2=0)
        );
        let (is_rem_zero:felt)=uint384_lib.eq(rem, Uint384(0,0,0));
        if (is_rem_zero == 1) {
            // NOTE: Code is repeated in the if-else to avoid declaring a_squared as a local variable
            let (a_squared: FQ2) = square_new(a);
            let (power: FQ2) = pow_inner(a_squared, exp_div_2, o);
        } else {
            let (a_squared: FQ2) = square_new(a);
            let (o_new: FQ2) = mul_kar(a, o);
            let (power: FQ2) = pow_inner(a_squared, exp_div_2, o_new);
        }
        return(res=power);
    }
        //this was part of pow_inner
        //let (a_sqr: FQ2) = square_new(a, a);
        //let (and_one: Uint768) = uint384_extension_lib.bit_and(
            //exp, Uint768(d0=1, d1=0, d2=0, d3=0, d4=0, d5=0)
        //);
        //if (and_one.d0 == 1) {
            //let (o_new: FQ2) = mul(a, o);
            //let (power: FQ2) = pow_inner(a_sqr, new_exp, o_new);
        //} else {
            //let (power: FQ2) = pow_inner(a_sqr, new_exp, o);
        //}

        //return (res=power);
    //}

    func check_is_not_zero{range_check_ptr}(a: FQ2) -> (is_zero: felt) {
        let res = is_not_zero(a.e0.d0 + a.e0.d1 + a.e0.d2 + a.e1.d0 + a.e1.d1 + a.e1.d2);
        return (res,);
    }

    func is_quadratic_residue{range_check_ptr}(a: FQ2) -> (
        is_quad_nonresidue: felt
    ) {

        let (c0: Uint384) = fq_lib.mul(a.e0, a.e0);
        let (c1: Uint384) = fq_lib.mul(a.e1, a.e1);
        let (c3: Uint384) = fq_lib.add_no_input_check(c0, c1);

        let (is_quad_residue: felt,_) = fq_lib.get_square_root(c3);

        return (is_quad_residue,);
    }

    func one() -> (res: FQ2) {
        return (
            res=FQ2(e0=Uint384(
                d0=1,
                d1=0,
                d2=0),
            e1=Uint384(
                d0=0,
                d1=0,
                d2=0)),
        );
    }

    func neg{range_check_ptr}(a: FQ2) -> (res: FQ2) {

        let (neg_e0: Uint384) = fq_lib.neg(a.e0);
        let (neg_e1: Uint384) = fq_lib.neg(a.e1);

        return (res=FQ2(e0=neg_e0, e1=neg_e1));
    }

    // https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-09#section-4.1
    func sgn0{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(a: FQ2) -> (sign: felt) {
      //alloc_locals;

        let sign = 0;
        let zero = 1;

        let (_, sign_i: Uint384) = uint384_lib.unsigned_div_rem(a.e0, Uint384(d0=2, d1=0, d2=0));
        let (zero_i: felt) = uint384_lib.eq(a.e0, Uint384(d0=0, d1=0, d2=0));

        let (zero_and_sign_i: felt) = bitwise_and(sign_i.d0, zero);

        let (sign: felt) = bitwise_or(sign, zero_and_sign_i);
        let (zero: felt) = bitwise_and(zero, zero_i);

        let (_, sign_i: Uint384) = uint384_lib.unsigned_div_rem(a.e1, Uint384(d0=2, d1=0, d2=0));
        let (zero_i: felt) = uint384_lib.eq(a.e1, Uint384(d0=0, d1=0, d2=0));

        let (zero_and_sign_i: felt) = bitwise_and(sign_i.d0, zero);

        let (sign: felt) = bitwise_or(sign, zero_and_sign_i);

        return (sign=sign);
    }

    func conjugate{range_check_ptr}(a: FQ2) -> (res: FQ2) {
        let (neg_x_i) = fq_lib.neg(a.e1);
        return (res=FQ2(e0=a.e0, e1=neg_x_i));
    }
}
