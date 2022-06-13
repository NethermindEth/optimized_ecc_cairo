from utils import (pack, print_fq2, split, neg_to_uint384)

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


def generate_optimized_sswu():
    P_MINUS_9_DIV_16 = 1001205140483106588246484290269935788605945006208159541241399033561623546780709821462541004956387089373434649096260670658193992783731681621012512651314777238193313314641988297376025498093520728838658813979860931248214124593092835  # noqa: E501

    EV1 = 1015919005498129635886032702454337503112659152043614931979881174103627376789972962005013361970813319613593700736144  # noqa: E501
    EV2 = 1244231661155348484223428017511856347821538750986231559855759541903146219579071812422210818684355842447591283616181  # noqa: E501
    EV3 = 1646015993121829755895883253076789309308090876275172350194834453434199515639474951814226234213676147507404483718679  # noqa: E501
    EV4 = 1637752706019426886789797193293828301565549384974986623510918743054325021588194075665960171838131772227885159387073  # noqa: E501

    RV1 = 1028732146235106349975324479215795277384839936929757896155643118032610843298655225875571310552543014690878354869257  # noqa: E501

    print(split(P_MINUS_9_DIV_16, 128, 6))
    print(split(RV1))

    print(neg_to_uint384(2))

    print("etas")
    print(split(EV1))
    print(split(EV2))
    print(split(EV3))
    print(split(EV4))
    print(neg_to_uint384(EV2))
    print(neg_to_uint384(EV4))



def get_psi():
    psi_x_i = pack([int('890dc9e4867545c3', 16), int('2af322533285a5d5', 16), int('50880866309b7e2c', 16), int('a20d1b8c7e881024', 16), int('14e4f04fe2db9068', 16), int('14e56d3f1564853a', 16)], 64)

    psi_y = pack([int('3e2f585da55c9ad1', 16), int('4294213d86c18183', 16), int('382844c88b623732', 16), int('92ad2afd19103e18', 16), int('1d794e4fac7cf0b9', 16), int('0bd592fc7d825ec8', 16)], 64)
    psi_y_i = pack([int('7bcfa7a25aa30fda', 16), int('dc17dec12a927e7c', 16), int('2f088dd86b4ebef1', 16), int('d1ca2087da74d4a7', 16), int('2da2596696cebc1d', 16), int('0e2b7eedbbfd87d2', 16)], 64)
    print(split(psi_x_i))

    print(split(psi_y))
    print(split(psi_y_i))

get_psi()