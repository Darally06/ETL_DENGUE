# ---------------------------------------------
#         CALCULO REM DENGUE GENERAL
# ---------------------------------------------

library(readr)
library(stringr)
library(dplyr)
library(tidyr)

# ---- Datos ----
casos_mun_año_total <- read_csv("C:/ETL_DENGUE/DATA/casos_x_año.csv")   # <-- ahora solo 1 archivo de casos
Poblacion_departamental <- read_csv("C:/ETL_DENGUE/DATA/poblacion_depart.csv")
Poblacion_departamental <- Poblacion_departamental %>% 
  filter(MUNICIPIO != "BARRANQUILLA")

años_col <- 2018:2023

# ---- Renombrar columnas ----
colnames(Poblacion_departamental) <- colnames(Poblacion_departamental) %>%
  str_replace("^([0-9]{4})$", "pob_\\1")

colnames(casos_mun_año_total) <- colnames(casos_mun_año_total) %>%
  str_replace("^([0-9]{4})$", "casos_\\1")

Poblacion_departamental <- Poblacion_departamental %>% select(-TOTAL)
casos_mun_año_total <- casos_mun_año_total %>% select(-TOTAL)

# ---- Merge ----
C_M_A_P_T <- merge(casos_mun_año_total, 
                   Poblacion_departamental,
                   by = "MUNICIPIO", 
                   all.x = TRUE)

# ---------------------------------------------
#      1. TABLA DEPARTAMENTAL ANUAL
# ---------------------------------------------
calcular_tabla_departamental <- function(df, años) {
  totales <- sapply(df[, sapply(df, is.numeric)], sum, na.rm = TRUE) %>% as.list()
  
  tabla <- data.frame(
    año = años,
    casos = sapply(años, function(a) totales[[paste0("casos_", a)]]),
    poblacion = sapply(años, function(a) totales[[paste0("pob_", a)]])
  )
  
  tabla$tasa <- tabla$casos / tabla$poblacion
  
  write.csv(tabla,
            "C:/ETL_DENGUE/ARCHIVOS/REM/Tasa_casosXaño_Total_Anual.csv",
            row.names = FALSE)
  return(tabla)
}

# ---------------------------------------------
#      2. CALCULO REM
# ---------------------------------------------
calcular_rem <- function(df, tabla_departamental, años) {
  for (año in años) {
    pob_col <- paste0("pob_", año)
    tasa_val <- tabla_departamental$tasa[tabla_departamental$año == año]
    esperado_col <- paste0("esperado_", año)
    df[[esperado_col]] <- df[[pob_col]] * tasa_val
  }
  
  for (año in años) {
    casos_col <- paste0("casos_", año)
    esperado_col <- paste0("esperado_", año)
    rem_col <- paste0("REM_", año)
    df[[rem_col]] <- df[[casos_col]] / df[[esperado_col]]
  }
  
  return(df)
}

# ---------------------------------------------
#      3. TRANSFORMAR A FORMATO LONG
# ---------------------------------------------
transformar_long <- function(df) {
  casos_long <- df %>%
    select(MUNICIPIO, starts_with("casos_")) %>%
    pivot_longer(cols = -MUNICIPIO, names_to = "año", values_to = "casos") %>%
    mutate(año = gsub("casos_", "", año))
  
  pob_long <- df %>%
    select(MUNICIPIO, starts_with("pob_")) %>%
    pivot_longer(cols = -MUNICIPIO, names_to = "año", values_to = "poblacion") %>%
    mutate(año = gsub("pob_", "", año))
  
  esperado_long <- df %>%
    select(MUNICIPIO, starts_with("esperado_")) %>%
    pivot_longer(cols = -MUNICIPIO, names_to = "año", values_to = "esperado") %>%
    mutate(año = gsub("esperado_", "", año))
  
  rem_long <- df %>%
    select(MUNICIPIO, starts_with("REM_")) %>%
    pivot_longer(cols = -MUNICIPIO, names_to = "año", values_to = "REM") %>%
    mutate(año = gsub("REM_", "", año))
  
  tabla_long <- casos_long %>%
    left_join(pob_long, by = c("MUNICIPIO", "año")) %>%
    left_join(esperado_long, by = c("MUNICIPIO", "año")) %>%
    left_join(rem_long, by = c("MUNICIPIO", "año")) %>%
    arrange(MUNICIPIO, año)
  
  write.csv(tabla_long,
            "C:/ETL_DENGUE/ARCHIVOS/REM/REM_Total_Año.csv",
            row.names = FALSE)
  return(tabla_long)
}
colnames(C_M_A_P_T)

# ---------------------------------------------
#      EJECUCIÓN PARA DENGUE TOTAL
# ---------------------------------------------

tabla_total_M <- calcular_tabla_departamental(C_M_A_P_T, años_col)
C_M_A_P_T <- calcular_rem(C_M_A_P_T, tabla_total_M, años_col)
tabla_long_T_M <- transformar_long(C_M_A_P_T)
