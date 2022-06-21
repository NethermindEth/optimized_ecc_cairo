import pytest
from utils import split, packFQP, field_modulus, splitFQP, max_base_bigint12_sum
from math import sqrt
from hypothesis import given, strategies as st, settings
from py_ecc.fields import bls12_381_FQ2 as FQ2
from sqrt_in_fq2 import has_squareroot, has_squareroot_v2

largest_factor = sqrt(2 ** (64 * 11))

def sgn0(fq) -> int:
    sign = 0
    zero = 1
    for x_i in fq.coeffs:
        sign_i = x_i.n % 2
        zero_i = x_i == 0
        sign = sign or (zero and sign_i)
        zero = zero and zero_i
    return sign

@given(
    x1=st.integers(min_value=0, max_value=(field_modulus)),
    y1=st.integers(min_value=0, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_sgn0(fq2_factory, x1, y1):
    x = (x1, y1)
    
    contract = fq2_factory
    execution_info = await contract.sgn0(splitFQP(x)).call()
    cairo_result = execution_info.result[0]

    x_fq2 = FQ2(x)
    python_result = sgn0(x_fq2)

    assert cairo_result == python_result


@given(
    x1=st.integers(min_value=0, max_value=(field_modulus)),
    y1=st.integers(min_value=0, max_value=(field_modulus)),
    exp=st.integers(min_value=0, max_value=(max_base_bigint12_sum))
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_fq2_pow(fq2_factory, x1, y1, exp):
    x = (x1, y1)
    
    contract = fq2_factory
    execution_info = await contract.pow(splitFQP(x), split(exp, 128, 6)).call()
    cairo_result = packFQP(execution_info.result[0])

    x_fq2 = FQ2(x)
    python_result = x_fq2 ** exp

    assert cairo_result == python_result.coeffs

@given(
    x1=st.integers(min_value=1, max_value=field_modulus - 1),
    x2=st.integers(min_value=0, max_value=field_modulus - 1),
    y1=st.integers(min_value=1, max_value=field_modulus - 1),
    y2=st.integers(min_value=0, max_value=field_modulus - 1),
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
    x1=st.integers(min_value=1, max_value=field_modulus - 1),
    x2=st.integers(min_value=0, max_value=field_modulus - 1),
    y1=st.integers(min_value=1, max_value=field_modulus - 1),
    y2=st.integers(min_value=0, max_value=field_modulus - 1),
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

    assert x_fq2 * x_inv_fq2 == FQ2.one()


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
    execution_info = await contract.eq(
        (split(x0), split(x1)),
        (split(y0), split(y1)),
    ).call()

    res = execution_info.result[0]
    x_fq2 = FQ2((x0, x1))
    y_fq2 = FQ2((y0, y1))
    python_res = int(x_fq2 == y_fq2)
    assert res == python_res


#
@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
    x1=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
async def test_fq2_is_zero(fq2_factory, x0, x1):
    contract = fq2_factory
    execution_info = await contract.is_zero((split(x0), split(x1))).call()

    res = execution_info.result[0]
    x_fq2 = FQ2((x0, x1))
    zero_fq2 = FQ2.zero()
    python_res = int(x_fq2 == zero_fq2)
    assert res == python_res


@given(
    x0=st.integers(min_value=1, max_value=field_modulus - 1),
    x1=st.integers(min_value=0, max_value=field_modulus - 1),
)
# @pytest.mark.skip(
#     reason="The python sqrt function does not seem to work: it says (2,# 0), but for this to happen 2 would need to have a sqrt in F_p, # which is not the case.\nNote however that get_square_root is # implicitly tested in s test for square_root_division_fq2\nWe leave # writing a proper test as TODO"
# )
@pytest.mark.asyncio
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_get_sqrt(fq2_factory, x0, x1):
    contract = fq2_factory

    x_fq2 = FQ2((x0, x1))
    python_success = has_squareroot(x_fq2)

    execution_info = await contract.get_square_root((split(x0), split(x1))).call()
    cairo_success = execution_info.result[0]

    cairo_sqrt = FQ2(packFQP(execution_info.result[1]))

    assert cairo_success == int(python_success)

    if cairo_success == 1:
        assert cairo_sqrt**2 == x_fq2
