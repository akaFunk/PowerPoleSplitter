// Select which part to generate
part = 1;    // 0 = Top, 1 = Bottom, 2 = top + bottom, 3 = single power pole slot

// Engraved name
name_enable = 1;
name = "Max";

// Voltage display
vd_enable = 1;
vd_width = 22.0;
vd_length = 9.9;
vd_height = 6.9;
vd_drill = 2.0;
vd_holder_width = 6.0;
vd_length_offset = 10.0;
vd_hole_dist = 26.0;

// Input power pole
ipp_enable = 1;

// Drill for the two case parts
drill_diameter_top = 3.2;
drill_diameter_bottom = 3.8;
drill_depth_bottom = 20.0;
drill_block_width = 10;   // size of the blocks in the bottom part including wall thickness

// Outer housing
housing_width = 50.0;
housing_height = 35.0;
housing_wall = 2.0;
housing_back_distance = 10.0;
housing_front_distance = 10.0;
housing_corner_radius = 2.0;
housing_top_radius = 1.5;    // Radius for the the top rounded edges
housing_bottom_radius = 1.5;    // Radius for the bottom rounded edges

// Settings for the power pole holder
pp_count = 6;
pp_distance = 15.0;
pp_wall_thickness = 2.0;
pp_width = 16.2;
pp_height = 8.2;
pp_length = 19.0;
pp_border = 0.5;
pp_slot_depth = 0.5;
pp_slot_width = 4.0;
pp_slot_offset = 2.1;
pp_drill_diameter_top = 2.5;
pp_drill_offset = 15.0;
pp_topcut_depth = 0.5;
pp_topcut_height = 2.0;

// Calculated values
pp_case_width = pp_width + 2*pp_wall_thickness;
pp_case_height = pp_height + 2*pp_wall_thickness;
housing_length_base = (pp_count-1)*pp_distance + pp_case_height + housing_back_distance;

pp_hole_offset_min_vd = housing_front_distance + vd_enable*(vd_length + vd_length_offset);
pp_hole_offset_min_ipp = housing_front_distance + ipp_enable*(pp_length+pp_wall_thickness);
pp_hole_offset = max(pp_hole_offset_min_vd, pp_hole_offset_min_ipp);

housing_length = housing_length_base + pp_hole_offset;

$fn=50;

