### Script for plotting EU ETS Historic Carbon Price 
### April 2008 to January 2019
## Chris Rea
## Last Modified: January 13, 2019

###### INSTALL PACKAGES ######

install.packages("dplyr")
install.packages("tidyr")
install.packages("broom")
install.packages("skimr")
install.packages("reshape2")
install.packages("data.table")
install.packages("ggplot2")
install.packages("ggalluvial")
install.packages("ggthemes")
install.packages("ggrepel")
install.packages("directlabels")
install.packages("scales")
install.packages("raster")
install.packages("ggpubr")
install.packages("zoo")
install.packages("tidyquant")

###### LOAD PACKAGES ######

library(dplyr)
library(tidyr)
library(broom)
library(sp)
library(reshape2)
library(data.table)
library(ggplot2)
library(ggalluvial)
library(ggmap)
library(ggthemes)
library(ggrepel)
library(skimr)
library(directlabels)
library(scales)
library(raster)
library(ggpubr)
library(zoo)
library(tidyquant)

###### SET WD ######
setwd("/Users/rea.115/Dropbox/Professional/Research/__Emissions_Trading/EU_ETS_Special_Issue_Culture_Practice_and_Europeanization")

####### LOAD DATA FOR PLOTS ##########

ets_path = "EU_ETS_Auctions_Revenues/EU_ETS_Weekly_price_2008_04_to_2019_01.csv"
ets_price = read.csv(ets_path, header = TRUE)

auctions_path = "EU_ETS_Auctions_Revenues/EU_ETS_Auctions_Revenues_by_2013_to_Jan2019.csv"
auct_rev = read.csv(auctions_path, header = TRUE)

## Format date as a date
ets_price$date_num <- as.Date(ets_price$Date, "%m/%d/%y")
auct_rev$date_num <- as.Date(auct_rev$Date, "%m/%d/%y")

##make "Total.Revenue.eur" a numeric value
auct_rev$total_rev<- as.numeric(auct_rev$Total.Revenue.eur)

## make total revenue in millions
auct_rev$total_rev<-auct_rev$total_rev/1000000

##calculate Total cumlatiove sum of revenues generated over time
auct_rev <- auct_rev %>% 
  arrange(date_num) %>% 
  mutate(cum_rev=cumsum(total_rev))

##calculate cumlatiove sum of revenues by country
auct_rev <- auct_rev %>% 
  arrange(date_num) %>%
  group_by(Country) %>%
  mutate(cum_rev_cntry=cumsum(total_rev))


#change cum rev to billions
auct_rev$cum_rev <- auct_rev$cum_rev/1000
auct_rev$cum_rev_cntry <- auct_rev$cum_rev_cntry/1000

#make dummy "Eur" variable
auct_rev$Eur <- "All of EU"


### make revenue dataframe dropping XA, XF,CZ, HU, LT, NL amounts
auct_rev_cln <-  auct_rev[auct_rev$Country!="XA"&
                            auct_rev$Country!="XF"&
                            auct_rev$Country!="CZ"&
                            auct_rev$Country!="HU"&
                            auct_rev$Country!="LT"&
                            auct_rev$Country!="NL", ]

## make dataframe dropping Poland
auct_rev_noPL <- auct_rev_cln[auct_rev_cln$Country!="PL", ]


###### SAVE FUNCTION ######

# Save plot (function)
save_plot <- function(root,addon,w,h,path){
  ggsave(paste(root,addon,".png",
               sep = ""), plot = last_plot(), path = path,
         width = w, height = h, units = "in", dpi = 380,
         limitsize = FALSE)
}


