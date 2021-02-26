include<common.scad>;

//flat_screw(Five_mm_screw_hole, 10);
//full_handle();
//extrusion_slide(Units, true, true);
//extrusion_rail(Units);
//rack_end_plate();
//color("Tomato") model_split_shape(full_width, full_depth, true, false);
//color("DarkOrange") model_split_shape(full_width, full_depth, false, false);
color("Tomato") { rack_end_plate_sections(1);}
//color("DarkOrange") {rack_end_plate_sections(2);}


/**********************/
/*** 2020 extrusion ***/
/**********************/

/*
 *
 * Mockup of a 2020 aluminum extrusion
 *
 */
module extrusion_rail(units) {
    extrude_len = rack_unit * units;
    difference() {
        translate([-extrusion_dim/2, -extrusion_dim/2, 0]) {
            cube([extrusion_dim, extrusion_dim, extrude_len]);
        }

        slide_distance = 7.8/2; // Slide distance from center
        // Slide cuts
        translate([0, slide_distance, -slip]) rotate([0, 0, 0]) extrusion_slide(extrude_len+1, false, true);
        translate([-slide_distance, 0, -slip]) rotate([0, 0, 90]) extrusion_slide(extrude_len+1, false, true);
        translate([0, -slide_distance, -slip]) rotate([0, 0, 180]) extrusion_slide(extrude_len+1, false, true);
        translate([slide_distance, 0, -slip]) rotate([0, 0, -90]) extrusion_slide(extrude_len+1, false, true);

        // Center hole
        translate([0, 0, -slip]) cylinder(d=Five_mm_screw_hole, extrude_len+slip*2);
    }
}

/*
 *
 * Extrusion cutout slide. Dimensions differ between various brands of 2020 extrusion.
 * Slide dimensions:
 *
 *       --------      <- 6
 *       |      |      <- thickness: 1.5 or 2.0
 *   -----      -----  <- 11
 *   |              |  <- 1.6
 *    \            /   <- [|] 2.7 (not the length of the edge but the vertical distance)
 *     ------------    <- 6
 *
 */
module extrusion_slide(units, hole=false, for_rail=false) {
    extrude_len = rack_unit * units;
    thickness = for_rail ? 2.0 : 1.5;
    slide_depth = thickness + 1.6 + 2.7 + slip;

    difference() {
        union() {
            translate([-3, 4.3-slip, 0]) {
                cube([6, thickness+slip, extrude_len]);
            }
            linear_extrude(extrude_len) {
                polygon([[-11/2, 4.3], [11/2, 4.3], [11/2, 4.3-1.6], [11/2-5/2, 0], [-11/2+5/2, 0], [-11/2, 4.3-1.6]]);
            }
        }
        if (hole) {
            for (i = [0 : units - 1]) {
                translate([0, 0, rack_unit * i]) {
                    translate([0, 0, (rack_unit/4)*1]) {
                        rotate([90, 0, 0]) {
                            cylinder(h=slide_depth*2, d=Four_mm_screw, center=true);
                        }
                    }
                    translate([0, 0, (rack_unit/4)*3]) {
                        rotate([90, 0, 0]) {
                            cylinder(h=slide_depth*2, d=Four_mm_screw, center=true);
                        }
                    }
                }
            }
        }
    }
}



/**********************************/
/*** Rack top and bottom plates ***/
/**********************************/

/*
 *
 * Rack top or bottom plate with a grid pattern
 *
 */
module rack_end_plate() {
    grid_fill_ratio = 4; // fill:empty :: 1:3
    end_plate_thickness = plate_thickness;

    union() {
        difference() {
            translate([0, 0, end_plate_thickness/2]) {
                minkowski() {
                    cube([full_width, full_depth, 0.01], center=true);
                    sphere(d=end_plate_thickness);
                }
            }

            // Plate inner hole
            translate([0, 0, end_plate_thickness/2]) {
                cube([inner_width, inner_depth, end_plate_thickness+slip*2], center=true);
            }

            // Countersink holes
            hole_x_displacement = inner_width/2 + extrusion_dim/2;
            hole_y_displacement = inner_depth/2 + extrusion_dim/2;
            translate([hole_x_displacement, hole_y_displacement, -slip]) flat_screw(Five_mm_screw_hole, 2);
            translate([hole_x_displacement, -hole_y_displacement, -slip]) flat_screw(Five_mm_screw_hole, 2);
            translate([-hole_x_displacement, -hole_y_displacement, -slip]) flat_screw(Five_mm_screw_hole, 2);
            translate([-hole_x_displacement, hole_y_displacement, -slip]) flat_screw(Five_mm_screw_hole, 2);
        }

