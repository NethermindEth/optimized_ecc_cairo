from utils import (pack, print_fq2)

def print_isogyny_params( x_num_1, x_num_2, x_num_3, x_num_4, x_den_1, x_den_2, x_den_3, x_den_4,y_num_1, y_num_2, y_num_3, y_num_4,y_den_1, y_den_2, y_den_3, y_den_4,
):
    print("ParamsThreeIsogenyG2(")

    print("x_num_1=", end='')
    print_fq2(x_num_1)
    print(",")

    print("x_num_2=", end='')
    print_fq2(x_num_2)
    print(",")

    print("x_num_3=", end='')
    print_fq2(x_num_3)
    print(",")

    print("x_num_4=", end='')
    print_fq2(x_num_4)
    print(",")

    print("x_den_1=", end='')
    print_fq2(x_den_1)
    print(",")

    print("x_den_2=", end='')
    print_fq2(x_den_2)
    print(",")

    print("x_den_3=", end='')
    print_fq2(x_den_3)
    print(",")

    print("x_den_4=", end='')
    print_fq2(x_den_4)
    print(",")

    print("y_num_1=", end='')
    print_fq2(y_num_1)
    print(",")

    print("y_num_2=", end='')
    print_fq2(y_num_2)
    print(",")

    print("y_num_3=", end='')
    print_fq2(y_num_3)
    print(",")

    print("y_num_4=", end='')
    print_fq2(y_num_4)
    print(",")

    print("y_den_1=", end='')
    print_fq2(y_den_1)
    print(",")

    print("y_den_2=", end='')
    print_fq2(y_den_2)
    print(",")

    print("y_den_3=", end='')
    print_fq2(y_den_3)
    print(",")

    print("y_den_4=", end='')
    print_fq2(y_den_4)
    print(")")



def three_isogeny_constants_g2():
    x_num_1 = int('5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6', 16)
    x_num_1_i = int('5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97d6', 16)

    x_num_2_i = int('11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71a', 16)

    x_num_3 = int('11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71e', 16)
    x_num_3_i = int('8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38d', 16)

    x_num_4 = int('171d6541fa38ccfaed6dea691f5fb614cb14b4e7f4e810aa22d6108f142b85757098e38d0f671c7188e2aaaaaaaa5ed1', 16)

    x_den_1_i = int('1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa63', 16)
    
    x_den_2 = int('c', 16)
    x_den_2_i = int('1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa9f', 16)

    y_num_1 = int('1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706', 16)
    y_num_1_i = int('1530477c7ab4113b59a4c18b076d11930f7da5d4a07f649bf54439d87d27e500fc8c25ebf8c92f6812cfc71c71c6d706', 16)

    y_num_2_i = int('5c759507e8e333ebb5b7a9a47d7ed8532c52d39fd3a042a88b58423c50ae15d5c2638e343d9c71c6238aaaaaaaa97be', 16)

    y_num_3 = int('11560bf17baa99bc32126fced787c88f984f87adf7ae0c7f9a208c6b4f20a4181472aaa9cb8d555526a9ffffffffc71c', 16)
    y_num_3_i = int('8ab05f8bdd54cde190937e76bc3e447cc27c3d6fbd7063fcd104635a790520c0a395554e5c6aaaa9354ffffffffe38f', 16)

    y_num_4 = int('124c9ad43b6cf79bfbf7043de3811ad0761b0f37a1e26286b0e977c69aa274524e79097a56dc4bd9e1b371c71c718b10', 16)

    y_den_1 = int('1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb', 16)
    y_den_1_i = int('1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa8fb', 16)

    y_den_2_i = int('1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffa9d3', 16)

    y_den_3 = int('12', 16)
    y_den_3_i = int('1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa99', 16)

    secret_number = pack([int('760900000002fffd', 16), int('ebf4000bc40c0002', 16), int('5f48985753c758ba', 16), int('77ce585370525745', 16), int('5c071a97a256ec6d', 16), int('15f65ec3fa80e493', 16)], 64)
    
    print_isogyny_params(
        [x_num_1, x_num_1_i],
        [0, x_num_2_i],
        [x_num_3, x_num_3_i],
        [x_num_4, 0],
        [0, x_den_1_i],
        [x_den_2, x_den_2_i],
        [secret_number,0],
        [0,0],
        [y_num_1, y_num_1_i],
        [0, y_num_2_i],
        [y_num_3, y_num_3_i],
        [y_num_4, 0],
        [y_den_1, y_den_1_i],
        [0, y_den_2_i],
        [y_den_3, y_den_3_i],
        [secret_number, 0]
    )
    
    

three_isogeny_constants_g2()