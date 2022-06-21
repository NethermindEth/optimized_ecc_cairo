from utils import Uint384, split, pack
from py_ecc.fields import optimized_bls12_381_FQ2 as FQ2

# This is a modification of Optimized_Point3D from the `py_ecc` library.
# For some reason I was getting typing errors with it so I wrote a minimal modified implementation
class Optimized_Point3D_Modified(object):
    def __init__(self, x: FQ2, y: FQ2, z: FQ2):
        self.x = x
        self.y = y
        self.z = z

    def __eq__(self, other):
        print(self.x / self.z)
        print(other.x / other.z)
        print(self.y / self.z)
        print(other.y / other.z)
        if self.z == FQ2.zero():
            return other.z == FQ2.zero()
        else:
            true_x_self = self.x / (self.z)
            true_y_self = self.y / (self.z)
            true_x_other = other.x / (other.z)
            true_y_other = other.y / (other.z)
            print((true_x_self == true_x_other), (true_y_self == true_y_other))
            return (true_x_self == true_x_other) and (true_y_self == true_y_other)
        
    def asTuple(self):
        return (
            tuple([split(coef)  for coef in self.x.coeffs]), 
            tuple([split(coef)  for coef in self.y.coeffs]), 
            tuple([split(coef)  for coef in self.z.coeffs]), 
            )
        
    def __repr__(self):
        return f"Optimized_Point3D_Modified({self.x}, {self.y}, {self.z})"

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
        #FQ2((pack(result[2][0]), pack(result[2][1]))),
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
def g2_scalar_mul(scalar: Uint384, pt: Optimized_Point3D_Modified) -> Optimized_Point3D_Modified:
    scalar = pack(list(scalar))
    if scalar == 0:
        return Optimized_Point3D_Modified(FQ2.one(), FQ2.one(), FQ2.zero())
    elif scalar == 1:
        return pt
    elif not scalar % 2:
        return g2_scalar_mul(split(scalar // 2), g2_double(pt))
    else:
        return g2_add(g2_scalar_mul( split(int(scalar // 2)), g2_double(pt)), pt)

def get_g2_infinity_point():
    return Optimized_Point3D_Modified(
        FQ2.one(),
        FQ2.one(),
        FQ2.zero(),
    )