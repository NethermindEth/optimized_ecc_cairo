from lib.fq2 import fq2
from lib.uint384 import Uint384
from starkware.cairo.common.cairo_builtins import BitwiseBuiltin

struct ParamsSWU:
    member a : fq2.FQ2
    member b : fq2.FQ2
    member z : fq2.FQ2
    member z_inv : fq2.FQ2
    member minus_b_over_a : fq2.FQ2
end

func get_swu_g2_params() -> (params : ParamsSWU):
    return (
        params=ParamsSWU(
        a=fq2.FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=16517514583386313282, d1=74322656156451461, d2=16683759486841714365)),
        b=fq2.FQ2(e0=Uint384(d0=2515823342057463218, d1=7982686274772798116, d2=30992210165343854), e1=Uint384(d0=2515823342057463218, d1=7982686274772798116, d2=7934098172177393262)),
        z=fq2.FQ2(e0=Uint384(d0=9794203289623549276, d1=7309342082925068282, d2=1139538881605221074), e1=Uint384(d0=4897101644811774638, d1=3654671041462534141, d2=569769440802610537)),
        z_inv=fq2.FQ2(e0=Uint384(d0=12452452969679491344, d1=11374291236854484173, d2=13099329512014041791), e1=Uint384(d0=16399576568092893731, d1=5746367929944742296, d2=886009817557060804)),
        minus_b_over_a=fq2.FQ2(e0=Uint384(d0=10393275865055580083, d1=6888480573845999877, d2=11497223857339693790), e1=Uint384(d0=3009155151022283512, d1=13768405011380760314, d2=14385194789933939525))
        ))
end

# parameters https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-06#section-8.7
# implementation https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-06#section-6.6.2.1
func simplified_swu{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(e : fq2.FQ2, u : fq2.FQ2) -> (
        x : fq2.FQ2, y : fq2.FQ2):
    alloc_locals

    let (params : ParamsSWU) = get_swu_g2_params()

    # should use squaring algorithm
    let (u_squared : fq2.FQ2) = fq2.square(u)
    let (tv1 : fq2.FQ2) = fq2.mul(u_squared, params.z)
    let (tv2 : fq2.FQ2) = fq2.square(tv1)
    let (x1 : fq2.FQ2) = fq2.add(tv1, tv2)
    let (x1 : fq2.FQ2) = fq2.inverse(x1)

    let (x1_is_not_zero : felt) = fq2.check_is_not_zero(x1)

    if x1_is_not_zero == 0:
        tempvar x1 : fq2.FQ2 = params.z_inv
    else:
        tempvar x1 = x1
    end

    let (x1 : fq2.FQ2) = fq2.mul(x1, params.minus_b_over_a)

    let (gx1 : fq2.FQ2) = fq2.square(x1)
    let (gx1 : fq2.FQ2) = fq2.add(gx1, params.a)
    let (gx1 : fq2.FQ2) = fq2.mul(gx1, x1)
    let (gx1 : fq2.FQ2) = fq2.add(gx1, params.b)

    let (x2 : fq2.FQ2) = fq2.mul(tv1, x1)

    let (tv2 : fq2.FQ2) = fq2.mul(tv1, tv2)
    let (gx2 : fq2.FQ2) = fq2.mul(gx1, tv2)

    let (is_nonresidue : felt) = fq2.is_quadratic_nonresidue(gx1)

    if is_nonresidue == 1:
        let x = x1
        let y2 = gx1
    else:
        let x = x2
        let y2 = gx2
    end

    let (y : Uint384) = 

    return (params.a, params.b)
end
