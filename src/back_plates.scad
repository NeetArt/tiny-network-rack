include<common.scad>;

cloud_key_back_plate();
//blank_base_plate(40, 120);
//base_plate_vents(30, 60);

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
