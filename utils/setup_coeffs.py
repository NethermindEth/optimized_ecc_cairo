### Credit to https://gist.github.com/HarryR/eb5ad0e5de51633678e015a6b06969a1#file-bls12_381-sage

field_modulus = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
desired_curve_order = 52435875175126190479447740508185965837690552500527637822603658699938581184513

Fp = GF(field_modulus)

PARAM_A4 = 0
PARAM_A6 = 4

E = EllipticCurve(Fp, [PARAM_A4, PARAM_A6])
E_order = E.order()
assert E_order % desired_curve_order == 0
assert desired_curve_order.is_prime() is True
E_cofactor = E_order // desired_curve_order
Fr = GF(desired_curve_order)

R.<T> = PolynomialRing(Fp)

# Starting at -1 is an arbitrary choice, could start at 1, where 2 will be the first non-residue
if not Fp(-1).is_square():
    print("# -1 is non-residue")
    non_residue = -1
    F2.<u> = Fp.extension(T^2-non_residue, 'u')
    for j in range(1,4):
        if not (u+j).is_square():
            quadratic_non_residue = u+j
            F12_equation = (T^6 - j)^2 - non_residue
            u_to_w = T^6 - j
            w_to_u = T + j
            break
else:
    print("Unknown")


F12.<w> = Fp.extension(F12_equation)
E12 = EllipticCurve(F12, [0, PARAM_A6])

E2 = EllipticCurve(F2, [0, PARAM_A6*quadratic_non_residue])
is_D_type = False
A_twist = 0
if not (E2.order()/desired_curve_order).is_integer():
    B_twist = PARAM_A6/quadratic_non_residue
    E2 = EllipticCurve(F2, [0, B_twist])
    if not (E2.order()/desired_curve_order).is_integer():
        raise Exception('no twist had appropriate order')
    is_D_type = True
    print("# D type twist")
    F2_PARAM_A4 = PARAM_A4 / quadratic_non_residue
    F2_PARAM_A6 = PARAM_A6 / quadratic_non_residue
else:
    # E2 order is divisible by curve order
    # TODO: get cofactor
    B_twist = PARAM_A6*quadratic_non_residue
    F2_PARAM_A6 = PARAM_A6 * quadratic_non_residue
    F2_PARAM_A4 = PARAM_A4 * quadratic_non_residue
    print('# M type twist')


E2_order = E2.order()
assert E2_order % desired_curve_order == 0
E2_cofactor = E2_order // desired_curve_order



def frobenius_coeffs_powers(modulus, degree, num=None, divisor=None):
    divisor = divisor or degree
    num = num or 1
    tower_modulus = modulus ** degree
    for i in range(num):
        a = i + 1
        q_power = 1
        powers = []
        for j in range(degree):
            powers.append((((a*q_power)-a) // divisor) % tower_modulus)
            q_power *= modulus
        yield powers


def frobenius_coeffs(non_residue, *args, **kwa):
    coeffs = list()
    for i, powers in enumerate(frobenius_coeffs_powers(*args, **kwa)):
        coeffs.append(list())
        for p_i in powers:
            coeffs[i].append( non_residue ** p_i )
    return coeffs


def find_generator(E, F, a6, cofactor, order):
    for x in range(1, 10**3):
        x = F(x)
        y2 = x**3 + a6
        if not y2.is_square():
            continue
        y = y2.sqrt()
        p = cofactor*E(x, y)
        if not p.is_zero() and (order*p).is_zero():
            negy = -p[1]
            if negy < p[1]:
                return -p
            return p


def find_s_t(name, n):
    for s in range(1, 50):
        if n % (2**s) == 0:
            t = n / 2**s
            assert t.is_integer()
            if not ((t-1)/2).is_integer():
                continue
            print (name, "s", s)
            print (name, "t", t)
            print (name, "t_minus_1_over_2", (t-1)/2)
            return s, t


# Finds an R such that R = 2^k, R > N, for the smallest k.
def mont_findR(N, limb_size=64):
    g = 0
    b = 2 ** limb_size
    R = b
    while g != 1:
        R *= b
        if R > N:
            g = gcd(R, N)
    return R


def print_field(name, q, F):
    print( name, 'modulus', q)
    print (name, 'num_bits', ceil(log(q,2)))
    print( name, 'euler', (q-1)//2)
    s, t = find_s_t(name, q-1)
    print (name, 'multiplicative_generator', F.vector_space()(F.multiplicative_generator()))
    gen = F.gen()
    for i in range(0, 100): #for i in range(-1, -100, -1):
        i = gen+i
        if not i.is_square():
            i_to_t = i**t
            print (name, 'nqr', F.vector_space()(i))
            print (name, 'nqr_to_t', F.vector_space()(i_to_t))
            break
    print ("")


def print_R(name, q, nbits):
    R = mont_findR(q, nbits)
    print (name, "R (%d-bit)" % (nbits,), R)
    print (name, "Rcubed (%d-bit)" % (nbits,), (R**2) % q)
    print (name, "Rsquared (%d-bit)" % (nbits,), (R**3) % q    )
    print (name, "inv (%d-bit)" % (nbits,), hex((-q^-1) % 2**nbits))


G1 = find_generator(E, Fp, PARAM_A6, E_cofactor, desired_curve_order)
print ('bls12_381 G1_zero', E(0))
print ('bls12_381 G1_one', [Fp.vector_space()(_) for _ in G1])
print ("")

G2 = find_generator(E2, F2, F2_PARAM_A6, E2_cofactor, desired_curve_order)
print  ('bls12_381_G2_zero', E2(0))
print ('bls12_381 G2_one', [F2.vector_space()(_) for _ in G2])
print ("")

print_field('bls12_381_Fq2', field_modulus**2, F2)
fp2_coeffs = frobenius_coeffs(non_residue, field_modulus, 2)
for i, c in enumerate(fp2_coeffs):
    print ('bls12_381_Fq2', 'Frobenius_coeffs_c1[%d]' % (i,), '=', c)
print ('')


fp6_coeffs = frobenius_coeffs(quadratic_non_residue, field_modulus, 6, 2, 3)
for i, _ in enumerate(fp6_coeffs):
    for j, c in enumerate(_):
        print ('bls12_381_Fq6', 'Frobenius_coeffs_c%d[%d]' % (i + 1, j), '=', F2.vector_space()(c))
print ('')

# Fq12 is two 6th degree towers
fp12_coeffs = frobenius_coeffs(quadratic_non_residue, field_modulus, 12, 1, 6)
for i, _ in enumerate(fp12_coeffs):
    for j, c in enumerate(_):
        print ('bls12_381_Fq12', 'Frobenius_coeffs_c%d[%d]' % (i + 1, j), '=', F2.vector_space()(c))
print ('')

print_R("bls12_381 Fr", desired_curve_order, 64)
print_R("bls12_381 Fr", desired_curve_order, 32)
print_field('bls12_381_Fr', desired_curve_order, Fr)

print_R("bls12_381 Fq", field_modulus, 64)
print_R("bls12_381 Fq", field_modulus, 32)
print_field('bls12_381_Fq', field_modulus, Fp)