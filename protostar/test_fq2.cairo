%lang starknet

from lib.fq2_new import fq2_lib, FQ2
from lib.curve_new import get_2_inverse, get_p_minus_one
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768, uint384_extension_lib
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256
//a=FQ2(Uint384(1,0,0), Uint384(1,0,0))
//b=FQ2(Uint384(0,0,0), Uint384(2,0,0))

@external
func test_add{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (add:FQ2) = fq2_lib.add(FQ2(Uint384(1,0,0), Uint384(1,0,0)),FQ2(Uint384(0,0,0), Uint384(2,0,0)));
    assert add = FQ2(Uint384(1,0,0), Uint384(3,0,0));
    return();
}

@external
func test_sub{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (subs:FQ2) = fq2_lib.sub(FQ2(Uint384(1,0,0), Uint384(2,0,0)),FQ2(Uint384(0,0,0), Uint384(2,0,0)));
    assert subs = FQ2(Uint384(1,0,0), Uint384(0,0,0));
    return();
}

@external
func test_scalar_mul{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:FQ2) = fq2_lib.scalar_mul(Uint384(13,0,0),FQ2(Uint384(0,0,0), Uint384(2,0,0)));
    assert mults = FQ2(Uint384(0,0,0), Uint384(26,0,0));
    return();
}

@external
func test_mul{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:FQ2) = fq2_lib.mul(FQ2(Uint384(1,0,0), Uint384(1,0,0)),FQ2(Uint384(2,0,0), Uint384(1,0,0)));
    assert mults = FQ2(Uint384(1,0,0), Uint384(3,0,0));
    return();
}

@external
func test_mul_kar{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mults:FQ2) = fq2_lib.mul_kar(FQ2(Uint384(1,0,0), Uint384(1,0,0)),FQ2(Uint384(2,0,0), Uint384(1,0,0)));
    assert mults = FQ2(Uint384(1,0,0), Uint384(3,0,0));
    return();
}

@external
func test_inv{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (invs:FQ2) = fq2_lib.inv(FQ2(Uint384(1,0,0), Uint384(1,0,0)));
    return();
}

@external
func test_get_square_root_new{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (bool:felt, sqrt:FQ2) = fq2_lib.get_square_root_new(FQ2(Uint384(0,0,0), Uint384(2,0,0)));
    assert (bool, sqrt) = (1,FQ2(Uint384(1,0,0), Uint384(1,0,0)));
    return();
}

@external
func test_square{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sq:FQ2) = fq2_lib.square(FQ2(Uint384(1,0,0), Uint384(1,0,0)));
    assert sq = FQ2(Uint384(0,0,0), Uint384(2,0,0));
    return();
}

@external
func test_square_new{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sq:FQ2) = fq2_lib.square_new(FQ2(Uint384(1,0,0), Uint384(1,0,0)));
    assert sq = FQ2(Uint384(0,0,0), Uint384(2,0,0));
    return();
}

@external
func test_square_kar{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sq:FQ2) = fq2_lib.square_kar(FQ2(Uint384(1,0,0), Uint384(1,0,0)));
    assert sq = FQ2(Uint384(0,0,0), Uint384(2,0,0));
    return();
}

@external
func test_pow{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (power:FQ2) = fq2_lib.pow(FQ2(Uint384(1,0,0), Uint384(1,0,0)),Uint768(2,0,0,0,0,0));
    assert power = FQ2(Uint384(0,0,0), Uint384(2,0,0));
    return();
}
