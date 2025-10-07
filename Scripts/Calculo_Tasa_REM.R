# CALCULO DE REM
library(readr)
library(stringr)


casos_dpto_año_clasico <- read_csv("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/casos_dpto_año_clasico.csv")
casos_dpto_año_grave <- read_csv("C:/Users/Hp/DENGUE/ETL/DATA/Resumen/casos_dpto_año_grave.csv")
Poblacion_nacional <- read_csv("C:/Users/Hp/DENGUE/JBOOK/Poblacion/Poblacion_nacional.csv")
colnames(Poblacion_nacional)[colnames(Poblacion_nacional) == "DEPARTAMENTO"] <- "departamento"


# Renombrar columnas excepto 'departamento' y 'TOTAL'
colnames(Poblacion_nacional) <- colnames(Poblacion_nacional) %>%
  str_replace("^([0-9]{4})\\.0$", "pob_\\1") %>%  # años con .0
  str_replace("^TOTAL$", "pob_total")            # total final
colnames(casos_dpto_año_clasico) <- colnames(casos_dpto_año_clasico) %>%
  str_replace("^([0-9]{4})$", "casos_\\1") %>%    # años sin .0
  str_replace("^total_casos_clasico$", "casos_total_clasico")
colnames(casos_dpto_año_grave) <- colnames(casos_dpto_año_grave) %>%
  str_replace("^([0-9]{4})$", "casos_\\1") %>%    # años sin .0
  str_replace("^total_casos_grave$", "casos_total_grave")

C_D_A_P_C <- merge(casos_dpto_año_clasico, Poblacion_nacional, by = "departamento", all.x = TRUE)
C_D_A_P_G <- merge(casos_dpto_año_grave, Poblacion_nacional, by = "departamento", all.x = TRUE)

# Crear lista con suma de cada columna numérica
TOTALES_C_D_A_P_C  <- sapply(C_D_A_P_C[, sapply(C_D_A_P_C, is.numeric)], sum, na.rm = TRUE)
TOTALES_C_D_A_P_C  <- as.list(TOTALES_C_D_A_P_C )


# Vector de años disponibles
años_col <- 2013:2023

# Calcular tasa por cada año
for (año in años_col) {
  casos_col <- paste0("casos_", año)
  pob_col   <- paste0("pob_", año)
  tasa_col  <- paste0("tasa_", año)
  
  C_D_A_P_C[[tasa_col]] <- C_D_A_P_C[[casos_col]] / C_D_A_P_C[[pob_col]]
  C_D_A_P_G[[tasa_col]] <- C_D_A_P_G[[casos_col]] / C_D_A_P_G[[pob_col]]
}


