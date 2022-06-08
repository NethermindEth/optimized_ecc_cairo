from numpy import right_shift
import pytest
from utils import split, packFQP, field_modulus, max_limb, splitFQP
from math import sqrt
from hypothesis import given, strategies as st, settings
import py_ecc
from py_ecc.fields import bls12_381_FQ2 as FQ2

largest_factor = sqrt(2 ** (64 * 11))


@given(
    x1=st.integers(min_value=1, max_value=field_modulus-1),
    x2=st.integers(min_value=0, max_value=field_modulus-1),
    y1=st.integers(min_value=1, max_value=field_modulus-1),
    y2=st.integers(min_value=0, max_value=field_modulus-1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_mul(fq2_factory, x1, x2, y1, y2):
    x = (x1, x2)
    y = (y1, y2)

    contract = fq2_factory
    execution_info = await contract.mul(splitFQP(x), splitFQP(y)).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq2 = FQ2(x)
    y_fq2 = FQ2(y)
    python_result = x_fq2 * y_fq2

    assert cairo_result == python_result.coeffs


# checks that (1 + x) * y = y + x * y
@given(
    x1=st.integers(min_value=1, max_value=field_modulus-1),
    x2=st.integers(min_value=0, max_value=field_modulus-1),
    y1=st.integers(min_value=1, max_value=field_modulus-1),
    y2=st.integers(min_value=0, max_value=field_modulus-1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_mul_associativity(fq2_factory, x1, x2, y1, y2):
    one = (1, 0)
    x = (x1, x2)
    y = (y1, y2)
    contract = fq2_factory

    execution_info = await contract.mul(splitFQP(one), splitFQP(y)).call()
    one_mul_y = packFQP(execution_info.result[0])

    execution_info = await contract.mul(splitFQP(x), splitFQP(y)).call()
    x_mul_y = packFQP(execution_info.result[0])

    execution_info = await contract.add(splitFQP(one_mul_y), splitFQP(x_mul_y)).call()
    left_side = packFQP(execution_info.result[0])

    execution_info = await contract.add(splitFQP(one), splitFQP(x)).call()
    one_plus_x = packFQP(execution_info.result[0])

    execution_info = await contract.mul(splitFQP(one_plus_x), splitFQP(y)).call()
    right_side = packFQP(execution_info.result[0])

    assert left_side == right_side


@given(
    x=st.integers(min_value=1, max_value=2**128 - 1),
    y1=st.integers(min_value=1, max_value=field_modulus - 1),
    y2=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_scalar_mul(fq2_factory, x, y1, y2):
    contract = fq2_factory
    execution_info = await contract.scalar_mul(x, (split(y1), split(y2))).call()

    result = packFQP(execution_info.result[0])

    assert result[0] == (x * y1) % field_modulus
    assert result[1] == (x * y2) % field_modulus


@given(
    x1=st.integers(min_value=1, max_value=field_modulus - 1),
    x2=st.integers(min_value=0, max_value=field_modulus - 1),
    y1=st.integers(min_value=1, max_value=field_modulus - 1),
    y2=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_add(fq2_factory, x1, x2, y1, y2):
    contract = fq2_factory
    execution_info = await contract.add(
        (split(x1), split(x2)), (split(y1), split(y2))
    ).call()

    result = packFQP(execution_info.result[0])

    assert result[0] == (x1 + y1) % field_modulus
    assert result[1] == (x2 + y2) % field_modulus


@given(
    x1=st.integers(min_value=1, max_value=field_modulus - 1),
    x2=st.integers(min_value=0, max_value=field_modulus - 1),
    y1=st.integers(min_value=1, max_value=field_modulus - 1),
    y2=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_sub(fq2_factory, x1, x2, y1, y2):
    contract = fq2_factory
    execution_info = await contract.sub(
        (split(x1), split(x2)), (split(y1), split(y2))
    ).call()

    result = packFQP(execution_info.result[0])

    assert result[0] == (x1 - y1) % field_modulus
    assert result[1] == (x2 - y2) % field_modulus


# TODO: make subindices consistent: here we have x0, x1, above we have x1, x2, etc
@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
    x1=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_get_inverse(fq2_factory, x0, x1):
    contract = fq2_factory
    execution_info = await contract.inv((split(x0), split(x1))).call()

    x_inv = packFQP(execution_info.result[0])
    x_inv_fq2 = FQ2(x_inv)
    x_fq2 = FQ2((x0, x1))
    
    assert x_fq2 * x_inv_fq2 ==  FQ2.one()

@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
    x1=st.integers(min_value=0, max_value=field_modulus - 1),
    y0=st.integers(min_value=1, max_value=field_modulus - 1),
    y1=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_eq(fq2_factory, x0, x1, y0, y1):
    contract = fq2_factory
    execution_info = await contract.eq((split(x0), split(x1)), (split(y0), split(y1)), ).call()

    res = execution_info.result[0]
    x_fq2 = FQ2((x0, x1))
    y_fq2 = FQ2((y0, y1))
    python_res = int(x_fq2 == y_fq2)
    assert res == python_res
    


@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
    x1=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_is_zero(fq2_factory, x0, x1):
    contract = fq2_factory
    execution_info = await contract.is_zero((split(x0), split(x1))).call()

    res = execution_info.result[0]
    x_fq2 = FQ2((x0, x1))
    zero_fq2 = FQ2.zero()
    python_res = int(x_fq2 == zero_fq2)
    assert res == python_res
    
