import pytest
from utils import (
    pack,
)

NUM=2 ** 128

def result_to_int(result):
    return result.low.low + NUM*result.low.high + NUM**2*result.high.low + NUM**3*result.high.high

@pytest.mark.asyncio
async def test_karatsuba(karatsuba_factory):

    #num = 2 ** 96
    num = 2 ** 128 - 1
    a = (num, num)
    aint = a[0] + NUM*a[1]
    b = (num, num)
    bint = b[0] + NUM*b[1]
    prod = aint*bint

    contract = karatsuba_factory
    print("\n")
    print(
    "%20s" % "function",
    "|",
    "%20s" % "n_steps",
    "|",
    "%-10s" % "builtins",
    )

    execution_info = await contract.mul_a(a, b).call()

    print(  
    "%20s" % "mul a",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    assert result_to_int(execution_info.result) == prod

    execution_info = await contract.mul_b(a, b).call()

    print(
    "%20s" % "mul b",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    assert result_to_int(execution_info.result) == prod
    
    execution_info = await contract.mul_c(a, b).call()

    print(
    "%20s" % "mul c",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    assert result_to_int(execution_info.result) == prod

    execution_info = await contract.kar_a(a, b).call()

    print(  
    "%20s" % "kar a",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )
    
    assert result_to_int(execution_info.result) == prod
    
    execution_info = await contract.kar_b(a, b).call()

    print(
    "%20s" % "kar b",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    assert result_to_int(execution_info.result) == prod

    execution_info = await contract.kar_c(a, b).call()

    print(
    "%20s" % "kar c",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    assert result_to_int(execution_info.result) == prod
    
