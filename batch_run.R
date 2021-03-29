print ("Batch Job pentru BAR CFR")

for (i in 1:8) {

print ("**********")
fetch_command <- paste0('RScript CFR_BAR_extract.r ',i)
print (fetch_command)
system(fetch_command)

fetch_command <- paste0('mv bar.doc bar',i,'.doc')
print (fetch_command)
system(fetch_command)

fetch_command <- paste0('mv bar_extras.json bar_extras',i,'.json')
print (fetch_command)
system(fetch_command)

fetch_command <- paste0('mv bar_extras.csv bar_extras',i,'.csv')
print (fetch_command)
system(fetch_command)

}

print("********")
print("* Done *")
print("********")