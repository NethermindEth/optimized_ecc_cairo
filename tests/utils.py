from typing import List, Tuple, Union, TypeVar

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

def splitFQ2(z):
    return (split(z[0]), split(z[1]))

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



def G1Point(x, y, z):
    return (split(x), split(y), split(z))


T_BigInt6 = TypeVar('T_BigInt6', bound="BigInt6")
IntOrBigInt6 = Union[int, T_BigInt6]
IntOrTuple = Union[int, tuple]
class BigInt6:
    def __init__(self, val : IntOrTuple):

        if isinstance(val, int):
            parts = split(val)
            self.d0 = parts[0]
            self.d1 = parts[1]
            self.d2 = parts[2]
            self.d3 = parts[3]
            self.d4 = parts[4]
            self.d5 = parts[5]
        elif isinstance(val, tuple):
            self.d0 = val[0]
            self.d1 = val[1]
            self.d2 = val[2]
            self.d3 = val[3]
            self.d4 = val[4]
            self.d5 = val[5]
        else:
            raise TypeError(
                "Expected an int or tuple, but got object of type {}"
                .format(type(val))
            )

    def __str__(self):
        return f'Bigint6 value is {pack(self)})'

    def __eq__(self, other:  IntOrBigInt6 ) -> bool:
        if isinstance(other, int):
            return pack(self) == int
        elif isinstance(other, BigInt6):
            return pack(self) == pack(other)
        else:
            raise TypeError(
                "Expected an int or BigInt6, but got object of type {}"
                .format(type(other))
            )

    def asTuple(self) -> tuple:
        return (self.d0, self.d1, self.d2, self.d3, self.d4, self.d5)

T_G1Point = TypeVar('T_G1Point', bound="G1Point")
IntTuple = (int,int,int)
BigInt6Tuple = (T_BigInt6, T_BigInt6, T_BigInt6)
TupleOrG1Point = Union[tuple, T_G1Point]
class G1Point: 
    def __init__(self, values: tuple): 
        self.x = BigInt6(values[0])
        self.y = BigInt6(values[1])
        self.z = BigInt6(values[2])

    def __eq__(self, other : TupleOrG1Point) -> bool:
        if isinstance(other, tuple):
            return self.x == BigInt6(other[0]) &  self.y == BigInt6(other[1]) & self.z == BigInt6(other[2])
        elif isinstance(other, tuple):
            return self.x == other[0] & self.y == other[1] & self.z == other[2]
        elif isinstance(other, G1Point):
            return (self.x == other.x) & (self.y == other.y) & (self.z == other.z)
        else:
            raise TypeError(
                "Expected an tuple or G1Point, but got object of type {}"
                .format(type(other))
            )

    def asTuple(self) -> tuple:
        return (self.x.asTuple(), self.y.asTuple(), self.z.asTuple())

    def __str__(self):
        return f'G1Point coordinates are {pack(self.x)}, {pack(self.y)}, {pack(self.z)})'