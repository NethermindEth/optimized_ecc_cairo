import pytest
from utils import split
from utils import field_modulus as p

@pytest.mark.skip("")
@pytest.mark.asyncio
async def test_benchmark_uin384(uint384_contract):
    
    print("\n")
    print("uint384 benchmarks")
    print(
    "%20s" % "function",
    "|",
    "%20s" % "n_steps",
    "|",
    "%-10s" % "builtins",
    )


    x = 2 ** 360
    y = 2 ** 360

    x_split = split(x, num_bits_shift=128, length=3)
    y_split = split(y, num_bits_shift=128, length=3)

    execution_info = await uint384_contract.uint384_eq(x_split, y_split).call()
    
    print(
    "%20s" % "eq",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_add(x_split, y_split).call()
    
    print(
    "%20s" % "add",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_sub(x_split, y_split).call()
    
    print(
    "%20s" % "sub",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_mul(x_split, y_split).call()
    
    print(
    "%20s" % "mul",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_mul_b(x_split, y_split).call()
    
    print(
    "%20s" % "mul b",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )
    
    execution_info = await uint384_contract.uint384_mul_c(x_split, y_split).call()
    
    print(
    "%20s" % "mul c",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )
    
    execution_info = await uint384_contract.uint384_mul_d(x_split, y_split).call()
    
    print(
    "%20s" % "mul d",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_mul_Toom3(x_split, y_split).call()
    
    print(
    "%20s" % "mul Toom 3",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_mul_mont(x_split, y_split).call()
    
    print(
    "%20s" % "mul mont",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_square_c(x_split).call()
    
    print(
    "%20s" % "square c",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_square_d(x_split).call()
    
    print(
    "%20s" % "square d",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )
    
    execution_info = await uint384_contract.uint384_square_e(x_split).call()
    
    print(
    "%20s" % "square e",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_unsigned_div_rem(x_split, y_split).call()
    
    print(
    "%20s" % "xor",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_and(x_split, y_split).call()
    
    print(
    "%20s" % "and",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_or(x_split, y_split).call()
    
    print(
    "%20s" % "or",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_shl(x_split, y_split).call()
    
    print(
    "%20s" % "shift left",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_shr(x_split, y_split).call()
    
    print(
    "%20s" % "shift right",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_pow2(x_split).call()
    
    print(
    "%20s" % "pow 2",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_sqrt(x_split).call()
    
    print(
    "%20s" % "sqrt",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await uint384_contract.uint384_reverse_endian(x_split).call()
    print("%20s" % "reverse endian","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|","%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,)

    execution_info = await uint384_contract.uint384_lt(x_split, y_split).call()
    
    print("%20s" % "lt","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|","%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,)

    execution_info = await uint384_contract.uint384_le(x_split, y_split).call()
    
    print("%20s" % "le","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|","%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,)

    execution_info = await uint384_contract.uint384_signed_le(x_split, y_split).call()
    
    print("%20s" % "signed le","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|","%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter)

    execution_info = await uint384_contract.uint384_signed_lt(x_split, y_split).call()
    
    print("%20s" % "signed lt","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|","%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,)

    execution_info = await uint384_contract.uint384_signed_nn(x_split).call()
    
    print("%20s" % "signed nn","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|","%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter)

    execution_info = await uint384_contract.uint384_signed_nn_le(x_split, y_split).call()
    print("%20s" % "signed nn_le","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|","%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter)

    execution_info = await uint384_contract.uint384_signed_div_rem(x_split, y_split).call()
    print("%20s" % "signed div rem","|","%20s" % execution_info.call_info.execution_resources.n_steps,"|", "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter)

@pytest.mark.asyncio
async def test_benchmark_field_arithmetic(fq_factory):
    
    print("\n")
    print("field arithmetic benchmarks")
    print(
    "%20s" % "function",
    "|",
    "%20s" % "n_steps",
    "|",
    "%-10s" % "builtins",
    )

    x = 2 ** 360
    y = 2 ** 360

    x_split = split(x, num_bits_shift=128, length=3)
    y_split = split(y, num_bits_shift=128, length=3)
    p_split = split(p, num_bits_shift=128, length=3)

    execution_info = await fq_factory.add(x_split, y_split).call()
    
    print(
    "%20s" % "add",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await fq_factory.sub(x_split, y_split).call()
    
    print(
    "%20s" % "sub",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await fq_factory.mul(x_split, y_split).call()
    
    print(
    "%20s" % "mul",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )


    execution_info = await fq_factory.pow(x_split, y_split).call()
    
    print(
    "%20s" % "pow",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await fq_factory.is_square_non_optimized(x_split).call()
    
    print(
    "%20s" % "is square",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )

    execution_info = await fq_factory.get_square_root(x_split).call()
    
    print(
    "%20s" % "sqrt",
    "|",
    "%20s" % execution_info.call_info.execution_resources.n_steps,
    "|",
    "%-10s" % execution_info.call_info.execution_resources.builtin_instance_counter,
    )