args = commandArgs(trailingOnly=TRUE)
print(args)
if (length(args)<1) {
    version = 0
} else { 
    version = as.integer(args[1]) 
}
print (version)
