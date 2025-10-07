# CALCULO DE REM
library(readr)
library(stringr)
library(dplyr)
library(tidyr)



# ----- 
  #----
  # COLOMBIA
  casos_dpto_año_clasico <- read_csv("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/casos_dpto_año_clasico.csv")
  casos_dpto_año_grave <- read_csv("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/casos_dpto_año_grave.csv")
  Poblacion_nacional <- read_csv("C:/Users/Hp/DENGUE/JBOOK/Poblacion/Poblacion_nacional.csv")
  colnames(Poblacion_nacional)[colnames(Poblacion_nacional) == "DEPARTAMENTO"] <- "departamento"
  años_col <- 2013:2023
  

  colnames(Poblacion_nacional) <- colnames(Poblacion_nacional) %>%
    str_replace("^([0-9]{4})\\.0$", "pob_\\1")  # años con .0
  colnames(casos_dpto_año_clasico) <- colnames(casos_dpto_año_clasico) %>%
    str_replace("^([0-9]{4})$", "casos_\\1")   # años sin .0
  colnames(casos_dpto_año_grave) <- colnames(casos_dpto_año_grave) %>%
    str_replace("^([0-9]{4})$", "casos_\\1")  # años sin .0
    
  Poblacion_nacional <- Poblacion_nacional %>%
    select(-TOTAL)
  casos_dpto_año_clasico <- casos_dpto_año_clasico %>%
    select(-total_casos_clasico)
  casos_dpto_año_grave <- casos_dpto_año_grave %>%
    select(-total_casos_grave)
  
  
  C_D_A_P_C <- merge(casos_dpto_año_clasico, Poblacion_nacional, by = "departamento", all.x = TRUE)
  C_D_A_P_G <- merge(casos_dpto_año_grave, Poblacion_nacional, by = "departamento", all.x = TRUE)
  
  calcular_tabla_nacional <- function(df, tipo_evento, años) {
    totales <- sapply(df[, sapply(df, is.numeric)], sum, na.rm = TRUE) %>% as.list()
    
    tabla <- data.frame(
      año = años,
      casos = sapply(años, function(a) totales[[paste0("casos_", a)]]),
      poblacion = sapply(años, function(a) totales[[paste0("pob_", a)]])
    )
    
    tabla$tasa <- tabla$casos / tabla$poblacion
    write.csv(tabla, paste0("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/Tasa_X_año_COL_", str_to_title(tipo_evento), ".csv"), row.names = FALSE)
    return(tabla)
  }
  calcular_rem <- function(df, tabla_nacional, años) {
    for (año in años) {
      pob_col <- paste0("pob_", año)
      tasa_val <- tabla_nacional$tasa[tabla_nacional$año == año]
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
  
  transformar_long <- function(df, tipo_evento) {
    casos_long <- df %>%
      select(departamento, starts_with("casos_")) %>%
      pivot_longer(cols = -departamento, names_to = "año", values_to = "casos") %>%
      mutate(año = gsub("casos_", "", año))
    
    pob_long <- df %>%
      select(departamento, starts_with("pob_")) %>%
      pivot_longer(cols = -departamento, names_to = "año", values_to = "poblacion") %>%
      mutate(año = gsub("pob_", "", año))
    
    esperado_long <- df %>%
      select(departamento, starts_with("esperado_")) %>%
      pivot_longer(cols = -departamento, names_to = "año", values_to = "esperado") %>%
      mutate(año = gsub("esperado_", "", año))
    
    rem_long <- df %>%
      select(departamento, starts_with("REM_")) %>%
      pivot_longer(cols = -departamento, names_to = "año", values_to = "REM") %>%
      mutate(año = gsub("REM_", "", año))
    
    tabla_long <- casos_long %>%
      left_join(pob_long, by = c("departamento", "año")) %>%
      left_join(esperado_long, by = c("departamento", "año")) %>%
      left_join(rem_long, by = c("departamento", "año")) %>%
      arrange(departamento, año)
    
    write.csv(tabla_long, paste0("C:/Users/Hp/DENGUE/JBOOK/REM/REM_", str_to_title(tipo_evento), "_COL.csv"), row.names = FALSE)
    return(tabla_long)
  }
  
  # Clásico
  tabla_clasico_D <- calcular_tabla_nacional(C_D_A_P_C, "clasico", años_col)
  C_D_A_P_C <- calcular_rem(C_D_A_P_C, tabla_clasico_D, años_col)
  tabla_long_C_D <- transformar_long(C_D_A_P_C, "clasico")
  
  # Grave
  tabla_grave_D <- calcular_tabla_nacional(C_D_A_P_G, "grave", años_col)
  C_D_A_P_G <- calcular_rem(C_D_A_P_G, tabla_grave_D, años_col)
  tabla_long_G_D <- transformar_long(C_D_A_P_G, "grave")
  
  
  
  #----
  # ATLANTICO
  casos_mun_año_clasico <- read_csv("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/casos_mun_año_clasico.csv")
  casos_mun_año_grave <- read_csv("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/casos_mun_año_grave.csv")
  Poblacion_departamental<- read_csv("C:/Users/Hp/DENGUE/JBOOK/Poblacion/Poblacion_departamental.csv")
  colnames(Poblacion_departamental)[colnames(Poblacion_departamental) == "MUNICIPIO"] <- "municipio"
  años_col <- 2017:2023
  
  # Renombrar columnas excepto 'municipio' y 'TOTAL'
  colnames(Poblacion_departamental) <- colnames(Poblacion_departamental) %>%
    str_replace("^([0-9]{4})\\.0$", "pob_\\1")  # años con .0
  colnames(casos_mun_año_clasico) <- colnames(casos_mun_año_clasico) %>%
    str_replace("^([0-9]{4})$", "casos_\\1")   # años sin .0
  colnames(casos_mun_año_grave) <- colnames(casos_mun_año_grave) %>%
    str_replace("^([0-9]{4})$", "casos_\\1")    # años sin .0
    
  Poblacion_departamental <- Poblacion_departamental %>%
    select(-TOTAL)
  casos_mun_año_clasico <- casos_mun_año_clasico %>%
    select(-total_casos_clasico)
  casos_mun_año_grave <- casos_mun_año_grave %>%
    select(-total_casos_grave)
  
  
  C_M_A_P_C <- merge(casos_mun_año_clasico, Poblacion_departamental, by = "municipio", all.x = TRUE)
  C_M_A_P_G <- merge(casos_mun_año_grave, Poblacion_departamental, by = "municipio", all.x = TRUE)
  
  calcular_tabla_departamental <- function(df, tipo_evento, años) {
    totales <- sapply(df[, sapply(df, is.numeric)], sum, na.rm = TRUE) %>% as.list()
    
    tabla <- data.frame(
      año = años,
      casos = sapply(años, function(a) totales[[paste0("casos_", a)]]),
      poblacion = sapply(años, function(a) totales[[paste0("pob_", a)]])
    )
    
    tabla$tasa <- tabla$casos / tabla$poblacion
    write.csv(tabla, paste0("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/Tasa_X_año_ATL_", str_to_title(tipo_evento), ".csv"), row.names = FALSE)
    return(tabla)
  }
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
  
  transformar_long <- function(df, tipo_evento) {
    casos_long <- df %>%
      select(municipio, starts_with("casos_")) %>%
      pivot_longer(cols = -municipio, names_to = "año", values_to = "casos") %>%
      mutate(año = gsub("casos_", "", año))
    
    pob_long <- df %>%
      select(municipio, starts_with("pob_")) %>%
      pivot_longer(cols = -municipio, names_to = "año", values_to = "poblacion") %>%
      mutate(año = gsub("pob_", "", año))
    
    esperado_long <- df %>%
      select(municipio, starts_with("esperado_")) %>%
      pivot_longer(cols = -municipio, names_to = "año", values_to = "esperado") %>%
      mutate(año = gsub("esperado_", "", año))
    
    rem_long <- df %>%
      select(municipio, starts_with("REM_")) %>%
      pivot_longer(cols = -municipio, names_to = "año", values_to = "REM") %>%
      mutate(año = gsub("REM_", "", año))
    
    tabla_long <- casos_long %>%
      left_join(pob_long, by = c("municipio", "año")) %>%
      left_join(esperado_long, by = c("municipio", "año")) %>%
      left_join(rem_long, by = c("municipio", "año")) %>%
      arrange(municipio, año)
    
    write.csv(tabla_long, paste0("C:/Users/Hp/DENGUE/JBOOK/REM/REM_", str_to_title(tipo_evento), "_ATL.csv"), row.names = FALSE)
    return(tabla_long)
  }
  
  # Clásico
  tabla_clasico_M <- calcular_tabla_departamental(C_M_A_P_C, "clasico", años_col)
  C_M_A_P_C <- calcular_rem(C_M_A_P_C, tabla_clasico_M, años_col)
  tabla_long_C_M <- transformar_long(C_M_A_P_C, "clasico")
  
  # Grave
  tabla_grave_M <- calcular_tabla_departamental(C_M_A_P_G, "grave", años_col)
  C_M_A_P_G <- calcular_rem(C_M_A_P_G, tabla_grave_M, años_col)
  tabla_long_G_M <- transformar_long(C_M_A_P_G, "grave")
  
  