## Across the United States, which types of events (as indicated in the EVTYPE variable) are most harmful with respect to population health?
## Across the United States, which types of events have the greatest economic consequences?

## Download datasets and load into R
    setwd("C:/Documents and Settings/Macro/Desktop/Ivandata/NOAA-Storm-Analysis")
    data.url <- "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
    data.csv <- "repdata-data-StormData.csv"
    if(!(file.exists(data.zip)))
        download.file(data.url, destfile="repdata-data-StormData.csv")
    noaa.data <- read.csv(data.csv,head=T)

## Dataset exploration     