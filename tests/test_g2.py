from re import A
import pytest
from hypothesis import given, strategies as st, settings
from sympy import Segment2D
from utils import (
    field_modulus,
    split
)
from utils_g2 import (
    g2_add,
    g2_double,
    get_g2_point_from_seed,
    g2_scalar_mul,
    get_g2_infinity_point,
    create_G2Point_from_tuple,
    create_G2Point_from_execution_result

)


@pytest.mark.asyncio
async def test_simplified_swu(g2_factory):
    contract = g2_factory

    u = (3167513664919274145284120531783832167109412382891894149785243170285502267171979051519659283907216630953242533668083, 937777375012248364046258719955852202763745212036378667068270601128566462923809130180553313818680631629584660435720)
    split_u = splitFQP(u)
    execution_info = await contract.swu(split_u).call()
    res_x = execution_info.result.x
    res_y = execution_info.result.y

    x = (1191280635306064362579559890038707975622268661555303961354228638611832621882023088035575204380024620397779485869656, 1933663121992846394380654530303100996747115576855130163728966149341897161049098093380522640470406163493706419998970)

    y2 = (1383282644364609129277359791348395049910790469702063624415180184742517341199180212944747239958125534558515354701338, 1540394283934845078656854127456278548048151841836384388403519137407486470551958789391043830952784400250293246580758)
    
    assert pack(res_x.e0) == x[0]
    assert pack(res_x.e1) == x[1]

    assert pack(res_y.e0) == y2[0]
    assert pack(res_y.e1) == y2[1]

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
async def test_g2_add_short(g2_factory, a_seed, b_seed):
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
@pytest.mark.skip(reason="Took several hours to complete")
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

@given(
    scalar=st.integers(min_value=0, max_value=2**50-1),
    seed=st.integers(min_value=0, max_value=field_modulus - 1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_scalar_mul(g2_factory, scalar, seed):
    contract = g2_factory

    print(scalar, seed)

    contract = g2_factory

    scalar = (24,0,0)
    seed =1

    print(scalar, seed)

    a = get_g2_point_from_seed(seed)


    print("findme0", a)
    print("findme1", a.asTuple())

    execution_info = await contract.scalar_mul(scalar, a.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)

    print("findme0", scalar)
    python_result = g2_scalar_mul(scalar, a)
    print("cairo_result", cairo_result)
    print("python_result", python_result)
    print("ff1")
    assert python_result == python_result
    print("ff2")


@pytest.mark.asyncio
async def test_g2_scalar_mul_specific(g2_factory):
    contract = g2_factory

    scalar = (24,0,0)
    seed =1

    print(scalar, seed)

    a = get_g2_point_from_seed(seed)
    
    
    print("findme0", a)
    print("findme1", a.asTuple())

    execution_info = await contract.scalar_mul(scalar, a.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(res)
    
    
    print("findme0", scalar)
    python_result = g2_scalar_mul(scalar, a)

    print("cairo_result", cairo_result)
    print("python_result", python_result)
    print("ff1")
    assert python_result == python_result
    print("ff2")