##### PLOT EUA PRICE ######
ggplot(ets_price,
       aes(x = date_num,
           y = Price #pct_max_norm
       ))+
  geom_line() +
  geom_vline(xintercept = as.Date("2012-12-31"),
             linetype = 2, colour = "#8E8E8E") +
  annotate("text", x = as.Date("2012-10-01"),
           y = 27.80, angle = 90,
           label = "Phase II",
           colour = "#8E8E8E") +
  annotate("text", x = as.Date("2013-04-01"),
           y = 27.95, angle = 90,
           label = "Phase III",
           colour = "#8E8E8E") +
  scale_x_date(labels = date_format("%b %Y"),
               date_breaks = "3 month") +
  scale_y_continuous(name = "Price in €/tCO2",
                     breaks=seq(-5,30,5)) +
  #  scale_colour_manual(name = "State (Land)", 
  #                      breaks = breaks_env,
  #                      values = fill_env) +
  #scale_y_log10() + 
  theme(panel.background = element_blank(),
        #axis.ticks = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5), #x-axis lables blank
        #axis.text.y = element_blank(), #y-axis lables blank
        panel.grid.major.y = element_line(colour = "#d3d3d3",
                                          size = 0.2),
        panel.grid.minor.y = element_line(colour = "#d3d3d3"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.title = element_blank(),#no legend title
        legend.text=element_text(size=8)) +
  coord_x_date(xlim=c("2008-04-01",
                      "2019-01-14"),
               ylim=c(-0.5,31),
               expand = FALSE)

save_plot("EU_ETS_EUA_Price",
          "2008_04_01_to_2019_01_14",
          12,5,"Figures")





##### Make Plot of PER AUCTION REVENUE ######
per_auction <- ggplot(auct_rev_noPL,
                      aes(x = date_num,
                          y = total_rev, #pct_max_norm,
                          group = Country,
                          colour = Country
                      ))+
  geom_line() +
  geom_vline(xintercept = as.Date("2012-12-31"),
             linetype = 2, colour = "#8E8E8E") +
  annotate("text", x = as.Date("2012-10-01"),
           y = 100, angle = 90,
           label = "Phase II",
           colour = "#8E8E8E") +
  annotate("text", x = as.Date("2013-04-01"),
           y = 100, angle = 90,
           label = "Phase III",
           colour = "#8E8E8E") +
  scale_x_date(labels = date_format("%b %Y"),
               date_breaks = "3 month") +
  scale_y_continuous(name = "Revenue per Auction\n(millions of €)",
                     breaks=seq(0,120,10)) +
  #  scale_colour_manual(name = "State (Land)", 
  #                      breaks = breaks_env,
  #                      values = fill_env) +
  #scale_y_log10() + 
  theme(panel.background = element_blank(),
        #axis.ticks = element_blank(),
        axis.title.x=element_blank(),
        #axis.text.x =element_blank(), #x-axis lables BLANK
        axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5), #x-axis lables
        #axis.text.y = element_blank(), #y-axis lables blank
        panel.grid.major.y = element_line(colour = "#d3d3d3",
                                          size = 0.2),
        panel.grid.minor.y = element_line(colour = "#d3d3d3"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.title = element_blank(),#no legend title
        legend.position="right",
        legend.text=element_text(size=8)) +
  coord_x_date(xlim=c("2012-06-01",
                      "2019-01-20"),
               ylim=c(-1,120),
               expand = FALSE)

per_auction




##### Make Plot of CUM AUCTION REVENUE ######
total_rev <- ggplot(auct_rev_noPL,
                    aes(x = date_num,
                        y = cum_rev_cntry, #pct_max_norm
                        group = Country,
                        colour = Country
                    ))+
  geom_line() +
  geom_line(data = auct_rev,
            inherit.aes = FALSE,
            show.legend = FALSE,
            aes(x = date_num,
                y = cum_rev,
                group = Eur,
                colour = Eur)) +
  geom_vline(xintercept = as.Date("2012-12-31"),
             linetype = 2, colour = "#8E8E8E") +
  annotate("text", x = as.Date("2012-10-01"),
           y = 27.5, angle = 90,
           label = "Phase II",
           colour = "#8E8E8E") +
  annotate("text", x = as.Date("2013-04-01"),
           y = 27.5, angle = 90,
           label = "Phase III",
           colour = "#8E8E8E") +
  scale_x_date(labels = date_format("%b %Y"),
               date_breaks = "3 month") +
  scale_y_continuous(name = "Cumulative Revenue\n(billions of €)",
                     breaks=seq(0,35,5)) +
  scale_colour_manual(values =c("#000000","#F8766D","#00BFC4")) +
  #scale_y_log10() + 
  theme(panel.background = element_blank(),
        #axis.ticks = element_blank(),
        axis.title.x=element_blank(),
        axis.text.x = element_text(angle = 90,
                                   hjust = 1,
                                   vjust = 0.5), #x-axis lables blank
        #axis.text.y = element_blank(), #y-axis lables blank
        panel.grid.major.y = element_line(colour = "#d3d3d3",
                                          size = 0.2),
        panel.grid.minor.y = element_line(colour = "#d3d3d3"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(),
        legend.title = element_blank(),#no legend title
        legend.position="right",
        legend.text=element_text(size=8)) +
  coord_x_date(xlim=c("2012-06-01",
                      "2019-01-20"),
               ylim=c(-1,35),
               expand = FALSE)

total_rev


# arrange plots
ggarrange(per_auction, total_rev,
          ncol = 1, nrow = 2,
          labels = c("A","B"),
          align = "v")

save_plot("EU_ETS_per_auction_and_cum_rev",
          "2012_06_01_to_2019_01_20",
          13,13,"Figures")

