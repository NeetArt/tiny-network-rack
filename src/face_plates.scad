include<common.scad>;

//blank_face_plate(2);
//unfi_switch_jack_cutout();
//unifi_switch_face_plate();
unifi_cloud_key_plate();
//patch_panel_face_plate();

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
            flat_screw(four_mm_screw_hole, 2);
        }
        // Left screw bottom
        translate([-full_width/2 + extrusion_dim/2, -plate_height/2 + rack_unit/4, 0]) {
            flat_screw(four_mm_screw_hole, 2);
        }
        // Right screw top
        translate([full_width/2 - extrusion_dim/2, plate_height/2 - rack_unit/4, 0]) {
            flat_screw(four_mm_screw_hole, 2);
        }
        // Right screw bottom
        translate([full_width/2 - extrusion_dim/2, -plate_height/2 + rack_unit/4, 0]) {
            flat_screw(four_mm_screw_hole, 2);
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
 *  |   |             14.5                                       |        31     |<23.1>|
 *  |   |              |-----------------------------------------|        |-15.5-|      |
 *  |   |                  ^v 10.5                                         ^v 8.5       |
 *  v   |-------------------------------------------------------------------------------|
 *
 * NOTE: We will be designing the plate with the face on the XY plane facing -ve Z. Which means
 *       the above schematic will be mirrored on the Y axis.
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
            translate([-full_width/2 + 23.1, -rack_unit + 8.5, -slip/2]) {
                cube([15.5, 31, plate_thickness + slip]);
            }

            translate([0, 8, 1-slip]) {
                rotate([0, 180, 0]) {
                    linear_extrude(1) {
                        text("UNIFI SWITCH", font="Arial Rounded MT Bold", size=9, halign="center");
                    }
                }
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
    }
}

/*
 * The following method creates a cutout of an ethernet jack on the switch
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


/**********************************/
/*** Unifi Cloud Key face plate ***/
/**********************************/

/*
 *
 * The following method creates a face plate for cloud key. This is still a WIP
 * Cloud key dimensions: (W x H x D) 47 x 27.3 x 120
 *
 */
module unifi_cloud_key_plate() {
    ck_width = 47;
    ck_height = 27.3;
    ck_depth = 120;
    hole_x_drift = extrusion_dim + 10;
    hole_y_drift = (rack_unit - ck_height)/2;
    difference() {
        blank_face_plate(1);

        // Hole for cloud key
        translate([full_width/2 - hole_x_drift - ck_width, -rack_unit/2 + hole_y_drift, -slip/2]) {
            cube([ck_width, ck_height, plate_thickness + slip]);
        }

        translate([0, 0, 1-slip]) {
            rotate([0, 180, 0]) {
                linear_extrude(1) {
                    text("CLOUD KEY", font="Arial Rounded MT Bold", size=9, halign="center", valign="center");
                }
            }
        }
    }
}


/******************************/
/*** Patch panel face plate ***/
/******************************/

/*
 *
 * Face plate for patch panel. This is still a WIP. Abandoned. Created in Fusion 360
 * Keystone jack dimensions. Model: CableCreation Cat6 Coupler
 * Amazon link: https://www.amazon.com/gp/product/B01FHC1BZ8/
 *
 *  Front View:         Side View:
 *                      <  -8-  >/|  ^v 1
 *     _____                   /-----------  ^
 *  1 |_____|           < -5->/---------| |  4
 *  4 |     |                           | |  v
 *  ------------        ----------------------------
 *  |          |        |                          |
 * 16.1        |        |  <10>  |>                |
 *  |          |        |                          |
 *  ----14.6----        ----------------------------
 *                         ^v 1 \_|
 *                      <   -8-   >
 *
 */
module patch_panel_face_plate() {
    socket_x_spacing = 3;
    socket_y_spacing = 4;
    socket_count = 10;
    total_socket_width = (socket_count * 14.6) + ((socket_count - 1) * socket_x_spacing);
    extrusion_gap = (inner_width - total_socket_width)/2;
    rightmost_pos = full_width/2 - extrusion_dim - extrusion_gap;
    difference() {
        union() {
            blank_face_plate(1);

            // Socket top and bottom grooves
            translate([rightmost_pos + socket_x_spacing, -rack_unit/2 + socket_y_spacing - 2, 0]) {
                rotate([0, -90, 0]) {
                    linear_extrude(total_socket_width + socket_x_spacing * 2) {
                        union() {
                            socket_height = 16.1 + 2;
                            // top
                            polygon([
                                [0, socket_height], [5, socket_height],
                                [5, socket_height + 5], [8, socket_height + 5],
                                [8, socket_height + 4], [10, socket_height + 4],
                                [10, socket_height + 6], [0, socket_height + 6]]);
                            // bottom
                            polygon([
                                [0, 0], [10, 0], [10, 2],
                                [8, 2], [8, 1], [5, 1],
                                [5, 2], [0, 2]]);
                        }
                    }
                }
            }

            // vertical support bars
            for (i=[0:socket_count]) {
                x_pos = rightmost_pos - (14.6 * i) - (socket_x_spacing * i);

                translate([x_pos, -rack_unit/2 + 2, 0]) {
                    cube([socket_x_spacing, 16.1 + 2 + 6, 10]);
                }
            }
        }

        for (i=[0:(socket_count - 1)]) {
            x_pos = rightmost_pos - (14.6 * (i + 1)) - (socket_x_spacing * i);

            translate([x_pos, -rack_unit/2 + socket_y_spacing, -slip/2]) {
                cube([14.6, 16.1, plate_thickness + slip]);
            }
        }

        remaining_upper_gap = rack_unit - 16.3 - 3;
        translate([0, rack_unit/2 - remaining_upper_gap/2, 1-slip]) {
            rotate([0, 180, 0]) {
                linear_extrude(1) {
                    text("PATCH PANEL", font="Arial Rounded MT Bold", size=5, halign="center", valign="center");
                }
            }
        }
    }
}

// Switch side plate
// 10mm from front & 35 mm from front & 25mm horizontally spaced
// 7.5mm from top or bottom & 25mm vertically spaced