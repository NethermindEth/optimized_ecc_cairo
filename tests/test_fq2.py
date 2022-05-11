import pytest
from utils import split,  packFQ2, field_modulus, max_felt
from math import sqrt
from hypothesis import given, strategies as st, settings

largest_factor = sqrt(2**(64 * 11))

@given(
    x=st.integers(min_value=1,  max_value=(max_felt)),
    y=st.integers(min_value=1,  max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_scalar_mul(fq2_factory, x, y):
    contract = fq2_factory
    execution_info = await contract.scalar_mul(x, (split(y), split(y))).call()

    result = packFQ2(execution_info.result[0])

    assert result[0] == (x * y) % field_modulus
    assert result[1] == (x * y) % field_modulus

@given(
    x=st.integers(min_value=1,  max_value=(field_modulus)),
    y=st.integers(min_value=1,  max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_add(fq2_factory, x, y):
    contract = fq2_factory
    execution_info = await contract.add((split(x), split(x)), (split(y), split(y))).call()

    result = packFQ2(execution_info.result[0])

    assert result[0] == (x + y) % field_modulus
    assert result[1] == (x + y) % field_modulus

@given(
    x=st.integers(min_value=1,  max_value=(field_modulus)),
    y=st.integers(min_value=1,  max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_sub(fq2_factory, x, y):
    contract = fq2_factory
    execution_info = await contract.sub((split(x), split(x)), (split(y), split(y))).call()

    result = packFQ2(execution_info.result[0])

    assert result[0] == (x - y) % field_modulus
    assert result[1] == (x - y) % field_modulus


