library(RCurl)

# In github, open the function and open the 'raw' version of the script. Copy this url and paste in the getURL function of RCurl. 
# here is an example for the function "export.R" stored in the function list. 
script <- getURL("https://raw.githubusercontent.com/Cagnacci-Lab/SCRIPTS/master/Analysis/Functions/export.R", ssl.verifypeer= FALSE)
eval(parse(text = script))

# and here for the function "opendir.R"
script <- getURL("https://raw.githubusercontent.com/Cagnacci-Lab/SCRIPTS/master/Analysis/Functions/opendir.R", ssl.verifypeer= FALSE)
eval(parse(text = script))
