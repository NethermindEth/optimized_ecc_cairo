from re import A
from matplotlib.cm import register_cmap
import pytest
from hypothesis import given, strategies as st, settings
from utils import create_G2Point_from_execution_result, field_modulus, split, g2_add, get_g2_point_from_seed




@given(
    a_seed=st.integers(min_value=1, max_value=field_modulus-1),
    b_seed=st.integers(min_value=1, max_value=field_modulus-1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_add_properties(g2_factory, a_seed, b_seed):
    contract = g2_factory
    
    print(a_seed, b_seed)
    
    a = get_g2_point_from_seed(a_seed)
    b = get_g2_point_from_seed(b_seed)
    zero = get_g2_point_from_seed(0)

    # a + 0
    execution_info = await contract.add(tuple(a.asTuple()), tuple(zero.asTuple())).call()
    res = execution_info.result[0]
    assert a ==  create_G2Point_from_execution_result(res)

    # 0 + b
    execution_info = await contract.add(zero.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    assert b ==  create_G2Point_from_execution_result(res)

    # a + b = b + a
    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res_1 = execution_info.result[0]

    execution_info = await contract.add(b.asTuple(), a.asTuple()).call()
    res_2 = execution_info.result[0]

    assert create_G2Point_from_execution_result(
        res_1
    ) == create_G2Point_from_execution_result(res_2)



@given(
    a_seed=st.integers(min_value=1, max_value=field_modulus-1),
    b_seed=st.integers(min_value=1, max_value=field_modulus-1),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_g2_add_(g2_factory,  a_seed, b_seed):
    contract = g2_factory
        
    a = get_g2_point_from_seed(a_seed)
    b = get_g2_point_from_seed(b_seed)

    execution_info = await contract.add(a.asTuple(), b.asTuple()).call()
    res = execution_info.result[0]
    cairo_result = create_G2Point_from_execution_result(
        res
    ) 
    
    python_result = g2_add(a, b)
    assert cairo_result == python_result
