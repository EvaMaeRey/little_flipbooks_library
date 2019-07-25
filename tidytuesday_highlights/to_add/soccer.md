---
title: "wwc"
author: "Ifeoma Egbogah"
date: "7/17/2019"
output: 
  html_document: 
    keep_md: yes
editor_options: 
  chunk_output_type: console
---





```r
library(tidyverse)
```

```
## ── Attaching packages ──────────────────────────────────────────────────── tidyverse 1.2.1 ──
```

```
## ✔ ggplot2 3.2.0     ✔ purrr   0.3.2
## ✔ tibble  2.1.3     ✔ dplyr   0.7.8
## ✔ tidyr   0.8.2     ✔ stringr 1.4.0
## ✔ readr   1.1.1     ✔ forcats 0.3.0
```

```
## Warning: package 'ggplot2' was built under R version 3.5.2
```

```
## Warning: package 'tibble' was built under R version 3.5.2
```

```
## Warning: package 'purrr' was built under R version 3.5.2
```

```
## Warning: package 'stringr' was built under R version 3.5.2
```

```
## ── Conflicts ─────────────────────────────────────────────────────── tidyverse_conflicts() ──
## ✖ dplyr::filter() masks stats::filter()
## ✖ dplyr::lag()    masks stats::lag()
```

```r
library(circlize)
```

```
## Warning: package 'circlize' was built under R version 3.5.2
```

```
## ========================================
## circlize version 0.4.6
## CRAN page: https://cran.r-project.org/package=circlize
## Github page: https://github.com/jokergoo/circlize
## Documentation: http://jokergoo.github.io/circlize_book/book/
## 
## If you use it in published research, please cite:
## Gu, Z. circlize implements and enhances circular visualization 
##   in R. Bioinformatics 2014.
## ========================================
```

```r
library(ggrepel)
library(broom)
library(countrycode)

wwc_outcomes <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-09/wwc_outcomes.csv")
```

```
## Parsed with column specification:
## cols(
##   year = col_integer(),
##   team = col_character(),
##   score = col_integer(),
##   round = col_character(),
##   yearly_game_id = col_integer(),
##   team_num = col_integer(),
##   win_status = col_character()
## )
```

```r
squads <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-09/squads.csv")
```

```
## Parsed with column specification:
## cols(
##   squad_no = col_integer(),
##   country = col_character(),
##   pos = col_character(),
##   player = col_character(),
##   dob = col_datetime(format = ""),
##   age = col_integer(),
##   caps = col_integer(),
##   goals = col_integer(),
##   club = col_character()
## )
```

```r
codes <- readr::read_csv("https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2019/2019-07-09/codes.csv")
```

```
## Parsed with column specification:
## cols(
##   country = col_character(),
##   team = col_character()
## )
```



```r
theme_set(theme_light())


MF_age <- squads%>%
  group_by(pos)%>%
  filter(pos == "MF", age >= 35)
```

```
## Warning: The `printer` argument is deprecated as of rlang 0.3.0.
## This warning is displayed once per session.
```

