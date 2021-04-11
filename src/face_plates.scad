include<common.scad>;

//blank_face_plate(2);
//unfi_switch_jack_cutout();
//unifi_switch_face_plate();
//unifi_cloud_key_plate();
//patch_panel_face_plate();
//unifi_switch_anchor_plate();
//unifi_switch_anchor_plate(true);
philips_hue_lutron_face_plate();

/************************/
/*** Blank face plate ***/
/************************/

/*
 *
 * A blank face plate which can be modeled per device
 * Orientation: Origin centered on XY plane sitting on +ve Z, with the face of the plate facing -Z
 *              and the top edge of the face on +Y along X axis
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

        // Screw holes, looking at XY plane from +Z towards -Z a.k.a the back of the plate
        for (hole_x=[-full_width/2 + extrusion_dim/2, full_width/2 - extrusion_dim/2]) {
            for (hole_y=[plate_height/2 - rack_unit/4, -plate_height/2 + rack_unit/4]) {
                translate([hole_x, hole_y, 0]) {
                    flat_screw(four_mm_screw_hole, 2);
                }
            }
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

/*
 *
 * The following module creates the side anchor plate for unifi switch.
 * The plate attaches side of the frame and the switch.
 * Dimensions of the side holes:
 * Holes are laid out as a square with centers of holes laid out 25 mm apart on each side.
 * The square is 10 mm from the front and 7.5 mm from top and bottom not accounting for shoes (2mm).
 *
 */
module unifi_switch_anchor_plate(mirrored=false) {
    plate_width = extrusion_dim + 10 + 25 + 10;
    plate_depth = rack_unit * 1.5;

    mirror_vector = mirrored ? 1 : 0;
    mirror([mirror_vector, 0, 0]) {
        difference() {
            translate([plate_thickness/2, plate_thickness/2, plate_thickness/2]) {
                minkowski() {
                    cube([plate_width - plate_thickness, plate_depth - plate_thickness, 0.01]);
                    sphere(d=plate_thickness);
                }
            }

            // extrusion holes
            for (extrusion_y=[plate_depth - rack_unit/4, rack_unit/4]) {
                translate([extrusion_dim/2, extrusion_y, 0]) {
                    flat_screw(four_mm_screw_hole, 2);
                }
            }

            // switch holes
            for (switch_x=[extrusion_dim + 10, extrusion_dim + 10 + 25]) {
                for (switch_y=[plate_depth - (7.5 + 2), plate_depth - (7.5 + 2 + 25)]) {
                    translate([switch_x, switch_y, 0]) {
                        flat_screw(four_mm_screw_hole, 2);
                    }
                }
            }
        }
    }
}


/**********************************/
/*** Unifi Cloud Key face plate ***/
/**********************************/

/*
 *
 * The following method creates a face plate for cloud key.
 * Cloud key dimensions: (W x H x D) 47 x 27.3 x 120
 *
 */
