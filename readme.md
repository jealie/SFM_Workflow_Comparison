# Intercomparison of photogrammetry software

Supplementary code for the paper "Intercomparison of photogrammetry software for three-dimensional vegetation modelling" by A. Probst, D. Gatziolis, J. Liénard and N. Strigul (Royal Society Open Science, 2018).

## Reproduce the main results of the 2018 paper

### Virtual environment

The virtual environment requires [pov-ray](http://www.povray.org/), the Persistence of Vision Raytracer. Run the bash script `do_n_convert.sh` to generate 1080p, 4K and 8K imagery from 200 circular viewpoints around the tree:

```bash
3D_env$ ./do_n_convert.sh
```

You can see here an illustration with 40 frames, using alternatively normal lens and fish-eye effect:

![alt text](https://github.com/jealie/SFM_Workflow_Comparison/raw/master/illustration_environment.gif "Virtual environment")


### Quantitative comparison

Launch R, set the working to the one where the repo has been cloned, and run the file `main.R`:

```R
R> setwd('git-directory')
R> source('main.R')
```

(don't forget to replace *git-directory* with the actual one)


#### R Dependencies

This analysis builds upon a number of previous works, including:

- [`geomorph`](https://github.com/geomorphR/geomorph), [`rgl`](https://r-forge.r-project.org/projects/rgl/), [`VoxR`](https://cran.r-project.org/web/packages/VoxR/index.html) for voxel-level manipulations used to compute the ROC curves

- [`alphashape3d`](https://cran.r-project.org/web/packages/alphashape3d/index.html), [`geometry`](https://davidcsterratt.github.io/geometry/) for volume computations

These should be installed prior to running the script, e.g. using the command `install.package('package-name')`.
