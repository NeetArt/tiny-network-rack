include<common.scad>;

//blank_face_plate(2);
//unfi_switch_jack_cutout();
unifi_switch_face_plate();

/************************/
/*** Blank face plate ***/
/************************/

/*
 *
 * A blank face plate which can be modeled per device
 * Orientation: Origin centered on XY plane sitting on +ve Z
 *
 */
module blank_face_plate(units) {
    plate_height = rack_unit * units;
    difference() {
        translate([0, 0, plate_thickness/2]) {
            minkowski() {
                cube([full_width - plate_thickness/2, plate_height - plate_thickness, 0.01], center=true);
                sphere(d=plate_thickness);
            }
        }

        // Screw holes
        // Left screw top
        translate([-full_width/2 + extrusion_dim/2, plate_height/2 - rack_unit/4, 0]) {
            flat_screw(Four_mm_screw_hole, 2);
        }
        // Left screw bottom
        translate([-full_width/2 + extrusion_dim/2, -plate_height/2 + rack_unit/4, 0]) {
            flat_screw(Four_mm_screw_hole, 2);
        }
        // Right screw top
        translate([full_width/2 - extrusion_dim/2, plate_height/2 - rack_unit/4, 0]) {
            flat_screw(Four_mm_screw_hole, 2);
        }
        // Right screw bottom
        translate([full_width/2 - extrusion_dim/2, -plate_height/2 + rack_unit/4, 0]) {
            flat_screw(Four_mm_screw_hole, 2);
        }
    }
}


/**************************************/
/*** Unifi Switch 8 150W face plate ***/
/**************************************/

/*
 * The dimensions of the switch are as follows:
 *  ^   |-------------------------------------------------------------------------------|
 *  |   |                   ^                                             ^v 3.5        |
 *  |   |                   v 18                                          |------|      |
 *  |   |              |--------------------128------------------|        |      |      |
 *  43  |<----53.4---->|                                         |<--15-->|=1.5t=|      |  1.5 denotes thickness
 *  |   |             14.5                                       |        29     |<23.1>|
 *  |   |              |-----------------------------------------|        |-15.5-|      |
 *  |   |                  ^v 10.5                                        ^v 10.5       |
 *  v   |-------------------------------------------------------------------------------|
 *
 * NOTE: We will be designing the plate with the face on the XY plane facing -ve Z. Which means
 *       the above schematic will be mirrored on the vertical axis.
 */
module unifi_switch_face_plate() {
    union() {
        difference() {
            blank_face_plate(2);

            // Hole for RJ45 ports
            translate([full_width/2 - 53.4 - 128, -rack_unit + 10.5, -slip/2]) {
                cube([128, 14.5, plate_thickness + slip]);
            }

            // Hole for SFP ports
            translate([-full_width/2 + 23.1, -rack_unit + 10.5, -slip/2]) {
                cube([15.5, 29, plate_thickness + slip]);
            }
        }

        // RJ45 cutouts laid out
        for (i=[0:7]) {
            x_pos = full_width/2 - 53.4 -128 + (16 * i);
            translate([x_pos, -rack_unit + 10.5, 0]) {
                union() {
                    linear_extrude(extrusion_dim + plate_thickness) {
                        unfi_switch_jack_cutout();
                    }

                    // Cutout support - 1
                    translate([0, 14.5, 0]) {
                        rotate([0, 90, 0]) {
                            linear_extrude(4.5) {
                                polygon([[0, 0], [0, 6], [-8, 0]]);
                            }
                        }
                    }

                    // Cutout support - 2
                    translate([16 - 4.5, 14.5, 0]) {
                        rotate([0, 90, 0]) {
                            linear_extrude(4.5) {
                                polygon([[0, 0], [0, 6], [-8, 0]]);
                            }
                        }
                    }
                }
            }
        }

        // // SFP port split
        // translate([-full_width/2 + 23.1, -rack_unit + 10.5 + ((29 - 1.5)/2), 0]) {
        //     union() {
        //         difference() {
        //             cube([15.5, 1.5, extrusion_dim + plate_thickness]);

