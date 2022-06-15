import pytest
from hashlib import sha256
from utils import packFQP, splitFQP, packPoint, pack, field_modulus, split
from hypothesis import given, strategies as st, settings
from py_ecc.bls.hash_to_curve import hash_to_field_FQ2, map_to_curve_G2, iso_map_G2, clear_cofactor_G2
from py_ecc.optimized_bls12_381.optimized_swu import sqrt_division_FQ2, optimized_swu_G2
from py_ecc.fields import (
    optimized_bls12_381_FQ2 as FQ2,
)


@pytest.mark.asyncio
async def test_sswu(
    hash_to_curve_factory
):  
    x_e0 = 1
    x_e1 = 2

    x = splitFQP((x_e0, x_e1))

    g2 = optimized_swu_G2(FQ2((x_e0, x_e1)))
    
    execution_info = await hash_to_curve_factory.sswu(x).call()
    print(execution_info)
    
    res = (FQ2(packFQP(execution_info.result.x)), 
    FQ2(packFQP(execution_info.result.y)), 
    FQ2(packFQP(execution_info.result.z)))

    assert res == g2


@given(
    u_e0=st.integers(min_value=1,  max_value=(field_modulus)),
    u_e1=st.integers(min_value=1,  max_value=(field_modulus)),
    v_e0=st.integers(min_value=1,  max_value=(field_modulus)),
    v_e1=st.integers(min_value=1,  max_value=(field_modulus)),
)
@settings(deadline=None)
@pytest.mark.asyncio
async def test_sqrt_div_fq2(
    hash_to_curve_factory,
    u_e0,
    u_e1,
    v_e0,
    v_e1
):  
    #u_e0 = 6704466015615104
    #u_e1 = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015661693267331723563
    #v_e0 = 15458688000000
    #v_e1 = 4002409555221667393417789825735904156556882819939007885332058136124031650490837864442687629129015664007519488559787
    u = splitFQP((u_e0, u_e1))
    v = splitFQP( (v_e0, v_e1) )

    print("gamma 1 " + str(splitFQP((904866787643216493162865161557708182631874241001798140054005332761593399486327068831291837213091505867113151808954, 744463903445922011632319549511244450475031948600322091634279861502307378579394884098823525357703520279878374341889))))

    success, expected = sqrt_division_FQ2(FQ2((u_e0, u_e1)), FQ2((v_e0, v_e1)))
    
    execution_info = await hash_to_curve_factory.sqrt_div_fq2(u, v).call()
    print(execution_info)
    
    is_success = execution_info.result[0]
    quotient = (FQ2(packFQP(execution_info.result[1])))
    
    assert is_success == success
    if is_success == 1:
        print(quotient)
        print(expected)
        assert quotient.coeffs[0] == expected.coeffs[0]
        assert quotient.coeffs[1] == expected.coeffs[1]

@pytest.mark.skip(reason="No")
@pytest.mark.asyncio
async def test_clear_cofactor(
    hash_to_curve_factory
):  
    x_e0 = 1
    x_e1 = 2
    y_e0 = 3
    y_e1 = 4
    z_e0 = 5
    z_e1 = 6

    x = splitFQP((x_e0, x_e1))
    y = splitFQP( (y_e0, y_e1) )
    z = splitFQP( (z_e0, z_e1) )

    py_ecc_res = clear_cofactor_G2((FQ2((x_e0, x_e1)), FQ2((y_e0, y_e1)), FQ2((z_e0, z_e1))))
    #execution_info = await hash_to_curve_factory.clear_cofactor((x, y, z)).call()
    res = (FQ2(( pack(( 254901378517544244706645441776018945913, 132049522493111832176764609945803451654, 34160335933974285331271138289732826020 )), pack(( 220770663610169593088940680860090029472, 284867596947214915087503149924202083865, 3368326084889830695407883316610177412 )) )),
        FQ2(( pack(( 205781181156407907781377572289095225933, 75930240239144567797244465197636892890, 19593488670596004384833296218985311585 )), pack(( 320814964242000688078187807810260073451, 162700578868616629276834792014594549126, 22522629189038034878135603531386017448 )) )),
        FQ2(( pack(( 112486017950633260614265052759105240696, 228004074530669371122078302061058892919, 29509685598246962113655062911654969676 )), pack(( 119838478576997659366518951764536221755, 268933459286166436140255995247419419418, 26859279577038315816007554627296393087 )) )))


    #print(execution_info)
    #res = packFQP(execution_info.result[0])
    print(py_ecc_res)
    print(res)
    assert res == py_ecc_res

