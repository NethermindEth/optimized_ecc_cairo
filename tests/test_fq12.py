import pytest
from utils import  packFQP, field_modulus, splitFQP
from math import sqrt
from hypothesis import given, strategies as st, settings
from py_ecc.fields import bls12_381_FQ12 as FQ12

largest_factor = sqrt(2 ** (64 * 11))

# NOTE: this test took 2h to complete in a macbook
@pytest.mark.skip(reason="The test passes. But it is very long! But one should check that the test passes")
@given(
    x0=st.integers(min_value=1, max_value=(field_modulus - 1)),
    y0=st.integers(min_value=1, max_value=(field_modulus - 1)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_mul_short(
    fq12_factory,
    x0,
    y0,
):
    # In this test we manually fill in some of the components of x and y to make it shorter
    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)
    y = [pow(y0, i, field_modulus) for i in range(1, 13)]
    y = tuple(y)

    print(x)
    print(y)
    print()

    contract = fq12_factory
    x_split = splitFQP(x)
    y_split = splitFQP(y)
    execution_info = await contract.mul(x_split, y_split).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq12 = FQ12(x)
    y_fq12 = FQ12(y)
    python_result = x_fq12 * y_fq12

    assert cairo_result == python_result.coeffs


@pytest.mark.asyncio
async def test_fq12_mul_specific(
    fq12_factory,
):
    x = (
        3807692610,
        30752,
        105,
        242,
        62770,
        36968,
        48815,
        13658594255010710970,
        46637,
        33096,
        123,
        143,
    )
    y = (
        2954,
        194,
        259,
        63707,
        6,
        53,
        196,
        183,
        31935,
        3020,
        59970,
        56226,
    )

    contract = fq12_factory
    x_split = splitFQP(x)
    y_split = splitFQP(y)
    execution_info = await contract.mul(x_split, y_split).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq12 = FQ12(x)
    y_fq12 = FQ12(y)
    python_result = x_fq12 * y_fq12

    assert cairo_result == python_result.coeffs


@given(
    x=st.integers(min_value=1, max_value=2**128 - 1),
    y0=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_scalar_mul(fq12_factory, x, y0):

    y = [pow(y0, i, field_modulus) for i in range(1, 13)]
    y = tuple(y)

    contract = fq12_factory
    execution_info = await contract.scalar_mul(x, splitFQP(y)).call()

    result = packFQP(execution_info.result[0])

    assert all(
        [result[index] == (x * y[index]) % field_modulus for index in range(len(y))]
    )


@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
    y0=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_add(fq12_factory, x0, y0):

    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)
    y = [pow(y0, i, field_modulus) for i in range(1, 13)]
    y = tuple(y)

    contract = fq12_factory
    execution_info = await contract.add(splitFQP(x), splitFQP(y)).call()

    result = packFQP(execution_info.result[0])
    
    assert all(
        [result[index] == (x[index] + y[index]) % field_modulus for index in range(len(x))]
    )




@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
    y0=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_sub(fq12_factory, x0, y0):

    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)
    y = [pow(y0, i, field_modulus) for i in range(1, 13)]
    y = tuple(y)

    contract = fq12_factory
    execution_info = await contract.sub(splitFQP(x), splitFQP(y)).call()

    result = packFQP(execution_info.result[0])
    
    assert all(
        [result[index] == (x[index] - y[index]) % field_modulus for index in range(len(x))]
    )