```r
age_boxplot<- squads%>%
  ggplot(aes(fct_reorder(pos, age), age))+
  geom_boxplot()+
  expand_limits(y = 0)+
  geom_label_repel(data = MF_age, aes(label = player))+
  theme(plot.subtitle = element_text(size = 10,
                                 color = "#939184",
                                 margin = margin(b = 0.1,
                                                 t = -0.1,
                                                 l = 2,
                                                 unit = "cm"),
                                 face = "bold"),
      
        
        plot.caption = element_text(size = 7,
                                hjust = .5,
                                margin = margin(t = 0.2,
                                                b = 0,
                                                unit = "cm"),
                                color = "#939184"))+
  
  labs(x = "Players Position",
       y = "Age of Players",
       title = "Age Distribution Of Players at the Women's World Cup",
       subtitle = "France 2019, Women's World Cup",
       caption = "Source: Data.World | Visualization: Ifeoma Egbogah")
  

goals_wwc<- squads%>%
  ggplot(aes(caps, goals, colour = pos))+
  geom_point()+
  scale_colour_viridis_d(option = "B")+
  geom_smooth(method = lm)+
  facet_wrap(~pos)+
  theme(plot.subtitle = element_text(size = 10,
                                 color = "#939184",
                                 margin = margin(b = 0.1,
                                                 t = -0.1,
                                                 l = 2,
                                                 unit = "cm"),
                                 face = "bold"),
      
        
        plot.caption = element_text(size = 7,
                                hjust = .5,
                                margin = margin(t = 0.2,
                                                b = 0,
                                                unit = "cm"),
                                color = "#939184"))+
  
  labs(x = "Caps",
       y = "Goals",
       title = "Relationship Between Goals and Caps",
       subtitle = "For ladies who featured in the 2019 FIFA women's world cup based on players positon on the field",
       caption = "Source: data.world | Visualization: Ifeoma Egbogah")


model <- squads%>%
  lm(goals ~ pos + caps + age, data = .)

est <- model%>%
  tidy(conf.int = TRUE)%>%
  filter(term != "(Intercept)")%>%
  mutate(term = str_replace(term, "posFW", "Forward"),
         term = str_replace(term, "posMF", "Midfielder"),
         term = str_replace(term, "posGK", "Goal Keeper/Goalie"),
         term = str_replace(term, "caps", "Caps"),
         term = str_replace(term, "age", "Age"),
         term = fct_reorder(term, estimate))%>%
  ggplot(aes(estimate, term))+
  geom_point(show.legend = FALSE)+
  geom_errorbarh(aes(xmin = conf.low, xmax = conf.high), show.legend = FALSE)+
  geom_vline(xintercept = 0, col = "red")+
  theme(plot.subtitle = element_text(size = 10,
                                 color = "#939184",
                                 margin = margin(b = 0.1,
                                                 t = -0.1,
                                                 l = 2,
                                                 unit = "cm"),
                                 face = "bold"),
      
        
        plot.caption = element_text(size = 7,
                                hjust = .5,
                                margin = margin(t = 0.2,
                                                b = 0,
                                                unit = "cm"),
                                color = "#939184"))+
  
  labs(x = "Coefficent Estimate",
       y = "Term",
       title = "Coefficent Estimated Effect On Goals",
       subtitle = "Based on players position, caps and age",
       caption = "Source: data.world | Visualization: Ifeoma Egbogah")
  

age_boxplot
```

![](soccer_files/figure-html/unnamed-chunk-2-1.png)<!-- -->

```r
goals_wwc
```

```
## Warning: Removed 32 rows containing non-finite values (stat_smooth).
```

```
## Warning: Removed 32 rows containing missing values (geom_point).
```

![](soccer_files/figure-html/unnamed-chunk-2-2.png)<!-- -->

```r
est
```

![](soccer_files/figure-html/unnamed-chunk-2-3.png)<!-- -->

```r
#ggsave("C:/Users/Egbogah/Desktop/wwc_boxplot.png", age_boxplot, width = 8, height = 8)
#ggsave("C:/Users/Egbogah/Desktop/goal_wwc.png", goals_wwc, width = 8, height = 8)
#ggsave("C:/Users/Egbogah/Desktop/est.png", est, width = 8, height = 8)
```


#Circlize plot of countries participating in the FIFA Women's World Cup 2019

