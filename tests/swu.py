from utils import (pack, print_fq2)

def print_swu_params(a, b, z , z_inv, minus_b):
    print("ParamsSWU(")

    print("a=", end='')
    print_fq2(a)
    print(",")

    print("b=", end='')
    print_fq2(b)
    print(",")

    print("z=", end='')
    print_fq2(z)
    print(",")

    print("z_inv=", end='')
    print_fq2(z_inv)
    print(",")

    print("minus_b_over_a=", end='')
    print_fq2(minus_b)
    print(")")


def generate_swu_params():

    a_x = pack([0, 0, 0, 0, 0, 0])
    a_y = pack([ int("e53a000003135242", 16), int("01080c0fdef80285", 16), int("e7889edbe340f6bd", 16), int("0b51375126310601", 16), int("02d6985717c744ab", 16), int("1220b4e979ea5467", 16) ])

    b_x = pack([ int("22ea00000cf89db2", 16), int("6ec832df71380aa4", 16), int("6e1b403db5a66e", 16), int("75bf3c53a79473ba", 16), int("3dd3a569412c0a34", 16), int("125cdb5e74dc4fd1", 16) ])
    b_y = pack([ int("22ea00000cf89db2", 16), int("6ec832df71380aa4", 16), int("6e1b94403db5a66e", 16), int("75bf3c53a79473ba", 16), int("3dd3a569412c0a34", 16), int("125cdb5e74dc4fd1", 16) ])

    z_x = pack([ int("87ebfffffff9555c", 16), int("656fffe5da8ffffa", 16), int("0fd0749345d33ad2", 16), int("d951e663066576f4", 16), int("de291a3d41e980d3", 16), int("0815664c7dfe040d", 16) ])
    z_y = pack([ int("43f5fffffffcaaae", 16), int("32b7fff2ed47fffd", 16), int("07e83a49a2e99d69", 16), int("eca8f3318332bb7a", 16), int("ef148d1ea0f4c069", 16), int("040ab3263eff0206", 16) ])

    z_inv_x = pack([ int("acd0000000011110", 16), int("9dd9999dc88ccccd", 16), int("b5ca2ac9b76352bf", 16), int("f1b574bcf4bc90ce", 16), int("42dab41f28a77081", 16), int("132fc6ac14cd1e12", 16) ])
    z_inv_y = pack([ int("e396ffffffff2223", 16), int("4fbf332fcd0d9998", 16), int("0c4bbd3c1aff4cc4", 16), int("6b9c91267926ca58", 16), int("29ae4da6aef7f496", 16), int("10692e942f195791", 16) ])

    minus_b_over_a_x = pack([ int("903c555555474fb3", 16), int("5f98cc95ce451105", 16), int("9f8e582eefe0fade", 16), int("c68946b6aebbd062", 16), int("467a4ad10ee6de53", 16), int("0e7146f483e23a05", 16) ])
    minus_b_over_a_y = pack([ int("29c2aaaaaab85af8", 16), int("bf133368e30eeefa", 16), int("c7a27a7206cffb45", 16), int("9dee04ce44c9425c", 16), int("04a15ce53464ce83", 16), int("0b8fcaf5b59dac95", 16) ])

    print_swu_params([a_x, a_y], [b_x, b_y], [z_x, z_y], [z_inv_x, z_inv_y], [minus_b_over_a_x, minus_b_over_a_y])





generate_swu_params()