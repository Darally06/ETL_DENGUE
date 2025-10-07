install.packages("openxlsx")
library(openxlsx)
library(dplyr)
library(tidyr)

# Cambiamos de largo a ancho

datos <- read.csv('C:/Dengue/casos_dengue_clasico.csv')
poblacion <- read.csv("C:/Dengue/proyeccion_poblacion_largo.csv")

datos <- datos %>%
  left_join(poblacion, by = c("departamento", "ano"))

datos_ancho <- datos %>%
  pivot_wider(
    names_from = ano,           # las columnas serán los años
    values_from = c(casos, poblacion)  # los valores que queremos expandir
  )

# Ver los primeros resultados
head(datos_ancho)

write.csv(datos_ancho, "C:/Dengue/REM_Clasico.csv")


# Ruta de archivo de casos con formato ancho

df <- read.csv("C:/Dengue/REM_Clasico.csv") 


# 1. Extraer nombres de columnas de casos y poblacion
casos_cols <- grep("^casos_", names(df), value = TRUE)
poblacion_cols <- grep("^poblacion_", names(df), value = TRUE)

# 2. Calcular sumas por año
suma_casos <- colSums(df[casos_cols], na.rm = TRUE)
suma_pobla <- colSums(df[poblacion_cols], na.rm = TRUE)

# 3. Calcular tasas año a año
tasa_por_año <- suma_casos / suma_pobla

names(tasa_por_año) <- gsub("casos_", "", names(tasa_por_año))


tasa_por_año

# 2. Crear nuevas columnas: poblacion_año * tasa[año]
for (col in poblacion_cols) {
  # Extraer año
  anio <- gsub("poblacion_", "", col)
  
  # Crear nuevo nombre de columna
  esperado <- paste0("esp_", anio)
  
  # Multiplicar población por la tasa correspondiente
  df[[esperado]] <- df[[col]] * tasa_por_año[anio]
}



# Extraer columnas resultado
esperado <- grep("^esp_", names(df), value = TRUE)

# Crear nuevas columnas: casos / resultado
for (i in seq_along(casos_cols)) {
  anio <- gsub("casos_", "", casos_cols[i])
  rem <- paste0("rem_", anio)
  
  df[[rem]] <- df[[casos_cols[i]]] / df[[esperado[i]]]
}

library(writexl)

write.csv(df, "C:/Dengue/REM_Clasico.csv")

library(tidyr)

df_largo <- df %>%
  pivot_longer(
    cols = matches("^(casos|poblacion|esp|rem)_"),  # columnas a pivotear
    names_to = c(".value", "anio"),   # .value mantiene prefijos como variables
    names_pattern = "(.*)_(\\d+)"     # separa prefijo y año
  )


write.csv(df_largo, "C:/Dengue/REM_Clasico_Largo.csv")
