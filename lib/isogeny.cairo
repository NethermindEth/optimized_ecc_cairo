from starkware.cairo.common.cairo_builtins import BitwiseBuiltin
from lib.fq2 import FQ2, fq2_lib
from lib.uint384 import Uint384
from lib.uint384_extension import Uint768

struct ParamsThreeIsogenyG2 {
    x_num_1: FQ2,
    x_num_2: FQ2,
    x_num_3: FQ2,
    x_num_4: FQ2,
    x_den_1: FQ2,
    x_den_2: FQ2,
    x_den_3: FQ2,
    x_den_4: FQ2,
    y_num_1: FQ2,
    y_num_2: FQ2,
    y_num_3: FQ2,
    y_num_4: FQ2,
    y_den_1: FQ2,
    y_den_2: FQ2,
    y_den_3: FQ2,
    y_den_4: FQ2,
}

func get_params_three_isogeny_g2() -> (params: ParamsThreeIsogenyG2) {
    return (
        params=ParamsThreeIsogenyG2(
        x_num_1=FQ2(e0=Uint384(d0=122487436713566051823985796909984552918, d1=67485199573184427182665239752178590045, d2=7681218565647756904175376894847872389), e1=Uint384(d0=122487436713566051823985796909984552918, d1=67485199573184427182665239752178590045, d2=7681218565647756904175376894847872389)),
        x_num_2=FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=27179943219759692008582783298185447194, d1=202455598719553281547995719256535770136, d2=23043655696943270712526130684543617167)),
        x_num_3=FQ2(e0=Uint384(d0=27179943219759692008582783298185447198, d1=202455598719553281547995719256535770136, d2=23043655696943270712526130684543617167), e1=Uint384(d0=13589971609879846004291391649092723597, d1=271368982820245872505685163344151990796, d2=11521827848471635356263065342271808583)),
        x_num_4=FQ2(e0=Uint384(d0=149667379933325743832568580208170000081, d1=269940798292737708730660959008714360181, d2=30724874262591027616701507579391489556), e1=Uint384(d0=0, d1=0, d2=0)),
        x_den_1=FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=40769914829639538012874174947278170723, d1=133542214618860690590306275168919549476, d2=34565483545414906068789196026815425751)),
        x_den_2=FQ2(e0=Uint384(d0=12, d1=0, d2=0), e1=Uint384(d0=40769914829639538012874174947278170783, d1=133542214618860690590306275168919549476, d2=34565483545414906068789196026815425751)),
        x_den_3=FQ2(e0=Uint384(d0=1, d1=0, d2=0), e1=Uint384(d0=0, d1=0, d2=0)),
        x_den_4=FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=0, d1=0, d2=0)),
        y_num_1=FQ2(e0=Uint384(d0=335693145642762702200156386192687290118, d1=20590820487717257360856140803476022528, d2=28164468074041775315309715281108865427), e1=Uint384(d0=335693145642762702200156386192687290118, d1=20590820487717257360856140803476022528, d2=28164468074041775315309715281108865427)),
        y_num_2=FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=122487436713566051823985796909984552894, d1=67485199573184427182665239752178590045, d2=7681218565647756904175376894847872389)),
        y_num_3=FQ2(e0=Uint384(d0=27179943219759692008582783298185447196, d1=202455598719553281547995719256535770136, d2=23043655696943270712526130684543617167), e1=Uint384(d0=13589971609879846004291391649092723599, d1=271368982820245872505685163344151990796, d2=11521827848471635356263065342271808583)),
        y_num_4=FQ2(e0=Uint384(d0=104308243825510444556476184021810907920, d1=156989404161594275501210824643270833234, d2=24323858791217896863222026833684929232), e1=Uint384(d0=0, d1=0, d2=0)),
        y_den_1=FQ2(e0=Uint384(d0=40769914829639538012874174947278170363, d1=133542214618860690590306275168919549476, d2=34565483545414906068789196026815425751), e1=Uint384(d0=40769914829639538012874174947278170363, d1=133542214618860690590306275168919549476, d2=34565483545414906068789196026815425751)),
        y_den_2=FQ2(e0=Uint384(d0=0, d1=0, d2=0), e1=Uint384(d0=40769914829639538012874174947278170579, d1=133542214618860690590306275168919549476, d2=34565483545414906068789196026815425751)),
        y_den_3=FQ2(e0=Uint384(d0=18, d1=0, d2=0), e1=Uint384(d0=40769914829639538012874174947278170777, d1=133542214618860690590306275168919549476, d2=34565483545414906068789196026815425751)),
        y_den_4=FQ2(e0=Uint384(d0=1, d1=0, d2=0), e1=Uint384(d0=0, d1=0, d2=0))
        ),
    );
}

