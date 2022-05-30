from lib.uint384 import Uint384

# Default modulus is field modulus for bls12-381 elliptic curve.
# decimal p = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
const P0 = 40769914829639538012874174947278170795
const P1 = 133542214618860690590306275168919549476
const P2 = 34565483545414906068789196026815425751

# (p-1)/2
const p_minus_one_div_2 = 2001204777610833805330894342995218419412155208657854580098133973608675194230876109464055216763280572277757820534784

const P0_p_minus_one_div_2 = 0
const P1_p_minus_one_div_2 = 0
const P2_p_minus_one_div_2 = 17282741772707453972472493883359494144

# @dev modify the returned value of this function to adjust the modulus
# @dev modulus must be less than 2 ** (128 * 3)
func get_modulus{range_check_ptr}() -> (mod : Uint384):
    return (mod=Uint384(d0=P0, d1=P1, d2=P2))
end


func get_p_minus_one_div_2()-> (res :Uint384):
    return (res=Uint384(d0=P0_p_minus_one_div_2, d1=P1_p_minus_one_div_2, d2=P2_p_minus_one_div_2))
end

# Modulus coefficients for fq2
const fq2_c0 = 1
const fq2_c1 = 0

# Modulus coefficients for fq12
const fq12_c0 = 2
const fq12_c1 = 0
const fq12_c2 = 0
const fq12_c3 = 0
const fq12_c4 = 0
const fq12_c5 = 0
const fq12_c6 = -2
const fq12_c7 = 0
const fq12_c8 = 0
const fq12_c9 = 0
const fq12_c10 = 0
const fq12_c11 = 0
