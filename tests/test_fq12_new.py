import pytest
from utils import split, packFQP, field_modulus, splitFQP
from math import sqrt
from hypothesis import given, strategies as st, settings
from py_ecc.fields import bls12_381_FQ12 as FQ12
from py_ecc.utils import (
    deg,
    poly_rounded_div,
    prime_field_inv,
)

# TODO: More exhaustive tests should be made. Right now FQ12 elements are taken to be of the form [a, a**2, a**3, ..., a**11] (mod p).
# This is slightly reasonable because exponentiation modulo a prime has a randomish behavior.
# But for full correctness confirmation we should write longer but exhaustieve tests

largest_factor = sqrt(2 ** (64 * 11))


# NOTE: this test took 2h to complete in a macbook
#@pytest.mark.skip(
#    reason="The test passes. But it is very long! But one should check that the test passes"
#)
@given(
    x0=st.integers(min_value=0, max_value=(field_modulus - 1)),
    y0=st.integers(min_value=0, max_value=(field_modulus - 1)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_mul_short(
    fq12_new_factory,
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

    contract = fq12_new_factory
    x_split = splitFQP(x)
    y_split = splitFQP(y)
    execution_info = await contract.mul_2(x_split, y_split).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq12 = FQ12(x)
    y_fq12 = FQ12(y)
    python_result = x_fq12 * y_fq12

    assert cairo_result == python_result.coeffs


@pytest.mark.asyncio
async def test_fq12_mul_specific(
    fq12_new_factory,
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

    contract = fq12_new_factory
    x_split = splitFQP(x)
    y_split = splitFQP(y)
    execution_info = await contract.mul(x_split, y_split).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq12 = FQ12(x)
    y_fq12 = FQ12(y)
    python_result = x_fq12 * y_fq12

    assert cairo_result == python_result.coeffs


@given(
    x=st.integers(min_value=0, max_value=2**128 - 1),
    y0=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_scalar_mul(fq12_new_factory, x, y0):

    y = [pow(y0, i, field_modulus) for i in range(1, 13)]
    y = tuple(y)

    contract = fq12_new_factory
    execution_info = await contract.scalar_mul2(x, splitFQP(y)).call()

    result = packFQP(execution_info.result[0])

    assert all(
        [result[index] == (x * y[index]) % field_modulus for index in range(len(y))]
    )


@given(
    x0=st.integers(min_value=0, max_value=field_modulus - 1),
    y0=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_add(fq12_new_factory, x0, y0):

    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)
    y = [pow(y0, i, field_modulus) for i in range(1, 13)]
    y = tuple(y)

    contract = fq12_new_factory
    execution_info = await contract.add(splitFQP(x), splitFQP(y)).call()

    result = packFQP(execution_info.result[0])

    assert all(
        [
            result[index] == (x[index] + y[index]) % field_modulus
            for index in range(len(x))
        ]
    )


@given(
    x0=st.integers(min_value=0, max_value=field_modulus - 1),
    y0=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_sub(fq12_new_factory, x0, y0):

    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)
    y = [pow(y0, i, field_modulus) for i in range(1, 13)]
    y = tuple(y)

    contract = fq12_new_factory
    execution_info = await contract.sub(splitFQP(x), splitFQP(y)).call()

    result = packFQP(execution_info.result[0])

    assert all(
        [
            result[index] == (x[index] - y[index]) % field_modulus
            for index in range(len(x))
        ]
    )

"""
@given(
    x0=st.integers(min_value=0, max_value=field_modulus - 1),
    exp=st.integers(min_value=0, max_value=(2**768) - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_pow(fq12_new_factory, x0, exp):
    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)

    contract = fq12_new_factory
    execution_info = await contract.pow(splitFQP(x), split(exp, 128, 6)).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq2 = FQ12(x)
    python_result = x_fq2**exp

    assert cairo_result == python_result.coeffs
"""

@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq12_inverse(fq12_new_factory, x0):
    contract = fq12_new_factory

    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)

    x_fq12 = FQ12(x)

    x_cairo_compatible = tuple([split(coeff) for coeff in x])
    execution_info = await contract.inverse(x_cairo_compatible).call()

    x_inv = packFQP(execution_info.result[0])
    x_inv_fq12 = FQ12(x_inv)

    assert x_fq12 * x_inv_fq12 == FQ12.one()


@pytest.mark.asyncio
async def test_fq12_inverse_specific(fq12_new_factory):
    print("findme++00")
    contract = fq12_new_factory
    print("findme++0")

    x0 = 1
    x = [pow(x0, i, field_modulus) for i in range(1, 13)]
    x = tuple(x)

    x_fq12 = FQ12(x)
    print("findme++")
    # python_x_fq12_inverse, low = inv_v2(x)
    python_x_fq12_inverse = x_fq12.inv()
    print("python inverse", python_x_fq12_inverse)
    # print("python low", low)

    x_cairo_compatible = tuple([split(coeff) for coeff in x])
    execution_info = await contract.inverse(x_cairo_compatible).call()

    x_inv = packFQP(execution_info.result[0])
    x_inv_fq12 = FQ12(x_inv)

    assert x_fq12 * x_inv_fq12 == FQ12.one()
