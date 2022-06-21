import pytest
from web3 import Web3
from utils import bytes_32_to_uint_256_little, bytes_32_to_uint_256_little, bitwise_or_bytes


@pytest.mark.asyncio
async def test_hash_to_fp(hash_to_curve_factory):
    contract = hash_to_curve_factory

    z_pad =  bytes.fromhex("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000")
    msg = bytes.fromhex("27c77ad9814f4e33e9d640482ccb7996eb095b0027384948140597fb9901ad63")
    l_i_b_str =  bytes.fromhex("0100")
    I20SP = bytes.fromhex("00")
    domain = bytes.fromhex("424c535f5349475f424c53313233383147325f584d443a5348412d3235365f535357555f524f5f4e554c5f")
    domainLen = bytes.fromhex("2b")
    I2OSP_1 = bytes.fromhex("01")

    b_0_bytes = z_pad + msg + l_i_b_str + I20SP + domain + domainLen
    b_0 = Web3.keccak(b_0_bytes)
    
    b_1_bytes = b_0 + I2OSP_1 + domain + domainLen
    b_1 = Web3.keccak(b_1_bytes)

    b_i = b_1
    total = b''
    for i in range (4):
        temp = Web3.keccak(bitwise_or_bytes(b_0, b_i) + int(1 + i).to_bytes(1, "little") + domain + domainLen)
        total = total + b_i
        b_i = temp
    
    msg_uint256 = bytes_32_to_uint_256_little(msg)

    test_keccak_call = await contract.hash_to_field(
       msg_uint256
    ).call()

    hashes = []
    
    hashes.append(test_keccak_call.result.one)
    hashes.append(test_keccak_call.result.two)
    hashes.append(test_keccak_call.result.three)
    hashes.append(test_keccak_call.result.four)
    
    res = ''
    for hash in hashes:
        res = res + hash.low.to_bytes(16, 'little').hex() + hash.high.to_bytes(16, 'little').hex()

    output = res

    assert output == total.hex()