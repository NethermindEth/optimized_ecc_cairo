import pytest
from utils import split, pack, field_modulus, field_modulus_sub1_div2
from utils import (
    split,
    pack,
    pack12,
    max_base_bigint12_sum,
    field_modulus,
)
from math import sqrt
from hypothesis import given, strategies as st, settings

largest_factor = sqrt(2 ** (64 * 11))


@given(
    x=st.integers(min_value=1, max_value=(field_modulus)),
    y=st.integers(min_value=1, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_add(fq_factory, x, y):
    contract = fq_factory
    execution_info = await contract.add(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x + y) % field_modulus


@given(x=st.integers(min_value=1, max_value=field_modulus))
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_square(fq_factory, x):
    contract = fq_factory

    execution_info = await contract.square(split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (x * x) % field_modulus


@given(
    x=st.integers(min_value=1, max_value=field_modulus),
    y=st.integers(min_value=1, max_value=field_modulus),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_mul(fq_factory, x, y):
    contract = fq_factory

    execution_info = await contract.mul(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x * y) % field_modulus


@given(
    x=st.integers(min_value=1, max_value=(field_modulus)),
    y=st.integers(min_value=1, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_sub(fq_factory, x, y):
    contract = fq_factory

    execution_info = await contract.sub(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x - y) % field_modulus


@given(
    x=st.integers(min_value=1, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_is_square(fq_factory, x):
    print(x)
    contract = fq_factory

    execution_info = await contract.is_square(split(x)).call()

    
    result = execution_info.result[0]
    python_result = pow(x, field_modulus_sub1_div2, field_modulus)

    # This `if` is checking whether `python_result` is -1 modulo `field_modulus``
    if (python_result - (-1)) % field_modulus == 0:
        # In this case `x` is not a square
        python_result = 0
    else:
        # Otherwise it is
        python_result = 1
    assert result == python_result


@pytest.mark.asyncio
async def test_fq_is_square_specific(fq_factory):
    x = 2    
    contract = fq_factory

    execution_info = await contract.is_square(split(x)).call()

    result = execution_info.result[0]
    python_result = pow(x, field_modulus_sub1_div2, field_modulus)
    
    # This `if` is checking whether `python_result` is -1 modulo `field_modulus``
    if (python_result - (-1)) % field_modulus == 0:
        # In this case `x` is not a square
        python_result = 0
    else:
        # Otherwise it is
        python_result = 1
    assert result == python_result



# TODO: test for fq_lib.pow
