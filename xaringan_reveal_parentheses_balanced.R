# Emi Tanaka (@statsgen) and Garrick Aden-Buie (@grrrck) and Evangeline Reynolds (@EvaMaeRey)
# have contributed to this code


library(tidyverse)

# just pull apart the code into components, and determine if parentheses are balanced
parse_code <- function(code) { 
  
  tibble(code = code) %>% 
    mutate(user_reveal = str_detect(code, "#REVEAL")) %>% # Handle user defined pause points
    mutate(code = str_remove(code, "#REVEAL")) %>% # pull out any comments
    separate(col = code, into = c("code", "comment"), sep = "#") %>% 
    mutate(comment = str_trim(comment)) %>% 
    mutate(comment = paste0("  # ", comment)) %>%  
    mutate(comment = ifelse("  # NA" == comment, "", comment)) %>% 
    mutate(code = str_remove(code, "\\s+$")) %>% 
    mutate(connector = str_extract(code, "%>%$|\\+$|->$")) %>% 
    mutate(connector = replace_na(connector, "")) %>% 
    mutate(code = str_remove(code, "%>%$|\\+$|->$")) %>% 
    mutate(num_open_par = str_count(code, "\\(|\\{|\\[")) %>% # Counting open parentheses
    mutate(num_closed_par = str_count(code, "\\)|\\}|\\]")) %>%  # Counting closed parentheses
    mutate(balanced_par = (cumsum(num_open_par) - cumsum(num_closed_par)) == 0 &
             code != "")
  
}


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



# knitr:::knit_code$get("the_code")
# parse_code(knitr:::knit_code$get("the_code")) %>% knitr::kable()

# parse_code(str_split(local_code, "\n")[[1]])

# proposed new reveal

reveal <- function(chunk_name, upto, highlight) {
  content <- knitr:::knit_code$get(chunk_name)
  parse_code(code = content) %>% 
    mutate(reveal = 1:n() <= upto) %>% 
    filter(reveal) %>% 
    mutate(connector = case_when(1:n() == n() ~ "",
                                 1:n() != n() ~ connector)) %>% 
    mutate(highlight = ifelse(1:n() %in% highlight, "#<<", ""
    )) %>% 
    mutate(out = paste0(code, "", connector, "", comment, highlight)) %>% 
    select(out) ->
    up_to_result
  up_to_result$out
}


# partial knit chunks

partial_knit_chunks <- function(chunk_name, user_reveal_defined = F, show_code = T) {
  # Create slide for lines 1:N for each line N in the given chunk
  # break_points <- seq_along(knitr:::knit_code$get(chunk_name)) # original code, breaks for each line
  
  
  parsed <- parse_code(knitr:::knit_code$get(chunk_name))
  
  if (user_reveal_defined == T) {
    
    breaks <- parsed$user_reveal
    
  } else {
    
    breaks <- parsed$balanced_par
    
  }
  
  the_break_points <- (1:length(breaks))[breaks]
  
  
  highlighting <- list()
  
  for (i in 1:length(the_break_points)) {
    if (i == 1) {  
      highlighting[[i]] <- 1:the_break_points[i]
    } else {
      highlighting[[i]] <- (the_break_points[i - 1] + 1):the_break_points[i]
    }
  }
  
  
  if (show_code == T) {
    partial_knit_steps <- glue::glue(
      "class: split-40",
      "count: false",
      "",
      ".column[.content[",
      "```{r plot_{{chunk_name}}_{{the_break_points}}, eval=FALSE, code=reveal('{{chunk_name}}', {{the_break_points}}, {{highlighting}})}",
      "```",
      "]]",
      ".column[.content[",
      "```{r output_{{chunk_name}}_{{the_break_points}}, echo=FALSE, code=reveal('{{chunk_name}}', {{the_break_points}}, {{highlighting}})}",
      "```",
      "]]",
      .open = "{{", .close = "}}", .sep = "\n"
    )
    glue::glue_collapse(partial_knit_steps, "\n---\n")
  } else {
    
    partial_knit_steps <- glue::glue("```{r output_{{chunk_name}}_{{the_break_points}}, echo=FALSE, code=reveal('{{chunk_name}}', {{the_break_points}}, {{highlighting}})}",
                                     "```",
                                     .open = "{{", .close = "}}", .sep = "\n"
    )
    glue::glue_collapse(partial_knit_steps, "\n---\n")
    
  }
  
}

apply_reveal <- function(chunk_name, show_code){
  paste(knitr::knit(text = partial_knit_chunks(chunk_name, show_code = T)), collapse = "\n")
}


