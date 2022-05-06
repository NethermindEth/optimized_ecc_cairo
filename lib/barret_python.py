import numpy as np
import math

b= 2**4
k = 2

def barret_reduction(x: int, m: int):
    mu = math.floor((b**(2*k)/m))
    
    q1 = math.floor(x/(b**(k-1)))
    q2 = q1 * mu
    q3 = math.floor(q2/(b**(k+1)))
    
    r1 = x % (b**(k+1))
    r2 = (q3*m) % (b**(k+1))
    r = r1 - r2 
    
    if r < 0:
        r = r + b**(k+1)
    while r >= m:
        r = r - m 
    return r

if __name__ == "__main__":
    x = 1 + 2* b + 3*(b**2) + 1*(b**3)
    print("x", x)
    m = 1 + b
    print("m", m)
    reduction = barret_reduction(x,m)
    print("reduction", reduction)
    print("expected reduction", x%m)
    assert reduction == x % m