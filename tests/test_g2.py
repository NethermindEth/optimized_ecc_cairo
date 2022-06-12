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
    g2_double,
    get_g2_point_from_seed,
    g2_scalar_mul,
    get_g2_infinity_point,
    create_G2Point_from_tuple,
)
from copy import deepcopy


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


@given(
    point_x_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_x_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    point_y_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_y_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    point_z_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_z_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    other_x_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    other_x_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    other_y_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    other_y_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    other_z_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    other_z_e1=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_add_long(
    g2_factory,
    point_x_e0,
    point_x_e1,
    point_y_e0,
    point_y_e1,
    point_z_e0,
    point_z_e1,
    other_x_e0,
    other_x_e1,
    other_y_e0,
    other_y_e1,
    other_z_e0,
    other_z_e1,
):
    contract = g2_factory

    a = create_G2Point_from_tuple(
        [point_x_e0, point_x_e1, point_y_e0, point_y_e1, point_z_e0, point_z_e1]
    )
    b = create_G2Point_from_tuple(
        [other_x_e0, other_x_e1, other_y_e0, other_y_e1, other_z_e0, other_z_e1]
    )

    if point_z_e0 == 0 and point_z_e1 == 0:
        a = get_g2_infinity_point()
    if other_z_e0 == 0 and other_z_e1 == 0:
        b = get_g2_infinity_point()

    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    python_result = g2_add(a, b)
    assert cairo_result == python_result


@given(
    point_x_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_x_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    point_y_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_y_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    point_z_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_z_e1=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_add_three_long(
    g2_factory,
    point_x_e0,
    point_x_e1,
    point_y_e0,
    point_y_e1,
    point_z_e0,
    point_z_e1,
):
    contract = g2_factory

    a = create_G2Point_from_tuple(
        [point_x_e0, point_x_e1, point_y_e0, point_y_e1, point_z_e0, point_z_e1]
    )
    if point_z_e0 == 0 and point_z_e1 == 0:
        a = get_g2_infinity_point()

    execution_info = await contract.add_three(a.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    python_result = g2_add(a, g2_add(a, a))
    assert cairo_result == python_result


@given(
    point_x_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_x_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    point_y_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_y_e1=st.integers(min_value=0, max_value=field_modulus - 1),
    point_z_e0=st.integers(min_value=0, max_value=field_modulus - 1),
    point_z_e1=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_double_long(
    g2_factory,
    point_x_e0,
    point_x_e1,
    point_y_e0,
    point_y_e1,
    point_z_e0,
    point_z_e1,
):
    contract = g2_factory

    a = create_G2Point_from_tuple(
        [point_x_e0, point_x_e1, point_y_e0, point_y_e1, point_z_e0, point_z_e1]
    )
    if point_z_e0 == 0 and point_z_e1 == 0:
        a = get_g2_infinity_point()

    execution_info = await contract.double(a.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    python_result = g2_double(a)
    assert cairo_result == python_result


@pytest.mark.asyncio
async def test_g2_add_specific(g2_factory):
    contract = g2_factory
    a_seed = 1
    b_seed = 1
    a = get_g2_point_from_seed(a_seed)
    b = get_g2_point_from_seed(b_seed)

    python_result = g2_add(deepcopy(a), deepcopy(b))
    # double_result = g2_double(a)
    # python_result = g2_add(a, python_result)

    execution_info = await contract.add(
        deepcopy(a).asTuple(), deepcopy(b).asTuple()
    ).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    # execution_info = await contract.double(a.asTuple()).call()
    # res = execution_info.result[0]
    # cairo_double_result = create_G2Point_from_execution_result(res)
    # execution_info = await contract.add(a.asTuple(), cairo_result.asTuple()).call()
    # res = execution_info.result[0]
    # cairo_result = create_G2Point_from_execution_result(res)

    # findme Optimized_Point3D_Modified((516846940138849715765221684869614166287724727204503387502812359365406335290382035814868032723078455724052054635660, 2551095720192892493287849666002316263706051942374304669481578089331858342635163270148959154038429305481381378868312), (3951867076697288153209900071355855328693413906437886495028205335110071039488536542638347487419517749290254590470825, 2424371192714917299748068189562179605307229040648349685857085153273267512083354640814718284158050679374689153986374), (1113759249295653619533605474141138022446455278970877711125047874458204458037492452608986866368023502785174836117276, 3463566580105363618915042755655956628006829456013913648681213609126865002805752807129014128579853032029248783266022))

    print("findme", python_result)
    # print("findme", double_result)
    # print(cairo_double_result)
    print(cairo_result)

    # assert double_result == python_result
    # assert cairo_result == cairo_double_result
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
    seed = 2

    print(scalar, seed)

    a = get_g2_point_from_seed(seed)

    print("findme0", a)
    print("findme1", a.asTuple())

    execution_info = await contract.scalar_mul(scalar, a.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    execution_info = await contract.add(a.asTuple(), a.asTuple()).call()
    cr2 = execution_info.result[0]
    cr2 = create_G2Point_from_execution_result(cr2)
    execution_info = await contract.add(a.asTuple(), cr2.asTuple()).call()
    cr2 = execution_info.result[0]
    cairo_result2 = create_G2Point_from_execution_result(cr2)

    python_result = g2_scalar_mul(scalar, a)

    python_result2 = g2_add(a, g2_add(a, a))
    print("cairo_result", cairo_result)
    print("cairo_result2", cairo_result2)
    print("python_result", python_result)
    print("python_result2", python_result2)
    assert cairo_result == cairo_result2
    print("ff1")
    assert python_result == python_result2
    print("ff2")
    assert cairo_result2 == python_result
