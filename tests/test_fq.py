"""contract.cairo test file."""

import pytest
from utils import split, packEnum,  pack,pack12, max_base_bigint6_sum, field_modulus
from math import sqrt
from hypothesis import given, strategies as st, settings

largest_factor = sqrt(2**(64 * 11))


@given(
    x=st.integers(min_value=1,  max_value=(field_modulus)),
    y=st.integers(min_value=1,  max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_sub(fq_factory, x, y):
    contract = fq_factory
    
    execution_info = await contract.sub(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x - y) % field_modulus


@given(
    x=st.integers(min_value=1,  max_value=(field_modulus)),
    y=st.integers(min_value=1,  max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_add(fq_factory, x, y):
    contract = fq_factory
    
    execution_info = await contract.add(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    print(result)
    print(x+y)
    print((x+y)% field_modulus )
    assert result == (x + y) % field_modulus

