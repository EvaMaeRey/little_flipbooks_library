# Emi Tanaka (@statsgen) and Garrick Aden-Buie (@grrrck) and Evangeline Reynolds (@EvaMaeRey)
# have contributed to this code


library(gapminder)

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
  ) %+%
  new_data ->  
my_plot "


library(tidyverse)

# # just pull apart the code into components, and determine if parentheses are balanced
# parse_code <- function(code) { 
#   
#   tibble(code = code) %>% 
#     mutate(user_reveal = str_detect(code, "#REVEAL")) %>% # Handle user defined pause points
#     mutate(code = str_remove(code, "#REVEAL")) %>% # pull out any comments
#     separate(col = code, into = c("code", "comment"), sep = "\\s# |^# ") %>% 
#     mutate(comment = str_trim(comment)) %>% 
#     mutate(comment = paste0("  # ", comment)) %>%  
#     mutate(comment = ifelse("  # NA" == comment, "", comment)) %>% 
#     mutate(code = str_remove(code, "\\s+$")) %>% 
#     mutate(connector = str_extract(code, "%>%$|\\+$|->$|%\\+%")) %>% 
#     mutate(connector = replace_na(connector, "")) %>% 
#     mutate(code = str_remove(code, "%>%$|\\+$|->|%\\+%$")) %>% 
#     mutate(num_open_par = str_count(code, "\\(|\\{|\\[")) %>% # Counting open parentheses
#     mutate(num_closed_par = str_count(code, "\\)|\\}|\\]")) %>%  # Counting closed parentheses
#     mutate(balanced_par = (cumsum(num_open_par) - cumsum(num_closed_par)) == 0 &
#              code != "")
#   
# }

# New - using parser
# We want to take just text (scalar), parse it and return a useful dataframe
parse_code <- function(code) {
  
  # code <- paste(knitr:::knit_code$get("the_code"), collapse = "\n")
  # code <- local_code
  
  raw_code <- tibble(raw_code = str_split(code, "\n")[[1]]) %>% 
    mutate(line = 1:n())
  
  sf <- srcfile(code)
  try(parse(text = code, srcfile = sf))
  getParseData(sf) %>%
    rename(line = line1) %>% 
    mutate(num_open_par = str_count(token, "\\(|\\{|\\[")) %>% # Counting open parentheses
    mutate(num_closed_par = str_count(token, "\\)|\\}|\\]"))  %>% # Counting closed parentheses
    group_by(line) %>%
    summarise(num_open_par = sum(num_open_par),
              num_closed_par = sum(num_closed_par),
              full_line = paste0(text, collapse = ""),
              comment = str_trim(paste0(ifelse(token == "COMMENT", text, ""),
                                        collapse = " "))) %>%
    left_join(raw_code) %>% 
    mutate(code = ifelse(comment != "", str_remove(raw_code, comment), raw_code)) %>%
    mutate(user_reveal = str_detect(comment, "#REVEAL")) %>%
    mutate(comment = str_remove(comment, "#REVEAL")) %>%
    mutate(connector = str_extract(str_trim(code), "%>%$|\\+$|->$|%\\+%")) %>%
    mutate(connector = replace_na(connector, "")) %>%
    mutate(code = str_remove(stringi::stri_trim_right(code), "%>%$|\\+$|->$|%\\+%")) %>%
    mutate(balanced_par = (cumsum(num_open_par) - cumsum(num_closed_par)) == 0 &
             code != "")
  
}


chunk_as_text <- function(chunk_name){
  
  paste(knitr:::knit_code$get(chunk_name), collapse = "\n")
  
}


# example
parse_code(code = local_code)


parse_chunk <- function(chunk_name){
  
  code <- chunk_as_text(chunk_name)
  
  parse_code(code)
  
}






# knitr:::knit_code$get("the_code")
# parse_code(knitr:::knit_code$get("the_code")) %>% knitr::kable()

# parse_code(str_split(local_code, "\n")[[1]])

# proposed new reveal

# reveal <- function(chunk_name, upto, highlight) {
#   content <- knitr:::knit_code$get(chunk_name)
#   parse_code(code = content) %>% 
#     mutate(reveal = 1:n() <= upto) %>% 
#     filter(reveal) %>% 
#     mutate(connector = case_when(1:n() == n() ~ "",
#                                  1:n() != n() ~ connector)) %>% 
#     mutate(highlight = ifelse(1:n() %in% highlight, "#<<", ""
#     )) %>% 
#     mutate(out = paste0(code, "", connector, "", comment, highlight)) %>% 
#     select(out) ->
#     up_to_result
#   up_to_result$out
# }


