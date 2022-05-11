from typing import List

one_bigint6 = ( 1, 0, 0, 0, 0, 0 )

max_base_bigint6 = (2 ** 64 - 1, 0, 0, 0, 0, 0)
max_base_bigint6_sum =( 2 ** 384 ) - 1
max_base_bigint12_sum =( 2 ** 768 ) - 1
base = 2 ** 64

field_modulus = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787

max_felt = 2**241

def split(num: int, length:int=6) -> List[int]:
    BASE = 2 ** 64
    a = []
    for _ in range(length):
        num, residue = divmod(num, BASE)
        a.append(residue)
    assert num == 0
    return tuple(a)

                


# Not checking for num = 0 
def unsafe_split(num: int, length:int=6) -> List[int]:
    BASE = 2 ** 64
    a = []
    for _ in range(length):
        num, residue = divmod(num, BASE)
        a.append(residue)
    return tuple(a),num

def pack(z):

    limbs = z.d0, z.d1, z.d2, z.d3, z.d4, z.d5

    return sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))

def packFQ2(z):
    return (pack(z.e0), pack(z.e1))

def pack12(z):
    limbs = z.d0, z.d1, z.d2, z.d3, z.d4, z.d5, z.d6, z.d7, z.d8, z.d9, z.d10, z.d11
    return sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))


def packEnum(z):
    return z[0] + z[1] * 2 ** 64  + z[2]   * 2 ** (64 * 2 ) + z[3]  * 2 ** (64 * 3)  + z[4] * 2 ** (64 * 4) + z[5]  * 2 ** (64 * 5)