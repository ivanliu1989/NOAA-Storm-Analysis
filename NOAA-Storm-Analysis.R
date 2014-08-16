## Across the United States, which types of events (as indicated in the EVTYPE variable) are most harmful with respect to population health (fatalities + injuries)?
## Across the United States, which types of events have the greatest economic consequences (cropdmg + propdmg)?

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
    # first step subsetting
    index.col <- c(1:2,7:8,21:28)
    noaa.sub <- subset(noaa.data, select=index.col)
    # calculate economic damage and health damage
    noaa.sub$healthdmg <- noaa.sub$fatalities + noaa.sub$injuries
    noaa.sub$cropmul[tolower(noaa.sub$cropdmgexp)=="k"]<-1000
    noaa.sub$cropmul[tolower(noaa.sub$cropdmgexp)=="m"]<-1000000
    noaa.sub$cropmul[is.na(noaa.sub$cropmul)] <- 1
    noaa.sub$propmul[tolower(noaa.sub$propdmgexp)=="k"]<-1000
    noaa.sub$propmul[tolower(noaa.sub$propdmgexp)=="m"]<-1000000
    noaa.sub$propmul[is.na(noaa.sub$propmul)] <- 1
    noaa.sub$cropdmg <- noaa.sub$cropdmg * noaa.sub$cropmul
    noaa.sub$propdmg <- noaa.sub$propdmg * noaa.sub$propmul
    noaa.sub$ecodmg <- noaa.sub$cropdmg + noaa.sub$propdmg
    # second step subsetting
    noaa.sub <- noaa.sub[,-c(1:3,5,6,10,12,14,15)]
    
## Clean the inconsistencies in EVTYPE column
    event.types <- readLines("evtype.txt")
    event.types <- as.factor(tolower(event.types))
    noaa.sub$evtype2 <- as.factor(tolower(noaa.sub$evtype)) ## create new column for testing
    spec_char <- c(" ","/","_",",",":","&","-")
    # a <- rep("",length(spec_char))
    # event.types.sub <- mapply(gsub,spec_char,a,as.character(event.types))
    # library(qdap)
    # event.types.sub <- mgsub(spec_char,a,as.character(event.types))  
    for (i in 1:length(spec_char)){
        print(spec_char[i])
        event.types <- gsub(spec_char[i],"",as.character(event.types))
        noaa.sub$evtype2 <- gsub(spec_char[i],"",as.character(noaa.sub$evtype2))
    }
    
    ## Matching event types based on event.types
    for (i in 1:length(event.types)){
        index <- grepl(pattern=event.types[i],x=noaa.sub$evtype2, fixed=F)
        noaa.sub$eventtype[index] <- event.types[i]
    }
    ## First aggregate to make datasets smaller for the efficiency of following cleansing steps
    noaa.sub$eventtype[is.na(noaa.sub$eventtype)] <- noaa.sub$evtype2[is.na(noaa.sub$eventtype)]
    library(plyr)
    noaa.agg <- ddply(noaa.sub, .(eventtype), summarize, propdmg=sum(propdmg),cropdmg=sum(cropdmg),
                      fatalities=sum(fatalities),injuries=sum(injuries),healthdmg=sum(healthdmg),
                      ecodmg=sum(ecodmg))
    noaa.agg$sum <- noaa.agg[,6]+noaa.agg[,7]
    noaa.agg <- noaa.agg[!(noaa.agg$sum==0),]
    noaa.agg <- noaa.agg[,-8]
    ## Mannual data cleansing
    adj <- matrix(c("tstm","thunderstormwind","thunder","thunderstormwind",
                    "thuder","thunderstormwind","avalan","avalanche",
                    "astronomical","astronomicallowtide","fog","freezingfog",
                    "hurricane","hurricane(typhoon)","cold","coldwindchill",
                    "torndao","tornado","thunerstormwinds","thunderstormwind",
                    "thundeerstormwinds","thunderstormwind",
                    "freeze","frost/freeze"), ncol=2,byrow = T)
    for (i in 1:length(adj[,1])){
        for (j in 1:length(noaa.agg$eventtype)){
            if(grepl(adj[i,1],noaa.agg$eventtype[j],fixed=F))
                noaa.agg$eventtype[j] <- adj[i,2]
        }
    }
    noaa.agg <- ddply(noaa.agg, .(eventtype), summarize, propdmg=sum(propdmg),cropdmg=sum(cropdmg),
                      fatalities=sum(fatalities),injuries=sum(injuries),healthdmg=sum(healthdmg),
                      ecodmg=sum(ecodmg))
## Sort and subset datasets for different analysis
    noaa.health <- noaa.agg[,-c(2,3,7)]
    noaa.eco <- noaa.agg[,-c(4,5,6)]
    noaa.health <- head(arrange(noaa.health,desc(healthdmg)),n=10)
    noaa.eco <- head(arrange(noaa.eco,desc(ecodmg)),n=10)
    
## Plots health
    library(ggplot2)
    g1 <- ggplot(noaa.health,aes(x=eventtype, y=fatalities))
    g1 + geom_bar(stat="identity", fill="red",alpha=1, colour="black",) + 
        labs(x="Health damage") + labs(y="Event types") + 
        labs(title=paste("Most Harmful Events to Population Health", "(Top 10)", sep="\n"))+
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
        geom_bar(aes(x=eventtype, y=injuries),stat="identity",fill="red",alpha=0.3, colour="black") +
        geom_bar(aes(x=eventtype, y=healthdmg),stat="identity",fill="red",alpha=0.3, colour="black")
    
## Plots Economy
    g2 <- ggplot(noaa.eco,aes(x=eventtype, y=propdmg))
    g2 + geom_bar(stat="identity", fill="black",alpha=0.5, colour="black",) + 
        labs(x="Health damage") + labs(y="Event types") + 
        labs(title=paste("Most Harmful Events to Economy", "(Top 10)", sep="\n"))+
        theme(axis.text.x = element_text(angle = 90, hjust = 1)) + 
        geom_bar(aes(x=eventtype, y=cropdmg),stat="identity",fill="blue",alpha=0.5, colour="black") +
        geom_bar(aes(x=eventtype, y=ecodmg),stat="identity",fill="blue",alpha=0.5, colour="black")    
    
    