```r
wwc_2019 <- wwc_outcomes%>%
  filter(year == "2019")

wwc_2019 <- wwc_2019%>%
  mutate(stage = case_when(round == "Group" & team == "FRA" ~ "Group A",
                          round == "Group" & team == "KOR" ~ "Group A",
                          round == "Group" & team == "NGA" ~ "Group A",
                          round == "Group" & team == "NOR" ~ "Group A",
                          round == "Group" & team == "GER" ~ "Group B",
                          round == "Group" & team == "CHN" ~ "Group B",
                          round == "Group" & team == "ESP" ~ "Group B",
                          round == "Group" &  team== "RSA" ~ "Group B",
                          round == "Group" &  team== "ITA" ~ "Group C",
                          round == "Group" &  team== "AUS" ~ "Group C",
                          round == "Group" &  team== "BRA" ~ "Group C",
                          round == "Group" &  team== "JAM" ~ "Group C",
                          round == "Group" &  team== "ENG" ~ "Group D",
                          round == "Group" &  team== "JPN" ~ "Group D",
                          round == "Group" &  team== "ARG" ~ "Group D",
                          round == "Group" &  team== "SCO" ~ "Group D",
                          round == "Group" &  team== "CAN" ~ "Group E",
                          round == "Group" &  team== "CMR" ~ "Group E",
                          round == "Group" &  team== "NZL" ~ "Group E",
                          round == "Group" &  team== "NED" ~ "Group E",
                          round == "Group" &  team== "USA" ~ "Group F",
                          round == "Group" &  team== "SWE" ~ "Group F",
                          round == "Group" &  team== "THA" ~ "Group F",
                          round == "Group" &  team== "CHI" ~ "Group F"),
         stage = coalesce(stage, round))

group <- wwc_2019%>%
  filter(round == "Group")


circos.clear()
circos.par(start.degree = 30, gap.degree = 4)
circos.initialize(factors = group$stage, xlim = c(0, 10))

#First Group Stage track
circos.trackPlotRegion(factors= group$stage, ylim = c(0, 6), track.height = 0.2,
                       panel.fun = function(x, y){
                       circos.text(x = seq(2, 8, 2), 
                                   y = 1,
                                   labels = c(" ", " ", " ", " "),
                                   facing = "clockwise",
                                   niceFacing = TRUE,
                                   adj = 0.6,
                                   cex = 0.9
                                   )})

circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group A",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("FRA", "NOR", "NGA", "KOR"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.2,
                cex = 0.82))

circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group F",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("USA", "SWE", "CHI", "THA"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.2,
                cex = 0.82))

circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group B",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("GER", "ESP", "CHN", "RSA"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.2,
                cex = 0.82))

circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group C",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("ITA", "AUS", "BRA", "JAM"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.2,
                cex = 0.82))

circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group D",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("ENG", "JPN", "ARG", "SCO"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.2,
                cex = 0.82))


circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group E",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("NED", "CAN", "CMR", "NZL"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.2,
                cex = 0.82))




#Group of 16 track
circos.trackPlotRegion(factors= group$stage, ylim = c(0, 2),track.height = 0.2,
                       panel.fun = function(x, y){
                       circos.text(x = seq(2, 8, 2), 
                                   y = 1,
                                   labels = c(" ", " ", " "),
                                   facing = "clockwise",
                                   niceFacing = TRUE,
                                   adj = 0.5,
                                   cex = 0.9
                                   )})


circos.update(track.index = 2, bg.border = "black",
              sector.index = "Group A",
              circos.text(x = seq(2, 6, 2), 
                          y = 1,
                labels = c("FRA", "NOR", "NGA"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 2, bg.border = "black",
              sector.index = "Group F",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("USA", "SWE"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 2, bg.border = "black",
              sector.index = "Group B",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("GER", "ESP", "CHN"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 2, bg.border = "black",
              sector.index = "Group C",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("ITA", "AUS", "BRA"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 2, bg.border = "black",
              sector.index = "Group D",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("ENG", "JPN"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))


circos.update(track.index = 2, bg.border = "black",
              sector.index = "Group E",
              circos.text(x = seq(2, 8, 2), 
                          y = 1,
                labels = c("NED", "CAN", "CMR"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))




#Quaterfinals track
circos.trackPlotRegion(factors= group$stage, ylim = c(0, 2), track.height = 0.2,
                       panel.fun = function(x, y){
                       circos.text(x = seq(2, 8, 2), 
                                   y = 1,
                                   labels = c(" ", " ", " "),
                                   facing = "clockwise",
                                   niceFacing = TRUE,
                                   adj = 0.5,
                                   cex = 0.9
                                   )})


circos.update(track.index = 3, bg.border = "black",
              sector.index = "Group A",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("FRA", "NOR"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 3, bg.border = "black",
              sector.index = "Group F",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("USA", "SWE"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 3, bg.border = "black",
              sector.index = "Group B",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("GER"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 3, bg.border = "black",
              sector.index = "Group C",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("ITA"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))

circos.update(track.index = 3, bg.border = "black",
              sector.index = "Group D",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("ENG"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))


circos.update(track.index = 3, bg.border = "black",
              sector.index = "Group E",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("NED"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))


#Colour
#red
highlight.sector(group$stage[3],
                 border = NA, 
                 col = NA,
                 text = group$stage[3],
                 facing = "bending.inside",
                 niceFacing = TRUE,
                 text.vjust = "20mm",
                 cex = 1.03)

highlight.sector(group$stage[9],
                 border = NA,
                 col = NA,
                 text = group$stage[9],
                 facing = "bending.inside",
                 niceFacing = TRUE,
                 text.vjust = "20mm",
                 cex = 1.03)

highlight.sector(sector.index = c(group$stage[3], group$stage[9]), #peach
                 col = "#FF000080")


#white
highlight.sector(group$stage[1],
                 border = NA,
                 col = NA,
                 text = group$stage[1],
                 facing = "bending.inside",
                 niceFacing = TRUE,
                 text.vjust = "20mm",
                 cex = 1.03)



highlight.sector(group$stage[13],
                 border = NA, 
                 col = NA,
                 text = group$stage[13],
                 facing = "bending.inside",
                 niceFacing = TRUE,
                 text.vjust = "20mm",
                 cex = 1.03)


#blue
highlight.sector(group$stage[17],
                 col = NA,
                 text = group$stage[17],
                 facing = "bending.inside",
                 niceFacing = TRUE,
                 text.vjust = "20mm",
                 cex = 1.03)

highlight.sector(group$stage[21],
                 col = NA,
                 text = group$stage[21],
                 facing = "bending.inside",
                 niceFacing = TRUE,
                 text.vjust = "20mm",
                 cex = 1.03)

highlight.sector(sector.index= c(group$stage[17], group$stage[21]), 
                 col = "#0000FF40")


#Semifinals track
circos.clear()
par(new = TRUE)

factors = paste("Group", sep = " ", LETTERS[4:6])
circos.par(canvas.xlim = c(-3, 3), canvas.ylim = c(-3, 3), gap.degree = 4)
circos.initialize(factors = factors, xlim = c(0, 10))
circos.track(ylim = c(0, 2), track.height = 0.49, panel.fun = function(x, y){
  circos.text(x = seq(0, 10, 2),
              y = 1,
              labels = c(" ", " ", " "),
              facing = "clockwise",
              niceFacing = TRUE,
              adj = 0.5)
  
})


circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group F",
              circos.text(x = seq(4, 8, 2), 
                          y = 1,
                labels = c("USA", "SWE"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))


circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group D",
              circos.text(x = seq(6, 10, 2), 
                          y = 1,
                labels = c("ENG"),
                           facing = "clockwise", 
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))


circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group E",
              circos.text(x = seq(6, 10, 2), 
                          y = 1,
                labels = c("NED"),
                           facing = "clockwise",
                           niceFacing = TRUE,
                           adj = 0.5,
                cex = 0.82))



#Finals
circos.clear()
par(new = TRUE)
factors1 = paste("Group", sep = " ", LETTERS[5:6])
circos.par(canvas.xlim = c(-6.4, 6.4), canvas.ylim = c(-6.4, 6.4), gap.degree = 4)
circos.initialize(factors = factors1, xlim = c(0, 2))
circos.track(ylim = c(0, 1), track.height = 0.5,
             panel.fun = function(x, y) {
               circos.text(x = c(0, 2),
                           y= 1,
                           labels = " ",
                           facing = "bending",
                           niceFacing = TRUE,
                           adj = 0.5)
             })


circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group E",
              circos.text(x = 1, 
                          y = 1,
                labels = c("NED"),
                           facing = "bending",
                           niceFacing = TRUE,
                           adj = 1,
                cex = 0.82))


circos.update(track.index = 1, bg.border = "black",
              sector.index = "Group F",
              circos.text(x = 1, 
                          y = 1,
                labels = c("USA"),
                           facing = "bending",
                           niceFacing = TRUE,
                           adj = 1,
                cex = 0.82))

#winner
text(0,0, "USA", cex = 0.82)
text(8.2, -6.8, cex= 0.6, "Source: data.world | Visualization: Ifeoma Egbogah")
title("2019 FIFA Women's World Cup")
```