@pytest.mark.skip(reason="No")
@pytest.mark.asyncio
async def test_clear_cofactor_2(
    hash_to_curve_factory
):  
    #inputs
    x_e0 = 1065677406967200509816609499423259421477445516936070432894744706131545618018271371235777696275644395847741467606580
    x_e1 = 1887682510382714014190262300940983615521688066406415135067802172795843728841716142801324000687676752845938582926909
    y_e0 = 3730666344553575518590442575555769011339512398551213036648031241094160328848553196936091635343188818506625671304033
    y_e1 = 3548517930152064589316394673841985885287391702088751980600432153435572174202349318006796823996071474565297895193995
    z_e0 = 3380320199399472671518931668520476396067793891014375699959770179129436917079329549063156654260311289858147769057277
    z_e1 = 0

    x = splitFQP((x_e0, x_e1))
    y = splitFQP( (y_e0, y_e1) )
    z = splitFQP( (z_e0, z_e1) )

    #expected outputs
    x_e0 = 1238357236673976904883383761949897458005933398715862486388082680596358564909360901167639680636649250024252200864048
    x_e1 = 2176671478811685548685422537274628613259355473920336201642139022643792583601891777492539871795574743143444755746685
    y_e0 = 307039709067892459706689765653742856053194360031017753606766825975525841751062961662075693543241207032539288958627
    y_e1 = 1057356291936096153218738131832523104416552153568862430652162642421229797640178040652221705178352835014718288323878
    z_e0 = 680515110440998969567192184401320539904999763830162702295655804716894250114174528471767566465332043369093230737599
    z_e1 = 2697028571936275266627777139954894429115172404954742516935731907450806602655154006786709169673582907014422306284443

    expected = (FQ2((x_e0, x_e1)), FQ2((y_e0, y_e1)), FQ2((z_e0, z_e1)))
    execution_info = await hash_to_curve_factory.clear_cofactor((x, y, z)).call()
    print(execution_info)
    
    res = (FQ2(packFQP(execution_info.result.x)), 
    FQ2(packFQP(execution_info.result.y)), 
    FQ2(packFQP(execution_info.result.z)))

    print(expected)
    print(res)
    assert res == expected

@pytest.mark.skip(reason="No")
@pytest.mark.asyncio
async def test_isogeny_map_g2(
    hash_to_curve_factory
):  
    x_e0 = 1
    x_e1 = 2
    y_e0 = 3
    y_e1 = 4
    z_e0 = 5
    z_e1 = 6

    contract = hash_to_curve_factory
    
    x = splitFQP((x_e0, x_e1))
    y = splitFQP( (y_e0, y_e1) )
    z = splitFQP( (z_e0, z_e1) )
    
    py_ecc_res = iso_map_G2(FQ2((x_e0, x_e1)), FQ2((y_e0, y_e1)), FQ2((z_e0, z_e1)))

    execution_info = await contract.isogeny_g2(x, y, z).call()
    g2point = (FQ2(packFQP(execution_info.result.x_res)), 
    FQ2(packFQP(execution_info.result.y_res)), 
    FQ2(packFQP(execution_info.result.z_res)))
    
    assert int(g2point[0].coeffs[0]) == int(py_ecc_res[0].coeffs[0])
    assert int(g2point[0].coeffs[1]) == int(py_ecc_res[0].coeffs[1])

    assert int(g2point[1].coeffs[0]) == int(py_ecc_res[1].coeffs[0])
    assert int(g2point[1].coeffs[1]) == int(py_ecc_res[1].coeffs[1])
    
    assert int(g2point[2].coeffs[0]) == int(py_ecc_res[2].coeffs[0])
    assert int(g2point[2].coeffs[1]) == int(py_ecc_res[2].coeffs[1])


