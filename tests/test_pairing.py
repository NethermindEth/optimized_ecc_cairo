from hypothesis import given, strategies as st, settings
from utils import field_modulus, split, pack, splitFQP
from py_ecc.optimized_bls12_381.optimized_pairing import linefunc
from py_ecc.fields import (
    optimized_bls12_381_FQ as FQ
)
import pytest

@given(
    x1=st.integers(min_value=0, max_value=(field_modulus)),
    y1=st.integers(min_value=0, max_value=(field_modulus)),
    z1=st.integers(min_value=0, max_value=(field_modulus)),
    x2=st.integers(min_value=0, max_value=(field_modulus)),
    y2=st.integers(min_value=0, max_value=(field_modulus)),
    z2=st.integers(min_value=0, max_value=(field_modulus)),
    xt=st.integers(min_value=1, max_value=(field_modulus)),
    yt=st.integers(min_value=0, max_value=(field_modulus)),
    zt=st.integers(min_value=0, max_value=(field_modulus))
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_line_func_g1(pairing_factory, x1, y1, z1, x2, y2, z2, xt, yt, zt):

    contract = pairing_factory

    print("case ", x1, y1, z1, x2, y2, z2, xt, yt, zt)
    x = (FQ(x1), FQ(y1), FQ(z1))
    y = (FQ(x2), FQ(y2), FQ(z2))
    t = (FQ(xt), FQ(yt), FQ(zt))
    py_res = linefunc(x, y, t)

    p1 = splitFQP((x1, y1, z1))
    p2 = splitFQP((x2, y2, z2))
    pt = splitFQP((xt, yt, zt))
    execution_info = await contract.line_func(p1, p2, pt).call()

    res_x = pack(execution_info.result.x)
    res_y = pack(execution_info.result.y)

    assert (res_x, res_y) == py_res
