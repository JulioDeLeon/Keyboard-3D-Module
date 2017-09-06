$fn = 100;
row = 5;
col = 12;

plate_thickness = 5;
plate_length = 231;
plate_width = 104;

hole_length = 14;
hole_width = 14;

screw_size = 3;
cherry_mx_plate_catch = 2;
hole_gap = 5;
offset = 1;

x_hole_offset = 20.5;
y_hole_offset = 23.5;
center_y_hole_offset = 9.5;

pcb_length = 35.56;
pcb_width = 17.84;
pcb_height = 1.57;
usb_length = 5.0;
usb_width = 7.5;
usb_height = 2.5;
button_length = 2.5;
button_width = 3.5;
button_height = 2.5 + 1.8;

module cherry_mx_mount_hole (thickness) {
    rem = thickness - cherry_mx_plate_catch;
    translate([offset/2,offset/2,0]) {
        color("red") cube([hole_length, hole_width, cherry_mx_plate_catch]);
    };
    translate([0,0,cherry_mx_plate_catch]) {
        color("red") cube([hole_length + offset, hole_width + offset, rem]);
    };
};

module spacer() {
    color("purple") cube([5,5,20]);
};

module mm_bolt_hole (diam, thickness) {
    cylinder(h=thickness, r=(diam / 2));
};

module cherry_mx_row (num_sockets, thickness) {
  for(itr = [0:num_sockets-1]) {
      translate([itr*(hole_length + hole_gap), 0, 0]) {
          cherry_mx_mount_hole(thickness);
      };
  };
};

module cherry_mx_grid (row_num, col_num, thickness) {
    for(itr = [0:row_num-1]) {
        translate([0,itr*(hole_width + hole_gap), 0]) {
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
        translate([width_border - offset/2, length_border - offset/2, 0]) {
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

module mm_bolt_catch( mm_diam, height) {
    difference () {
      cylinder(h=height, r=mm_diam+1);
      mm_bolt_hole(mm_diam, height); 
    };
};

module teensy_32 () {
    // https://www.pjrc.com/teensy/dimensions.html
    //pcb
    cube([pcb_length,pcb_width, pcb_height]);
    
    //usb
    translate([0,pcb_width/2 - usb_width/2,pcb_height]) cube([usb_length, usb_width, usb_height]);
    
    //button
    translate([2.54 + 29.97 - (button_length/2), pcb_width/2 - button_width/2, pcb_height]) cube([button_length, button_width, button_height]);
    
    //usb space
    color("red") translate([-10,pcb_width/2 -10/2,pcb_height - 0.20]) cube([10, 10, 10]);
    
    //button space
    color("red") translate([2.54 + 29.97 - (button_length/2), pcb_width/2 - button_width/2, pcb_height]) cube([button_length, button_width, button_height + 10]);
    
    //pcb underspace
    pcb_buff_length = 10;
    pcb_buff_width = pcb_width + 6;
    pcb_buff_height = 4;
    color("red") translate([0,-((pcb_buff_width - pcb_width)/2),-pcb_buff_height]) cube([pcb_buff_length,pcb_buff_width, pcb_buff_height]);
};

module case (length, width, plate_thick, depth, thickness) {
    shell_thick = 5;
    lip_height = 4;
    plate_lip = 7;
    space_height = depth - (plate_thick + lip_height) - shell_thick;
    difference () {
        //shell
        cube([length + (shell_thick*2), width + (2*shell_thick), depth]);
        //plate fitting
        translate ([shell_thick,shell_thick, depth - (plate_thick +lip_height)]) {
            cube([length, width, plate_thick + lip_height]);
        };
        
        //chassis space
        translate ([shell_thick, shell_thick + plate_lip/2, shell_thick]) {
            cube([length, width - plate_lip, space_height]);
        };
        
        // teensy catch
        translate([60, width + (shell_thick*2) -3, shell_thick + pcb_height - 1]) {
            rotate([0,180,90]) teensy_32();
        };
        
    };
        
    //bolt catches
    translate([shell_thick + x_hole_offset, shell_thick + y_hole_offset,shell_thick]) {
       mm_bolt_catch(screw_size, space_height);
    };
    
    translate([shell_thick + x_hole_offset, (width + (shell_thick*2)) - (y_hole_offset + shell_thick),shell_thick]){ 
        mm_bolt_catch(screw_size, space_height);
    };
    
    translate([(length + (shell_thick*2)) - (x_hole_offset + shell_thick), (width + (shell_thick *2)) - (shell_thick + y_hole_offset), shell_thick]){ 
        mm_bolt_catch(screw_size, space_height);
    };
    
    translate([(length + (shell_thick*2)) - (shell_thick + x_hole_offset),(shell_thick + y_hole_offset) ,shell_thick]){ 
        mm_bolt_catch(screw_size, space_height);
    };
    
    translate([(length + (shell_thick * 2))/2,((width + (shell_thick * 2))/2) - (center_y_hole_offset),shell_thick]){ 
        mm_bolt_catch(screw_size, space_height);
    };
};

//translate([5 + plate_length, 5, 30-4]) {
//    rotate([0,180,0]) {
//        color("green") keyboard_plate(plate_length,     plate_width, plate_thickness);
 //   };
//};

color("blue") case(plate_length, plate_width, plate_thickness, 20);
//translate([50, 5 + pcb_length + ,5 + pcb_height + button_height]) rotate([0,180,90]) color("yellow") teensy_32();

//teensy_32();
//translate([5 + x_hole_offset + 3.4,5 + y_hole_offset,5]) color("red") cube([3.5,3.5,3.5]);
//mm_bolt_catch(3, 12);