if(part == 0 || part == 2)
{
    difference()
    {
        union()
        {
            difference()
            {
                // Main top plate
                minkowski()
                {
                    minkowski()
                    {
                        cylinder(r=housing_corner_radius-housing_top_radius,h=housing_wall-housing_top_radius);
                        translate([0,0,-housing_wall])
                        {
                            difference()
                            {
                                translate([0, 0, housing_top_radius])  sphere(r=housing_top_radius);
                                cylinder(r=housing_top_radius, h=housing_top_radius);
                            }
                        }
                    }
                    translate([0, housing_length/2, -housing_top_radius])
                        cube([housing_width-2*housing_corner_radius, housing_length-2*housing_corner_radius, 1e-20], center=true);
                }
                
                // Cut for the power poles
                translate([-pp_case_width/2, pp_hole_offset, -housing_wall-0.1])
                    cube([pp_case_width, (pp_count-1)*pp_distance+pp_case_height, housing_wall+0.2]);
                // Voltage display cut
                if(vd_enable)
                {
                    translate([-vd_width/2, housing_front_distance, -housing_wall-0.1])
                        cube([vd_width, vd_length, housing_wall+0.2]);
                }
            }
            
            // Voltage display
            if(vd_enable)
            {
                difference()
                {
                    union()
                    {
                    translate([vd_width/2, housing_front_distance + (vd_length-vd_holder_width)/2, -vd_height])
                        cube([vd_holder_width, vd_holder_width, vd_height-housing_wall]);
                    translate([-vd_width/2-vd_holder_width, housing_front_distance + (vd_length-vd_holder_width)/2, -vd_height])
                        cube([vd_holder_width, vd_holder_width, vd_height-housing_wall]);
                    }
                    translate([vd_hole_dist/2, housing_front_distance + vd_length/2, -vd_height-0.2])
                        cylinder(r=vd_drill/2, h=vd_height-1.0+0.2, center=false, $fn=36);
                    translate([-vd_hole_dist/2, housing_front_distance + vd_length/2, -vd_height-0.2])
                        cylinder(r=vd_drill/2, h=vd_height-1.0+0.2, center=false, $fn=36);
                }
            }
            translate([0, pp_hole_offset, 0])
            {
                // Power pole holders at the top
                for(pp = [0 : 1 : pp_count-1])
                    translate([0, pp*pp_distance+pp_case_height/2, 0])
                        SinglePowerPoleHolder();
                // Walls between the holders
                for(pp = [0 : 1 : pp_count-2])
                {
                    difference()
                    {
                        translate([-pp_case_width/2, pp*pp_distance+pp_case_height, -pp_length-pp_wall_thickness])
                        {
                            cube([pp_case_width, pp_distance-pp_case_height, pp_length+pp_wall_thickness]);
                        }
                        translate([0, pp*pp_distance+pp_case_height, -pp_length+pp_drill_offset])
                            rotate(a=[90,0,0])
                                cylinder(r=pp_drill_diameter_top/2, h=pp_height+2*pp_wall_thickness+0.2, center=true, $fn=36);
                    }
                }
            }
        }
        // Drills
        translate([-housing_width/2+drill_block_width/2, drill_block_width/2, -housing_wall-0.1])
            cylinder(r=drill_diameter_top/2, h=housing_wall+0.2, center=false, $fn=36);
        translate([housing_width/2-drill_block_width/2, housing_length-drill_block_width/2, -housing_wall-0.1])
            cylinder(r=drill_diameter_top/2, h=housing_wall+0.2, center=false, $fn=36);
        translate([-housing_width/2+drill_block_width/2, housing_length-drill_block_width/2, -housing_wall-0.1])
            cylinder(r=drill_diameter_top/2, h=housing_wall+0.2, center=false, $fn=36);
        translate([housing_width/2-drill_block_width/2, drill_block_width/2, -housing_wall-0.1])
            cylinder(r=drill_diameter_top/2, h=housing_wall+0.2, center=false, $fn=36);
    }
}

