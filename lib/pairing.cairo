from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.uint384 import Uint384, uint384_lib
from lib.fq import fq_lib
from lib.fq2 import FQ2, fq2_lib
from lib.fq12 import FQ12, fq12_lib
from lib.g1 import g1_lib
from lib.g2 import g2_lib

namespace pairing_lib:
    
    func pairing(Q: FQ2, P:Uint384) -> (res: FQ12):
        let (is_Q_on_curve) = g2_lib.is_on_curve(Q)
        assert is_Q_on_curve = 1
        let (is_P_on_curve) = g1_lib.is_on_curve(P)
        assert is_P_on_curve = 1
        let (twisted_Q : FQ12) = twist(Q)
        let (P_as_fq12: FQ12) = cast_point_to_fq12(P)
        let (res : FQ12) = miller_loop(twisted_Q, P_as_fq12)
    end
    
    func miller_loop(Q: FQ12, P: FQ12) -> (res: FQ12):
        
    end
    
end