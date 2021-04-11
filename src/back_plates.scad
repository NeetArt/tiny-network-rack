include<common.scad>;

// philips_hue_back_plate();
// translate([0, 180, 0])
//     philips_hue_back_anchor_plate();
// translate([inner_width/2 + 5, 0, 0])
    lutron_back_plate();
// translate([inner_width, 160, 0])
//     lutron_back_anchor_plate();
//cloud_key_back_plate();
//blank_base_plate(40, 120);
//base_plate_vents(30, 60);
//plate_screw_trap_extension();
//plate_device_positioning_notch([30, 20]);
//plate_device_anchor_hook();
// plate_device_anchor_clip(26.5);


/******************************/
/*** Philips Hue back plate ***/
/******************************/

/*
 *
 * The following method creates a back plate for Philips Hue hub and a PoE splitter.
 * Philips Hue Hub dimensions: (W x H x D) 91 x 26 x 91
 * PoE body dimensions: (W x H x D) 27 x 22 x 80
 *
 */
module philips_hue_back_plate() {
    union() {
        color("lightblue") blank_base_plate(inner_width/2 + 5, 180);

        // hue placement guides
        translate([5, 12, 0]) {
            plate_device_positioning_notch([91, 91]);
        }

        // hue anchor clips
        for(anchor_x=[-1, 91]) {
            translate([5 + anchor_x, 12 + 90/2, plate_thickness]) {
                plate_device_anchor_clip(26.5, anchor_x != -1);
            }
        }

        // PoE adapter placement guides
        translate([10, 12 + 91 + 30, 0]) {
            plate_device_positioning_notch([82, 30]);
        }

        // PoE anchors
        for (clip_y=[12 + 91 + 10, 12 + 91 + 30 + 30 + 5]) {
            translate([10 + 35, clip_y, 0]) {
                plate_device_anchor_hook();
            }
        }

        // Back screw traps
        for(trap_x=[rack_unit/4 - back_screw_hole_axis, (rack_unit * 3/4) - back_screw_hole_axis]) {
            translate([trap_x + 10 + plate_thickness, 180, plate_thickness]) {
                rotate([0, 0, 180]) {
                    plate_screw_trap();
                }
            }
        }
    }

    if($preview) {
        translate([5, 12, plate_thickness]) {
            color("blue") cube([91, 91, 26.5]);
        }

        translate([10, 12 + 91 + 30, plate_thickness]) {
            color("salmon") cube([82, 30, 22]);
        }
    }
}

/*
 *
 * A plate which anchors the Philips Hue back plate to the back extrusion
 *
 */
module philips_hue_back_anchor_plate() {
    back_anchor_plate(180);
}


/*****************************/
/*** Lutron Hub back plate ***/
/*****************************/

/*
 *
 * The following method creates a back plate for Lutron hub and a PoE splitter.
 * Lutron Hub dimensions: (W x H x D) 70 x 30.3 x 70
 * PoE body dimensions: (W x H x D) 27 x 22 x 80
 *
 */
module lutron_back_plate() {
    plate_width = inner_width/2 - 5;
    union() {
        color("lightgreen") {
            blank_base_plate(plate_width, 160, false);

            // cusom screw traps
            for (trap_x=[0, plate_width/2 - 5, plate_width - 10]) {
                translate([trap_x, 0, plate_thickness]) {
                    plate_screw_trap_extension(4);
                    translate([0, 0, 4]) {
                        plate_screw_trap();
                    }
                }
            }
        }

        // lutron placement guides
        translate([(plate_width - 70)/2, 12, 0]) {
            plate_device_positioning_notch([70, 70]);
        }

        // lutron anchor clips
        for(anchor_x=[-1, 70]) {
            translate([(plate_width - 70)/2 + anchor_x, 12 + 70/2, plate_thickness]) {
                plate_device_anchor_clip(30.2, anchor_x != -1);
            }
        }

        // PoE adapter placement guides
        translate([5, 12 + 70 + 30, 0]) {
            plate_device_positioning_notch([82, 30]);
        }

        // PoE anchors
        for (clip_y=[12 + 70 + 10, 12 + 70 + 30 + 30 + 5]) {
            translate([5 + 35, clip_y, 0]) {
                plate_device_anchor_hook();
            }
        }

        // Back screw traps
        for(trap_x=[rack_unit/4 - back_screw_hole_axis, (rack_unit * 3/4) - back_screw_hole_axis]) {
            translate([plate_width - trap_x - plate_thickness, 160, plate_thickness]) {
                rotate([0, 0, 180]) {
                    plate_screw_trap_extension(4);
                    translate([0, 0, 4]) {
                        plate_screw_trap();
                    }
                }
            }
        }

    }

