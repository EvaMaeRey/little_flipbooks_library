# parse functions

library(rlang)



gapminder %>%             # the data  #REVEAL
filter(year == (2000 + 7)) %>%  # subset 
ggplot() +              # pipe to ggplot 
aes(x = gdpPercap) +
aes(y = lifeExp) +  
# Describing what follows
geom_point() + #REVEAL
aes(color = 
paste("continent", 
continent) 
) ->  
my_plot


local_code <- # for testing w/o knitting
  "gapminder %>%             # the data  #REVEAL
filter(year == (2000 + 7)) %>%  # subset 
ggplot() +              # pipe to ggplot 
aes(x = gdpPercap) +
aes(y = lifeExp) +  
# Describing what follows
geom_point() + #REVEAL
aes(color = 
paste(\"continent\", 
continent) 
) ->  
my_plot "

rlang::parse_expr(local_code)
rlang::parse_exprs(local_code)
rlang::parse_quo(local_code)
rlang::parse_quos(local_code)
