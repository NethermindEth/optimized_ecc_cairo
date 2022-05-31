%lang starknet
%builtins range_check bitwise

from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.g2 import simplified_swu
from lib.fq2 import fq2

@view
func swu{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(e : fq2.FQ2, u : fq2.FQ2) -> (
        x : fq2.FQ2, y : fq2.FQ2):
    alloc_locals
    let (x : fq2.FQ2, y : fq2.FQ2) = simplified_swu(e, u)

    return (x, y)
end