    if ($preview) {
        translate([(plate_width - 70)/2, 12, plate_thickness]) {
            color("green") cube([70, 70, 30.2]);
        }

        translate([5, 12 + 70 + 30, plate_thickness]) {
            color("salmon") cube([82, 30, 22]);
        }
    }
}

/*
 *
 * A plate which anchors the Lutron back plate to the back extrusion
 *
 */
module lutron_back_anchor_plate() {
    mirror([1, 0, 0]) {
        back_anchor_plate(160);
    }
}


/****************************/
/*** cloud Key back plate ***/
/****************************/

/*
 *
 * The following method creates a back plate for cloud key.
 * Cloud key dimensions: (W x H x D) 47 x 27.3 x 120
 * Cloud key has 2 positioning notches, one on each side.
 * Position: 12mm from front & 3 mm wide / 10 mm from bottom & 5 mm high / 1 mm deep
 *
 */
module cloud_key_back_plate() {
    ck_width = 47;
    ck_height = 27.3;
    ck_depth = 120;
    union() {
        // bottom
        translate([plate_thickness, 0, 0]) {
            blank_base_plate(ck_width, ck_depth, screw_traps=false);
        }

        // Generate the screw traps manually on the wall since they need to be
        // a little further up to accomodate the base plate hanging slightly below the face plate
        // left wall
        translate([plate_thickness, 0, 0]) {
            rotate([0, -90, 0]) {
                blank_base_plate(ck_height + plate_thickness, ck_depth, screw_traps=false);
            }
        }

        // right wall
        translate([plate_thickness + ck_width, 0, ck_height + plate_thickness]) {
            rotate([0, 90, 0]) {
                blank_base_plate(ck_height + plate_thickness, ck_depth, screw_traps=false);
            }
        }

        // side notches
        for (notch_x=[plate_thickness, plate_thickness + ck_width]) {
            translate([notch_x, 12 - plate_thickness, 10 + plate_thickness]) {
                hull() {
                    translate([0, 0, 1]) {
                        sphere(r=1);
                    }
                    translate([0, 0, 3]) {
                        sphere(r=1);
                    }
                }
            }
        }

        // screw traps left
        for (trap_z=[3, ck_height + plate_thickness - 10]) {
            translate([0, 0, trap_z]) {
                rotate([0, -90, 0]) {
                    plate_screw_trap();
                }
            }
        }

        // screw traps right
        for (trap_z=[3, ck_height + plate_thickness - 10]) {
            translate([ck_width + (plate_thickness * 2), 0, trap_z + 10]) {
                rotate([0, 90, 0]) {
                    plate_screw_trap();
                }
            }
        }

        // back lip
        translate([plate_thickness, ck_depth - plate_thickness - 1, plate_thickness]) {
            cube([ck_width, 1, 1]);
        }
    }
}


/************************/
/*** Blank back plate ***/
/************************/

/*
 *
 * A blank back plate which can be modeled per device
 * Orientation: Origin bottom left on XY plane sitting on +ve Z
 *
 */
module blank_base_plate(width, depth, screw_traps=true) {
    y_vent_clearance = depth > 30 ? 10 : depth/4;
    x_vent_clearance = width > 30 ? 10 : width/4;

    union() {
        difference() {
            cube([width, depth, plate_thickness]);

            translate([x_vent_clearance, y_vent_clearance, 0]) {
                base_plate_vents(width - (x_vent_clearance * 2), depth - (y_vent_clearance * 2));
            }
        }

        if (screw_traps) {
            for (trap_x=[0, width - 10]) {
                translate([trap_x, 0, plate_thickness]) {
                    plate_screw_trap();
                }
            }
        }

        // if width is greater than thrice of total width, add a screw trap in the center as well
        if (screw_traps && width >= inner_width/3) {
                translate([width/2 - 5, 0, plate_thickness]) {
                    plate_screw_trap();
                }
        }
    }
}

/*
 *
 * Slotted vent shape to be cutout from the bank plate
 *
 */
module base_plate_vents(width, depth) {
    rounded_radius = 1;
    vent_thickness = rounded_radius * 2;
    vent_spacing = rounded_radius * 3;

    // (vent_thickness + vent_spacing) * x + vent_thickness = depth
    // x = (depth - vent_thickness) / (vent_thickness + vent_spacing)
    vent_count = floor((depth - vent_spacing) / (vent_thickness + vent_spacing)) + 1;

    occupied_depth = ((vent_count - 1) * (vent_thickness + vent_spacing)) + vent_thickness;
    y_drift = occupied_depth + 1 < depth ? (depth - occupied_depth)/2 : 0; // 1 is added to avoid adding drift for differences less than 1 mm

