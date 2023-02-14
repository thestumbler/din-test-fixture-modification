include <lib.scad>



hole = 4; //hole diamter
rail_thk = 1.0;
rail_base = 27;
rail_hgt = 7.5;
rail_wid = 35;
rail_lip = 0.5 * (rail_wid - rail_base) + rail_thk;
slot_len = 18.0;
slot_wid = 6.3;
slot_c2c = 25.0;
slot_gap = slot_c2c - slot_len;
slot_hole_c2c = slot_len - slot_wid;
module make_din_rail( length ) {
  color("silver") {
  // draw the edges and lips
  translate([rail_hgt-rail_thk,0.5*rail_base-rail_thk,0]) 
    cube([rail_thk,rail_lip,length]);
  translate([0,0.5*rail_base-rail_thk,0]) 
    cube([rail_hgt,rail_thk,length]);;
  mirror([0,1,0]) {
    translate([rail_hgt-rail_thk,0.5*rail_base-rail_thk,0]) 
      cube([rail_thk,rail_lip,length]);
    translate([0,0.5*rail_base-rail_thk,0]) 
      cube([rail_hgt,rail_thk,length]);;
  }

  difference() {
    // base rail
    translate([0,-0.5*rail_base,0]) 
      cube([rail_thk,rail_base,length]);
    // holes
    for(z= [0:slot_c2c:length-0.5*slot_gap]) {
      translate([-0.5*rail_thk,0,z+0.5*slot_wid+0.5*slot_gap])
      rotate([0,90,0])  
      hull() {
        translate([-slot_hole_c2c,0,0])
          cylinder(h=2*rail_thk,d=slot_wid, $fn=30);
        cylinder(h=2*rail_thk,d=slot_wid, $fn=30);
      }
    }  
  }
  }
}

module place_din_rail(length=100) {
  rotate(-90,[1,0,0])
  rotate(-90,[0,0,1])
  make_din_rail(length);
}

module place_din_rail_access(length=100) {
  rail_box2 = [ rail_base-3*rail_thk, length, rail_hgt];
  translate([-0.5*rail_wid,0,rail_hgt+0.5])
  #cube( [rail_wid, length, 100] );
  translate([-0.5*rail_box2.x,0,rail_thk])
  #cube( rail_box2 );
}

bkt_off = 23;
bkt_thk = 16;
bkt_hgt = 100;
bkt_recess = 1.4;

wedge=[50,bkt_thk-0.5,25];
din_proud=[26,wedge.y,1.0];
din_recess=[28,10+wedge.y,2];
wedge_ang = 20;
m5_insert_deep = 5;
m5_insert_dia = 8;
module make_wedge() {
  difference() {
    union() {
      // sloping wedge
      translate([-0.735*wedge.x*cos(wedge_ang),0,0]) // 0.735 positions rail along the wedge slope 
        rotate(-wedge_ang,[0,1,0]) {
          translate([0,0,-wedge.z])
            difference() {
              cube(wedge);
              // m5 brass insert, _deep-xxx is additional depth of brass insert hole
              translate([0.5*wedge.x,0.5*wedge.y,wedge.z-m5_insert_deep-1.3-din_recess.z])
                cylinder(h=20,d=m5_insert_dia);
              // din rail recess
              translate([0.5*(wedge.x-din_recess.x),
                         0.5*(wedge.y-din_recess.y),wedge.z-1.5])
                cube(din_recess);
            }
        }
      // DIN rail protrusion
      translate([-0.5*din_proud.x,0,-din_proud.z+0.01])
        cube(din_proud);
    }
    // trim bottom
    translate([0.5*din_proud.x,-5,-30])
      cube([100,100,30]);
    translate([-100-0.5*din_proud.x,-5,-30])
      cube([100,100,30]);
    translate([-50,-5,-30-1])
      cube([100,25,30]);
    // trim ends
    translate([17,-10+0.5*wedge.y,-0.5])
      cube([20,20,50]);
    translate([-20-28,-10+0.5*wedge.y,-0.5])
      cube([20,20,50]);
    // m5 brass insert, _deep+xxx is additional depth of brass insert hole
    translate([0,0.5*wedge.y,-din_proud.z-0.01])
      cylinder(h=m5_insert_deep+4.5,d=m5_insert_dia);
  }
}
module make_wedge_cutaway() {
  // used to adjust depth of m5 insert holes
  difference() { // cut away
    make_wedge();
    translate([0,4,0])
      cube([100,10,100],center=true);
  }
}
module print_wedge() {
// has to be printed on its side
// because of din rail protrusion on the bottom
rotate(90,[1,0,0])
  make_wedge();
}
module draw_wedge() {
  // make pretty view of wedge for readme
  sep=5;
  color("darkorchid") {
    translate([0, -0.5*wedge.y,sep])
    make_wedge();
    translate([0, 0.5*wedge.y,-sep])
    rotate(180,[1,0,0])
    make_wedge();
  }
}



module make_bracket(slice=false) {
  cut = [300,300,40];
  color("olive")
  translate([0,bkt_thk+0.01,0])
  rotate(90,[1,0,0])
  difference() {
    translate([0,-bkt_off-bkt_recess,0.5*bkt_thk])
      import("din-test-fixture-triangle-support.stl");
    if(slice) {
      translate([-0.5*cut.x, 25, -0.25*cut.z])
        cube(cut);
    }
  }
}


module make_assy() {
  make_bracket();
  make_wedge();
  translate([0,300-bkt_thk,0]) {
    make_bracket();
    make_wedge();
  }

  // bottom anguled rail
  translate([-11,-0.01,7])
    rotate(-wedge_ang,[0,1,0]) {
      place_din_rail(300);
      place_din_rail_access(300);
    }

  din_angle = 60;
  // top din rail
  translate([0,0,bkt_hgt-bkt_recess]) place_din_rail(300);

  translate([-60.0,0,38.3])
    rotate(-din_angle,[0,1,0])
      place_din_rail(300);

  translate([60.0,0,38.3])
    rotate(din_angle,[0,1,0])
      place_din_rail(300);
}

// make_assy();
// print_wedge();
// draw_wedge();
make_wedge();
