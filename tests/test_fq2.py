from numpy import right_shift
import pytest
from utils import split,  packFQ2, field_modulus, max_limb, splitFQ2
from math import sqrt
from hypothesis import given, strategies as st, settings

largest_factor = sqrt(2**(64 * 11))


# one * f + x * f == (one + x) * f
@pytest.mark.asyncio
async def test_fq2_mul(fq2_factory):
    x = (1, 0)
    y = (1, 2)
    one = (1, 0)

    contract = fq2_factory

    execution_info = await contract.mul(splitFQ2(one), splitFQ2(y)).call()
    one_mul_y = packFQ2(execution_info.result[0])

    execution_info = await contract.mul(splitFQ2(x), splitFQ2(y)).call()
    x_mul_y = packFQ2(execution_info.result[0])

    execution_info = await contract.add(splitFQ2(one_mul_y), splitFQ2(x_mul_y)).call()
    left_side = packFQ2(execution_info.result[0])
    
    execution_info = await contract.add(splitFQ2(one), splitFQ2(x)).call()
    one_plus_x = packFQ2(execution_info.result[0])

    execution_info = await contract.mul(splitFQ2(one_plus_x), splitFQ2(y)).call()
    right_side = packFQ2(execution_info.result[0])

    assert left_side == right_side

@given(
    x=st.integers(min_value=1,  max_value=(max_limb)),
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


