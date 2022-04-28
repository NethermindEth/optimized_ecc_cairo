%lang starknet
%builtins range_check bitwise

from lib.fq import fq_add, fq_sub
from lib.BigInt6 import BigInt6
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

# Returns the current balance.
@view
func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
    res : BigInt6
):
    alloc_locals
    let (res : BigInt6) = fq_add(x, y)

    return (res)
end

@view
func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : BigInt6, y : BigInt6) -> (
    res : BigInt6
):
    alloc_locals

    let (res : BigInt6) = fq_sub(x, y)

    return (res)
end
