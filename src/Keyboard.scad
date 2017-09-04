$fn = 100;
row = 5;
col = 12;

plate_thickness = 2;
plate_length = 231;
plate_width = 104;

hole_length = 14;
hole_width = 14;

screw_size = 3;

module cherry_mx_mount_hole (thickness) {
    color("red") cube([hole_length, hole_width, thickness]);
};

module mm_bolt_hole (diam, thickness) {
    cylinder(h=thickness, r=(diam / 2));
};

module cherry_mx_row (num_sockets, thickness) {
  for(itr = [0:num_sockets-1]) {
      translate([itr*(hole_length + 5), 0, 0]) {
          cherry_mx_mount_hole(thickness);
      };
  };
};

module cherry_mx_grid (row_num, col_num, thickness) {
    for(itr = [0:row_num-1]) {
        translate([0,itr*(hole_width + 5), 0]) {
            cherry_mx_row(col_num, thickness);
        };
    };
};

module keyboard_plate (length, width, thickness) {
    length_border = 7;
    width_border = 4;
    difference () {
        cube([length, width, thickness]);
        
        // grid
        translate([width_border, length_border, 0]) {
            //cherry_mx_row(12, thickness);
            cherry_mx_grid(row, col, thickness);
        };
        
        //screw holes
        translate([20.5,23.25,0]){ 
            mm_bolt_hole(screw_size, thickness);
        };
        
        translate([20.5,width - 23.25,0]){ 
            mm_bolt_hole(screw_size, thickness);
        };
        
        translate([length - 20.5,width - 23.25,0]){ 
            mm_bolt_hole(screw_size, thickness);
        };
        
        translate([length - 20.5,23.25,0]){ 
            mm_bolt_hole(screw_size, thickness);
        };
        
        translate([length/2,(width/2) - 9.5,0]){ 
            mm_bolt_hole(screw_size, thickness);
        };
    };
};

keyboard_plate(plate_length, plate_width, plate_thickness);