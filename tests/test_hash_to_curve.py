import pytest
from hashlib import sha256
from utils import packFQP, splitFQP, packPoint, pack, field_modulus
from hypothesis import given, strategies as st, settings
from py_ecc.bls.hash_to_curve import hash_to_field_FQ2, map_to_curve_G2, iso_map_G2, clear_cofactor_G2

from py_ecc.fields import (
    optimized_bls12_381_FQ2 as FQ2,
)

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
    execution_info = await hash_to_curve_factory.clear_cofactor_g2((x, y, z)).call()
    res = packFQP(execution_info.result[0])
    assert res == py_ecc_res

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