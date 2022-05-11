import numpy as np
import math
b = 2**64
k = 6


def find_largest_limb_index(n):
    for idx in range(13):
        if b**idx > n:
            return idx


def barret_reduction(x: int, m: int):
    iteration_num = 0
    mu = math.floor((b ** (2 * k) / m))

    q1 = math.floor(x / (b ** (k - 1)))
    q2 = q1 * mu
    q3 = math.floor(q2 / (b ** (k + 1)))

    r1 = x % (b ** (k + 1))
    r2 = (q3 * m) % (b ** (k + 1))
    r = r1 - r2

    if r < 0:
        r = r + b ** (k + 1)
    print(r-m)
    

    
    while r >= m:

        
        r_largest_limb_idx = find_largest_limb_index(r)
        m_largest_limb_idx = find_largest_limb_index(m)
        if r_largest_limb_idx > m_largest_limb_idx:
            limb_delta = r_largest_limb_idx - m_largest_limb_idx
            int_to_subtract = m*(b**(limb_delta-1))
            r = r - int_to_subtract
        else:
            r = r - m
        if iteration_num % 10**6 == 0:
            print("iteration num", iteration_num, limb_delta)
        iteration_num += 1
    return r


if __name__ == "__main__":
    x = 20042277575013791667125926197955011048719829756306435301145390326721041016076443063112985210850570485217514554359039978576402621831
    print("x", x)
    m = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664037894272559787
    print("m", m)
    reduction = barret_reduction(x, m)
    print("reduction", reduction)
    expected_reduction = x % m
    print("expected reduction", expected_reduction)
    difference = reduction - expected_reduction
    print("difference", difference)
    assert difference == 0