reveal_parsed <- function(parsed, upto = 3, highlight = 1:3){
  
  parsed %>% 
    mutate(reveal = 1:n() <= upto) %>% 
    filter(reveal) %>% 
    mutate(connector = case_when(1:n() == n() ~ "",
                                 1:n() != n() ~ connector)) %>% 
    mutate(highlight = ifelse(1:n() %in% highlight, "#<<", ""
    )) %>% 
    mutate(out = paste0(code, "", connector, " ", comment, highlight)) %>% 
    select(out) ->
    up_to_result
  up_to_result$out  
  
}

reveal_code <- function(code, ...) {
  
  parsed <- parse_code(code = code) 
  
  reveal_parsed(parsed = parsed, ...)
  
}

# example
reveal_code(code = local_code)

reveal_chunk <- function(chunk_name, ...){

  content <- chunk_as_text(chunk_name)
  parsed <- parse_code(code = content) 
  
  reveal_parsed(parsed = parsed, ...)

}



calc_highlight <- function(breaks) {
  
  highlighting <- list()

for (i in 1:length(breaks)) {
  if (i == 1) {  
    highlighting[[i]] <- 1:breaks[i]
  } else {
    highlighting[[i]] <- (breaks[i - 1] + 1):breaks[i]
  }
}
  
  return(highlighting)

}

# example
calc_highlight(c(1,5,7,10))


# partially_knit_code <- function(code, name, user_reveal_defined = F, show_code = T, title = "") {
#   
#   parsed <- parse_code(code = local_code)
#   
#   if (user_reveal_defined == T) { breaks <- parsed$line[parsed$user_reveal]  } else {
#     breaks <- parsed$line[parsed$balanced_par] }
#   
#     highlighting <- calc_highlight(breaks)
#   
#   
#   if (show_code == T) {
#     partial_knit_steps <- glue::glue(
#       "class: split-40",
#       "count: false",
#       ".column[.content[",
#       "```{r plot_{{name}}_{{breaks}}, eval=FALSE, code=reveal_code('{{code}}', {{breaks}}, {{highlighting}})}",
#       "```",
#       "]]",
#       ".column[.content[",
#       "```{r output_{{name}}_{{breaks}}, echo=FALSE, code=reveal_code('{{code}}', {{breaks}}, {{highlighting}})}",
#       "```",
#       "]]",
#       .open = "{{", .close = "}}", .sep = "\n"
#     )
#   } else {
#     
#     partial_knit_steps <- glue::glue(title,"```{r output_{{name}}_{{breaks}}, echo=FALSE, code=reveal_code('{{code}}', {{breaks}}, {{highlighting}})}",
#                                      "```",
#                                      .open = "{{", .close = "}}", .sep = "\n"
#     )
#     
#   }
#   
#   glue::glue_collapse(x = partial_knit_steps, sep = "\n---\n")
#   
# }
# 
# 
# # example
# partially_knit_code(code = local_code, name = "new_chunks")
# 
# 
# apply_reveal_code <- function(...){
#   paste(knitr::knit(text = partially_knit_code(...)), collapse = "\n")
# }
# 
# # example
# apply_reveal_code(code = local_code, name = "new_chunks")



# partial knit chunks

partially_knit_chunks <- function(chunk_name, user_reveal_defined = F, show_code = T, title = "") {
  # Create slide for lines 1:N for each line N in the given chunk
  # break_points <- seq_along(knitr:::knit_code$get(chunk_name)) # original code, breaks for each line
  
  parsed <- parse_chunk(chunk_name)
  
  if (user_reveal_defined == T) { breaks <- parsed$line[parsed$user_reveal]  } else {
        breaks <- parsed$line[parsed$balanced_par] }
  

  highlighting <- calc_highlight(breaks = breaks)
  
  
  if (show_code == T) {
    partial_knit_steps <- glue::glue(
      "class: split-40",
      "count: false",
      ".column[.content[",
      "```{r plot_{{chunk_name}}_{{breaks}}, eval=FALSE, code=reveal_chunk('{{chunk_name}}', {{breaks}}, {{highlighting}})}",
      "```",
      "]]",
      ".column[.content[",
      "```{r output_{{chunk_name}}_{{breaks}}, echo=FALSE, code=reveal_chunk('{{chunk_name}}', {{breaks}}, {{highlighting}})}",
      "```",
      "]]",
      .open = "{{", .close = "}}", .sep = "\n"
    )
  } else {
    
    partial_knit_steps <- glue::glue(title,"```{r output_{{chunk_name}}_{{breaks}}, echo=FALSE, code=reveal_chunk('{{chunk_name}}', {{breaks}}, {{highlighting}})}",
                                     "```",
                                     .open = "{{", .close = "}}", .sep = "\n"
    )
    
  }
  
  glue::glue_collapse(x = partial_knit_steps, sep = "\n---\n")
}

