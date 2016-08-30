# source the function that allows to read point clouds
setwd('/media/jean/ntfs/PROJECT_Comparison_Workflow/')
source('gitcode/helpers.R')
source('gitcode/ROC_VOL_analysis.R')

####################
# LOADS THE MODELS #
####################

ref = color.read.ply('~/tmptodelete/mockup_ref.ply', ShowSpecimen = F, addNormals = F)
recons_names = list('CMPMVS final ply.ply',
                    'model.ALIGNED_J_CROPPED.ply',
                    'MVE final ply.ply',
                    'Photoscan highest final ply.ply',
                    'Photoscan high final ply.ply',
                    'Photoscan lowest final ply.ply',
                    'Photoscan low final ply.ply',
                    'Photoscan medium final ply.ply',
                    'SURE final ply_J_REALIGNED_DOWNSCALED_ICP.ply')
recons_names_human = list('CMPMVS',
                    'CMVS/PMVS',
                    'MVE',
                    'Photoscan (highest)',
                    'Photoscan (high)',
                    'Photoscan (lowest)',
                    'Photoscan (low)',
                    'Photoscan (medium)',
                    'SURE')
recons_list = lapply(recons_names, color.read.ply, ShowSpecimen = F, addNormals = F)


##########################
# ROC CURVES COMPUTATION #
##########################

grid_grain = 0.001
grid_grain_filename = sub('\\.', '_', as.character(grid_grain))
grid = readRDS(paste0('/media/jean/ext4/simulation_3D_ref/grid_',grid_grain_filename,'.rds'))
not_ref_indices = readRDS(paste0('/media/jean/ext4/simulation_3D_ref/not_ref_indices_',grid_grain_filename,'.rds'))

# the following computes the ROC curves for all models (time consuming: ~1 hour for 5 models)
recons_fpr_tpr = lapply(recons_list, compute_tpr_fpr_grid2, ref, grid_grain=grid_grain, grid=grid, not_ref_indices=not_ref_indices)

auc = sapply(1:length(recons_fpr_tpr), function(i)sum(diff(recons_fpr_tpr[[i]]$fpr)*recons_fpr_tpr[[i]]$tpr[-1]))
plot_order = order(auc, decreasing = T)

plot(1,1,type='n', xlim=c(0,1), ylim=c(0,1), 
     xlab = expression(paste("False Positive Rate ",italic('  (fraction of points that are not in reference cloud)'))),
     ylab = expression(paste("True Positive Rate ",italic('  (fraction of reference cloud recovered)'))),
     xaxs='i', yaxs='i', las=1)
abline(0,1)
cols = NULL
for (i in 1:length(recons_fpr_tpr)) {
  col = i
  if (col == 9)
    col = 'orange'
  cols = c(cols, col)
  points(c(0,recons_fpr_tpr[[plot_order[i]]]$fpr,1), c(0,recons_fpr_tpr[[plot_order[i]]]$tpr,1), col=col, type='l', lwd=3, lty=i+1, xpd=T)
}
legend('bottomright', fill=cols, unlist(recons_names_human)[plot_order], bty='n')


## ZOOMED VERSION:
plot(1,1,type='n', xlim=c(0,0.4), ylim=c(0.6,1), 
     xlab = expression(paste("False Positive Rate ",italic('  (fraction of points that are not in reference cloud)'))),
     ylab = expression(paste("True Positive Rate ",italic('  (fraction of reference cloud recovered)'))),
     xaxs='i', yaxs='i')
cols = NULL
for (i in 1:length(recons_fpr_tpr)) {
  col = i
  if (col == 9)
    col = 'orange'
  cols = c(cols, col)
  points(c(0,recons_fpr_tpr[[plot_order[i]]]$fpr,1), c(0,recons_fpr_tpr[[plot_order[i]]]$tpr,1), col=col, type='l', lwd=3, lty=i+1)
}
legend('topleft', fill=cols, unlist(recons_names_human)[plot_order], bty='n')


## BARPLOT OF AUC:
barplot(auc[plot_order], cex.names = 0.75, names.arg = c(unlist(lapply(recons_names_human, function(x)sub(' ', '\n', x)))[plot_order]), ylab = 'AUC (area under the curve)', las=1)


saveRDS(recons_fpr_tpr, 'recons_fpr_tpr_001.rds')



## VOLUME COMPUTATION (~15 minutes for 5 models)

alpha = 0.025 # derived so that the trunk is filled (the largest width of the trunk being 0.022)

# the following computes the volume of the alpha shape for all models (time consuming: ~1 hour for 5 models)
recons_ref_volumes = lapply(c(recons_list, list(ref)), compute_volume, ref, radius = alpha)

plot.ashape3d(recons_ref_volumes[[1]]$as3d)

# assuming that the tree (0.7 in virtual world) is 4 meters tall:
scaling_factor = (0.7 * 4)^3
barplot(sapply(recons_ref_volumes, function(r) {r$vol * scaling_factor})[-10], cex.names = 0.75, names.arg = c(unlist(lapply(recons_names_human, function(x)sub(' ', '\n', x)))), ylab = 'Volume (assuming a tree 4 meters tall)', las=1)
abline(recons_ref_volumes[[10]]$vol * scaling_factor, 0, lty=2, lwd=2, col='red')
text(0.5, recons_ref_volumes[[10]]$vol * scaling_factor, 'Reference', col='red', pos = 3,adj=1)

saveRDS(recons_ref_volumes, 'recons_vol_001.rds')
