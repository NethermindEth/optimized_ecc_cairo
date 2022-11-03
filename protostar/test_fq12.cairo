%lang starknet

from lib.fq12_new import fq12_lib, FQ12
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
    let (add:FQ12) = fq12_lib.add(FQ12(Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0)),
				  FQ12(Uint384(0,0,0),
				       Uint384(2,0,0),
				       Uint384(3,0,0),
				       Uint384(4,0,0),
				       Uint384(5,0,0),
				       Uint384(6,0,0),
				       Uint384(7,0,0),
				       Uint384(8,0,0),
				       Uint384(9,0,0),
				       Uint384(10,0,0),
				       Uint384(11,0,0),
				       Uint384(12,0,0)));
    
    assert add = FQ12(Uint384(1,0,0),
		      Uint384(3,0,0),
		      Uint384(4,0,0),
		      Uint384(5,0,0),
		      Uint384(6,0,0),
		      Uint384(7,0,0),
		      Uint384(8,0,0),
		      Uint384(9,0,0),
		      Uint384(10,0,0),
		      Uint384(11,0,0),
		      Uint384(12,0,0),
		      Uint384(13,0,0));
    return();
}

@external
func test_sub{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sub:FQ12) = fq12_lib.sub(FQ12(Uint384(1,0,0),
				       Uint384(2,0,0),
				       Uint384(3,0,0),
				       Uint384(4,0,0),
				       Uint384(5,0,0),
				       Uint384(6,0,0),
				       Uint384(7,0,0),
				       Uint384(8,0,0),
				       Uint384(9,0,0),
				       Uint384(10,0,0),
				       Uint384(11,0,0),
				       Uint384(12,0,0)),
				  FQ12(Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0)));
    
    assert sub = FQ12(Uint384(0,0,0),
		      Uint384(1,0,0),
		      Uint384(2,0,0),
		      Uint384(3,0,0),
		      Uint384(4,0,0),
		      Uint384(5,0,0),
		      Uint384(6,0,0),
		      Uint384(7,0,0),
		      Uint384(8,0,0),
		      Uint384(9,0,0),
		      Uint384(10,0,0),
		      Uint384(11,0,0));
    return();
}

@external
func test_sub_2{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sub:FQ12) = fq12_lib.sub_2(FQ12(Uint384(1,0,0),
				       Uint384(2,0,0),
				       Uint384(3,0,0),
				       Uint384(4,0,0),
				       Uint384(5,0,0),
				       Uint384(6,0,0),
				       Uint384(7,0,0),
				       Uint384(8,0,0),
				       Uint384(9,0,0),
				       Uint384(10,0,0),
				       Uint384(11,0,0),
				       Uint384(12,0,0)),
				  FQ12(Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0)));
    
    assert sub = FQ12(Uint384(0,0,0),
		      Uint384(1,0,0),
		      Uint384(2,0,0),
		      Uint384(3,0,0),
		      Uint384(4,0,0),
		      Uint384(5,0,0),
		      Uint384(6,0,0),
		      Uint384(7,0,0),
		      Uint384(8,0,0),
		      Uint384(9,0,0),
		      Uint384(10,0,0),
		      Uint384(11,0,0));
    return();
}

@external
func test_sub_3{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sub:FQ12) = fq12_lib.sub_3(FQ12(Uint384(1,0,0),
				       Uint384(2,0,0),
				       Uint384(3,0,0),
				       Uint384(4,0,0),
				       Uint384(5,0,0),
				       Uint384(6,0,0),
				       Uint384(7,0,0),
				       Uint384(8,0,0),
				       Uint384(9,0,0),
				       Uint384(10,0,0),
				       Uint384(11,0,0),
				       Uint384(12,0,0)),
				  FQ12(Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0),
				       Uint384(1,0,0)));
    
    assert sub = FQ12(Uint384(0,0,0),
		      Uint384(1,0,0),
		      Uint384(2,0,0),
		      Uint384(3,0,0),
		      Uint384(4,0,0),
		      Uint384(5,0,0),
		      Uint384(6,0,0),
		      Uint384(7,0,0),
		      Uint384(8,0,0),
		      Uint384(9,0,0),
		      Uint384(10,0,0),
		      Uint384(11,0,0));
    return();
}

@external
func test_scalar_mul{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mul:FQ12) = fq12_lib.scalar_mul(3,
					 FQ12(Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0),
					      Uint384(1,0,0)));
    
    assert mul = FQ12(Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0));
    return();
}


@external
func test_scalar_mul2{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mul:FQ12) = fq12_lib.scalar_mul2(3,
					  FQ12(Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0),
					       Uint384(1,0,0)));
    
    assert mul = FQ12(Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0),
		      Uint384(3,0,0));
    return();
}


@external
func test_scalar_mul_uint384{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mul:FQ12) = fq12_lib.scalar_mul_uint384(Uint384(1,2,3),
						 FQ12(Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0),
						      Uint384(1,0,0)));
    
    assert mul = FQ12(Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3),
		      Uint384(1,2,3));
    return();
}


@external
func test_mul{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mul:FQ12) = fq12_lib.mul(FQ12(Uint384(1,0,0),
				       Uint384(2,0,0),
				       Uint384(3,0,0),
				       Uint384(4,0,0),
				       Uint384(5,0,0),
				       Uint384(6,0,0),
				       Uint384(7,0,0),
				       Uint384(8,0,0),
				       Uint384(9,0,0),
				       Uint384(10,0,0),
				       Uint384(11,0,0),
				       Uint384(12,0,0)),
				  FQ12(Uint384(2,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0)),
				  );
    assert mul = FQ12(Uint384(2,0,0),
		      Uint384(4,0,0),
		      Uint384(6,0,0),
		      Uint384(8,0,0),
		      Uint384(10,0,0),
		      Uint384(12,0,0),
		      Uint384(14,0,0),
		      Uint384(16,0,0),
		      Uint384(18,0,0),
		      Uint384(20,0,0),
		      Uint384(22,0,0),
		      Uint384(24,0,0));
    return();
}

@external
func test_mul_2{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (mul:FQ12) = fq12_lib.mul_2(FQ12(Uint384(1,0,0),
				       Uint384(2,0,0),
				       Uint384(3,0,0),
				       Uint384(4,0,0),
				       Uint384(5,0,0),
				       Uint384(6,0,0),
				       Uint384(7,0,0),
				       Uint384(8,0,0),
				       Uint384(9,0,0),
				       Uint384(10,0,0),
				       Uint384(11,0,0),
				       Uint384(12,0,0)),
				  FQ12(Uint384(2,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0),
				       Uint384(0,0,0)));
    
    assert mul = FQ12(Uint384(2,0,0),
		      Uint384(4,0,0),
		      Uint384(6,0,0),
		      Uint384(8,0,0),
		      Uint384(10,0,0),
		      Uint384(12,0,0),
		      Uint384(14,0,0),
		      Uint384(16,0,0),
		      Uint384(18,0,0),
		      Uint384(20,0,0),
		      Uint384(22,0,0),
		      Uint384(24,0,0));
    return();
}

@external
func test_square{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sq:FQ12) = fq12_lib.square(FQ12(Uint384(2,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0),
					 Uint384(0,0,0)));

    assert sq = FQ12(Uint384(4,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0));
    return();
}

@external
func test_square_2{syscall_ptr: felt*, range_check_ptr}(
    
) {
    let (sq:FQ12) = fq12_lib.square_2(FQ12(Uint384(2,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0),
					   Uint384(0,0,0)));

    assert sq = FQ12(Uint384(4,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0),
		     Uint384(0,0,0));
    return();
}
