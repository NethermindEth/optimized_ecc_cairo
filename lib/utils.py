
# Takes an integer `num`, a number of bits `n_b`, and a length l, and returns a tuple (d0, ..., d_{l-1})
# such that num = d_0 + d_1 * 2**(n_b) + d_2 * 2**(2n_b) + ... + d_{l-1}*2**((l-1)*n_b)
# Each d_i is a positive integer of less than n_b bits
def split(num: int, num_bits_shift: int = 128, length: int=2):
    a = []
    for _ in range(length):
        a.append( num & ((1 << num_bits_shift) - 1) )
        num = num >> num_bits_shift 
    return tuple(a)

# The inverse operation of `split`: takes a tuple z of integers (d0, ..., d_{l-1}) and returns
# d_0 + d_1 * 2**(n_b) + d_2 * 2**(2n_b) + ... + d_{l-1}*2**((l-1)*n_b)
# Note that d_i can be larger than 2**128 here (but in this repo d_i is always less than 2**128)
def pack(z, num_bits_shift: int = 128) -> int:
    limbs = (limb for limb in z)
    return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))

