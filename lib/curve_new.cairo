from lib.uint384 import Uint384, Uint384_expand

// Default modulus is field modulus for bls12-381 elliptic curve.
// decimal p = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
const P0 = 40769914829639538012874174947278170795;
const P1 = 133542214618860690590306275168919549476;
const P2 = 34565483545414906068789196026815425751;

//split64(modulus)



//entries of the 'expanded' modulus in the sense of the Uint384_expand struct
const P0exp = 247231214919135414563355292530659819520;
const P1exp = 40769914829639538012874174947278170795;
const P2exp = 137163985873926021497095410661308235775;
const P3exp = 133542214618860690590306275168919549476;
const P4exp = 99835693301805499553651678317486871231;
const P5exp = 34565483545414906068789196026815425751;
const P6exp = 1873798617647539866;

// (p-1)/2
const p_minus_one_div_2 = 2001204777610833696708894912867952078278441409969503942666029068062015825245418932221343814564507832018947136279893;

const P0_p_minus_one_div_2 = 20384957414819769006437087473639085397;
const P1_p_minus_one_div_2 = 236912290769899577026840441300343880466;
const P2_p_minus_one_div_2 = 17282741772707453034394598013407712875;

// @dev modify the returned value of this function to adjust the modulus
// @dev modulus must be less than 2 ** (128 * 3)
func get_modulus() -> (mod: Uint384) {
    return (mod=Uint384(d0=P0, d1=P1, d2=P2));
}

//returns the modulus in a Uint384_expand format
func get_modulus_expand() -> (modexp:Uint384_expand) {
    return (modexp=Uint384_expand(P0exp, P1exp, P2exp, P3exp, P4exp, P5exp, P6exp));
}

func get_p_minus_one_div_2() -> (res: Uint384) {
    return (res=Uint384(d0=P0_p_minus_one_div_2, d1=P1_p_minus_one_div_2, d2=P2_p_minus_one_div_2));
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