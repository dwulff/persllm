require(tidyverse)
require(rvest)
require(xml2)



corrs = read_csv("1_data/Jose/Open_Source_Psychometrics/derivatives/item_correlation.tsv")

table(corrs$inventory_i) %>% sort()


# 16PF -------

scores = read_delim("1_data/open_psychometric/16PF/data.csv",delim = "\t")

items = read_html("1_data/open_psychometric/16PF/codebook.html") %>% 
  html_nodes(xpath = "//tr") %>% 
  sapply(function(x) html_nodes(x, xpath = "td")[c(1,3)] %>% html_text())
items = items[lengths(items) == 2] %>% do.call(what = rbind) %>% as.data.frame() %>% 
  as_tibble() 
items = items %>% 
  mutate(V2 = str_extract(V2, '"[^"]+')) %>% 
  slice(1:162) %>% 
  mutate(V2 = str_remove(V2, '"') %>% paste0(".")) %>% 
  pull(V2, V1)


corrs = cor(scores %>% select(all_of(names(items))))
rownames(corrs) = colnames(corrs) = items[rownames(corrs)]

corrs_16PF = crossing(item_i = rownames(corrs), item_j = colnames(corrs)) %>% 
  mutate(cor = c(corrs), 
         abs_cor = abs(cor), 
         inventory = "16PF")



# BIG5 -------


scores = read_delim("1_data/open_psychometric/BIG5/data.csv",delim = "\t")

items = read_lines("1_data/open_psychometric/BIG5/codebook.txt") %>% 
  `[`(5:54) %>% 
  str_split("\t") %>% 
  do.call(what = "rbind") %>% 
  as.data.frame() %>% 
  as_tibble() %>% 
  pull(V2, V1)

corrs = cor(scores %>% select(all_of(names(items))))
rownames(corrs) = colnames(corrs) = items[rownames(corrs)]

corrs_BIG5 = crossing(item_i = rownames(corrs), item_j = colnames(corrs)) %>% 
  mutate(cor = c(corrs), 
         abs_cor = abs(cor), 
         inventory = "BIG5")



# HEXACO -------


scores = read_delim("1_data/open_psychometric/HEXACO/data.csv",delim = "\t")

items = read_lines("1_data/open_psychometric/HEXACO/codebook.txt") %>% 
  `[`(4:243) %>% 
  str_split(" ") %>% 
  tibble(V1 = sapply(., function(x) x[1]),
         V2 = sapply(., function(x) x[-1] %>% paste0(collapse=" "))) %>% 
  select(-1) %>% 
  pull(V2, V1)

corrs = cor(scores %>% select(all_of(names(items))))
rownames(corrs) = colnames(corrs) = items[rownames(corrs)]

corrs_HEXACO = crossing(item_i = rownames(corrs), item_j = colnames(corrs)) %>% 
  mutate(cor = c(corrs), 
         abs_cor = abs(cor), 
         inventory = "HEXACO")


# FFM -------

scores = read_delim("1_data/open_psychometric/IPIP-FFM-data-8Nov2018/data-final.csv",delim = "\t")

items = read_lines("1_data/open_psychometric/IPIP-FFM-data-8Nov2018/codebook.txt") %>% 
  `[`(8:57) %>% 
  str_split("\t") %>% 
  do.call(what = "rbind") %>% 
  as.data.frame() %>% 
  as_tibble() %>% 
  pull(V2, V1)


scores_sel = scores %>% select(all_of(names(items))) %>% as.matrix()
mode(scores_sel) = "numeric"
corrs = cor(scores_sel, use = "pairwise.complete.obs")
rownames(corrs) = colnames(corrs) = items[rownames(corrs)]

corrs_FFM = crossing(item_i = rownames(corrs), item_j = colnames(corrs)) %>% 
  mutate(cor = c(corrs), 
         abs_cor = abs(cor), 
         inventory = "FFM")

# COMBINE -------

corrs = corrs_16PF %>% 
  bind_rows(corrs_BIG5) %>% 
  bind_rows(corrs_HEXACO) %>% 
  bind_rows(corrs_FFM)

write_csv(corrs, "1_data/correlations.csv")