if(part == 1 || part == 2)
{
    difference()
    {
        union()
        {
            difference()
            {
                union()
                {
                    difference()
                    {
                        // Main body
                        translate([-housing_width/2+housing_corner_radius, housing_corner_radius, housing_bottom_radius-housing_height])
                        minkowski()
                        {
                            minkowski()
                            {
                                cylinder(r=housing_corner_radius-housing_bottom_radius,h=housing_wall);
                                {
                                    difference()
                                    {
                                        sphere(r=housing_bottom_radius);
                                        cylinder(r=housing_bottom_radius, h=housing_bottom_radius);
                                    }
                                }
                            }
                                cube([housing_width-2*housing_corner_radius, housing_length-2*housing_corner_radius, housing_height-2*housing_wall-housing_bottom_radius], center=false);
                        }
                        
                        // Two cubes in order to remove the inner part of the main body
                        translate([-housing_width/2+drill_block_width, housing_wall, -housing_height+housing_wall])
                            cube([housing_width-2*drill_block_width, housing_length-2*housing_wall, housing_height-2*housing_wall+0.1], center=false);
                        translate([-housing_width/2+housing_wall, drill_block_width, -housing_height+housing_wall])
                            cube([housing_width-2*housing_wall, housing_length-2*drill_block_width, housing_height-2*housing_wall+0.1], center=false);
                        
                        // Hole for the input connector
                        if(ipp_enable)
                        {
                            translate([-pp_case_width/2, -0.1, -housing_height+housing_wall])
                                cube([pp_case_width, pp_case_width+0.2, pp_case_height]);
                        }
                        // akaFunk logo
                        translate([0, housing_length/2, -housing_height+housing_wall-0.5])
                            rotate(a=[0,0,0])
                            {
                                linear_extrude(height = 0.6)
                                {
                                    text(text = str("akaFunk"), font = "Sans", size = 7, valign = "center", halign = "center");
                                }
                            }
                        // Name ingravement
                        if(name_enable == 1)
                        {
                            translate([0, housing_length/2, -housing_height+0.5])
                                rotate(a=[180, 0, 90])
                                    linear_extrude(height = 0.6)
                                    {
                                        text(text = str(name), font = "Sans", size = 6, valign = "center", halign = "center");
                                    }
                        }
                    }
                    // Input connector
                    if(ipp_enable)
                    {
                    translate([0, 0, pp_case_height/2-housing_height+housing_wall])
                        rotate([90, 0, 0])
                            SinglePowerPoleHolder();
                    }
                }
            }
            
        }
        // Drills
        translate([-housing_width/2+drill_block_width/2, drill_block_width/2, -drill_depth_bottom-housing_wall])
            cylinder(r=drill_diameter_bottom/2, h=drill_depth_bottom+0.2, center=false, $fn=36);
        translate([housing_width/2-drill_block_width/2, housing_length-drill_block_width/2, -drill_depth_bottom-housing_wall])
            cylinder(r=drill_diameter_bottom/2, h=drill_depth_bottom+0.2, center=false, $fn=36);
        translate([-housing_width/2+drill_block_width/2, housing_length-drill_block_width/2, -drill_depth_bottom-housing_wall])
            cylinder(r=drill_diameter_bottom/2, h=drill_depth_bottom+0.2, center=false, $fn=36);
        translate([housing_width/2-drill_block_width/2, drill_block_width/2, -drill_depth_bottom-housing_wall])
            cylinder(r=drill_diameter_bottom/2, h=drill_depth_bottom+0.2, center=false, $fn=36);
    }
}

if(part == 3)
{
    SinglePowerPoleHolder();
}

module SinglePowerPoleHolder()
{
    difference()
    {
        // Main body of the power pole case
        translate([-pp_case_width/2, -pp_case_height/2, -pp_length-pp_wall_thickness])
            cube([pp_case_width,pp_case_height,pp_length+pp_wall_thickness]);
        // Most of the power pole connector itself
        translate([-pp_width/2, -pp_height/2, -pp_length])
            cube([pp_width,pp_height,pp_length+0.1]);
        // Add a hole to the bottom including the pp_border so the connector will lock in place
        translate([-pp_width/2+pp_border, -pp_height/2+pp_border, -pp_length-pp_wall_thickness-0.1])
            cube([pp_width-2*pp_border,pp_height-2*pp_border,pp_wall_thickness+0.2]);
        // Side slot
        translate([-pp_width/2-pp_slot_depth, -pp_slot_width/2, -pp_length])
            cube([pp_slot_depth+0.1,pp_slot_width,pp_length+0.1]);
        // Left slot
        translate([pp_slot_offset, -pp_height/2-pp_slot_depth, -pp_length])
            cube([pp_slot_width,pp_slot_depth+0.1,pp_length+0.1]);
        // Right slot
        translate([-pp_slot_offset-pp_slot_width, -pp_height/2-pp_slot_depth, -pp_length])
            cube([pp_slot_width,pp_slot_depth+0.1,pp_length+0.1]);
        // Drill
        translate([0, 0, -pp_length+pp_drill_offset])
            rotate(a=[90,0,0])
                cylinder(r=pp_drill_diameter_top/2, h=pp_height+2*pp_wall_thickness+0.2, center=true, $fn=36);
        // Top cutout
        translate([-pp_width/2-pp_topcut_depth, -pp_height/2-pp_topcut_depth, -pp_length+pp_length-pp_topcut_height+0.1])
            cube([pp_width+2*pp_topcut_depth, pp_height+2*pp_topcut_depth, pp_topcut_height+0.1]);
    }
}
