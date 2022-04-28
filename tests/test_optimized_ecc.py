"""contract.cairo test file."""

import pytest
from utils import split, packEnum,  pack,pack12, max_base_bigint6_sum, base
from math import sqrt
from hypothesis import given, strategies as st, settings

largest_factor = sqrt(2**(64 * 11))


# an empty test so I remember how to use hypothese
@given(
    x=st.integers(min_value=1,  max_value=(10)),
    y=st.integers(min_value=1,  max_value=(10)),
    base = st.integers(min_value=0, max_value=(5))
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_unused(multi_precision_factory, x, y, base):
    assert x == y
