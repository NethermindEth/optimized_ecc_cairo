from utils import (pack, print_fq2)
from py_ecc.bls.hash_to_curve import iso_map_G2
from py_ecc.fields import (
    optimized_bls12_381_FQ2 as FQ2,
)

def print_isogyny_params( x_num_1, x_num_2, x_num_3, x_num_4, x_den_1, x_den_2, x_den_3, x_den_4,y_num_1, y_num_2, y_num_3, y_num_4,y_den_1, y_den_2, y_den_3, y_den_4,
):
    print("ParamsThreeIsogenyG2(")

    print("x_num_1=", end='')
    print_fq2(x_num_1)
    print(",")

    print("x_num_2=", end='')
    print_fq2(x_num_2)
    print(",")

    print("x_num_3=", end='')
    print_fq2(x_num_3)
    print(",")

    print("x_num_4=", end='')
    print_fq2(x_num_4)
    print(",")

    print("x_den_1=", end='')
    print_fq2(x_den_1)
    print(",")

    print("x_den_2=", end='')
    print_fq2(x_den_2)
    print(",")

    print("x_den_3=", end='')
    print_fq2(x_den_3)
    print(",")

    print("x_den_4=", end='')
    print_fq2(x_den_4)
    print(",")

    print("y_num_1=", end='')
    print_fq2(y_num_1)
    print(",")

    print("y_num_2=", end='')
    print_fq2(y_num_2)
    print(",")

    print("y_num_3=", end='')
    print_fq2(y_num_3)
    print(",")

    print("y_num_4=", end='')
    print_fq2(y_num_4)
    print(",")

    print("y_den_1=", end='')
    print_fq2(y_den_1)
    print(",")

    print("y_den_2=", end='')
    print_fq2(y_den_2)
    print(",")

    print("y_den_3=", end='')
    print_fq2(y_den_3)
    print(",")

    print("y_den_4=", end='')
    print_fq2(y_den_4)
    print(")")



def three_isogeny_constants_g2():
    ISO_3_K_1_0_VAL = 889424345604814976315064405719089812568196182208668418962679585805340366775741747653930584250892369786198727235542  # noqa: E501
    x_num_1 = ISO_3_K_1_0_VAL
    x_num_1_i = ISO_3_K_1_0_VAL

    x_num_2_i = 2668273036814444928945193217157269437704588546626005256888038757416021100327225242961791752752677109358596181706522

    x_num_3 = 2668273036814444928945193217157269437704588546626005256888038757416021100327225242961791752752677109358596181706526
    x_num_3_i = 1334136518407222464472596608578634718852294273313002628444019378708010550163612621480895876376338554679298090853261

    x_num_4 = 3557697382419259905260257622876359250272784728834673675850718343221361467102966990615722337003569479144794908942033

    x_den_1_i = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559715
    
    x_den_2 = 12
    x_den_2_i = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559775
    ISO_3_K_3_0_VAL = 3261222600550988246488569487636662646083386001431784202863158481286248011511053074731078808919938689216061999863558 
    y_num_1 = ISO_3_K_3_0_VAL
    y_num_1_i = ISO_3_K_3_0_VAL

    y_num_2_i = 889424345604814976315064405719089812568196182208668418962679585805340366775741747653930584250892369786198727235518

    y_num_3 =2668273036814444928945193217157269437704588546626005256888038757416021100327225242961791752752677109358596181706524
    y_num_3_i = 1334136518407222464472596608578634718852294273313002628444019378708010550163612621480895876376338554679298090853263

    y_num_4 = 2816510427748580758331037284777117739799287910327449993381818688383577828123182200904113516794492504322962636245776

    ISO_3_K_4_0_VAL = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559355 
    y_den_1 = ISO_3_K_4_0_VAL
    y_den_1_i = ISO_3_K_4_0_VAL

    y_den_2_i = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559571

    y_den_3 = 18
    y_den_3_i = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559769

    #projected_one = pack([int('760900000002fffd', 16), int('ebf4000bc40c0002', 16), int('5f48985753c758ba', 16), int('77ce585370525745', 16), int('5c071a97a256ec6d', 16), int('15f65ec3fa80e493', 16)], 64)
    
    #temp = pack([int('47f671c71ce05e62', 16), int('06dd57071206393e', 16), int('7c80cd2af3fd71a2', 16), int('048103ea9e6cd062',16), int('c54516acc8d037f6',16), int('13808f550920ea41',16)], 64)
    
    print_isogyny_params(
        [x_num_1, x_num_1_i],
        [0, x_num_2_i],
        [x_num_3, x_num_3_i],
        [x_num_4, 0],
        [0, x_den_1_i],
        [x_den_2, x_den_2_i],
        [1,0],
        [0,0],
        [y_num_1, y_num_1_i],
        [0, y_num_2_i],
        [y_num_3, y_num_3_i],
        [y_num_4, 0],
        [y_den_1, y_den_1_i],
        [0, y_den_2_i],
        [y_den_3, y_den_3_i],
        [1, 0]
    )
    
    

#three_isogeny_constants_g2()
x_e0 = 1
x_e1 = 2
y_e0 = 3
y_e1 = 4
z_e0 = 5
z_e1 = 6
#py_ecc_res = iso_map_G2(FQ2((x_e0, x_e1)), FQ2((y_e0, y_e1)), FQ2((z_e0, z_e1)))

class fq():
    def __init__(self, d0, d1, d2):
      self.d0 = d0
      self.d1 = d1
      self.d2 = d2
class fq2():
    def __init__(self, e0, e1):
      self.e0 = e0
      self.e1 = e1


def pack(z, num_bits_shift: int = 128) -> int:
    limbs = (z.d0, z.d1, z.d2)
    return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

def packFQP(z):
    z_split = (z.e0, z.e1)
    return tuple(pack(z_component) for i, z_component in enumerate(z_split))

e1 = fq(1, 2, 3)
e0 = fq(1,2,3)
res = fq2(e0, e1)

#print(packFQP(res))

three_isogeny_constants_g2()