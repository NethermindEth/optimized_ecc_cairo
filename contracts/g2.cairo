%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.swu import simplified_swu
from lib.fq2 import FQ2

@view
func swu{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(u : FQ2) -> (x : FQ2, y : FQ2):
    alloc_locals
    let (x : FQ2, y : FQ2) = simplified_swu(u)

    return (x, y)
end
