from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.uint384 import Uint384, uint384_lib
from lib.uint384_extension import Uint768
from lib.fq import fq_lib
from lib.fq2 import FQ2, fq2_lib
from lib.isogeny import isogeny_map_g2

struct ParamsSWU:
    member a : FQ2
    member b : FQ2
    member z : FQ2
    member z_inv : FQ2
    member minus_b_over_a : FQ2
end

func get_swu_g2_params() -> (params : ParamsSWU):
    return (
        params=ParamsSWU(
        a=FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=16517514583386313282, d1=74322656156451461, d2=16683759486841714365)),
        b=FQ2(e0=Uint384(d0=2515823342057463218, d1=7982686274772798116, d2=30992210165343854), e1=Uint384(d0=2515823342057463218, d1=7982686274772798116, d2=7934098172177393262)),
        z=FQ2(e0=Uint384(d0=9794203289623549276, d1=7309342082925068282, d2=1139538881605221074), e1=Uint384(d0=4897101644811774638, d1=3654671041462534141, d2=569769440802610537)),
        z_inv=FQ2(e0=Uint384(d0=12452452969679491344, d1=11374291236854484173, d2=13099329512014041791), e1=Uint384(d0=16399576568092893731, d1=5746367929944742296, d2=886009817557060804)),
        minus_b_over_a=FQ2(e0=Uint384(d0=10393275865055580083, d1=6888480573845999877, d2=11497223857339693790), e1=Uint384(d0=3009155151022283512, d1=13768405011380760314, d2=14385194789933939525))
        ))
end

# implementation https://datatracker.ietf.org/doc/html/draft-irtf-cfrg-hash-to-curve-06#section-6.6.2.1
func simplified_swu{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(u : FQ2) -> (x : FQ2, y : FQ2):
    alloc_locals

    let (params : ParamsSWU) = get_swu_g2_params()
    # should use squaring algorithm
    let (u_squared : FQ2) = fq2_lib.square(u)

    let (tv1 : FQ2) = fq2_lib.mul(u_squared, params.z)
    let (tv2 : FQ2) = fq2_lib.square(tv1)
    let (x1 : FQ2) = fq2_lib.add(tv1, tv2)

    let (x1 : FQ2) = fq2_lib.inv(x1)
    let (x1_is_not_zero : felt) = fq2_lib.check_is_not_zero(x1)

    let (one : FQ2) = fq2_lib.one()

    let (x1 : FQ2) = fq2_lib.add(x1, one)
    if x1_is_not_zero == 0:
        tempvar x1 : FQ2 = params.z_inv
    else:
        tempvar x1 = x1
    end

    let (x1 : FQ2) = fq2_lib.mul(x1, params.minus_b_over_a)

    let (gx1 : FQ2) = fq2_lib.square(x1)
    let (gx1 : FQ2) = fq2_lib.add(gx1, params.a)
    let (gx1 : FQ2) = fq2_lib.mul(gx1, x1)
    let (gx1 : FQ2) = fq2_lib.add(gx1, params.b)

    let (x2 : FQ2) = fq2_lib.mul(tv1, x1)

    let (tv2 : FQ2) = fq2_lib.mul(tv1, tv2)
    let (gx2 : FQ2) = fq2_lib.mul(gx1, tv2)

    let (is_nonresidue : felt) = fq2_lib.is_quadratic_nonresidue(gx1)

    if is_nonresidue == 1:
        tempvar x = x1
        tempvar y2 = gx1
    else:
        tempvar x = x2
        tempvar y2 = gx2
    end

    let (y : FQ2) = fq2_lib.sqrt(y2)

    return (x, y2)
end

func get_iso_3_z() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=340282366920938463463374607431768211455,
            d1=340282366920938463463374607431768211455,
            d2=340282366920938463463374607431768211455),
        e1=Uint384(d0=340282366920938463463374607431768211454,
            d1=340282366920938463463374607431768211455,
            d2=340282366920938463463374607431768211455)))
end

func get_iso_3_a() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=0,
            d1=0,
            d2=0),
        e1=Uint384(d0=240,
            d1=0,
            d2=0)))
end

func get_iso_3_b() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=1012,
            d1=0,
            d2=0),
        e1=Uint384(d0=1012,
            d1=0,
            d2=0)))
end

func get_eta_one() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=97710379176584833058534861421733158032,
            d1=235150566928972101101145896555062155640,
            d2=8773647769805767362649701180528995527),
        e1=Uint384(d0=72907088905583766286187874428783946165,
            d1=53834397263844341258217423639391948324,
            d2=10745394347322746542648937813521287652)
        ))
end