    for (i=[0:vent_count - 1]) {
        y_axis = (i * (vent_thickness + vent_spacing)) + y_drift;
        union() {
            translate([rounded_radius, y_axis, -slip/2]) {
                cube([width - vent_thickness, vent_thickness, plate_thickness + slip]);
            }
            translate([rounded_radius, y_axis + rounded_radius, -slip/2]) {
                cylinder(h=plate_thickness + slip, d=vent_thickness);
            }
            translate([width - rounded_radius, y_axis + rounded_radius, -slip/2]) {
                cylinder(h=plate_thickness + slip, d=vent_thickness);
            }
        }
    }
}


/**********************/
/*** Helper modules ***/
/**********************/

/*
 *
 * A plate which anchors back plate to the back extrusion
 *
 */
module back_anchor_plate(plate_depth) {
    y_length = inner_depth + extrusion_dim - plate_depth;
    x_length = 40;
    // extrusion mount
    translate([plate_thickness, y_length, 0]) {
        rotate([90, 0, -90]) {
            difference() {
                translate([plate_thickness/2, plate_thickness/2, plate_thickness/2]) {
                    minkowski() {
                        cube([y_length - plate_thickness, rack_unit - plate_thickness, 0.01]);
                        sphere(d=plate_thickness);
                    }
                }

                // screw holes
                for (extrusion_y=[rack_unit - rack_unit/4, rack_unit/4]) {
                    translate([extrusion_dim/2, extrusion_y, 0]) {
                        flat_screw(four_mm_screw_hole, 2);
                    }
                }
            }
        }
    }

    // back plate mount
    translate([0, plate_thickness, 0]) {
        rotate([90, 0, 0]) {
            difference() {
                translate([plate_thickness/2, plate_thickness/2, plate_thickness/2]) {
                    minkowski() {
                        cube([x_length - plate_thickness, rack_unit - plate_thickness, 0.01]);
                        sphere(d=plate_thickness);
                    }
                }

                // screw holes
                for (hole_x=[rack_unit/4, rack_unit * 3/4]) {
                    translate([hole_x + plate_thickness, back_screw_hole_axis + plate_thickness, 0]) {
                        flat_screw(four_mm_screw_hole, 2);
                    }
                }
            }
        }
    }
}

/*
 *
 * A quarter sphere trap for a 4mm screw to be mounted on the blank plate
 *
 */
module plate_screw_trap() {
    translate([back_screw_hole_axis, 0, 0]) {
        difference() {
            slice_cube_dim = (back_screw_hole_axis * 4) + 2;
            intersection() {
                scale([0.5, 1, 1]) {
                    sphere(r=back_screw_hole_axis * 2, $fn=100);
                }

                translate([-slice_cube_dim/2, 0, 0]) {
                    cube([slice_cube_dim, slice_cube_dim, slice_cube_dim]);
                }
            }

            translate([0, 0, back_screw_hole_axis]) {
                rotate([90, 0, 0]) {
                    translate([0, 0, -slice_cube_dim/2]) {
                        cylinder(d=four_mm_screw, h=slice_cube_dim, $fn=100);
                    }
                }
            }
        }
    }
}

/*
 *
 * An extension for the trap for a 4mm screw to be mounted on the blank plate
 *
 */
module plate_screw_trap_extension(length = 5) {
    linear_extrude(length) {
        projection(true) {
            plate_screw_trap();
        }
    }
}

/*
 *
 * Generates L shaped notches to position the device in place
 * device_size  => size of the device in coordinate format, as [width, depth]
 *
 */
module plate_device_positioning_notch(device_size) {
    for (guide_pos=[
            [[- 1, - 1], 0],
            [[device_size[0] + 1, - 1], 90],
            [[device_size[0] + 1, device_size[1] + 1], 180],
            [[- 1, device_size[1] + 1], 270]]) {
        translate([guide_pos[0][0], guide_pos[0][1], 0]) {
            rotate([0, 0, guide_pos[1]]) {
                cube([3, 1, 2 + plate_thickness]);
                cube([1, 3, 2 + plate_thickness]);
            }
        }
    }
}

/*
 *
 * Generates a hook to which a Velcro strap can be anchored
 *
 */
module plate_device_anchor_hook() {
    cube([1, 2, 2 + plate_thickness]);
    translate([0, 0, 2 + plate_thickness]) {
        cube([15, 2, 1]);
    }
    translate([14, 0, 0]) {
        cube([1, 2, 2 + plate_thickness]);
    }
    cube([15, 2, plate_thickness]);
}

/*
 *
 * Generates a clip to which holds the device in place
 *
 */
module plate_device_anchor_clip(device_height, flip=false) {
    translate([flip ? 1 : 0, 0, 0]) {
        mirror([flip ? 1 : 0, 0, 0]) {
            cube([1, 5, device_height + 1]);
            translate([0, 0, device_height]) {
                cube([2, 5, 1]);
            }
        }
    }
}
