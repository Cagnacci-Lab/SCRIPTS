# Load functions from github

In github, open the function and open the 'raw' version of the script. Copy this url and paste in the getURL function of RCurl. 
Here is an example for the functions "export.R" and "opendir.R" stored in the function list. 

**Load functions from github**  

```R
library(RCurl)
script <- getURL("https://raw.githubusercontent.com/Cagnacci-Lab/SCRIPTS/master/Analysis/Functions/export.R", ssl.verifypeer= FALSE)
eval(parse(text = script))
script <- getURL("https://raw.githubusercontent.com/Cagnacci-Lab/SCRIPTS/master/Analysis/Functions/opendir.R", ssl.verifypeer= FALSE)
eval(parse(text = script))
```