func get_eta_two() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=267375278015354697177186733002984265291,
            d1=286447969657094122205157183792376263131,
            d2=329536972573615716920725669618246923803),
        e1=Uint384(d0=97710379176584833058534861421733158032,
            d1=235150566928972101101145896555062155640,
            d2=8773647769805767362649701180528995527)
        ))
end

func get_eta_three() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=95450171764268221280445492964679872023,
            d1=91702902864024686091207920961879423746,
            d2=14215271560981299785781687939924171680),
        e1=Uint384(d0=9135564124949561123718946740112428993,
            d1=228759127577150150895163237045810393568,
            d2=14143908420745810639611080239366197452)
        ))
end

func get_eta_four() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=331146802795988902339655660691655782463,
            d1=111523239343788312568211370385957817887,
            d2=326138458500192652823763527192402014003),
        e1=Uint384(d0=95450171764268221280445492964679872023,
            d1=91702902864024686091207920961879423746,
            d2=14215271560981299785781687939924171680)
        ))
end

func optimized_sswu{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(t : FQ2) -> (
        x : FQ2, y : FQ2, z : FQ2):
    alloc_locals

    let (t2 : FQ2) = fq2_lib.pow(t, Uint768(d0=2, d1=0, d2=0, d3=0, d4=0, d5=0))
    let (iso_3_z : FQ2) = get_iso_3_z()

    let (iso_3_z_t2 : FQ2) = fq2_lib.mul(t2, iso_3_z)

    let (iso_3_z_t2_squared : FQ2) = fq2_lib.pow(
        iso_3_z_t2, Uint768(d0=2, d1=0, d2=0, d3=0, d4=0, d5=0))

    let (temp : FQ2) = fq2_lib.add(iso_3_z_t2, iso_3_z_t2_squared)

    let (iso_3_a : FQ2) = get_iso_3_a()
    let (denominator_positive : FQ2) = fq2_lib.mul(iso_3_a, temp)
    let (denominator : FQ2) = fq2_lib.neg(denominator_positive)

    let (fq2_one : FQ2) = fq2_lib.one()
    let (temp : FQ2) = fq2_lib.add(fq2_one, temp)
    let (iso_3_b : FQ2) = get_iso_3_b()

    let (numerator : FQ2) = fq2_lib.mul(iso_3_b, temp)

    let (is_denominator_zero : felt) = fq2_lib.is_zero(denominator)

    if is_denominator_zero == 1:
        let (denominator : FQ2) = fq2_lib.mul(iso_3_z, iso_3_a)
        tempvar denominator = denominator
        tempvar range_check_ptr = range_check_ptr
        tempvar bitwise_ptr = bitwise_ptr
    else:
        tempvar denominator = denominator
        tempvar range_check_ptr = range_check_ptr
        tempvar bitwise_ptr = bitwise_ptr
    end

    tempvar range_check_ptr = range_check_ptr
    tempvar bitwise_ptr = bitwise_ptr
    tempvar denominator = denominator
    let (u : FQ2, v : FQ2) = get_u_and_v(numerator, denominator)

    let (success : felt, y : FQ2) = sqrt_div(u, v)

    if success == 1:
        let (denominator : FQ2) = fq2_lib.mul(denominator, y)

        return (x=numerator, y=y, z=denominator)
    end

    let (sign_t : felt) = fq2_lib.sgn0(t)

    # u(x1) = Z^3 * t^6 * u(x0)
    let (t_cubed : FQ2) = fq2_lib.pow(t, Uint768(d0=3, d1=0, d2=0, d3=0, d4=0, d5=0))
    let (sqrt_candidate : FQ2) = fq2_lib.mul(t_cubed, t_cubed)

    let (eta_one : FQ2) = get_eta_one()
    let (success_eta_one : felt, y : FQ2) = test_eta(sqrt_candidate, eta_one, u, v)

    if success_eta_one == 1:
        let (numerator : FQ2) = fq2_lib.mul(iso_3_z_t2, numerator)
        let (denominator : FQ2) = fq2_lib.mul(denominator, y)
        let (sign_y : felt) = fq2_lib.sgn0(y)
        if sign_y != sign_t:
            let (y : FQ2) = fq2_lib.neg(y)
            return (x=numerator, y=y, z=denominator)
        else:
            return (x=numerator, y=y, z=denominator)
        end
    end

    let (eta_two : FQ2) = get_eta_two()
    let (success_eta_two : felt, y : FQ2) = test_eta(sqrt_candidate, eta_two, u, v)

    if success_eta_two == 1:
        let (numerator : FQ2) = fq2_lib.mul(iso_3_z_t2, numerator)
        let (denominator : FQ2) = fq2_lib.mul(denominator, y)
        let (sign_y : felt) = fq2_lib.sgn0(y)
        if sign_y != sign_t:
            let (y : FQ2) = fq2_lib.neg(y)
            return (x=numerator, y=y, z=denominator)
        else:
            return (x=numerator, y=y, z=denominator)
        end
    end

    let (eta_three : FQ2) = get_eta_three()
    let (success_eta_three : felt, y : FQ2) = test_eta(sqrt_candidate, eta_three, u, v)

    if success_eta_three == 1:
        let (numerator : FQ2) = fq2_lib.mul(iso_3_z_t2, numerator)
        let (denominator : FQ2) = fq2_lib.mul(denominator, y)
        let (sign_y : felt) = fq2_lib.sgn0(y)
        if sign_y != sign_t:
            let (y : FQ2) = fq2_lib.neg(y)
            return (x=numerator, y=y, z=denominator)
        else:
            return (x=numerator, y=y, z=denominator)
        end
    end

    let (eta_four : FQ2) = get_eta_four()
    let (success_eta_four : felt, y : FQ2) = test_eta(sqrt_candidate, eta_four, u, v)

    if success_eta_four == 1:
        let (numerator : FQ2) = fq2_lib.mul(iso_3_z_t2, numerator)
        let (denominator : FQ2) = fq2_lib.mul(denominator, y)
        let (sign_y : felt) = fq2_lib.sgn0(y)
        if sign_y != sign_t:
            let (y : FQ2) = fq2_lib.neg(y)
            return (x=numerator, y=y, z=denominator)
        else:
            return (x=numerator, y=y, z=denominator)
        end
    end

    # TODO : throw error with message here
    assert 1 = 0
    return (u, u, u)
end

func test_eta{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        sqrt_candidate : FQ2, eta : FQ2, u : FQ2, v : FQ2) -> (success_eta : felt, y : FQ2):
    alloc_locals
    let (eta_sqrt_candidate : FQ2) = fq2_lib.mul(eta, sqrt_candidate)
    let (eta_sqrt_candidate_squared : FQ2) = fq2_lib.pow(
        eta_sqrt_candidate, Uint768(d0=2, d1=0, d2=0, d3=0, d4=0, d5=0))

    let (temp1) = x_mul_v_min_u(eta_sqrt_candidate_squared, u, v)

    let (is_temp1_zero : felt) = fq2_lib.is_zero(temp1)

    if is_temp1_zero == 1:
        return (success_eta=1, y=eta_sqrt_candidate)
    else:
        return (success_eta=1, y=eta_sqrt_candidate)
    end
end

func get_u_and_v{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        numerator : FQ2, denominator : FQ2) -> (u : FQ2, v : FQ2):
    alloc_locals
    let (v : FQ2) = fq2_lib.pow(denominator, Uint768(d0=3, d1=0, d2=0, d3=0, d4=0, d5=0))

    # u = N^3 + a * N * D^2 + b* D^3
    let (numerator_cubed : FQ2) = fq2_lib.pow(
        numerator, Uint768(d0=3, d1=0, d2=0, d3=0, d4=0, d5=0))

    let (denominator_squared : FQ2) = fq2_lib.pow(
        denominator, Uint768(d0=2, d1=0, d2=0, d3=0, d4=0, d5=0))

    let (times_numerator : FQ2) = fq2_lib.mul(numerator, denominator_squared)
    let (iso_3_a : FQ2) = get_iso_3_a()
    let (times_iso_3_a : FQ2) = fq2_lib.mul(iso_3_a, times_numerator)

    let (iso_3_b : FQ2) = get_iso_3_b()
    let (iso_3_b_mul_v : FQ2) = fq2_lib.mul(iso_3_b, v)

    let (u : FQ2) = fq2_lib.add_three_terms(numerator_cubed, times_iso_3_a, iso_3_b_mul_v)

    return (u, v)
end

func get_p_minus_9_div_16() -> (p_minus_9_div_16 : Uint768):
    return (
        p_minus_9_div_16=Uint768(d0=286857986772314612652822467347357309155,
        d1=199944827894017520769600272993951486927,
        d2=23710747341675874659599022676268096004,
        d3=6700067088695907924253780480712216304,
        d4=210255754591213467865922552437427267773,
        d5=219445078718614456327821801537335902))
end

# FQ2([1, 0])
func get_roots_of_unity_one() -> (res : FQ2):
    return (FQ2(e0=Uint384(d0=1, d1=0, d2=0), e1=Uint384(d0=0, d1=0, d2=0)))
end

# FQ2([0, 1])
func get_roots_of_unity_two() -> (res : FQ2):
    return (FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=1, d1=0, d2=0)))