@pytest.mark.skip(reason="No")
@pytest.mark.parametrize('H', [sha256])
@pytest.mark.parametrize(
    'msg,x,y',
    [
        (b'',
        FQ2([0x0141ebfbdca40eb85b87142e130ab689c673cf60f1a3e98d69335266f30d9b8d4ac44c1038e9dcdd5393faf5c41fb78a, 0x05cb8437535e20ecffaef7752baddf98034139c38452458baeefab379ba13dff5bf5dd71b72418717047f5b0f37da03d]),
        FQ2([0x0503921d7f6a12805e72940b963c0cf3471c7b2a524950ca195d11062ee75ec076daf2d4bc358c4b190c0c98064fdd92, 0x12424ac32561493f3fe3c260708a12b7c620e7be00099a974e259ddc7d1f6395c3c811cdd19f1e8dbf3e9ecfdcbab8d6])),
        (b'abc',
        FQ2([0x02c2d18e033b960562aae3cab37a27ce00d80ccd5ba4b7fe0e7a210245129dbec7780ccc7954725f4168aff2787776e6, 0x139cddbccdc5e91b9623efd38c49f81a6f83f175e80b06fc374de9eb4b41dfe4ca3a230ed250fbe3a2acf73a41177fd8]),
        FQ2([0x1787327b68159716a37440985269cf584bcb1e621d3a7202be6ea05c4cfe244aeb197642555a0645fb87bf7466b2ba48, 0x00aa65dae3c8d732d10ecd2c50f8a1baf3001578f71c694e03866e9f3d49ac1e1ce70dd94a733534f106d4cec0eddd16])),
        (b'abcdef0123456789',
        FQ2([0x121982811d2491fde9ba7ed31ef9ca474f0e1501297f68c298e9f4c0028add35aea8bb83d53c08cfc007c1e005723cd0, 0x190d119345b94fbd15497bcba94ecf7db2cbfd1e1fe7da034d26cbba169fb3968288b3fafb265f9ebd380512a71c3f2c]),
        FQ2([0x05571a0f8d3c08d094576981f4a3b8eda0a8e771fcdcc8ecceaf1356a6acf17574518acb506e435b639353c2e14827c8, 0x0bb5e7572275c567462d91807de765611490205a941a5a6af3b1691bfe596c31225d3aabdf15faff860cb4ef17c7c3be])),
        (b'a512_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
        FQ2([0x01a6ba2f9a11fa5598b2d8ace0fbe0a0eacb65deceb476fbbcb64fd24557c2f4b18ecfc5663e54ae16a84f5ab7f62534, 0x11fca2ff525572795a801eed17eb12785887c7b63fb77a42be46ce4a34131d71f7a73e95fee3f812aea3de78b4d01569]),
        FQ2([0x0b6798718c8aed24bc19cb27f866f1c9effcdbf92397ad6448b5c9db90d2b9da6cbabf48adc1adf59a1a28344e79d57e, 0x03a47f8e6d1763ba0cad63d6114c0accbef65707825a511b251a660a9b3994249ae4e63fac38b23da0c398689ee2ab52])),
    ]
)
@pytest.mark.asyncio
async def test_expanded_hash_to_curve(
    hash_to_curve_factory,
    msg,
    x,
    y,
    H
):  

    DST = b'QUUX-V01-CS02-with-BLS12381G2_XMD:SHA-256_SSWU_RO_'
    u0, u1 = hash_to_field_FQ2(msg, 2, DST, H)
    q0 = map_to_curve_G2(u0)

    a = u0.coeffs[0]
    execution_info = await hash_to_curve_factory.fq2_to_curve(splitFQP(u0.coeffs)).call()
    x = execution_info.result.x
    y = execution_info.result.y
    z = execution_info.result.z

    print(x)
    print(y)
    print(z)
    
    assert packPoint(x, y, z) == q0