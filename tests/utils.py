from typing import List, Union, TypeVar, Callable
from py_ecc.fields import optimized_bls12_381_FQ2 as FQ2
one_bigint6 = (1, 0, 0, 0, 0, 0)

max_base_bigint6 = (2**64 - 1, 0, 0, 0, 0, 0)
max_base_bigint6_sum = (2**384) - 1
max_base_bigint12_sum = (2**768) - 1
base = 2**64

field_modulus = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
field_modulus_sub1_div2 = 2001204777610833696708894912867952078278441409969503942666029068062015825245418932221343814564507832018947136279893
max_felt = 2**241
max_limb = 2**128 - 1
all_ones = 2**384 - 1
    

def split(num: int, num_bits_shift: int = 128, length: int = 3):
    a = []
    for _ in range(length):
        a.append(num & ((1 << num_bits_shift) - 1))
        num = num >> num_bits_shift
    return tuple(a)


def splitFQP(z):
    return tuple(split(z_component) for z_component in z)


# Not checking for num = 0
def unsafe_split(num: int, length: int = 6) -> List[int]:
    BASE = 2**64
    a = []
    for _ in range(length):
        num, residue = divmod(num, BASE)
        a.append(residue)
    return tuple(a), num


def pack(z, num_bits_shift: int = 128) -> int:
    limbs = list(z)
    return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))


def packFQP(z):
    return tuple(pack(z_component) for z_component in z)

def packPoint(z):
    return tuple(packFQP(z_component) for z_component in z)

def print_uint384(x):
    parts = split(x)

    print("Uint384(", "d0=", parts[0] , ", d1=", parts[1], ", d2= ", parts[2], ")", end='')

# TODO: Not used?
def pack12(z):
    limbs = z.d0, z.d1, z.d2, z.d3, z.d4, z.d5, z.d6, z.d7, z.d8, z.d9, z.d10, z.d11
    return sum(limb * 2 ** (64 * i) for i, limb in enumerate(limbs))


# TODO: Not used?
def packEnum(z):
    return (
        z[0]
        + z[1] * 2**64
        + z[2] * 2 ** (64 * 2)
        + z[3] * 2 ** (64 * 3)
        + z[4] * 2 ** (64 * 4)
        + z[5] * 2 ** (64 * 5)
    )

def print_fq2(params):
    print("FQ2(", "e0=", end='')
    print_uint384(params[0])
    print(", e1=", end='')
    print_uint384(params[1])
    print(")")

def neg_to_uint384(num):
    return split(all_ones - num + 1)


def bitwise_or_bytes(var, key):
    return bytes(a ^ b for a, b in zip(var, key))

bytes_to_int_little: Callable[[bytes], int] = lambda word: int.from_bytes(word, "little")

bytes_32_to_uint_256_little : Callable[[bytes], tuple] = lambda word : split(bytes_to_int_little(word), 128, 2)

T_Uint384 = TypeVar('T_Uint384', bound="Uint384")
IntOrUint384 = Union[int, T_Uint384]
IntOrTuple = Union[int, tuple]


class Uint384:
    def __init__(self, val: IntOrTuple):

        if isinstance(val, int):
            parts = split(val)
            self.d0 = parts[0]
            self.d1 = parts[1]
            self.d2 = parts[2]
        elif isinstance(val, tuple):
            self.d0 = val[0]
            self.d1 = val[1]
            self.d2 = val[2]

        else:
            raise TypeError(
                "Expected an int or tuple, but got object of type {}".format(type(val))
            )

    def __repr__(self):
        return f"Uint384 value is {self.d0, self.d1, self.d2}"

    def __eq__(self, other: IntOrUint384) -> bool:
        if isinstance(other, int):
            return pack(self.asTuple()) == int
        elif isinstance(other, Uint384):
            return pack(self.asTuple()) == pack(other.asTuple())
        else:
            raise TypeError(
                "Expected an int or Uint384, but got object of type {}".format(
                    type(other)
                )
            )

    def asTuple(self) -> tuple:
        return (self.d0, self.d1, self.d2)