module unifi_cloud_key_plate() {
    ck_width = 47;
    ck_height = 27.3;
    ck_depth = 120;
    cutout_x_drift = extrusion_dim + 10;
    cutout_y_drift = (rack_unit - ck_height)/2;
    difference() {
        blank_face_plate(1);

        // Cutout for cloud key
        ck_cutout_x_pos = full_width/2 - cutout_x_drift - ck_width;
        ck_cutout_y_pos = -rack_unit/2 + cutout_y_drift;
        translate([ck_cutout_x_pos, ck_cutout_y_pos, -slip/2]) {
            cube([ck_width, ck_height, plate_thickness + slip]);
        }

        translate([-full_width/4 + ck_cutout_x_pos/2, 0, 1-slip]) {
            rotate([0, 180, 0]) {
                linear_extrude(1) {
                    text("CLOUD KEY", font="Arial Rounded MT Bold", size=9, halign="center", valign="center");
                }
            }
        }

        // Screw holes for back plate, looking at XY plane from +Z towards -Z a.k.a the back of the plate
        // Screw hole bottom left
        for (hole_x=[ck_cutout_x_pos - (back_screw_hole_axis + plate_thickness), full_width/2 - cutout_x_drift + back_screw_hole_axis + plate_thickness]) {
            for (hole_y=[ck_cutout_y_pos + back_screw_hole_axis, -ck_cutout_y_pos - back_screw_hole_axis]) {
                translate([hole_x, hole_y, 0]) {
                    flat_screw(four_mm_screw_hole, 2);
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
 * Face plate for patch panel. Contains 10 jack slots.
 * Keystone jack dimensions. Model: CableCreation Cat6 Coupler
 * Amazon link: https://www.amazon.com/gp/product/B01FHC1BZ8/
 *
 *  Front View:         Side View:
 *                      <  -8-  >/|<  -5- > ^v 1
 *     _____                   /-----------  ^
 *  1 |_____|           < -5->/---------| |  4
 *  4 |     |                           | |  v
 *  ------------        ----------------------------
 *  |          |        |                          |
 * 16.3        |        |  <10>  |>                |
 *  |          |        |< -5- >                   |
 *  ----14.8----        ----------------------------
 *                         ^v 1 \_|
 *                      <   -8-   >
 *
 */
module patch_panel_face_plate() {
    socket_x_spacing = 3;
    socket_y_spacing = 3; // this is from the bottom
    socket_width = 14.8;
    socket_count = 10;
    total_socket_width = (socket_count * socket_width) + ((socket_count + 1) * socket_x_spacing);
    extrusion_gap = (inner_width - total_socket_width)/2;
    leftmost_pos = -full_width/2 + extrusion_dim + extrusion_gap;
    difference() {
        union() {
            blank_face_plate(1);

            // keystone support block
            translate([leftmost_pos, -rack_unit/2 + socket_y_spacing - 2, 0]) {
                cube([total_socket_width, 24.3, 10]);
            }
        }

        for (i=[1:socket_count]) {
            x_pos = leftmost_pos + (socket_x_spacing * i) + (socket_width * (i - 1));

            translate([x_pos, -rack_unit/2 + socket_y_spacing, -slip/2]) {
                patch_panel_keystone_model();
            }
        }

        remaining_upper_gap = rack_unit - 16.3 - socket_y_spacing;
        translate([0, rack_unit/2 - remaining_upper_gap/2, 1-slip]) {
            rotate([0, 180, 0]) {
                linear_extrude(1) {
                    text("PATCH PANEL", font="Arial Rounded MT Bold", size=5, halign="center", valign="center");
                }
            }
        }
    }
}


/*
 *
 * The following method creates model for a keystore jack which is 20mm deep.
 * 20mm depth is arbitrary but enough to punch a hole in the panel above.
 * For the exact model dimensions, refer to the patch_panel_face_plate() description.
 *
 */
module patch_panel_keystone_model() {
    translate([14.8, 0, 0]) {
        rotate([0, -90, 0]) {
            linear_extrude(14.8) {
                polygon([
                    [0, 0], [5, 0], [5, -1], [8, -1], [8, 0], [20, 0],
                    [20, 16.3], [13, 16.3], [13, 20.3], [8, 20.3],
                    [8, 21.3], [5, 21.3], [5, 20.3], [3, 20.3],
                    [3, 18.3], [0, 16.3]]);
            }
        }
    }
}


/**********************************************/
/*** Philips Hue and Lutron hubs face plate ***/
/**********************************************/

/*
 *
 * The following method creates a face plate for Philips Hue and Lutron.
 * Some other interesting information:
 * Lutron has LEDs at 11-11.5 mm from bottom. Philips Hue has LEDs 26.5mm from bottom
 *
 */
module philips_hue_lutron_face_plate() {
    difference() {
        union() {
            blank_face_plate(1);

            // Lutron LED light pipe - wall
            translate([-inner_width/8 - back_screw_hole_axis, -rack_unit/2 - 4 + 11 + plate_thickness + 0.8, 0]) {
                cylinder(d=3.2, h=12 + plate_thickness);
            }

            // Philips Hue LEDs light pipe - wall
            for (led_wall=[-15, 0, 15]) {
                translate([full_width/4 - extrusion_dim/2 + led_wall, rack_unit/2 - plate_thickness - 1, 0]) {
                    cylinder(d=3.2, h=3 + plate_thickness);
                }
            }
        }

        // Lutron LED light pipe - hole
        translate([-inner_width/8 - back_screw_hole_axis, -rack_unit/2 - 4 + 11 + plate_thickness + 0.8, -slip/2]) {
            cylinder(d=1.6, h=12 + plate_thickness + slip);
        }

        // Philips Hue LEDs light pipe - hole
        for (led_wall=[-15, 0, 15]) {
            translate([full_width/4 - extrusion_dim/2 + led_wall, rack_unit/2 - plate_thickness - 1, -slip/2]) {
                cylinder(d=1.6, h=3 + plate_thickness + slip);
            }
        }

        translate([full_width/4 - extrusion_dim/2, back_screw_hole_axis, 1-slip]) {
            rotate([0, 180, 0]) {
                linear_extrude(1) {
                    text("PHILIPS HUE", font="Arial Rounded MT Bold", size=9, halign="center", valign="center");
                }
            }
        }

        translate([-full_width/4 + extrusion_dim/2 - back_screw_hole_axis, back_screw_hole_axis, 1-slip]) {
            rotate([0, 180, 0]) {
                linear_extrude(1) {
                    text("LUTRON", font="Arial Rounded MT Bold", size=9, halign="center", valign="center");
                }
            }
        }

        // Screw holes for Philips Hue back plate, looking at XY plane from +Z towards -Z a.k.a the back of the plate
        for (hole_x=[inner_width/2 - back_screw_hole_axis, inner_width/4 - back_screw_hole_axis/2, 0]) {
            translate([hole_x, -rack_unit/2 + plate_thickness + back_screw_hole_axis, 0]) {
                flat_screw(four_mm_screw_hole, 2);
            }
        }

        // Screw holes for Lutron back plate, looking at XY plane from +Z towards -Z a.k.a the back of the plate
        for (hole_x=[-inner_width/2 + back_screw_hole_axis, -inner_width/4 - back_screw_hole_axis/2, -back_screw_hole_axis*2]) {
            translate([hole_x, -rack_unit/2 + plate_thickness + back_screw_hole_axis, 0]) {
                flat_screw(four_mm_screw_hole, 2);
            }
        }
    }
}

// One rack unit with Lutron Hub (micro usb) and Philips Hub (Barrel Jack 2.5/5.5 center +ve) on either sides
// Lutron has LEDs at 11-11.5 mm from bottom. Philips Hue has LEDs 26.5mm from bottom
// One rack unit for pihole and VPN