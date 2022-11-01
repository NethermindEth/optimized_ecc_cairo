from dataclasses import field
import pytest
from utils import (
    split,
    pack,
    field_modulus,
    field_modulus_sub1_div2
)
from sqrt_mod_p import get_square_root_mod_p
from math import sqrt
from hypothesis import given, strategies as st, settings

largest_factor = sqrt(2 ** (64 * 11))


@given(
    x=st.integers(min_value=1,  max_value=(2 ** 255)),
    y=st.integers(min_value=1,  max_value=(2 ** 255)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_from_64_bytes(x, y, fq_new_factory):
    contract = fq_new_factory

    R = pack([
		int("75b3cd7c5ce820f", 16),
		int("3ec6ba621c3edb0b", 16),
		int("168a13d82bff6bce", 16),
		int("87663c4bf8c449d2", 16),
		int("15f34c83ddc8d830", 16),
		int("f9628b49caa2e85", 16)],
        64
    )

    r_squared = pack([
        int("f4df1f341c341746", 16), 
        int("0a76e6a609d104f1", 16),
        int("8de5476c4c95b6d5", 16), 
        int("67eb88a9939d83c0", 16),
        int("9a793e85b519952d", 16), 
        int("11988fe592cae3aa", 16)], 
        64
    )
    
    execution_info = await contract.from_64_bytes(split(x, 128, 2), split(y, 128, 2)).call()
    
    res = pack(execution_info.result[0])
    
    x_mont = x * r_squared 

    y_mont = y * r_squared

    desired_res = ((R * x_mont) % field_modulus + y_mont) % field_modulus
    assert res == desired_res


@given(
    x=st.integers(min_value=1,  max_value=(field_modulus-1)),
    y=st.integers(min_value=1,  max_value=(field_modulus-1)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_add(fq_new_factory, x, y):
    contract = fq_new_factory
    execution_info = await contract.add(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x + y) % field_modulus


@given(x=st.integers(min_value=1, max_value=field_modulus))
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_square(fq_new_factory, x):
    contract = fq_new_factory

    execution_info = await contract.square(split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (x * x) % field_modulus


@given(x=st.integers(min_value=1, max_value=field_modulus))
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_square2(fq_new_factory, x):
    contract = fq_new_factory

    execution_info = await contract.square2(split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (x * x) % field_modulus


@given(
    x=st.integers(min_value=1, max_value=field_modulus),
    y=st.integers(min_value=1, max_value=field_modulus),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_mul(fq_new_factory, x, y):
    contract = fq_new_factory

    execution_info = await contract.mul(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x * y) % field_modulus


@given(
    x=st.integers(min_value=1, max_value=(field_modulus)),
    y=st.integers(min_value=1, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_sub(fq_new_factory, x, y):
    contract = fq_new_factory

    execution_info = await contract.sub(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x - y) % field_modulus

"""
@given(
    x=st.integers(min_value=1, max_value=(field_modulus)),
    y=st.integers(min_value=1, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_sub2(fq_new_factory, x, y):
    contract = fq_new_factory

    execution_info = await contract.sub2(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert result == (x - y) % field_modulus
"""

@given(
    x=st.integers(min_value=0, max_value=field_modulus-1),
    scalar=st.integers(min_value=0, max_value=2**128 - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_scalar_mul(fq_new_factory, scalar, x):
    contract = fq_new_factory

    execution_info = await contract.scalar_mul(scalar, split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (scalar * x) % field_modulus


@given(
    x=st.integers(min_value=0, max_value=field_modulus-1),
    scalar=st.integers(min_value=0, max_value=2**128 - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_scalar_mul2(fq_new_factory, scalar, x):
    contract = fq_new_factory

    execution_info = await contract.scalar_mul2(scalar, split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (scalar * x) % field_modulus


@given(
    x=st.integers(min_value=0, max_value=field_modulus-1),
    scalar=st.integers(min_value=0, max_value=2**128 - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_scalar_mul3(fq_new_factory, scalar, x):
    contract = fq_new_factory

    execution_info = await contract.scalar_mul3(scalar, split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (scalar * x) % field_modulus


@given(
    x=st.integers(min_value=0, max_value=field_modulus-1),
    scalar=st.integers(min_value=0, max_value=2**128 - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_scalar_mul4(fq_new_factory, scalar, x):
    contract = fq_new_factory

    execution_info = await contract.scalar_mul4(scalar, split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (scalar * x) % field_modulus


@given(
    x=st.integers(min_value=0, max_value=field_modulus-1),
    scalar=st.integers(min_value=0, max_value=2**64 - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_scalar64_mul(fq_new_factory, scalar, x):
    contract = fq_new_factory

    execution_info = await contract.scalar64_mul(scalar, split(x)).call()

    result = pack(execution_info.result[0])

    assert result == (scalar * x) % field_modulus


@given(
    x=st.integers(min_value=0, max_value=field_modulus-1),
    y=st.integers(min_value=1, max_value=field_modulus-1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_div(fq_new_factory, x, y):
    contract = fq_new_factory

    execution_info = await contract.div(split(x), split(y)).call()

    result = pack(execution_info.result[0])

    assert x == (y * result) % field_modulus
    assert result < field_modulus


@given(
    x=st.integers(min_value=1, max_value=field_modulus-1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_inverse(fq_new_factory, x):
    contract = fq_new_factory

    execution_info = await contract.inverse(split(x)).call()

    result = pack(execution_info.result[0])

    assert 1 == (x * result) % field_modulus
    assert result < field_modulus


@given(
    x=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq_get_sqrt(fq_new_factory, x):
    contract = fq_new_factory
    
    print(x)
    
    execution_info = await contract.get_square_root(split(x)).call()

    success = execution_info.result[0]
    sqrt = execution_info.result[1]
    
    sqrt = pack(sqrt)

    
    python_success, python_sqrt = get_square_root_mod_p(x, field_modulus)

    assert python_success == success

    # Sanity check
    alternative_python_success = pow(x, (field_modulus-1) //2, field_modulus)
    if ((alternative_python_success  +1) %field_modulus )==0:
        # If the power is -1 mod p, then x is not a root, otherwise it is 1 if x!= 0 or 0 if x=0
        alternative_python_success = 0
    if x == 0:
        # If x= 0 then x is a square
        alternative_python_success = 1
    assert ((alternative_python_success - success) % field_modulus) == 0

    # Check that the sqrt root is correct
    # Since there are two roots, we make two
    if success == 1:
        # Check that the sqrt root is correct
        # Since there are two roots, we make two checks
        assert (python_sqrt == sqrt) or ((-python_sqrt) % field_modulus == sqrt)


# TODO: test for fq_lib.pow
