# CALCULO DE REM
library(readr)
library(stringr)
library(dplyr)
library(tidyr)

REM_Grave_COL <- read_csv("C:/Users/Hp/DENGUE/JBOOK/REM/REM_Grave_COL.csv")
REM_Clasico_COL <- read_csv("C:/Users/Hp/DENGUE/JBOOK/REM/REM_Clasico_COL.csv")

REM_Grave_ATL <- read_csv("C:/Users/Hp/DENGUE/JBOOK/REM/REM_Grave_ATL.csv")
REM_Clasico_ATL <- read_csv("C:/Users/Hp/DENGUE/JBOOK/REM/REM_Clasico_ATL.csv")


calcular_rem_por_periodo_COL <- function(df, tipo_evento) {
  resultado <- df %>%
    mutate(periodo = case_when(
      año %in% 2013:2016 ~ "2013-2016",
      año %in% 2017:2020 ~ "2017-2020",
      año %in% 2021:2023 ~ "2021-2023"
    )) %>%
    group_by(departamento, periodo) %>%
    summarise(
      casos_obs = sum(casos, na.rm = TRUE),
      casos_esp = sum(esperado, na.rm = TRUE),
      REM = casos_obs / casos_esp,
      .groups = "drop"
    )
  write.csv(resultado, paste0("C:/Users/Hp/DENGUE/JBOOK/REM/REM_PERIODO_", str_to_title(tipo_evento), "_COL.csv"), row.names = FALSE)
  return (resultado)
}
rem_periodos_grave_COL <- calcular_rem_por_periodo_COL(REM_Grave_COL, "grave")
rem_periodos_clasico_COL <- calcular_rem_por_periodo_COL(REM_Clasico_COL, "clasico")

#---
calcular_rem_por_periodo_ATL <- function(df, tipo_evento) {
  resultado <- df %>%
    mutate(periodo = case_when(
      año %in% 2017:2020 ~ "2017-2020",
      año %in% 2021:2023 ~ "2021-2023"
    )) %>%
    group_by(municipio, periodo) %>%
    summarise(
      casos_obs = sum(casos, na.rm = TRUE),
      casos_esp = sum(esperado, na.rm = TRUE),
      REM = casos_obs / casos_esp,
      .groups = "drop"
    )
  write.csv(resultado, paste0("C:/Users/Hp/DENGUE/JBOOK/REM/REM_PERIODO_", str_to_title(tipo_evento), "_ATL.csv"), row.names = FALSE)
  return (resultado)
}
rem_periodos_grave_ATL <- calcular_rem_por_periodo_ATL(REM_Grave_ATL, "grave")
rem_periodos_clasico_ATL <- calcular_rem_por_periodo_ATL(REM_Clasico_ATL, "clasico")