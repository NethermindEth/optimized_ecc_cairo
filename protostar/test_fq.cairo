%lang starknet

from lib.fq_new import fq_lib
from lib.curve_new import get_2_inverse, get_p_minus_one
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256

@external
func test_add{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (add:Uint384) = fq_lib.add(Uint384(11,0,0),Uint384(7,0,0));
    assert add = Uint384(18,0,0);
    return();
}

@external
func test_sub{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (minus:Uint384) = fq_lib.sub(Uint384(11,0,0),Uint384(7,0,0));
    assert minus = Uint384(4,0,0);
    return();
}


@external
func test_sub1{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (minus:Uint384) = fq_lib.sub1(Uint384(11,0,0),Uint384(7,0,0));
    assert minus = Uint384(4,0,0);
    return();
}

@external
func test_mul{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mult:Uint384) = fq_lib.mul(Uint384(11,0,0),Uint384(7,0,0));
    assert mult = Uint384(77,0,0);
    return();
}

@external
func test_square{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sqr:Uint384) = fq_lib.square(Uint384(11,0,0));
    assert sqr = Uint384(121,0,0);
    return();
}

@external
func test_square2{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sqr:Uint384) = fq_lib.square2(Uint384(11,0,0));
    assert sqr = Uint384(121,0,0);
    return();
}

@external
func test_scalar_mul{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mult:Uint384) = fq_lib.scalar_mul(10,Uint384(11,0,0));
    assert mult = Uint384(110,0,0);
    return();
}

@external
func test_scalar_mul2{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mult:Uint384) = fq_lib.scalar_mul2(10,Uint384(11,0,0));
    assert mult = Uint384(110,0,0);
    return();
}

@external
func test_scalar_mul3{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mult:Uint384) = fq_lib.scalar_mul3(10,Uint384(11,0,0));
    assert mult = Uint384(110,0,0);
    return();
}

@external
func test_scalar_mul4{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mult:Uint384) = fq_lib.scalar_mul4(10,Uint384(11,0,0));
    assert mult = Uint384(110,0,0);
    return();
}

@external
func test_scalar64_mul{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mult:Uint384) = fq_lib.scalar64_mul(10,Uint384(11,0,0));
    assert mult = Uint384(110,0,0);
    return();
}

@external
func test_div{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (divs:Uint384) = fq_lib.div(Uint384(11,0,0),Uint384(11,0,0));
    assert divs = Uint384(1,0,0);
    return();
}

@external
func test_inverse{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (invs:Uint384) = fq_lib.inverse(Uint384(2,0,0));
    let (twoinv:Uint384) = get_2_inverse();
    assert invs = twoinv;
    return();
}

@external
func test_pow{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (power:Uint384) = fq_lib.pow(Uint384(11,0,0), Uint384(2,0,0));
    assert power = Uint384(121,0,0);
    return();
}

@external
func test_pow_expanded{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (power:Uint384) = fq_lib.pow_expanded(Uint384(11,0,0), Uint384(2,0,0));
    assert power = Uint384(121,0,0);
    return();
}

@external
func test_get_square_root{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (bool:felt, sqrt:Uint384) = fq_lib.get_square_root(Uint384(4,0,0));
    assert (bool, sqrt) = (1,Uint384(2,0,0));
    return();
}

@external
func test_from256{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (fr:Uint384) = fq_lib.from_256_bits(Uint256(4,5));
    return();
}

@external
func test_from64{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (fr:Uint384) = fq_lib.from_64_bytes(Uint256(11,0), Uint256(7,0));
    return();
}

@external
func test_neg{syscall_ptr: felt*, range_check_ptr}(
    
) {
    alloc_locals;
    let (p_minus:Uint384) = get_p_minus_one();
    let (no:Uint384) = fq_lib.neg(Uint384(1,0,0));
    assert no = p_minus; 
    return();
}

@external
func test_mul_three_terms{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:Uint384) = fq_lib.mul_three_terms(Uint384(11,0,0), Uint384(7,0,0), Uint384(5,0,0));
    assert mults = Uint384(385,0,0);
    return();
}

@external
func test_sub_three_terms{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:Uint384) = fq_lib.sub_three_terms(Uint384(11,0,0), Uint384(7,0,0), Uint384(3,0,0));
    assert mults = Uint384(1,0,0);
    return();
}

@external
func test_sub_three_terms_new{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:Uint384) = fq_lib.sub_three_terms_new(Uint384(11,0,0), Uint384(7,0,0), Uint384(3,0,0));
    assert mults = Uint384(1,0,0);
    return();
}

@external
func test_sub_three_terms2{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:Uint384) = fq_lib.sub_three_terms2(Uint384(11,0,0), Uint384(7,0,0), Uint384(3,0,0));
    assert mults = Uint384(1,0,0);
    return();
}

@external
func test_sub_three_terms3{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:Uint384) = fq_lib.sub_three_terms3(Uint384(11,0,0), Uint384(7,0,0), Uint384(3,0,0));
    assert mults = Uint384(1,0,0);
    return();
}
