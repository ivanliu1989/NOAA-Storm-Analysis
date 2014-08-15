## Across the United States, which types of events (as indicated in the EVTYPE variable) are most harmful with respect to population health?
## Across the United States, which types of events have the greatest economic consequences?

## Download datasets and load into R
    setwd(choose.dir())
    data.url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
    data.csv <- "repdata-data-StormData.csv"
    if(!(file.exists(data.csv)))
        download.file(data.url, destfile="repdata-data-StormData.csv")
    library(data.table)
    dir()
    system.time(noaa.data <- read.csv(data.csv,head=T))
    
## Dataset exploration     
    str(noaa.data)
    head(noaa.data,n=3)
    colnames(noaa.data)<-tolower(colnames(noaa.data))

## Subset dataset according to analysis requirement
    index.col <- c(1:2,7:8,21:28)
    noaa.sub <- subset(noaa.data, select=index.col)
    str(noaa.sub)

## Clean the inconsistencies in EVTYPE column
    event.types <- readLines("evtype.txt")
    event.types <- as.factor(tolower(event.types))
    noaa.sub$evtype2 <- as.factor(tolower(noaa.sub$evtype)) ## create new column for testing
    spec_char <- c(" ","/","_",",",":","&","-")
    a <- rep("",length(spec_char))
    event.types.sub <- mapply(gsub,spec_char,a,as.character(event.types))
    # library(qdap)
    # event.types.sub <- mgsub(spec_char,a,as.character(event.types))
    for (i in 1:length(spec_char)){
        print(spec_char[i])
        event.types <- gsub(spec_char[i],"",as.character(event.types),)
        noaa.sub$evtype2 <- gsub(spec_char[i],"",as.character(noaa.sub$evtype2))
    }
    
    for (i in 1:length(event.types)){
        index <- grepl(pattern=event.types[i],x=noaa.sub$evtype2, fixed=F)
        noaa.sub$eventtype[index] <- event.types[i]
    }
    
    
