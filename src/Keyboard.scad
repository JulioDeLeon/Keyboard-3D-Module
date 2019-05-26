$fn = 100;

// plate dimensions
plate_thickness = 5.30;
plate_length = 250 - 19;
plate_width = 123 - 19;
hole_length = 14;
hole_width = 14;

// case dimensions
front_height = 10;
back_height = 22.25;
height_diff = front_height - back_height;
case_thickness = 1.5;
case_length =  plate_length + (case_thickness * 2);
case_width = plate_width + (case_thickness * 2);
rotate_f = 6; 
spacing_factor = 1.10;

// front pieces calculations 
front_angle_b = 180 - (90 + rotate_f);
front_angle_a = 180 - (90 + front_angle_b);
f_front_height = front_height * ( sin(front_angle_b) / sin(90) );
front_width = sqrt(pow(front_height, 2) - pow(f_front_height, 2));


// back pieces calculations
back_angle_a = 180 - (90 + rotate_f);
back_bottom_length = sin(back_angle_a) * case_width;
b_back_height = sqrt(pow(case_width, 2) - pow(back_bottom_length, 2));

// teensy calculations 
pcb_length = 36.3;                                                             
pcb_width = 17.95;                                                              
pcb_height = 2.25;                                                              
usb_length = 6.5;                                                               
usb_width = 8.8;                                                                
usb_height = 3;                                                               
button_length = 2.5;                                                            
button_width = 3.5;                                                             
button_height = 2.5 + 1.8;                                                      

// mm screw catch dims
screw_size = 3;

module  plate_spacing() {
  cube([
    plate_length,
    plate_width, 
    plate_height
  ]);
};
 
module mm_bolt_hole (diam, thickness) {
  cylinder(h=thickness, r=(diam / 2));                                        
};     

module mm_bolt_catch (mm_diam, height) { 
  difference () {                                                             
    cylinder(h=height, r=mm_diam+0.3);                                          
    mm_bolt_hole(mm_diam, height);                                            
  };                                                                          
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
  //plate catch dims
  plate_lip_width = 7;
  plate_lip_height = 10;

  chassis_space_length = case_length - (case_thickness * 2);
  chassis_space_width =  case_width - ((case_thickness * 2) + (plate_lip_width * 2));
  chassis_space_height = 50;

  teensy_catch();
  difference() {
    keyboard_chassis(plate_length, plate_width, plate_height, angle_trn);
    
    // chassis space
    translate([case_thickness, case_thickness + plate_lip_width, case_thickness]) {
      cube([chassis_space_length, chassis_space_width, chassis_space_height]);
      };

    // teensy spacing
    teensy_spacing(); 
  };

  hf1 = 3;
  difference() {
    translate([case_thickness + (hole_length * hf1) + (5 * hf1), case_width/2 - 10.5, 0])
      mm_bolt_catch(screw_size, back_height);
    plate_catch_spacing();
  };

  hf2 = 9;
  difference() {
    translate([case_thickness + (hole_length * hf2) + (5 * hf2), case_width/2 - 10.5, 0])
      mm_bolt_catch(screw_size, back_height);
    plate_catch_spacing();
  };
};

module plate_catch_spacing () {
  translate([0, front_height, 0])
    rotate([rotate_f, 0, 0])
    translate([case_thickness, -(case_thickness*5), front_height - (plate_thickness * spacing_factor)])
    cube([plate_length, plate_width , back_height]);
};

module keyboard_chassis (plate_length, plate_width, plate_height, angle_trn) {
  keyboard_case_front();
  keyboard_case_back();

  translate([0, angle_trn, 0]) {
    rotate([rotate_f, 0, 0]) { 
      difference() {   
        cube([case_length, case_width, front_height]);
        translate([case_thickness, case_thickness, front_height - (plate_height * spacing_factor)]) {
          cube([plate_length, plate_width, plate_height * spacing_factor]);
        };
      };
    };
  };
};

module teensy_catch () {
  catch_length = pcb_width - 2;
  catch_width = 8;
  catch_height = 5.5;

  difference() {
    translate([61 - pcb_width, case_width - pcb_length - case_thickness, 0])
      cube([catch_length, catch_width, catch_height]);
    teensy_spacing();
  };
};

module teensy_32 () {                                                           
    // https://www.pjrc.com/teensy/dimensions.html                              
    //pcb                                                                       
    cube([pcb_length,pcb_width, pcb_height]);                                   
                                                                                
    //usb                                                                       
    translate([0,pcb_width/2 - usb_width/2,pcb_height]) cube([usb_length, usb_width, usb_height]);
                                                                                
    //button                                                                    
    translate([2.54 + 29.97 - (button_length/2), pcb_width/2 - button_width/2, pcb_height]) 
      cube([button_length, button_width, button_height]);
                                                                                
    //usb space                                                                 
    color("red") translate([-10,pcb_width/2 -10/2,pcb_height - 4]) 
      cube([10, 10, 10]);
                                                                                
    //button space                                                              
    color("red") 
      translate([2.54 + 29.97 - (button_length/1.5), pcb_width/2 - button_width/1.5, pcb_height]) 
      cube([button_length * 1.5, button_width * 1.5, button_height + 10]);
                                                                                
    //pcb underspace                                                            
    pcb_buff_length = 10;                                                       
    pcb_buff_width = pcb_width + 24;                                             
    pcb_buff_height = 7;                                                        
    color("red") 
      translate([0,-((pcb_buff_width - pcb_width)/2),-pcb_buff_height]) 
      cube([pcb_buff_length,pcb_buff_width, pcb_buff_height]);
};      

module teensy_spacing() {
  translate([60, case_width,  pcb_height + case_thickness + 2]) {
    rotate([0, 180, 90]) {
      teensy_32();
    };
  };
};

//translate([0,0, 30]) {
//  rotate([top_plate_rotation, 0, 0]) {
//        keyboard_plate(plate_length, plate_width, plate_thickness);
//    };
//};

keyboard_case(plate_length, plate_width, plate_thickness, front_width);
  

