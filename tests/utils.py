from typing import List, Tuple, Union, TypeVar
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



def split(num: int, num_bits_shift: int = 128, length: int = 3) -> List[int]:
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
    limbs = (limb for limb in z)
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


T_G1Point = TypeVar("T_G1Point", bound="G1Point")
IntTuple = (int, int, int)
BigInt6Tuple = (T_Uint384, T_Uint384, T_Uint384)
TupleOrG1Point = Union[tuple, T_G1Point]
class G1Point: 
    def __init__(self, values: tuple): 
        if isinstance(values, int):
            parts = split(values)
            self.d0 = parts[0]
            self.d1 = parts[1]
            self.d2 = parts[2]
        elif isinstance(values, tuple):
            self.d0 = values[0]
            self.d1 = values[1]
            self.d2 = values[2]

    def __eq__(self, other: TupleOrG1Point) -> bool:
        if isinstance(other, tuple):
            return (
                self.x
                == Uint384(other[0]) & self.y
                == Uint384(other[1]) & self.z
                == Uint384(other[2])
            )
        elif isinstance(other, tuple):
            return self.x == other[0] & self.y == other[1] & self.z == other[2]
        elif isinstance(other, G1Point):
            return (self.x == other.x) & (self.y == other.y) & (self.z == other.z)
        else:
            raise TypeError(
                "Expected a tuple or G1Point, but got object of type {}".format(
                    type(other)
                )
            )

    def asTuple(self) -> tuple:
        return (self.x.asTuple(), self.y.asTuple(), self.z.asTuple())

    def __str__(self):
        return f"G1Point coordinates are {pack(self.x.asTuple())}, {pack(self.y.asTuple())}, {pack(self.z.asTuple())})"


# TODO: Add typing support similarly as in other classes
class FQ2Element:
    def __init__(self, e0: Uint384, e1:Uint384):
        self.e0 = e0
        self.e1 = e1
    
    def __eq__(self, other):
        return (self.e0 == other.e0) & (self.e1 == other.e1)
    
    def __repr__(self):
        return f"FQ2 element: {self.e0}, {self.e1}"
    
    def asTuple(self):
        return (self.e0.asTuple(), self.e1.asTuple())

T_G2Point = TypeVar("T_G2Point", bound="G2Point")
TupleOrG2Point = Union[tuple, T_G2Point]


# This is a modification of Optimized_Point3D from the `py_ecc` library.
# For some reason I was getting typing errors with it so I wrote a minimal modified implementation
class Optimized_Point3D_Modified(object):
    def __init__(self, x: FQ2, y: FQ2, z: FQ2):
        self.x = x
        self.y = y
        self.z = z

    def __eq__(self, other):
        print(self.x * self.z)
        print(other.x * other.z)
        return self.x * self.z == other.x * other.z
    
    def asTuple(self):
        return (
            tuple([split(coef)  for coef in self.x.coeffs]), 
            tuple([split(coef)  for coef in self.y.coeffs]), 
            tuple([split(coef)  for coef in self.z.coeffs]), 
            )
    
    def __repr__(self):
        return f"({self.x}, {self.y}, {self.z})"

# Given an initial integer seed, creates a G2 point by taking the powers of the seed
# Used in testing: to reduce the number of variables to be explored by `hypothesis`
def get_g2_point_from_seed(seed):
    components = [pow(seed, exp) for exp in range(6)]
    return Optimized_Point3D_Modified(
        FQ2((components[0], components[1])),
        FQ2((components[2], components[3])),
        FQ2((components[4], components[5])),
    )

# Given a G2Point resulting from a call to a StarkNet contract,
# it created the corresponding `Optimized_Point3D_Modified` version
# of the point
def create_G2Point_from_execution_result(result): 
    return Optimized_Point3D_Modified(
        FQ2((pack(result[0][0]), pack(result[0][1]))),
        FQ2((pack(result[1][0]), pack(result[1][1]))),
        FQ2((pack(result[2][0]), pack(result[2][1]))),
    )

def create_G2Point_from_tuple(tuple_of_reduced_integers): 
    t = tuple_of_reduced_integers
    return Optimized_Point3D_Modified(
        FQ2((t[0], t[1])),
        FQ2((t[2], t[3])),
        FQ2((t[4], t[5])),
    )
            
# ----------------------------------------------------------------
#
# Almost copy-paste functions from py_ecc.optimized_curve
# Modified to use `Optimized_Point3D_Modified` instead of `Optimized_Point3D`
#
#
# ----------------------------------------------------------------
def g2_double(pt: Optimized_Point3D_Modified) -> Optimized_Point3D_Modified:
    x, y, z = pt.x, pt.y, pt.z
    W = 3 * x * x
    S = y * z
    B = x * y * S
    H = W * W - 8 * B
    S_squared = S * S
    newx = 2 * H * S
    newy = W * (4 * B - H) - 8 * y * y * S_squared
    newz = 8 * S * S_squared
    return Optimized_Point3D_Modified(newx, newy, newz)


# Elliptic curve addition
def g2_add(p1: Optimized_Point3D_Modified,
        p2: Optimized_Point3D_Modified) -> Optimized_Point3D_Modified:    
    zero = FQ2.zero()
    one = FQ2.one()
    if p1.z == zero or p2.z == zero:
        return p1 if p2.z == zero else p2
    x1, y1, z1 = p1.x, p1.y, p1.z
    x2, y2, z2 = p2.x, p2.y, p2.z
    U1 = y2 * z1
    U2 = y1 * z2
    V1 = x2 * z1
    V2 = x1 * z2
    if V1 == V2 and U1 == U2:
        return g2_double(p1)
    elif V1 == V2:
        return Optimized_Point3D_Modified(one, one, zero)
    U = U1 - U2
    V = V1 - V2
    V_squared = V * V
    V_squared_times_V2 = V_squared * V2
    V_cubed = V * V_squared
    W = z1 * z2
    A = U * U * W - V_cubed - 2 * V_squared_times_V2
    newx = V * A
    newy = U * (V_squared_times_V2 - A) - V_cubed * U2
    newz = V_cubed * W
    return Optimized_Point3D_Modified(newx, newy, newz)



# Elliptic curve point multiplication
def g2_scalar_mul(scalar, pt: Optimized_Point3D_Modified) -> Optimized_Point3D_Modified:
    if scalar == 0:
        return Optimized_Point3D_Modified(FQ2.one(), FQ2.one(), FQ2.zero())
    elif scalar == 1:
        return pt
    elif not scalar % 2:
        return g2_scalar_mul(scalar // 2, g2_double(pt))
    else:
        return g2_add(g2_scalar_mul( int(scalar // 2), g2_double(pt)), pt)

def get_g2_infinity_point():
    return Optimized_Point3D_Modified(
        FQ2.one(),
        FQ2.one(),
        FQ2.zero(),
    )