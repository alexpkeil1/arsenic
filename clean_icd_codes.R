icd <- read.csv("/Users/akeil/EpiProjects/MT_copper_smelters/data/icd-8-codes.csv", stringsAsFactors = FALSE, header=FALSE)
names(icd) <- c("code", "description")
icd$order <- 1:length(icd$code)
add = icd$order[icd$code=="519.2"]+.1

#add in COPD (see july 2011 update to LTAS here: http://www.cdc.gov/niosh/LTAS/rates.html)
newobs <- icd[1,]
newobs$code = "519.3"
newobs$order = add
newobs$description = "Chronic obstructive pulmonary disease (US ICD-8 only)"
icd <- rbind(icd, newobs)
icd <- icd[order(icd$order),c("code", "description")]

icd$icdnum <- as.numeric(gsub("E", "", icd$code))
icd$icdchar <- icd$code

icd[!is.na(icd$icdnum),]$icdchar <- gsub("([0-9])([0-9])([0-9])([0-9])", "\\1\\2\\3\\.\\4", sprintf("%04d", icd$icdnum[!is.na(icd$icdnum)]*10))
dup <- (gsub(".0", "", icd$code)==c(gsub(".0", "", icd$code)[-1], '000'))
icd[dup,]$icdchar <- gsub("([0-9])([0-9])([0-9])\\.([0-9])", "(\\1\\2\\3.\\4-\\1\\2\\3.9)", icd$icdchar[dup])
icd[dup,]$icdnum <- NA

#note that this leaves some icd codes that start with E, N, or Y, some of which have overlapping numbers. 
# Epicure (lifetable/regression software) appears to use the E codes, so these were given the numeric verisions in these data.


write.csv(icd[,c(4,3,2)], "/Users/akeil/EpiProjects/MT_copper_smelters/data/icd-8-codes-clean.csv", row.names = FALSE, na = "")
