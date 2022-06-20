
from py_ecc.optimized_bls12_381 import field_modulus as q
from py_ecc.optimized_bls12_381 import FQ2
from py_ecc.fields import bls12_381_FQ2 as FQ2
from sqrt_mod_p import get_square_root_mod_p as field_sqrt
FQ2_order = q ** 2 - 1
eighth_roots_of_unity = [
    FQ2([1, 1]) ** ((FQ2_order * k) // 8)
    for k in range(8)
]


# Adapted from https://github.com/ethereum/trinity/blob/a1b0f058e7bc8e385c8dac3164c49098967fd5bb/eth2/_utils/bls.py#L63-L77 
def has_squareroot(value):
    a, b = value[0], value[1]
    if b==0:
        return pow(a, (q-1)//2, q)
    l = a**2 + b**2
    legendre_l = pow(l, (q-1)//2, q)
    if legendre_l == -1:
        return -1
    l = field_sqrt(l)
    delta = (a+l)/2
    legendre_delta = pow(delta, (q-1)//2,q)
    if legendre_delta == -1:
        delta = (a-l)/2
    legendre_delta = pow(delta, (q-1)//2,q)
    if legendre_delta == -1:
        return -1
    return 1

def has_squareroot_v2(value):
    a, b = value.coeffs[0].n, value.coeffs[1].n
    print("findme", type(a), type(b))
    if a==0:
        if b==0:
            return 1
        else:
            return 0
    else:
        if b==0:
            leg_symbol= pow(a, (q-1)//2, q)
            if leg_symbol == -1:
                return 0
            else:
                return 1
        else:
            l = a**2 + b**2
            success, l_sqrt=field_sqrt(l, q)
            if success == 0:
                return 0
            k = (-a + l_sqrt) / FQ2((2,0,0))
            success, r1 = field_sqrt(k, q)
            if success == 0:
                return 0
            # In this case the sqrt is ( b / (2*r1), r1 )
            return 1
      