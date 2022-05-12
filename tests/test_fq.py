import pytest
from utils import (
    split,
    packEnum,
    pack,
    pack12,
    max_base_bigint6_sum,
    max_base_bigint12_sum,
    field_modulus,
)
from math import sqrt
from hypothesis import given, strategies as st, settings

largest_factor = sqrt(2 ** (64 * 11))


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

    assert result == (x + y) % field_modulus


@given(
    x=st.integers(min_value=1,  max_value=field_modulus)
)
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
    x=st.integers(min_value=1, max_value=(max_base_bigint12_sum)),
    y=st.integers(min_value=1, max_value=(max_base_bigint12_sum)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_sub_bigint12(fq_factory, x, y):
    print(x, y)
    
    # TODO: Never go into negative since it is not clear what the modulo should be in this test. Run a test where this is not done?
    if x < y:
        (x,y) = (y,x)
    contract = fq_factory

    execution_info = await contract.sub_bigint12(split(x, 12), split(y, 12)).call()

    result = pack12(execution_info.result[0])

    assert result == (x - y) 


@given(number=st.integers(min_value=1, max_value=2**(64*7)))
@settings(deadline=None)
@pytest.mark.asyncio
async def test_barret_reduction(fq_factory, number):

    contract = fq_factory
    number_bigint12 = split(number, length=12)
    execution_info = await contract.reduce(
        number_bigint12 ).call()
    msg = f"Input number: {number}\nSplit input number: {split(number, 12)}\nResult: {execution_info.result[0]}\n"
    print(msg)
    result = pack(execution_info.result[0])
    assert result == number %field_modulus

@pytest.mark.asyncio
async def test_barret_reduction_specific_number(fq_factory):
    number= 20042277575013791667125926197955011048719829756306435301145390326721041016076443063112985210850570485217514554359039978576402621831

    contract = fq_factory
    number_bigint12 = split(number, length=12)
    execution_info = await contract.reduce(
        number_bigint12).call()
    msg = f"Input number: {number}\nSplit input number: {split(number, 12)}\nResult: {execution_info.result[0]}\n"
    print(msg)
    result = pack(execution_info.result[0])
    assert result == number %field_modulus

