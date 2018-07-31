//-----------------------------------------------------
#include "colors.inc"

#include "try.pov"
//-----------------------------------------------------
#declare Tree_01 = object{TREE double_illuminate hollow}
//-----------------------------------------------------
object{ Tree_01
        scale 0.7
        rotate< 0, 0, 0>
        translate< 0, 0.00, 0>
      }
//----------------------------------------------------


// sky ---------------------------
plane{<0,1,0>,1 hollow
       texture{
        pigment{ bozo turbulence 0.92
          color_map {
           [0.00 rgb <0.2, 0.3, 1>*0.5]
           [0.50 rgb <0.2, 0.3, 1>*0.8]
           [0.70 rgb <1,1,1>]
           [0.85 rgb <0.25,0.25,0.25>]
           [1.0 rgb <0.5,0.5,0.5>]}
          scale<1,1,1.5>*2.5
          translate<1.0,0,-1>
          }// end of pigment
        finish {ambient 1 diffuse 0}
        }// end of texture
        scale 10000
     }// end of plane

// fog on the ground -------------
fog { fog_type   2
      distance   50
      color      White
      fog_offset 0.1
      fog_alt    1.5
      turbulence 1.8
    }
//--------------------------------

#declare C = 0.25;

#macro Target (POSI, COLO)
  box{
    -C/2 + <0,-C/2+0.01>, +C/2 + <0,-C/2+0.01>
    rotate 45*y
    translate POSI
    texture {
      pigment{ 
        //rgb<1,1,1>
        image_map {
          png COLO 
          interpolate 2
        }
      }
      rotate 90 * x
      translate POSI+2*C
      scale C
    }
  }
#end // ------------------ end of macro

#macro TargetH (POSI, COLO, D, R)
  difference{
    box {
      C/2, -C/2
        pigment {
          rgb<1,1,1>
        }
      rotate 45 * (<1,0,1> - POSI)
      rotate 45*y
      translate POSI+<0,1,0>
    }
    plane { POSI+<0,1,0>, D
    }
      texture {
        pigment {
          image_map {
            png COLO 
            interpolate 2
          }
        }
        #switch (R)
        #case (1)
          rotate 45*x
          rotate 90-z*45
          #break
        #case (2)
          rotate 45*x
          rotate 90+x*45
          #break
        #else
          rotate 90+POSI*45
          #break
        #end
        scale C
        translate C/2
      }
  }
#end // ------------------ end of macro

#declare bluet = <1, 0, 1>;
#declare redt = <1, 0, -1>;
#declare purplet = <-1, 0, 1>;
#declare yellowt = <-1, 0, -1>;

Target(bluet, "target_blue")
Target(redt, "target_brown")
Target(purplet, "target_purple")
Target(yellowt, "target_orange")

TargetH(bluet, "target_cyan", sqrt(3), 2)
TargetH(redt, "target_red", sqrt(3), 0)
TargetH(purplet, "target_pink", sqrt(3), 0)
TargetH(yellowt, "target_yellow", sqrt(3), 1)

#declare light_object = 
  sphere { 0,1 
           pigment { rgbf 1 } 
           finish { specular 1 } }

light_source { <20,3,20> color rgb 1.0 looks_like { light_object } }

object {
  //box { <0,0,0,> <1,1,1>  }
  cylinder { <0,0,0,> <1,1,1> 50 }
  texture {
    pigment{ image_map { jpeg "grass.jpg" //png  "soil2.png" 
        interpolate 2}
    }
normal { bumps 1 scale 2 }
    finish {
     ambient 0.1 diffuse 0.4
phong 0.1 specular 0.1
brilliance 0.2
reflection 0.05
    }
  }
  rotate x*90
  translate -0.5*(x+z) // center on the origin
  scale <2, 0.001, 2>
}


#declare dist = 0.8;

// Fish-eye camera
camera {
  ultra_wide_angle
  sky <0,1,0>
  location <dist*cos(2.0*pi*clock), 0.5, dist*sin(2.0*pi*clock)>
  look_at  <0, 0.45,  0>
}


light_source { <0, 0, 10> color White}
light_source { <5, 10, 5> color White}
light_source { <-5, 10, 5> color White}

// // Top light source
// light_source {
//     <0, 999, 0> color White
//         parallel
//           point_at <0,0,0>
//         }
