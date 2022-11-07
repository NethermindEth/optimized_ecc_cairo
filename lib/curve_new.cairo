from lib.uint384 import Uint384, Uint384_expand

// Default modulus is field modulus for bls12-381 elliptic curve.
// decimal p = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
// hex p = 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab

//entries of the 'expanded' modulus in the sense of the Uint384_expand struct
const P0exp =                                                                                 0xb9feffffffffaaab0000000000000000;
const P1exp =                                                                 0x1eabfffeb153ffffb9feffffffffaaab;
const P2exp =                                                 0x6730d2a0f6b0f6241eabfffeb153ffff;
const P3exp =                                 0x64774b84f38512bf6730d2a0f6b0f624;
const P4exp =                 0x4b1ba7b6434bacd764774b84f38512bf;
const P5exp = 0x1a0111ea397fe69a4b1ba7b6434bacd7;
const P6exp = 0x1a0111ea397fe69a;

const P0 = P1exp;
const P1 = P3exp;
const P2 = P5exp;

//p-1
func get_p_minus_one() -> (res:Uint384) {
    return(res=Uint384(0x1eabfffeb153ffffb9feffffffffaaaa, P1, P2));
}

//inverse of 2 modulo p is 2001204777610833696708894912867952078278441409969503942666029068062015825245418932221343814564507832018947136279894 in decimal
//inverse of 2 modulo p, as a Uint384
const twoinvd0=20384957414819769006437087473639085398;
const twoinvd1=236912290769899577026840441300343880466;
const twoinvd2=17282741772707453034394598013407712875;

// inverse of 2 modulo p, as a Uint384_expand
const twoinv0=293756790920036939022588322018068791296;
const twoinv1=20384957414819769006437087473639085398;
const twoinv2=238723176397432242480235009046538223615;
const twoinv3=236912290769899577026840441300343880466;
const twoinv4=49917846650902749776825839158743435615;
const twoinv5=17282741772707453034394598013407712875;
const twoinv6=936899308823769933;


// (p-1)/2
const p_minus_one_div_2 = 2001204777610833696708894912867952078278441409969503942666029068062015825245418932221343814564507832018947136279893;

const P0_p_minus_one_div_2 = 20384957414819769006437087473639085397;
const P1_p_minus_one_div_2 = 236912290769899577026840441300343880466;
const P2_p_minus_one_div_2 = 17282741772707453034394598013407712875;

// 2*p
const twice_p0 = 0x3d57fffd62a7ffff73fdffffffff5556;
const twice_p1 = 0xc8ee9709e70a257ece61a541ed61ec48;
const twice_p2 = 0x340223d472ffcd3496374f6c869759ae;

// @dev modify the returned value of this function to adjust the modulus
// @dev modulus must be less than 2 ** (128 * 3)
func get_modulus() -> (mod: Uint384) {
    return (mod=Uint384(d0=P0, d1=P1, d2=P2));
}

//returns the modulus in a Uint384_expand format
func get_modulus_expand() -> (modexp:Uint384_expand) {
    return (modexp=Uint384_expand(P0exp, P1exp, P2exp, P3exp, P4exp, P5exp, P6exp));
}

func get_2_inverse() -> (twoinv:Uint384) {
    return (twoinv=Uint384(twoinvd0, twoinvd1, twoinvd2));
}

func get_2_inverse_exp() -> (twoinvexp:Uint384_expand) {
    return (twoinvexp=Uint384_expand(twoinv0, twoinv1, twoinv2, twoinv3, twoinv4, twoinv5, twoinv6));
}

func get_p_minus_one_div_2() -> (res: Uint384) {
    return (res=Uint384(d0=P0_p_minus_one_div_2, d1=P1_p_minus_one_div_2, d2=P2_p_minus_one_div_2));
}

func get_twice_p() -> (twice_p: Uint384) {
    return (twice_p=Uint384(d0=twice_p0, d1=twice_p1, d2=twice_p2));
}

// Modulus coefficients for fq2
const fq2_c0 = 1;
const fq2_c1 = 0;

// Modulus coefficients for fq12
const fq12_c0 = 2;
const fq12_c1 = 0;
const fq12_c2 = 0;
const fq12_c3 = 0;
const fq12_c4 = 0;
const fq12_c5 = 0;
const fq12_c6 = -2;
const fq12_c7 = 0;
const fq12_c8 = 0;
const fq12_c9 = 0;
const fq12_c10 = 0;
const fq12_c11 = 0;

func get_r_squared() -> (r_squared: Uint384) {
    return (
        r_squared=Uint384(
        d0=13909649096278139578749890098095200070,
        d1=138133445170552300919073500999554807509,
        d2=23389023624093491168052924610514621741),
    );
}

func get_r_mod_p() -> (r_mod_p: Uint384) {
    return (
        r_mod_p=Uint384(
        d0=313635500375121084810881640338032885757,
        d1=159249536114007638540741953206796900538,
        d2=29193015012204308844271843190429379693),
    );
}
