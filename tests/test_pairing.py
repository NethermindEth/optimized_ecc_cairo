from hypothesis import given, strategies as st, settings
from utils import field_modulus, split, splitFQP, packFQP
from utils_g2 import get_g2_point_from_seed
from py_ecc.optimized_bls12_381.optimized_pairing import linefunc, twist, miller_loop, pairing
from py_ecc.fields import (
    optimized_bls12_381_FQ as FQ,
    optimized_bls12_381_FQ2 as FQ2,
    optimized_bls12_381_FQ12 as FQ12
)
import pytest

@pytest.mark.asyncio
async def test_ate_loop_iteration(pairing_factory):
    contract = pairing_factory

    x1,xi1 = 352701069587466618187139116011060144890029952792775240219908644239793785735715026873347600343865175952761926303160, 3059144344244213709971259814753781636986470325476647558659373206291635324768958432433509563104347017837885763365758
    y1, yi1 = 1985150602287291935568054521177171638300868978215655730859378665066344726373823718423869104263333984641494340347905, 927553665492332455747201965776037880757740193453592970025027978793976877002675564980949289727957565575433344219582
    z1, zi1 = 1,0
    x2, y2, z2 = 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507, 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569, 1
    Q = (splitFQP(( x1, xi1 )), splitFQP(( y1, yi1 )), splitFQP(( z1, zi1 )))
    P = (split(x2), split(y2), split(z2))
    execution_info = await contract._ate_loop_iter(Q, P).call()
    print(execution_info)

@pytest.mark.skip("we want to test the other one rn")
@pytest.mark.asyncio
async def test_pairing(pairing_factory):
    contract = pairing_factory

    x1,xi1 = 352701069587466618187139116011060144890029952792775240219908644239793785735715026873347600343865175952761926303160, 3059144344244213709971259814753781636986470325476647558659373206291635324768958432433509563104347017837885763365758
    y1, yi1 = 1985150602287291935568054521177171638300868978215655730859378665066344726373823718423869104263333984641494340347905, 927553665492332455747201965776037880757740193453592970025027978793976877002675564980949289727957565575433344219582
    z1, zi1 = 1,0
    x2, y2, z2 = 3685416753713387016781088315183077757961620795782546409894578378688607592378376318836054947676345821548104185464507, 1339506544944476473020471379941921221584933875938349620426543736416511423956333506472724655353366534992391756441569, 1

    python_res = pairing((FQ2(( x1, xi1 )), FQ2(( y1, yi1 )), FQ2(( z1, zi1 ))), (FQ(x2), FQ(y2), FQ(z2)), False )
    Q = (splitFQP(( x1, xi1 )), splitFQP(( y1, yi1 )), splitFQP(( z1, zi1 )))
    P = (split(x2), split(y2), split(z2))
    execution_info = await contract.pairing(Q, P).call()
    print(execution_info)
    res = FQ12(packFQP(execution_info.result[0]))
    
    assert python_res == res

@pytest.mark.skip("we want to test the other one rn")
@pytest.mark.asyncio
async def test_miller_loop(pairing_factory):
    contract = pairing_factory

    x1,xi1, y1, yi1, z1, zi1 = field_modulus- 522,51234124,11251525, field_modulus - 621414265,12612645,6126412645
    x2, y2, z2 = 125125,field_modulus - 512551, 125152
    print("miller loop python")
    x,y = miller_loop((FQ2(( x1, xi1 )), FQ2(( y1, yi1 )), FQ2(( z1, zi1 ))), (FQ(x2), FQ(y2), FQ(z2)), False )
    print((x, y))

    Q = (splitFQP(( x1, xi1 )), splitFQP(( y1, yi1 )), splitFQP(( z1, zi1 )))
    P = (split(x1), split(y1), split(z1))
    print("miller loop cairo")
    execution_info = await contract._miller_loop(Q, P).call()
    print(execution_info)
    res_x = FQ12(packFQP(execution_info.result.f_num))
    res_y = FQ12(packFQP(execution_info.result.f_den))
    print((res_x, res_y))
    print((x, y))
    assert (res_x, res_y) == (x, y)

@pytest.mark.skip("we want to test the other one rn")
@given(
    x=st.integers(min_value=0, max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_twist(pairing_factory, x):

    contract = pairing_factory
    
    p1 = get_g2_point_from_seed(x)
    
    py_res = twist((p1.x, p1.y, p1.z))

    execution_info = await contract.twist_g2(p1.asTuple()).call()

    res_x = (FQ12(packFQP(execution_info.result[0].x)), FQ12(packFQP(execution_info.result[0].y)), FQ12(packFQP(execution_info.result[0].z)))

    assert res_x == py_res

@pytest.mark.skip("we want to test the other one rn")
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
async def test_line_func_gt(pairing_factory, x1, y1, z1, x2, y2, z2, xt, yt, zt):
    contract = pairing_factory

    def makefq12(num):
        return FQ12((num,num,num,num,num,num,num,num,num,num,num,num))

    x = (makefq12(x1), makefq12(y1), makefq12(z1))
    y = (makefq12(x2), makefq12(y2), makefq12(z2))
    t = (makefq12(xt), makefq12(yt), makefq12(zt))
    py_res = linefunc(x, y, t)
    def makefq12(num):
        return splitFQP((num, num,num,num,num,num,num,num,num,num,num,num))

    p1 = (makefq12(x1), makefq12(y1), makefq12(z1))
    p2 = (makefq12(x2), makefq12(y2), makefq12(z2))
    pt = (makefq12(xt), makefq12(yt), makefq12(zt))
    execution_info = await contract.line_func(p1, p2, pt).call()
    res_x = FQ12(packFQP(execution_info.result.x))
    res_y = FQ12(packFQP(execution_info.result.y))
    assert (res_x, res_y) == py_res