![](soccer_files/figure-html/unnamed-chunk-3-1.png)<!-- -->


#Number of games played, won, lost, and tied since featuring in the world cup

```r
wwc_continent <- wwc_outcomes%>%
  left_join(., codes)%>%
  mutate(continent = countrycode(country, "country.name", "continent"))%>%
  mutate(continent2 = case_when(country == "England" ~ "Europe",
                               country == "Scotland" ~ "Europe"),
         continent = coalesce(continent, continent2))%>%
  select(-continent2)
```

```
## Joining, by = "team"
```

```
## Warning in countrycode(country, "country.name", "continent"): Some values were not matched unambiguously: England, Scotland
```

```r
processed <- wwc_continent%>%
  arrange(team, year)%>%
  group_by(team)%>%
  mutate(rolling_play = row_number(),
         rolling_play_win = cumsum(win_status == "Won"))%>%
  ungroup()


processed2 <- processed%>%
  group_by(team, win_status)%>%
  summarise(total_win = n())%>%
  ungroup()%>%
  group_by(team)%>%
  mutate(total = sum(total_win),
         pct = total_win/sum(total_win))

processed2<- processed2%>%
  left_join(., codes)%>%
  mutate(continent = countrycode(country, "country.name", "continent"))%>%
  mutate(continent2 = case_when(country == "England" ~ "Europe",
                               country == "Scotland" ~ "Europe"),
         continent = coalesce(continent, continent2))%>%
  select(-continent2)
```

