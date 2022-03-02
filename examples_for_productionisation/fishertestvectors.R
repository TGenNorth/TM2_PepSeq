#takes 2 vectors of the same length: test(eg Cleaved) and control (eg Uncleaved) and returns a vector of that length consisting of -log10Pvalues
#P-values are calculated by a one-tailed Fishers exact test which iterates over every focal position in the vector and asks whether test is enriched over control
#for each focal position, a 2x2 contingency table is generated consisting of focaltest,focalcontrol,sumnonfocaltest,sumnonfocalcontrol
#sumnonfocal is the sum of all nonfocal positions in the indicated vector
#Fishers test requires integers, and this function is to be used with vectors of raw (non-normalized) counts

fishertestvectors = function(test,control){
cont_table=cbind(test,sum(test)-test,control,sum(control)-control)
P=apply(cont_table,1, function(x) fisher.test(matrix(x,nr=2), alternative = "greater")$p.value)
return(-log(P,10))}
