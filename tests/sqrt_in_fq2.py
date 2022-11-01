from py_ecc.optimized_bls12_381 import field_modulus as q
from py_ecc.optimized_bls12_381 import FQ2
from py_ecc.fields import bls12_381_FQ2 as FQ2
from sqrt_mod_p import get_square_root_mod_p as field_sqrt

FQ2_order = q**2 - 1
eighth_roots_of_unity = [FQ2([1, 1]) ** ((FQ2_order * k) // 8) for k in range(8)]

def has_squareroot(value):
    a, b = value.coeffs[0].n, value.coeffs[1].n
    leg_symbol = pow(a*a + b*b, (q - 1) // 2, q)
    if (leg_symbol + 1) % q == 0:
        return 0
    return 1
