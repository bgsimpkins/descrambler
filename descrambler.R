list.of.packages <- c("lexicon", "gtools","stringi", "jsonlite")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages,repos="http://cran.r-project.org")

require(lexicon)
require(gtools)
require(stringi)
require(jsonlite)

testing <- FALSE

scrambleWord <- function(word)
{
  scramble <- word
  
  ##Make sure we don't end up with the same word
  while (scramble == word) {
    letterVec <- unlist(strsplit(word,""))
    lvRand <- sample(letterVec)
    scramble <- paste(lvRand,collapse="")
  }
  return(scramble)
}


sortLetters <- function(word)
{
  letterVec <- unlist(strsplit(word,""))
  lvSorted <- sort(letterVec)
  paste(lvSorted,collapse="")
}

sortGradyAug <- function(grady_augmented)
{
  res <- sapply(grady_augmented,function(x)
  {
    sortLetters(x)
  })
  
  return(unlist(res))
}

sortGradyAugRegex <- function(grady_augmented)
{
  res <- sapply(grady_augmented,function(x)
  {
    letterVec <- unlist(strsplit(x,""))
    lvSorted <- sort(letterVec)
    paste(lvSorted,collapse="[a-z]*?")
  })
  
  return(unlist(res))
}

dictionaryLookup <- function(word)
{
  res <- NULL
  sel <- which(grady_augmented==tolower(word))
  if (length(sel) > 0)
    return(grady_augmented[sel])
}

findMatches <- function(scramble)
{
  ##Break word into a vector of letters
  letterVec <- unlist(strsplit(scramble,""))
  idVec <- 1:length(letterVec)
  
  ##n! (where n is the number of letters) is number of possible combinations
  nCombs <- factorial(length(letterVec))
  print(paste("Number of combinations=",nCombs))
  
  ##Use gtools to get all possible combinations
  combs <- permutations(n=length(letterVec),r=length(letterVec),v=idVec)
  
  ##Paste letters back together to make words
  pasteWord <- function(x) 
  {
    lVec <- letterVec[x]
    paste(lVec,collapse="")
  }
  combs <- apply(combs,1,pasteWord)
  
  res <- unlist(sapply(combs,function(comb){
    dictionaryLookup(comb)
  }))
  return(unique(res))
  
}

##WAY FASTER!!
findMatches2 <- function(scramble, dictSorted)
{
  ##Sort letters of scramble (A-Z)
  scrSorted <- sortLetters(tolower(scramble))
  
  ##Lookup sorted word in sorted dictionary
  sel <- which(scrSorted == dictSorted)
  
  if (length(sel) > 0)
  {
    return(names(dictSorted[sel]))
  }
  
}

findAllMatches <- function(scramble, dictSortedRegex,minNumLetters=2)
{
  scrSorted <- sortLetters(tolower(scramble))
  sel <-which(stri_detect_regex(scrSorted,dictSortedRegex))
  matches <- names(dictSortedRegex[sel])
  return(matches[ nchar(matches) >= minNumLetters])
}

allMatchesWrapper <- function(scramble,id,dict)
{
  dictSortedRegex <- sortGradyAugRegex(dict)
  m <- findAllMatches(scramble,dictSortedRegex)
  
  df <- data.frame(word=m,numLetters=nchar(m))
  df <- df[order(df$numLetters,decreasing=T),] 
  #writeLines(df$word,"descrambleResults.txt")
  writeLines(toJSON(df),paste("descrambleResults_",id,".txt",sep=""))
}

#################################################RUN
st <- which(commandArgs()=="--args")

if (st && length(commandArgs()) > st)
{
  args <- commandArgs()[ (st+1):length(commandArgs())]
  print("Command args")
  print(args)
  print("_________________")
  
  scramble <- ""
  paramPos <- grep("--scramble",args)
  if (length(paramPos) > 0 && length(args) > paramPos)
  {
    scramble <- args[paramPos+1]
    print(paste("Scramble problem=",scramble,sep=""))
  }else
  {
    error("No scramble word provided!!")
  }
  paramPos <- grep("--id",args)
  if (length(paramPos) > 0 && length(args) > paramPos)
  {
    id <- args[paramPos+1]
    print(paste("Id=",id,sep=""))
  }else
  {
    error("No id provided!!")
  }
}else{
  print("You're not very good at this. You could try again...")
}


#########################
###########################TEST

if (testing)
{
  ##Sort letters of all words in dictionary (A-Z)
  scramble <- scrambleWord("peesh")
  print(paste("Scramble problem=",scramble))
  #########################################################
  ##Test first match algorithm
  print("Testing first algorithm.....")
  startTime <- Sys.time()
  res <- findMatches(scramble)
  print("Matches:")
  print(res)
  stopTime <- Sys.time()
  print(stopTime - startTime)
  
  ##########################################################
  ##Test second match algorithm
  print("Testing second algorithm.....")
  dictSorted <- sortGradyAug(grady_augmented)
  startTime <- Sys.time()
  res <- findMatches2(scramble,dictSorted)
  print("Matches:")
  print(res)
  stopTime <- Sys.time()
  print(stopTime - startTime)

}else{
  
  print("Running descrambler (all possibilies with word length down to two)...")
  allMatchesWrapper(scramble,id,grady_augmented)
  print(paste("Scramble results in file ",getwd(),"/descrambleResults_",id,".txt",sep=""))
  
  
  #####Run single-word match (only works with interactive)
  # 
  # print("Loading dictionary...")
  # dictSorted <- sortGradyAug()
  # 
  # scramble <- readline("Enter the word to unscramble:")
  # startTime <- Sys.time()
  # res <- findMatches2(scramble,dictSorted)
  # print("Matches:")
  # print(res)
  # stopTime <- Sys.time()
  # print(stopTime - startTime)
  # 
}
