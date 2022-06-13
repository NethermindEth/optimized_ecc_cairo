
from py_ecc.optimized_bls12_381 import field_modulus as q
from py_ecc.fields import bls12_381_FQ2 as FQ2

FQ2_order = q ** 2 - 1
eighth_roots_of_unity = [
    FQ2([1, 1]) ** ((FQ2_order * k) // 8)
    for k in range(8)
]

# Wraps around `modular_squareroot` so as to return values in the same way as `get_square_root_mod_p` 
# from sqrt_mod_py returns values
def wrapped_modular_squareroot(value):
    sqrt = modular_squareroot(value)
    if sqrt is None:
        return 0, None
    else:
        return 1, sqrt
    
    
# Adapted from https://github.com/ethereum/trinity/blob/a1b0f058e7bc8e385c8dac3164c49098967fd5bb/eth2/_utils/bls.py#L63-L77 
# Only changed the typing (no typing here) in the function signature
def modular_squareroot(value):
    """
    ``modular_squareroot(x)`` returns the value ``y`` such that ``y**2 % q == x``,
    and None if this is not possible. In cases where there are two solutions,
    the value with higher imaginary component is favored;
    if both solutions have equal imaginary component the value with higher real
    component is favored.
    """
    candidate_squareroot = value ** ((FQ2_order + 8) // 16)
    check = candidate_squareroot ** 2 / value
    if check in eighth_roots_of_unity[::2]:
        x1 = candidate_squareroot / eighth_roots_of_unity[eighth_roots_of_unity.index(check) // 2]
        x2 = FQ2([-x1.coeffs[0], -x1.coeffs[1]])  # x2 = -x1
        return x1 if (x1.coeffs[1], x1.coeffs[0]) > (x2.coeffs[1], x2.coeffs[0]) else x2
    return None