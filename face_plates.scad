// Multiply by 1 to avoid displaying constants as parameters
$fn = 50 * 1;

include<common.scad>;

//blank_face_plate(1);


/*
 *
 * A blank face plate which can be modeled per device
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
            cylinder(h=20, d=Four_mm_screw, center=true);
        }
        // Left screw bottom
        translate([-full_width/2 + extrusion_dim/2, -plate_height/2 + rack_unit/4, 0]) {
            cylinder(h=20, d=Four_mm_screw, center=true);
        }
        // Right screw top
        translate([full_width/2 - extrusion_dim/2, plate_height/2 - rack_unit/4, 0]) {
            cylinder(h=20, d=Four_mm_screw, center=true);
        }
        // Right screw bottom
        translate([full_width/2 - extrusion_dim/2, -plate_height/2 + rack_unit/4, 0]) {
            cylinder(h=20, d=Four_mm_screw, center=true);
        }
    }
}
