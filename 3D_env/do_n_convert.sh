#!/bin/bash

nbpic=40

mkdir -p 1080p
mkdir -p 4K
mkdir -p 1080p_fisheye
mkdir -p 4K_fisheye

mkdir -p 1080p_jpg
mkdir -p 4K_jpg
mkdir -p 1080p_fisheye_jpg
mkdir -p 4K_fisheye_jpg

#povray +kff$nbpic +O1080p/1080_ -d +H1080 +W1920 r_target.pov
#mogrify -format jpg 1080p/*.png
#mv 1080p/*.jpg 1080p_jpg/
#
povray +kff$nbpic +O1080p_fisheye/1080_fisheye_ -d +H1080 +W1920 r_fisheye_target.pov
mogrify -format jpg 1080p_fisheye/*.png
mv 1080p_fisheye/*.jpg 1080p_fisheye_jpg/
#
#povray +kff$nbpic +O4K/4K -d +H2160 +W4096 r_target.pov
#mogrify -format jpg 4K/*.png
#mv 4K/*.jpg 4K_jpg/
#
#povray +kff$nbpic +O4K_fisheye/4K_fisheye_ -d +H2160 +W4096 r_fisheye_target.pov
#mogrify -format jpg 4K_fisheye/*.png
#mv 4K_fisheye/*.jpg 4K_fisheye_jpg/