        //             // SFP light left
        //             translate([3, 1, -slip/2]) {
        //                 linear_extrude(extrusion_dim + plate_thickness + slip) {
        //                     polygon([[0, 0], [1, -0.5], [2, 0]]);
        //                 }
        //             }

        //             // SFP light right
        //             translate([10, 0.5, -slip/2]) {
        //                 linear_extrude(extrusion_dim + plate_thickness + slip) {
        //                     polygon([[0, 0], [2, 0], [1, 0.5]]);
        //                 }
        //             }
        //         }

        //         // Support column - 1
        //         translate([-4, 0, 0]) {
        //             rotate([0, 90, 0]) {
        //                 linear_extrude(4) {
        //                     polygon([[0, -6 + 1.5], [0, 6 + 1.5], [-8, 1.5], [-8, 0]]);
        //                 }
        //             }
        //         }

        //         // Support column - 2
        //         translate([15.5, 0, 0]) {
        //             rotate([0, 90, 0]) {
        //                 linear_extrude(4) {
        //                     polygon([[0, -6 + 1.5], [0, 6 + 1.5], [-8, 1.5], [-8, 0]]);
        //                 }
        //             }
        //         }
        //     }
        // }
    }
}

/*
 * This method creates a cutput of an ethernet jack on the switch
 * The side and bottom walls won't be printed to allow space for RJ45 jackets to fit in
 * Orientation: Origin in bottom left corner on XY plane, sitting on +ve Z
 * The dimensions are as follows:
 *
 *  ^   ||================||  <- 1.5 (thickness of top bar)
 *  |   ||___|<2.5x1  |___||  height x thickness
 * 14.5 ||^3x1            ||  width x thixkness
 *  |   ||                ||
 *  v   ||<------15------>||  inner width (full width = 16)
 *                         ^  0.5 (thickness)
 * Well, could I have just created 2 rectangles for the LED cutouts? Mmm, yes, but where's the fun in that?
 */
module unfi_switch_jack_cutout() {
    // Polygon points start bottom left and go clockwise
    full_port_coord = [
        [0, 0], [16, 0],
        [16, 14.5], [0, 14.5]
    ];
    full_port_index = [0, 1, 2, 3];

    led_cutout_y_lower = 14.5 - 1.5 - 2.5;
    led_cutout_y_upper = 14.5 - 1.5;

    left_led_cutout_coord = [
        [0.5, led_cutout_y_lower], [0.5 + 3, led_cutout_y_lower],
        [0.5 + 3, led_cutout_y_upper], [0.5, led_cutout_y_upper]
    ];
    left_led_cutout_index = [4, 5, 6, 7];

    right_led_cutout_coord = [
        [0.5 + 15 - 3, led_cutout_y_lower], [0.5 + 15, led_cutout_y_lower],
        [0.5 + 15, led_cutout_y_upper], [0.5 + 15 - 3, led_cutout_y_upper]
    ];
    right_led_cutout_index = [8, 9, 10, 11];

    jack_cutout_coord = [
        [0, 0], [16, 0],
        [16, led_cutout_y_lower-1], [16 - 0.5 - 3 - 1, led_cutout_y_lower - 1],
        [16 - 0.5 - 3 - 1, led_cutout_y_upper+1.5], [0.5 + 3 + 1, led_cutout_y_upper + 1.5],
        [0.5 + 3 + 1, led_cutout_y_lower-1], [0, led_cutout_y_lower - 1],
    ];
    jack_cutout_index = [12, 13, 14, 15, 16, 17, 18, 19];

    //polygon(jack_cutout_coord);
    all_coord = concat(full_port_coord, left_led_cutout_coord, right_led_cutout_coord, jack_cutout_coord);
    all_index = [full_port_index, left_led_cutout_index, right_led_cutout_index, jack_cutout_index];
    polygon(all_coord, all_index);
}
