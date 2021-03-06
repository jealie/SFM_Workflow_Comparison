# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# This file contains auxiliary functions to compute the ROC curve and alphashape volume #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #


# This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
# Author: Jean Liénard
#
# Any results obtained with this code should refer to the following publication:
# Probst, A., Gatziolis, D., Liénard, J., and Strigul, N., "Intercomparison of photogrammetry software for three-dimensional vegetation modelling", Royal Society Open Science (2018)
#####


## FINE-GRID BASED APPROACH TO COMPUTE THE ROC CURVE, BOUNDED ON THE REFERENCE TREE
compute_tpr_fpr_grid2 = function(recons, ref, grid_grain = 0.001, grid=NULL, not_ref_indices=NULL) {
  require('VoxR')
  require('FNN')
  
  cat('\nComputing the fine grid...\n')
  
  recons_vox = vox(t(recons$vb[1:3,]), grid_grain)
  ref_vox = vox(t(ref$vb[1:3,]), grid_grain)
  for (c_i in 1:3) {
    to_exclude = which((recons_vox[,c_i] < min(ref_vox[,c_i])) | (recons_vox[,c_i] > max(ref_vox[,c_i])))
    if (length(to_exclude) > 0) {
      recons_vox = recons_vox[-to_exclude, ]
    }
  }
  
  grid_grain_filename = sub('\\.', '_', as.character(grid_grain))
  
  recons_to_ref = get.knnx(recons_vox[,1:3], ref_vox[,1:3], k=1) # distance from ref to closest recons
  
  grid = as.matrix(expand.grid(apply(ref_vox[,1:3], 2, function(l){seq(min(l),max(l)+1e-9,by=grid_grain)})))
  flatgrid = apply(grid, 1, paste0, collapse='')
  flatref = apply(ref_vox[,1:3], 1, paste0, collapse='')
  not_ref_indices = which( (!duplicated(c(flatref, flatgrid)))[(nrow(ref_vox)+1):(nrow(ref_vox)+length(flatgrid))] )
  
  recons_to_notref = get.knnx(recons_vox[,1:3], grid[not_ref_indices,1:3], k=1) # distance from not-ref to closest recons
  
  card_pos = nrow(ref_vox)
  card_neg = length(not_ref_indices)
  
  cat('\nVarying the detection threshold...\n')
  
  fprs=NULL
  tprs=NULL
  rang = seq(0.002, 1, by=0.005)
  pb = txtProgressBar(min=1, max=1+length(rang), style=3)
  for (th_i in seq_along(rang)) {
    th = rang[th_i]
    setTxtProgressBar(pb, th_i)
    
    tpr = sum(recons_to_ref$nn.dist <= th) / card_pos
    fpr = sum(recons_to_notref$nn.dist <= th) / card_neg
    
    tprs = c(tprs, tpr)
    fprs = c(fprs, fpr)
  }
  return(list(th=rang, fpr=fprs, tpr=tprs))
  
}



## ALPHASHAPE BASED APPROACH TO COMPUTE THE VOLUME, BOUNDED ON THE REFERENCE TREE
compute_volume = function(recons, ref, radius = 0.025, do_plot=F) {
  require('alphashape3d')
  require('geometry')
  
  cat('\nComputing the alphashape volume...\n')
  gc()
  pb = txtProgressBar(min=1, max=6, style=3)
  
  setTxtProgressBar(pb, 1)
  recons_pts = t(recons$vb[1:3,])
  
  setTxtProgressBar(pb, 2)
  ref_pts = t(ref$vb[1:3,])
  
  setTxtProgressBar(pb, 3)
  for (c_i in 1:3) {
    to_exclude = which((recons_pts[,c_i] < min(ref_pts[,c_i])) | (recons_pts[,c_i] > max(ref_pts[,c_i])))
    if (length(to_exclude) > 0) {
      recons_pts = recons_pts[-to_exclude, ]
    }
  }
  
  setTxtProgressBar(pb, 4)
  recons_pts=unique(recons_pts)
  as3d = mod_ashape3d(recons_pts, alpha=radius, pert=T)
  if (do_plot) {
    plot.ashape3d(as3d)
  }
  
  setTxtProgressBar(pb, 5)
  true_volume = volume_ashape3d(as3d)
  
  setTxtProgressBar(pb, 6)
  return(list(vol=true_volume, as3d=as3d))
}