        // Grid pattern
        intersection() {
            union() {
                rotate([0, 0, 45]) {
                    min_size = inner_width + inner_depth;
                    segment_width = 4;

                    cell_width = segment_width * grid_fill_ratio;
                    segment_count = (ceil(min_size / cell_width) * grid_fill_ratio) + 1;
                    echo(segment_count);

                    segment_length =  segment_count * segment_width;
                    echo(segment_length);
                    for (i = [-segment_length/2 : cell_width : segment_length/2]) {
                        translate([-segment_length/2, i, 0]) {
                            cube([segment_length, segment_width, end_plate_thickness]);
                        }
                        translate([i, -segment_length/2, 0]) {
                            cube([segment_width, segment_length, end_plate_thickness]);
                        }
                    }
                }
            }
            translate([0, 0, end_plate_thickness/2]) {
                cube([inner_width, inner_depth, end_plate_thickness], center=true);
            }
        }
    }
}

/*
 *
 * Rack top or bottom plate split in two for easy fit 3D printer build plate
 *
 */
module rack_end_plate_sections(section) {
    if (section == 1) {
        intersection() {
            model_split_shape(full_width+plate_thickness, full_depth+plate_thickness, is_female=false, across_width=false);
            rack_end_plate();
        }
    } else if (section == 2) {
        intersection() {
            model_split_shape(full_width+plate_thickness, full_depth+plate_thickness, is_female=true, across_width=false);
            rack_end_plate();
        }
    }
}



/*******************/
/*** Rack handle ***/
/*******************/

/*
 *
 * Top handle of the rack
 *
 */
module full_handle() {
    union() {
        half_handle();
        mirror([0, 1, 0]) {
            half_handle();
        }
    }
}

/*
 *
 * Construction helper method for the top handle.
 * This is half of the handle modeled, which is then mirrored
 *
 */
module half_handle() {
    half_length = full_depth/2;
    difference() {
        // When looking at YZ plane from positive X axis towards negative X axis:
        // finger_clearance, tan(handle_angle) -> triangle on the inner side of the handle with the perpendicular along the Z axis
        // extrusion_dim, sin(handle_angle) -> triangle hanging below the XY plane with perpendicular being the cross section of the angled extrusion
        // Both triangles have their theta angle where the inner edge of the angled extrusion meets XY plane

        union() {
            // Horizontal handle
            horz_extrude_length = half_length - (finger_clearance / tan(handle_angle)) - (extrusion_dim / sin(handle_angle));
            translate([0, 0, extrusion_dim/2+finger_clearance]) {
                rotate([-90, 0, 0]) {
                    linear_extrude(horz_extrude_length) {
                        handle_polygon();
                    }
                }
            }

            // Angled handle
            angle_extrude_length = (finger_clearance / sin(handle_angle)) + (extrusion_dim / tan(handle_angle));
            translate([0, half_length, 0]) {
                rotate([90 - handle_angle, 0, 0]) {
                    translate([0, -extrusion_dim/2, 0])
                    linear_extrude(angle_extrude_length+slip) {
                        handle_polygon();
                    }
                }
            }

            // Top fillet
            translate([extrusion_dim/2, horz_extrude_length, finger_clearance]) {
                rotate([0, -90, 0]) {
                    rotate_extrude(angle=handle_angle, $fn=100) {
                        translate([extrusion_dim/2, extrusion_dim/2, 0]) {
                            handle_polygon();
                        }
                    }
                }
            }
        }
        
        translate([-extrusion_dim, 0, -extrusion_dim*4]) {
            cube([extrusion_dim*2, half_length*2, extrusion_dim*4]);
        }

        // Screw shank
        // Head diameter is twice the thread diameter
        screw_size = Five_mm_screw_hole;
        screw_head_height = (extrusion_dim/2 - screw_size) * tan(handle_angle);
        translate([0, half_length - extrusion_dim/2, screw_head_height]) {
            rotate([180, 0, 0]) {
                flat_screw(Five_mm_screw_hole, finger_clearance+extrusion_dim);
            }
        }
    }
}

/*
 *
 * Polygon which defines a cross-sectional profile of the top handle
 *
 */
module handle_polygon() {
    fillet_radius = extrusion_dim/4;
    offset(r=fillet_radius) {
        offset(delta=-fillet_radius) {
            square(extrusion_dim, center=true);
        }
    }
}