end

# FQ2([RV1, RV1])
func get_roots_of_unity_three() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=316894176541198687613159979572632210441, d1=96002276489854850962923926559567004101, d2=8884304212930445318911794655404326910), e1=Uint384(d0=316894176541198687613159979572632210441, d1=96002276489854850962923926559567004101, d2=8884304212930445318911794655404326910)))
end

# FQ2([RV1, -RV1])
func get_roots_of_unity_four() -> (res : FQ2):
    return (
        FQ2(e0=Uint384(d0=316894176541198687613159979572632210441, d1=96002276489854850962923926559567004101, d2=8884304212930445318911794655404326910), e1=Uint384(d0=23388190379739775850214627859136001015, d1=244280090431083612500450680872201207354, d2=331398062708008018144462812776363884545)))
end

func sqrt_div{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(u : FQ2, v : FQ2) -> (
        is_valid : felt, sqrt_candidate : FQ2):
    alloc_locals
    let (inv_v : FQ2) = fq2_lib.inv(v)

    let (u_div_v : FQ2) = fq2_lib.mul(u, v)

    let (success : felt, sqrt : FQ2) = fq2_lib.get_square_root(u_div_v)
    return (success, sqrt)
end

func sqrt_div_fq2{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(u : FQ2, v : FQ2) -> (
        is_valid : felt, sqrt_candidate : FQ2):
    alloc_locals

    let (v_pow_seven : FQ2) = fq2_lib.pow(v, Uint768(d0=7, d1=0, d2=0, d3=0, d4=0, d5=0))
    let (t0 : FQ2) = fq2_lib.mul(u, v_pow_seven)
    let (v_pow_eight : FQ2) = fq2_lib.pow(v, Uint768(d0=8, d1=0, d2=0, d3=0, d4=0, d5=0))
    let (t1 : FQ2) = fq2_lib.mul(t0, v_pow_eight)

    let (p_minus_9_div_16 : Uint768) = get_p_minus_9_div_16()

    let (gamma : FQ2) = fq2_lib.pow(t1, p_minus_9_div_16)
    let (gamma : FQ2) = fq2_lib.mul(t0, gamma)

    let (root : FQ2) = get_roots_of_unity_one()
    let (sqrt_candidate : FQ2) = fq2_lib.mul(gamma, root)

    let (temp2 : FQ2) = x_mul_v_min_u(sqrt_candidate, u, v)

    let (is_valid_sqrt : felt) = fq2_lib.is_zero(temp2)

    if is_valid_sqrt == 1:
        return (is_valid=1, sqrt_candidate=sqrt_candidate)
    end

    let (root : FQ2) = get_roots_of_unity_two()
    let (sqrt_candidate : FQ2) = fq2_lib.mul(gamma, root)

    let (temp2 : FQ2) = x_mul_v_min_u(sqrt_candidate, u, v)

    let (is_valid_sqrt : felt) = fq2_lib.is_zero(temp2)

    if is_valid_sqrt == 1:
        return (is_valid=1, sqrt_candidate=sqrt_candidate)
    end

    let (root : FQ2) = get_roots_of_unity_three()
    let (sqrt_candidate : FQ2) = fq2_lib.mul(gamma, root)

    let (temp2 : FQ2) = x_mul_v_min_u(sqrt_candidate, u, v)

    let (is_valid_sqrt : felt) = fq2_lib.is_zero(temp2)

    if is_valid_sqrt == 1:
        return (is_valid=1, sqrt_candidate=sqrt_candidate)
    end

    let (root : FQ2) = get_roots_of_unity_four()
    let (sqrt_candidate : FQ2) = fq2_lib.mul(gamma, root)

    let (temp2 : FQ2) = x_mul_v_min_u(sqrt_candidate, u, v)

    let (is_valid_sqrt : felt) = fq2_lib.is_zero(temp2)

    if is_valid_sqrt == 1:
        return (is_valid=1, sqrt_candidate=sqrt_candidate)
    end

    return (is_valid=0, sqrt_candidate=u)
end

func x_mul_v_min_u{range_check_ptr, bitwise_ptr : BitwiseBuiltin*}(
        sqrt_candidate : FQ2, u : FQ2, v : FQ2) -> (res : FQ2):
    alloc_locals
    let (sqrt_candidate_squared : FQ2) = fq2_lib.pow(
        sqrt_candidate, Uint768(d0=2, d1=0, d2=0, d3=0, d4=0, d5=0))
    let (times_v : FQ2) = fq2_lib.mul(sqrt_candidate_squared, v)
    let (temp2 : FQ2) = fq2_lib.sub(times_v, v)

    return (res=temp2)
end
