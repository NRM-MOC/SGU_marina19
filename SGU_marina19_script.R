library(tidyverse)
library(readxl)
library(MoCiS2) # devtools::install_github("NRM-MOC/MoCiS2") # detach("MoCiS2", unload = TRUE)

################################################################
# No metals are submitted for 2019 as lab analysis are delayed #
################################################################

setwd('Y:/MFO_Privat/MG/MOCIS/SGU/SGU_marina19/')

# Cleans table of biodata to contain columns PROV_KOD_ORIGINAL, PROVTAG_DAT, TOTV,TOTL, ALDR, ANTAL_DAGAR, KON
biodata <- read_excel("data/marina19biodata.xlsx", guess_max = 100000) %>% 
  select(PROV_KOD_ORIGINAL = ACCNR_ESBASE, PROVTAG_DAT = DATE, PROVTAG_DAT2 = DATE, Katalog = SPECIES, Kon = SEX, 
         TOTV, TOTL, ALDR) %>% 
  mutate(PROVTAG_DAT2 = as.Date(PROVTAG_DAT2),
         PROVTAG_DAT = as.Date(PROVTAG_DAT),
         ANTAL_DAGAR = 1,
         # ANTAL_DAGAR = as.numeric(PROVTAG_DAT2-PROVTAG_DAT),
         # ANTAL_DAGAR = ifelse(is.na(ANTAL_DAGAR), 1, ANTAL_DAGAR), 
         KON = case_when(Katalog == "Sterna hirundo" ~ "I",
                         Katalog == "Uria aalge" ~ "I",
                         Katalog == "Haematopus ostralegus" ~ "I",
                         Katalog == "Mytilus edulis" ~ "H",
                         Kon == "male" ~ "M",
                         Kon == "female" ~ "F"),
         TOTV = as.numeric(TOTV),
         TOTL = as.numeric(TOTL),
         ALDR = as.numeric(ALDR)) %>%
  select(-Katalog, -Kon, -PROVTAG_DAT2) %>% 
# Date unavailable for the following
  mutate(PROVTAG_DAT = ifelse(PROV_KOD_ORIGINAL %in% c("C2019/03689","C2019/03690","C2019/03691","C2019/03692",
                                                       "C2019/03693","C2019/03694","C2019/03695","C2019/03696",
                                                       "C2019/03697","C2019/03698","C2019/03699","C2019/03700",
                                                       "C2019/03701","C2019/03702","C2019/03703","C2019/03704",
                                                       "C2019/03705","C2019/03706","C2019/03707","C2019/03708",
                                                       "C2019/03709","C2019/03710","C2019/03711","C2019/03712",
                                                       "C2019/05939","C2019/05940","C2019/05941","C2019/05942",
                                                       "C2019/05943","C2019/05944","C2019/05945","C2019/05946",
                                                       "C2019/05947","C2019/05948","C2019/05949","C2019/05950",
                                                       "C2019/05951","C2019/05952","C2019/05953","C2019/05954",
                                                       "C2019/05955","C2019/05956","C2019/05957","C2019/05958",
                                                       "C2019/05959","C2019/05960","C2019/05961","C2019/05962"),
                              "2019-10-01",
                              as.character(PROVTAG_DAT)))


#metaller <- moc_read_lab("data/Metaller_marina 2019_2018 prover.xlsm")
bromerade <- moc_read_lab("data/BFRs_Marina2020_2019ArsProver_201027.xlsm")
klorerade <- moc_read_lab("data/CLCs_Marina2020_2019ArsProver_201001.xlsm")
dioxiner <- moc_read_lab("data/Dioxins_Marin 2020_NRM 2020-10-17.xlsm")
hg <- moc_read_lab("data/Hg_Marin_2020_7315.xlsm")
pah <- moc_read_lab("data/PAHs_Marin_RA.xlsm")
tennorganiska <- moc_read_lab("data/Tinorganic_Marin_RA.xlsm")
pfas <- moc_read_lab("data/PFASs_Marin2020_2019ArsProver_modifierad.xlsm")
sia <- moc_read_lab("data/SI_Marin_2020_7315_mod.xlsm", negative_for_nondetect = FALSE)


analysdata <- bind_rows(#metaller, 
  bromerade, 
  klorerade, 
  dioxiner, 
  hg, 
  pah, 
  tennorganiska, 
  pfas, 
  sia)

SGU <- moc_join_SGU(biodata, analysdata)

moc_write_SGU(SGU, "PROVMETADATA", "marina19_PROVMETADATA.xlsx", program = "hav")
moc_write_SGU(SGU, "PROVDATA_BIOTA", "marina19_PROVDATA_BIOTA.xlsx", program = "hav")
moc_write_SGU(SGU, "DATA_MATVARDE", "marina19_DATA_MATVARDE.xlsx", program = "hav")