```
## Joining, by = "team"
```

```
## Warning in countrycode(country, "country.name", "continent"): Some values were not matched unambiguously: England
```

```
## Warning in countrycode(country, "country.name", "continent"): Some values were not matched unambiguously: Scotland
```

```r
pct_games<-processed2%>%
  ggplot(aes(team, pct))+
  geom_bar(stat = "identity", aes(fill = win_status))+
  coord_flip()+
  scale_y_continuous(labels = scales::percent_format())+
  scale_fill_viridis_d(option = "E")+
  facet_wrap(~continent, scales = "free_y")+
  theme(plot.subtitle = element_text(size = 10,
                                 color = "#939184",
                                 margin = margin(b = 0.1,
                                                 t = -0.1,
                                                 l = 2,
                                                 unit = "cm"),
                                 face = "bold"),
      
        plot.caption = element_text(size = 7,
                                hjust = .5,
                                margin = margin(t = 0.2,
                                                b = 0,
                                                unit = "cm"),
                                color = "#939184"))+
  
  labs(x = "Teams",
       y = "Percentage of Games",
       title = "Percentage of Games Won, Lost or Tied Per Country",
       subtitle = "Since featuring in the Women's World Cup",
       caption = "Source: Data.World | Visualization: Ifeoma Egbogah",
       fill = "Game Status")
  

pct_games
```

![](soccer_files/figure-html/unnamed-chunk-4-1.png)<!-- -->

```r
#ggsave("C:/Users/Egbogah/Desktop/pct_games.png", pct_games, width = 8, height = 8)
```
