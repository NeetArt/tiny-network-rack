include<common.scad>;
use<rack_frame.scad>;
use<face_plates.scad>;
use<back_plates.scad>;

//rack_structure(Units);
//cloud_key_test();
philips_hue_lutron_test();

/*
 *
 * Full rack structure assembled together with a switch frame
 *
 */
module rack_structure(units) {
    extrude_len = rack_unit * units;
    // extrusions
    color("Black") {
        translate([extrusion_dim/2, extrusion_dim/2, plate_thickness]) extrusion_rail(units);
        translate([inner_width + extrusion_dim * 3/2, extrusion_dim/2, plate_thickness]) extrusion_rail(units);
        translate([inner_width + extrusion_dim * 3/2, inner_depth + extrusion_dim * 3/2, plate_thickness]) extrusion_rail(units);
        translate([extrusion_dim/2, inner_depth + extrusion_dim * 3/2, plate_thickness]) extrusion_rail(units);
    }

    // switch
    color("Silver") {
        translate([0, extrusion_dim, plate_thickness]) {
            cube([235, 200, 43]);
        }
    }

    // switch plate
    plate_unit = 2;
    color("DarkGray")
    translate([full_width/2, -plate_thickness, plate_unit * rack_unit/2 + plate_thickness]) {
        rotate([-90, 180, 0]) {
            unifi_switch_face_plate();
        }
    }

    // Patch panel
    color("DarkGray")
    translate([full_width/2, -plate_thickness, rack_unit * 2 + rack_unit/2 + plate_thickness]) {
        rotate([-90, 180, 0]) {
            patch_panel_face_plate();
        }
    }

    // Cloud key
    color("DarkGray")
    translate([full_width/2, -plate_thickness, rack_unit * 3 + rack_unit/2 + plate_thickness]) {
        rotate([-90, 180, 0]) {
            unifi_cloud_key_plate();
        }
    }

    // // other plates
    // for (i = [4 : 9]) {
    //     translate([full_width/2, 0, (i * rack_unit) + rack_unit/2 + plate_thickness]) {
    //         rotate([90, 0, 0]) {
    //             blank_face_plate(1);
    //         }
    //     }
    // }

    // Rack plates
    color("Black") {
        // bottom plate
        translate([full_width/2, full_depth/2, 0]) {
            rack_end_plate();
        }

        // top plate
        translate([full_width/2, full_depth/2, (plate_thickness * 2) + extrude_len]) {
            rotate([180, 0, 0]) {
                rack_end_plate();
            }
        }
    }

    // Handles
    color("BurlyWood") {
        translate([full_width - extrusion_dim/2, full_depth/2, (plate_thickness * 2) + extrude_len]) {
            full_handle();
        }

        translate([extrusion_dim/2, full_depth/2, (plate_thickness * 2) + extrude_len]) {
            full_handle();
        }
    }
}

module cloud_key_test() {
    rotate([-90, 180, 0]) {
        unifi_cloud_key_plate();
    }

    cutout_y_drift = (rack_unit - 27.3)/2;
    translate([-full_width/2 + extrusion_dim + 10 - plate_thickness, plate_thickness, -rack_unit/2 + cutout_y_drift - 3]) {
        cloud_key_back_plate();
    }
}

module philips_hue_lutron_test() {
    philips_hue_back_plate();
    translate([0, 180, 0]) philips_hue_back_anchor_plate();
    translate([inner_width/2 + 5, 0, -4])
        lutron_back_plate();
    translate([inner_width, 160, 0])
        lutron_back_anchor_plate();

    translate([inner_width/2, -plate_thickness, rack_unit/2]) {
        rotate([-90, 180, 0]) {
            philips_hue_lutron_face_plate();
        }
    }
}
