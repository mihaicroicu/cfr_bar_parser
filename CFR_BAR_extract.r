## Extractor de Buletine de Avizare Restrictie (BAR)
## author: Mihai Croicu
## organization: Asociatia Proinfrastructura

#Cauta ultimul BAR de pe site-ul CFR si il descarca automat.
#Apoi converteste BAR-ul intr-un format sane, pe care-l salveaza ca CSV si Excel.

#Iti trebuie curl instalat si disponibil in PATH.
#Chestia asta e facuta sa mearga pe un sistem Linux sau OSX. 
#Ai nevoie de curl si soffice in path. Poti testa deschizand un terminal si tastand soffice && curl
#Pe windows, cat timp merge in powershell curl si soffice, ar *trebui* sa mearga. 
#Daca nu, Ubuntu subsystem for Windows ar trebui sa mearga.

if (!require("pacman")) {
    install.packages("pacman")
    library("pacman")
    }
pacman::p_load(tidyverse, docxtractr, textreadr, jsonlite)
pacman::p_load(rvest)
#Incarca RVEST la sfarsit. Namespace-ul rvest e busit (R!) asa ca rvest::read_html nu merge
#Si celelalte pachete expun si ele un read_html.

#1:Bucureşti 2:Braşov 3:Cluj 4:Constanţa 5:Craiova 6:Galaţi 7:Iaşi 8:Timişoara
oras <- 1 

cfr_web <- read_html('http://cfr.ro/index.php/ct-menu-item-105/ct-menu-item-116')

link <- html_nodes(cfr_web,'.art-button') %>% html_attr('href')
web_bar_bucuresti <- paste0('http://cfr.ro',link[oras])

print(paste0("Fetching ", web_bar_bucuresti))
fetch_command <- paste0('curl ',web_bar_bucuresti,' -o bar.doc')
system(fetch_command)

print ("Converting MSDOC to DOCX...:")
# If this gives an error, then you NEED
system('soffice --headless --convert-to docx bar.doc')

## Obtine lista de linii

print("Citim restrictiile...")
print("Procesul este relativ lent. Asteptati...")
bucuresti_b0 <- textreadr::read_docx('bar.docx')

print("Extragem lista de linii...")

#Liniile sunt definite de un text de forma LINIA(\s|\t)(100-999)[\sA-Z]

lista_linii <- bucuresti_b0[str_detect(bucuresti_b0, "LINIA[:blank:][:digit:]")]

print("Extragem tabelele de restrictii...")
real_world <- docxtractr::read_docx('bar.docx')
docx_tbl_count(real_world)
# get all the tables
tbls <- docxtractr::docx_extract_all_tbls(real_world, preserve = TRUE, trim = TRUE)

lista_linii <- c('',str_replace(lista_linii,'LINIA[:blank:]',''))

lista_linii

if (length(lista_linii) != docx_tbl_count(real_world)) {
    stop("value_erorr : Numarul de tabele de restrictii difera de numarul de capete de tabel")
}

## Obtine restrictiile

scoate_magistrala <- function(index){
    #Extrage magistrala
    tabel_restrictii <- tbls[index][[1]]
    fir1 <- tabel_restrictii%>%filter(V3 != '')%>%select(V2,V3,V4)%>%rename(borne=V2,viteza=V3,nume=V4)
    fir2 <- tabel_restrictii%>%filter(V8 != '')%>%select(V7,V8,V9)%>%rename(borne=V7,viteza=V8,nume=V9)
    fir1['fir'] <- 1
    fir2['fir'] <- 2
    fir <- rbind(fir1,fir2) %>% mutate (viteza=as.integer(viteza))
    return(fir) 
}

identifica_restrictii <- function(fir){
    # :fir - dataframe -> fir[c('borne','viteza','nume','fir')]
    # :return - dataframe -> firRestrictii[c('r_start','r_stop')]
    # Dat fiind un tabel de tip fir, continand un set de borne CFR-istice (ex. 66+291 39+020)
    # Sparge borna in pozitii "start" si "stop", si converteste-le in numerice (floats)
    # Daca nu avem nici o restrictie pe directa, tabelul va fi gol -> return(empty(firRestrictii))
    if(nrow(fir)==0) {
        return(data.frame(r_start = double(),r_end = double())) 
        }
    #Sparge borna in "start" si "stop"
    poz_km <- fir %>% select(borne)
    #Minimal clean-up cu regex.
    poz_km <- poz_km %>% mutate(borne = str_replace_all(borne,'[[:blank:]|\n]\\([a-zA-Z1-9]*[:blank:]*[a-z1-9]*\\)',''))
    poz_km <- poz_km %>% mutate(borne = str_replace_all(borne,'toată linia','0+000\n0+000'))
    poz_km <- ((poz_km%>%select(borne))[[1]]%>%str_split('\\n', simplify=TRUE))
    #Fallback  -  daca textul din borna se parseaza rau, si rezulta in mai mult de 2 coloane, nu-mi distruge CSV-ul
    #Ideal, toata chestia asta ar trebui sa intre intr-un try-except-catch, 
    # doar ca R se chinuie prea mult inainte sa arunce o eroare
    # si prefera sa faca matrici si liste neconforme fara nici un sunet pana e prea tarziu.
    if (ncol(poz_km)>2) {poz_km <- poz_km[,1:2]}
    #Converteste + in . pentru o conversie in float
    poz_km <- poz_km%>%str_split('\\+',simplify=TRUE)
    #Calculeaza restrictia in metri si inapoi in km. Functioneaza si cu 160+0 si cu 160+000.
    poz_km <- (as.integer(poz_km[,1])*1000+as.integer(poz_km[,2]))/1000
    #R-tidy produce o matrice de 2 coloane x 2*nr_restrictii. Sparge in doua si return df.
    nr_restrictii <- length(poz_km)/2
    r_start <- poz_km[1:nr_restrictii]
    r_end <- poz_km[(nr_restrictii+1):length(poz_km)]
    identifica_restrictii <- data.frame(r_start = r_start, r_end = r_end)
}

bar_final <- data.frame()
for (i in 2:length(lista_linii)) {
    print(paste(i," Extrag : ",lista_linii[i]))
    fir <- scoate_magistrala(i)
    restrictii <- identifica_restrictii(fir)
    fir['r_start'] <- restrictii['r_start']
    fir['r_end'] <- restrictii['r_end']
    fir['linie'] <- lista_linii[i]
    bar_final <- rbind(bar_final,fir)
}

print("Gata! \n Primele randuri din setul de date \n**********")
head(bar_final)
print("**********")

write_json(bar_final, "bar_extras.json")

write_csv(bar_final, "bar_extras.csv")
