import numpy as np
import math
from hypothesis import given, strategies as st, settings
import pytest


class Division(object):
    def __init__(self, base):
        # self.modulo = 23
        self.base = base

    def get_num_limbs(self, integer):
        return 1 + math.floor(math.log(integer, self.base))

    def split(self, num: int, length: int = 6):
        a = []
        for _ in range(length):
            num, residue = divmod(num, self.base)
            a.append(residue)
        assert num == 0
        return tuple(a)

    def packEnum(self, z):
        result = 0
        for index, coef in enumerate(z):
            result += coef * self.base**index
        return result

    def div(self, x, y):
        assert x >= y

        num_limbs_x = self.get_num_limbs(x) - 1
        num_limbs_y = self.get_num_limbs(y) - 1

        limbs_delta = num_limbs_x - num_limbs_y
        q = [0 for _ in range(limbs_delta + 1)]

        while x >= y * (self.base ** (limbs_delta)):
            q[limbs_delta] += 1
            x -= y * (self.base ** (limbs_delta))

        x = self.split(x, num_limbs_x + 1)
        y = self.split(y, num_limbs_y + 1)
        for i in range(num_limbs_x, num_limbs_y, -1):
            print(i, num_limbs_y)
            if x[i] == y[num_limbs_y]:
                q[i - num_limbs_y - 1] = self.base - 1
            else:
                q[i - num_limbs_y - 1] = math.floor(
                    (x[i] * self.base + x[i - 1]) / (y[num_limbs_y])
                )
            while (
                q[i - num_limbs_y - 1]
                * (y[num_limbs_y] * self.base + y[num_limbs_y - 1])
                > x[i] * (self.base**2) + x[i - 1] * self.base + x[i - 2]
            ):
                q[i - num_limbs_y - 1] -= 1

            x = self.packEnum(x)
            y = self.packEnum(y)
            x -= q[i - num_limbs_y - 1] * y * (self.base ** (i - num_limbs_y - 1))
            if x < 0:
                x += y * (self.base ** (i - num_limbs_y - 1))
                q[i - num_limbs_y - 1] -= 1
            x = self.split(x, num_limbs_x + 1)
            y = self.split(y, num_limbs_y + 1)

        r = self.packEnum(x)
        packed_q = self.packEnum(q)
        return (packed_q, r)


@given(
    x=st.integers(min_value=2**8, max_value=2**15),
    y=st.integers(min_value=2, max_value=2**15),
    base=st.integers(min_value=4, max_value=2**5),
)
@settings(deadline=None)
@pytest.mark.asyncio
def test_div(x, y, base):
    print(f"{x}, {y}, {base}")
    if x < y:
        return True
    if base >= y:
        return True
    div = Division(base)
    assert div.div(x, y) == (x // y, x % y)
