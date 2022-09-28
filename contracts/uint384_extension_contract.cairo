// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
from starkware.cairo.common.uint256 import Uint256, uint256_sqrt
// Import uint384 files (path may change in the future)
from lib.uint384 import uint384_lib, Uint384
from lib.uint384_extension import uint384_extension_lib, Uint768

// StarkNet contract implementing view calls to lib/uint384_extension.cairo's functions

// Adds a 768-bit integer and a 384-bit integer. Returns the result as a 768-bit integer and the (1-bit) carry.
@view
func uint384_add_uint768_and_uint384{range_check_ptr}(a: Uint768, b: Uint384) -> (
    res: Uint768, carry: felt
) {
    let (res: Uint768, carry: felt) = uint384_extension_lib.add_uint768_and_uint384(a, b);
    return (res, carry);
}

// Multiplies a 768-bit integer and a 384-bit integer.
// Returns the result (1152 bits) as a 768-bit integer (the lower bits of the result) and
// a 384-bit integer (the higher bits of the result)
@view
func uint384_mul_uint768_by_uint384{range_check_ptr}(a: Uint768, b: Uint384) -> (
    low: Uint768, high: Uint384
) {
    let (low: Uint768, high: Uint384) = uint384_extension_lib.mul_uint768_by_uint384(a, b);
    return (low, high);
}

@view
func uint384_mul_uint768_by_uint384_c{range_check_ptr}(a: Uint768, b: Uint384) -> (
    low: Uint768, high: Uint384
) {
    let (low: Uint768, high: Uint384) = uint384_extension_lib.mul_uint768_by_uint384_c(a, b);
    return (low, high);
}

@view
func uint384_mul_uint768_by_uint384_d{range_check_ptr}(a: Uint768, b: Uint384) -> (
    low: Uint768, high: Uint384
) {
    let (low: Uint768, high: Uint384) = uint384_extension_lib.mul_uint768_by_uint384_d(a, b);
    return (low, high);
}

@view
func uint384_mul_uint768_by_uint384_kar{range_check_ptr}(a: Uint768, b: Uint384) -> (
    low: Uint768, high: Uint384
) {
    let (low: Uint768, high: Uint384) = uint384_extension_lib.mul_uint768_by_uint384_kar(a, b);
    return (low, high);
}

@view
func uint384_mul_uint768_by_uint384_kar_d{range_check_ptr}(a: Uint768, b: Uint384) -> (
    low: Uint768, high: Uint384
) {
    let (low: Uint768, high: Uint384) = uint384_extension_lib.mul_uint768_by_uint384_kar_d(a, b);
    return (low, high);
}

@view
func uint384_mul_uint768_by_uint384_Toom25{range_check_ptr}(a: Uint768, b: Uint384) -> (
    low: Uint768, high: Uint384
) {
    let (low: Uint768, high: Uint384) = uint384_extension_lib.mul_uint768_by_uint384_Toom25(a, b);
    return (low, high);
}

// Unsigned integer division between a 768-bit integer and a 384-bit integer. Returns the quotient (768 bits) and the remainder (384 bits).
// Conforms to EVM specifications: division by 0 yields 0.
@view
func uint384_unsigned_div_rem_uint768_by_uint384{range_check_ptr}(a: Uint768, div: Uint384) -> (
    quotient: Uint768, remainder: Uint384
) {
    let (
        quotient: Uint768, remainder: Uint384
    ) = uint384_extension_lib.unsigned_div_rem_uint768_by_uint384(a, div);
    return (quotient, remainder);
}