func isogeny_map_g2{range_check_ptr, bitwise_ptr: BitwiseBuiltin*}(x: FQ2, y: FQ2, z: FQ2) -> (
    x_res: FQ2, y_res: FQ2, z_res: FQ2
) {
    alloc_locals;

    let (z_2: FQ2) = fq2_lib.pow(z, Uint768(d0=2, d1=0, d2=0, d3=0, d4=0, d5=0));
    let (z_3: FQ2) = fq2_lib.pow(z, Uint768(d0=3, d1=0, d2=0, d3=0, d4=0, d5=0));

    %{
        def pack(z, num_bits_shift: int = 128) -> int:
            limbs = (z.d0, z.d1, z.d2)
            return sum(limb << (num_bits_shift * i) for i, limb in enumerate(limbs))


        def packFQP(z):
            z_split = (z.e0, z.e1)
            return tuple(pack(z_component, 128) for i, z_component in enumerate(z_split))

        print("z " + str(packFQP(ids.z)))
        print("z^2 " + str(packFQP(ids.z_2)))
        print("z^3 " + str(packFQP(ids.z_3)))
    %}
    let (params: ParamsThreeIsogenyG2) = get_params_three_isogeny_g2();

    let x_num: FQ2 = params.x_num_4;
    let x_den: FQ2 = params.x_den_4;
    let y_num: FQ2 = params.y_num_4;
    let y_den: FQ2 = params.y_den_4;

    let (x_num: FQ2) = fq2_lib.mul(x_num, x);
    let (z_1_mul_3) = fq2_lib.mul(z, params.x_num_3);
    let (x_num) = fq2_lib.add(x_num, z_1_mul_3);

    let (x_num: FQ2) = fq2_lib.mul(x_num, x);
    let (z_2_mul_2) = fq2_lib.mul(z_2, params.x_num_2);
    let (x_num) = fq2_lib.add(x_num, z_2_mul_2);

    let (x_num: FQ2) = fq2_lib.mul(x_num, x);
    let (z_3_mul_1) = fq2_lib.mul(z_3, params.x_num_1);
    let (x_num) = fq2_lib.add(x_num, z_3_mul_1);

    let (x_den: FQ2) = fq2_lib.mul(x_den, x);
    let (z_1_mul_3) = fq2_lib.mul(z, params.x_den_3);
    let (x_den) = fq2_lib.add(x_den, z_1_mul_3);

    let (x_den: FQ2) = fq2_lib.mul(x_den, x);
    let (z_2_mul_2) = fq2_lib.mul(z_2, params.x_den_2);
    let (x_den) = fq2_lib.add(x_den, z_2_mul_2);

    let (x_den: FQ2) = fq2_lib.mul(x_den, x);
    let (z_3_mul_1) = fq2_lib.mul(z_3, params.x_den_1);
    let (x_den) = fq2_lib.add(x_den, z_3_mul_1);

    let (y_num: FQ2) = fq2_lib.mul(y_num, x);
    let (z_1_mul_3) = fq2_lib.mul(z, params.y_num_3);
    let (y_num) = fq2_lib.add(y_num, z_1_mul_3);

    let (y_num: FQ2) = fq2_lib.mul(y_num, x);
    let (z_2_mul_2) = fq2_lib.mul(z_2, params.y_num_2);
    let (y_num) = fq2_lib.add(y_num, z_2_mul_2);

    let (y_num: FQ2) = fq2_lib.mul(y_num, x);
    let (z_3_mul_1) = fq2_lib.mul(z_3, params.y_num_1);
    let (y_num) = fq2_lib.add(y_num, z_3_mul_1);

    %{ print("y_den " + str(packFQP(ids.y_den))) %}
    let (y_den: FQ2) = fq2_lib.mul(y_den, x);
    let (z_1_mul_3) = fq2_lib.mul(z, params.y_den_3);
    let (y_den) = fq2_lib.add(y_den, z_1_mul_3);
    %{ print("y_den " + str(packFQP(ids.y_den))) %}

    let (y_den: FQ2) = fq2_lib.mul(y_den, x);
    let (z_2_mul_2) = fq2_lib.mul(z_2, params.y_den_2);
    let (y_den) = fq2_lib.add(y_den, z_2_mul_2);
    %{ print("y_den " + str(packFQP(ids.y_den))) %}

    let (y_den: FQ2) = fq2_lib.mul(y_den, x);
    let (z_3_mul_1) = fq2_lib.mul(z_3, params.y_den_1);
    let (y_den) = fq2_lib.add(y_den, z_3_mul_1);
    %{ print("y_den " + str(packFQP(ids.y_den))) %}

    let (y_num: FQ2) = fq2_lib.mul(y_num, y);
    %{ print("y_den " + str(packFQP(ids.y_den))) %}
    %{ print("z " + str(packFQP(ids.z))) %}
    let (y_den: FQ2) = fq2_lib.mul(y_den, z);

    let (z_res: FQ2) = fq2_lib.mul(x_den, y_den);
    %{ print("y_den " + str(packFQP(ids.y_den))) %}
    let (x_res: FQ2) = fq2_lib.mul(x_num, y_den);
    let (y_res: FQ2) = fq2_lib.mul(y_num, x_den);

    return (x_res, y_res, z_res);
}
