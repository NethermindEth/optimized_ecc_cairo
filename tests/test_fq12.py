from numpy import right_shift
import pytest
from utils import split, packFQP, field_modulus, splitFQP
from math import sqrt
from hypothesis import given, strategies as st, settings
import py_ecc
from py_ecc.fields import bls12_381_FQ12 as FQ12

largest_factor = sqrt(2 ** (64 * 11))


@given(
    x0=st.integers(min_value=1, max_value=(field_modulus)),
    x1=st.integers(min_value=0, max_value=(field_modulus)),
    x2=st.integers(min_value=0, max_value=(field_modulus)),
    x3=st.integers(min_value=0, max_value=(field_modulus)),
    x4=st.integers(min_value=0, max_value=(field_modulus)),
    x5=st.integers(min_value=0, max_value=(field_modulus)),
    x6=st.integers(min_value=0, max_value=(field_modulus)),
    x7=st.integers(min_value=0, max_value=(field_modulus)),
    x8=st.integers(min_value=0, max_value=(field_modulus)),
    x9=st.integers(min_value=0, max_value=(field_modulus)),
    x10=st.integers(min_value=0, max_value=(field_modulus)),
    x11=st.integers(min_value=0, max_value=(field_modulus)),
    y0=st.integers(min_value=1, max_value=(field_modulus)),
    y1=st.integers(min_value=0, max_value=(field_modulus)),
    y2=st.integers(min_value=0, max_value=(field_modulus)),
    y3=st.integers(min_value=0, max_value=(field_modulus)),
    y4=st.integers(min_value=0, max_value=(field_modulus)),
    y5=st.integers(min_value=0, max_value=(field_modulus)),
    y6=st.integers(min_value=0, max_value=(field_modulus)),
    y7=st.integers(min_value=0, max_value=(field_modulus)),
    y8=st.integers(min_value=0, max_value=(field_modulus)),
    y9=st.integers(min_value=0, max_value=(field_modulus)),
    y10=st.integers(min_value=0, max_value=(field_modulus)),
    y11=st.integers(min_value=0, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_mul(
    fq12_factory,
    x0,
    x1,
    x2,
    x3,
    x4,
    x5,
    x6,
    x7,
    x8,
    x9,
    x10,
    x11,
    y0,
    y1,
    y2,
    y3,
    y4,
    y5,
    y6,
    y7,
    y8,
    y9,
    y10,
    y11,
):
    x = (x0, x1, x2, x3, x4, x5, x6, x7, x8, x9, x10, x11)
    y = (y0, y1, y2, y3, y4, y5, y6, y7, y8, y9, y10, y11)

    contract = fq12_factory
    x_split = splitFQP(x)
    y_split = splitFQP(y)
    execution_info = await contract.mul(x_split, y_split).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq12 = FQ12(x)
    y_fq12 = FQ12(y)
    python_result = x_fq12 * y_fq12

    assert cairo_result == python_result.coeffs


# checks that (1 + x) * y = y + x * y
@given(
    x1=st.integers(min_value=1, max_value=(field_modulus)),
    x2=st.integers(min_value=1, max_value=(field_modulus)),
    y1=st.integers(min_value=1, max_value=(field_modulus)),
    y2=st.integers(min_value=1, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_mul_associativity(fq12_factory, x1, x2, y1, y2):
    one = (1, 0)
    x = (x1, x2)
    y = (y1, y2)
    contract = fq12_factory

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
async def test_fq12_scalar_mul(fq12_factory, x, y1, y2):
    contract = fq12_factory
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
async def test_fq12_add(fq12_factory, x1, x2, y1, y2):
    contract = fq12_factory
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
async def test_fq12_sub(fq12_factory, x1, x2, y1, y2):
    contract = fq12_factory
    execution_info = await contract.sub(
        (split(x1), split(x2)), (split(y1), split(y2))
    ).call()

    result = packFQP(execution_info.result[0])

    assert result[0] == (x1 - y1) % field_modulus
    assert result[1] == (x2 - y2) % field_modulus
