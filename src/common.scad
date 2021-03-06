$fn = 100 * 1;
// width is along the x axis
// depth is along the y axis
extrusion_dim    = 20 * 1;
inner_width      = 195 * 1;
inner_depth      = 202 * 1;
full_width       = inner_width + (extrusion_dim * 2);
full_depth       = inner_depth + (extrusion_dim * 2);
rack_unit        = 25 * 1;
plate_thickness  = 3 * 1;
finger_clearance = extrusion_dim;
handle_angle     = 60;
slip             = 0.1 * 1; // additional dimension for clean cuts in model
clearance        = 0.1 * 1; // clearance between joined parts

//Hole size for 4mm screws or freedom unit equivalent
Four_mm_screw = 3.8 * 1;
//Hole size for 5mm screws or freedom unit equivalent
Five_mm_screw = 4.8 * 1;
// Hole size for 4 mm screw no threading
Four_mm_screw_hole  = 4 * 1;
// Hole size for 5 mm screw no threading
Five_mm_screw_hole  = 5 * 1;


Units = 10;

/*
 *
 * A DIN 7991 screw dimension with 90deg countersink angle
 * Based off of McMasterCarr M5 and M6 screws
 *
 */
module flat_screw(size, length) {
    head_dia = size * 2;
    union() {
        // Cut-out for head
        translate([0, 0, -length + 0.01]) {
            cylinder(d=head_dia, h=length + 0.01);
        }
        // Head
        cylinder(d1=head_dia, d2=size, h=size/2);
        // Thread pipe
        translate([0, 0, size/2 - slip]) {
            cylinder(d=size, h=length + slip);
        }
    }
}


/*
 *
 * Following modules are helpers for fitting into the 3d printer bed
 *
 */

/*
 *
 * Split a model in half across width or across depth with notches at either end to connect them together
 *
 */
module model_split_shape(width, depth, is_female, across_width) {
    if (is_female) {
        difference() {
            cube([width, depth, 10-slip], center=true);
            model_split_shape_inner(width + slip, depth + slip, true, across_width);
        }
    } else {
        model_split_shape_inner(width, depth, false, across_width);
    }
}

/*
 *
 * across_width -> object to be split in two, across x axis and along y axis
 * is_female adds slips if true
 *
 */
module model_split_shape_inner(width, depth, is_female, across_width) {
    x_length = across_width ? width/2 : depth/2;
    y_length = across_width ? depth : width;
    notch_slip = is_female ? slip : 0;
    notch_clearance = is_female ? clearance : 0;

    notch_polygon = [
        [0.1, 2 + notch_clearance], [0.1, -2 - notch_clearance],
        [-6 - notch_clearance, -4 - notch_clearance], [-6 - notch_clearance, 4 + notch_clearance]
    ];

    rotate([0, 0, across_width ? 0 : 90]) {
        union() {
            // main body
            translate([x_length/2, 0, 0]) {
                cube([x_length + notch_slip, y_length + notch_slip, 10], center=true);
            }
            // upper notch
            translate([0, y_length/2 - extrusion_dim/2 - plate_thickness/2, 0]) {
                linear_extrude(10, center=true) {
                    polygon(notch_polygon);
                }
            }
            // lower notch
            translate([0, -y_length/2 + extrusion_dim/2 + plate_thickness/2, 0]) {
                linear_extrude(10, center=true) {
                    polygon(notch_polygon);
                }
            }
        }
    }
}
