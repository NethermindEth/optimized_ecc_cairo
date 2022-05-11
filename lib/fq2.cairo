from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.BigInt6 import BigInt6
from lib.fq import fq

namespace fq2:
    struct FQ2:
        member e0 : BigInt6
        member e1 : BigInt6
    end

    func add{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        alloc_locals

        let (e0 : BigInt6) = fq.add(x.e0, y.e0)
        let (e1 : BigInt6) = fq.add(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func sub{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : FQ2, y : FQ2) -> (sum_mod : FQ2):
        alloc_locals

        let (e0 : BigInt6) = fq.sub(x.e0, y.e0)
        let (e1 : BigInt6) = fq.sub(x.e1, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end

    func scalar_mul{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(x : felt, y : FQ2) -> (
            product : FQ2):
        alloc_locals

        let (e0 : BigInt6) = fq.scalar_mul(x, y.e0)
        let (e1 : BigInt6) = fq.scalar_mul(x, y.e1)

        return (FQ2(e0=e0, e1=e1))
    end
end
