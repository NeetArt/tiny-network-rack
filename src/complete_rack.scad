include<common.scad>;
use<rack_frame.scad>;
use<face_plates.scad>;

rack_structure(Units);

/*
 *
 * Full rack structure assembled together with a switch frame
 *
 */
module rack_structure(units) {
    extrude_len = rack_unit * units;
    // extrusions
    color("DimGray") {
        translate([extrusion_dim/2, extrusion_dim/2, plate_thickness]) extrusion_rail(units);
        translate([inner_width + extrusion_dim*3/2, extrusion_dim/2, plate_thickness]) extrusion_rail(units);
        translate([inner_width + extrusion_dim*3/2, inner_depth + extrusion_dim*3/2, plate_thickness]) extrusion_rail(units);
        translate([extrusion_dim/2, inner_depth + extrusion_dim*3/2, plate_thickness]) extrusion_rail(units);
    }

    // switch
    color("Silver") {
        translate([0, extrusion_dim, plate_thickness]) {
            cube([235, 200, 43]);
        }
    }

    // switch plate
    color("SteelBlue") {
        plate_unit = 2;
        translate([full_width/2, 0, plate_unit*rack_unit/2 + plate_thickness]) {
            rotate([90, 0, 0]) {
                blank_face_plate(plate_unit);
            }
        }
    }

    // other plates
    for (i = [2 : 9]) {
        translate([full_width/2, 0, i*rack_unit + rack_unit/2 + plate_thickness]) {
            rotate([90, 0, 0]) {
                blank_face_plate(1);
            }
        }
    }

    // Rack plates
    color("Black") {
        // bottom plate
        translate([full_width/2, full_depth/2, 0]) {
            rack_end_plate();
        }

        // top plate
        translate([full_width/2, full_depth/2, plate_thickness*2+extrude_len]) {
            rotate([180, 0, 0]) {
                rack_end_plate();
            }
        }
    }

    // Handles
    color("BurlyWood") {
        translate([full_width-extrusion_dim/2, full_depth/2, plate_thickness*2+extrude_len]) {
            full_handle();
        }

        translate([extrusion_dim/2, full_depth/2, plate_thickness*2+extrude_len]) {
            full_handle();
        }
    }
}
