library(tidyverse)
library(jsonlite)

linii <- c()
bar <- data.frame()

for (i in 1:8) {
    cur_bar <- tryCatch({
        read_csv(paste0('bar_extras',i,'.csv'))
        },
        error=function(cond){
          head(tibble(linie=NA),0)
        })
    cur_bar <- cur_bar %>% filter(!linie %in% linii)
    linii_noi <- (cur_bar%>%select(linie)%>%unique())[['linie']]
    linii <- c(linii, linii_noi)
    bar <- rbind(bar, cur_bar)
}

write_json(bar, 'bar_final.json')
write_csv(bar, 'bar_final.csv')