apply_reveal <- function(...){
  paste(knitr::knit(text = partially_knit_chunks(...)), collapse = "\n")
}


save_complete_plot_from_chunk <- function(chunk_name, filename = chunk_name, path = "figures/", type = ".png"){
  get_what_save_what <- chunk_name
  eval(parse(text = paste(knitr:::knit_code$get(get_what_save_what), collapse = "")))
  ggsave(paste0(path, filename, type), dpi = 300)  
}

make_html_picture_link <- function(path, link){
  cat(paste0('<a href="', link, '"><img src="', path, '"width="150" height="150" title=' ,path, ' alt=', path,'></a>'))
}




# parse_code(code = local_code)
# reveal(chu)
# knitr:::knit_code$get("the_code")
# parse_code(knitr:::knit_code$get("the_code")) %>% knitr::kable()

# parse_code(str_split(local_code, "\n")[[1]])

# proposed new reveal

new_reveal <- function(input, is_chunk_name = T, upto, highlight) {
  
  if (is_chunk_name == T) {
  content <- paste(knitr:::knit_code$get(input), collapse = "\n")
  } else {
  content <- input  
  }
    
  new_parse_code(code = content) %>% 
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


flipbook_mini <- function(chunk_name, file_out, user_reveal_defined = F, title = "") {
  # Create slide for lines 1:N for each line N in the given chunk
  # break_points <- seq_along(knitr:::knit_code$get(chunk_name)) # original code, breaks for each line
  
  
  parsed <- parse_chunk(chunk_name)
  
  if (user_reveal_defined == T) { breaks <- parsed$line[parsed$user_reveal]  } else {
    breaks <- parsed$line[parsed$balanced_par] }
  
  
  highlighting <- calc_highlight(breaks = breaks)
  
  
  for (i in 1:length(breaks)) {
    if(!dir.exists("mini")) {dir.create("mini")}
    if(!dir.exists("mini/temp_for_mini")) {dir.create("mini/temp_for_mini")}
    # print(reveal(chunk_name, breaks[i], highlighting[[i]])) 
    writeLines(text = reveal_chunk(chunk_name, breaks[i], highlighting[[i]]), con  = "tmp.R")
    source("tmp.R")
    the_plot <- last_plot()
    ggplot(tibble(label = 
                    reveal_chunk(chunk_name, 
                                 breaks[i], 
                                 highlighting[[i]])) %>% 
                           mutate(n = 1:n()) %>% 
             mutate(highlight = ifelse(str_detect(label, "#<<"), "yes", "no")) %>%
             mutate(highlight = factor(highlight, levels = c("yes", "no"))) %>% 
             mutate(label = str_remove(label, "#<<"))
             ) +
      aes(x = 1) +
      aes(y = -n) +
      scale_y_continuous(limits = c(-17,3), expand = c(0,0)) +
      scale_x_continuous(limits = c(0,50), expand = c(0,0)) +
      coord_fixed(ratio = 3.5) +
      aes(label = label) +
      geom_rect(aes(ymin = -n + .5, ymax = -n - .5, alpha = highlight),
                xmin = 0, xmax = 50, fill = "plum4") +
      labs(fill = NULL) +
      scale_alpha_discrete(range = c(.7,0), breaks = c("no", "yes"), guide = F) +
      geom_text(hjust = 0, family = "mono", size = 3) +
      theme_void() -> text
    
      title <- cowplot::ggdraw() + 
        cowplot::draw_label(label = title, fontface = 'bold')
      side_by_side <- cowplot::plot_grid(text, the_plot, rel_widths = c(1, 1))
      cowplot::save_plot(cowplot::plot_grid(title, 
                                            side_by_side, 
                                            rel_heights = c(0.1, 1), ncol = 1,), 
                         filename = paste0("mini/temp_for_mini/", i, ".png"))
                         
      
  }
  
  
  setwd("mini/temp_for_mini")
  list.files(pattern = ".png") %>% 
    file.info() %>% 
    rownames_to_column(var = "file") %>% 
    arrange(mtime) %>% # sort them by time modified
    pull(file) %>% 
    purrr::map(magick::image_read) %>% # reads each path file
    magick::image_join() %>% # joins image
    magick::image_animate(fps = 1) %>% # animates
    magick::image_write(path = paste0("../", file_out))
  
  unlink("../temp_for_mini")
  
  
}

