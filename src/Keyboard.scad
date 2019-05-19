$fn = 100;

// plate dimensions
plate_thickness = 2;
plate_length = 250 - 19;
plate_width = 123 - 19;
hole_length = 14;
hole_width = 14;

// case dimensions
front_height = 12.25;
back_height = 22.25;
height_diff = front_height - back_height;
case_thickness = 1.5;
case_length =  plate_length + (case_thickness * 2);
case_width = plate_width + (case_thickness * 2);
rotate_f = 6; 


// front pieces calculations 
front_angle_b = 180 - (90 + rotate_f);
echo("front_angle_b=", front_angle_b);
front_angle_a = 180 - (90 + front_angle_b);
echo("front_angle_a=", front_angle_a);
f_front_height = front_height * ( sin(front_angle_b) / sin(90) );
echo("f_front_height=", f_front_height);
front_width = sqrt(pow(front_height, 2) - pow(f_front_height, 2));
echo("front_width=", front_width);


// back pieces calculations
back_angle_a = 180 - (90 + rotate_f);
back_bottom_length = sin(back_angle_a) * case_width;
b_back_height = sqrt(pow(case_width, 2) - pow(back_bottom_length, 2));


module  plate_spacing() {
  cube([
    plate_length,
    plate_width, 
    plate_height
  ]);
};
 

module cherry_mx_mount_hole (thickness) {
    color("red") cube([hole_length, hole_width, thickness]);
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
        //cherry_mx_mount_hole(thickness);
        translate([width_border, length_border, 0]) {
            //cherry_mx_row(12, thickness);
            cherry_mx_grid(5, 12, thickness);
        };
    };
};

module keyboard_case_front () {
  polyhedron(
    points = [
      [0, 0, 0],                    // 0
      [case_length, 0, 0],          // 1
      [case_length, front_width, 0],  // 2
      [0, front_width, 0],            // 3
      [case_length, 0, f_front_height],  // 4
      [0, 0, f_front_height],            // 5
    ],
    faces = [
      [0, 1, 2, 3],
      [2, 1, 4],
      [5, 0, 3],
      [0, 5, 4, 1],
      [2, 4, 5, 3],
    ],
    convexity = 1
  );
};

module keyboard_case_back () {  
 polyhedron(
    points = [
      [0, front_width, 0],                                         // 0
      [case_length, front_width, 0],                               // 1
      [case_length, front_width + back_bottom_length, 0],               // 2
      [0, front_width + back_bottom_length, 0],                         // 3
      [case_length, front_width + back_bottom_length, b_back_height],   // 4
      [0, front_width + back_bottom_length, b_back_height],             // 5
    ],
    faces = [
      [0, 1, 2, 3],
      [2, 1, 4],
      [5, 0, 3],
      [0, 5, 4, 1],
      [2, 4, 5, 3],
    ],
    convexity = 1
  );
};


module keyboard_case (plate_length, plate_width, plate_height, angle_trn) {
  keyboard_case_front();
  keyboard_case_back();
  translate([0, angle_trn, 0]) {
    rotate([rotate_f, 0, 0]) { 
      difference() {   
        cube([case_length, case_width, front_height]);
        translate([case_thickness, case_thickness, front_height - plate_height]) {
          cube([plate_length, plate_width, plate_height]);
        };
      };
    };
  };
};


//translate([0,0, 30]) {
//  rotate([top_plate_rotation, 0, 0]) {
//        keyboard_plate(plate_length, plate_width, plate_thickness);
//    };
//};

keyboard_case(plate_length, plate_width, plate_thickness, front_width);

