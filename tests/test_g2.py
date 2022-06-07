from re import A
from matplotlib.cm import register_cmap
import pytest
from hypothesis import given, strategies as st, settings
from sympy import Segment2D
from utils import (
    create_G2Point_from_execution_result,
    field_modulus,
    split,
    g2_add,
    get_g2_point_from_seed,
    g2_scalar_mul,
    get_g2_infinity_point
)




@given(
    a_seed=st.integers(min_value=1, max_value=field_modulus - 1),
    b_seed=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_eq(g2_factory, a_seed, b_seed):
    contract = g2_factory

    a = get_g2_point_from_seed(a_seed)
    b = get_g2_point_from_seed(b_seed)

    execution_info = await contract.eq(a.asTuple(), b.asTuple()).call()
    cairo_result = execution_info.result[0]

    python_result = a == b
    assert cairo_result == python_result


@given(
    a_seed=st.integers(min_value=1, max_value=field_modulus - 1),
    b_seed=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_add_properties(g2_factory, a_seed, b_seed):
    contract = g2_factory

    print(a_seed, b_seed)

    a = get_g2_point_from_seed(a_seed)
    b = get_g2_point_from_seed(b_seed)
    infinity = get_g2_infinity_point()

    # a + 0
    execution_info = await contract.add(
        tuple(a.asTuple()), tuple(infinity.asTuple())
    ).call()
    res = execution_info.result[0]
    assert a == create_G2Point_from_execution_result(res)

    # 0 + b
    execution_info = await contract.add(infinity.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    assert b == create_G2Point_from_execution_result(res)

    # a + b = b + a
    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res_1 = execution_info.result[0]

    execution_info = await contract.add(b.asTuple(), a.asTuple()).call()
    res_2 = execution_info.result[0]

    assert create_G2Point_from_execution_result(
        res_1
    ) == create_G2Point_from_execution_result(res_2)


@given(
    a_seed=st.integers(min_value=1, max_value=field_modulus - 1),
    b_seed=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_add(g2_factory, a_seed, b_seed):
    contract = g2_factory

    a = get_g2_point_from_seed(a_seed)
    b = get_g2_point_from_seed(b_seed)

    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    python_result = g2_add(a, b)
    assert cairo_result == python_result


@pytest.mark.asyncio
async def test_g2_add_specific(g2_factory):
    contract = g2_factory
    a_seed, b_seed = 9541646223264729170, 20991
    a = get_g2_point_from_seed(a_seed)
    b = get_g2_point_from_seed(b_seed)

    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    python_result = g2_add(a, b)
    assert cairo_result == python_result



@given(
    scalar=st.integers(min_value=1, max_value=2**250),
    seed=st.integers(min_value=1, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_scalar_mul(g2_factory, scalar, seed):
    contract = g2_factory
    
    print(scalar, seed)
    
    a = get_g2_point_from_seed(seed)

    execution_info = await contract.scalar_mul(scalar, a.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    python_result = g2_scalar_mul(scalar, a)
    assert cairo_result == python_result


@pytest.mark.asyncio
async def test_g2_scalar_mul_specific(g2_factory):
    contract = g2_factory
    
    scalar = 3
    seed = 1
    
    print(scalar, seed)
    
    a = get_g2_point_from_seed(seed)
    
    print("findme0", a)
    print("findme1", a.asTuple())
    
    execution_info = await contract.scalar_mul(scalar, a.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    python_result = g2_scalar_mul(scalar, a)
    print("cairo_result", cairo_result)
    print("python_result", python_result)
    assert cairo_result == python_result
