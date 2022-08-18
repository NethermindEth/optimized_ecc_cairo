
import pytest


@pytest.mark.asyncio
async def test_ecdsa(ecdsa_factory):
    contract = ecdsa_factory

    print("start ecdsa")
    execution_info = await contract.verify().call()
    
    print(execution_info)
    print("end ecdsa")