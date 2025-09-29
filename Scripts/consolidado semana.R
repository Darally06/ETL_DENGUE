library(readr)
library(dplyr)
library(lubridate)
library(tidyr)
library(lubridate)
library(fastDummies)
library(stringr)

#---------
# DATA

col <- read_csv("C:/Users/Hp/DENGUE/Data/procesados/col_pros.csv", locale = locale(encoding = "latin1")) 
atl <- read_csv("C:/Users/Hp/DENGUE/Data/procesados/atl_pros.csv", locale = locale(encoding = "latin1")) 


col_clasico <- col %>% filter(evento == "Clasico")
col_grave <- col %>% filter(evento == "Grave")
atl_clasico <- atl %>% filter(evento == "Clasico")
atl_grave <- atl %>% filter(evento == "Grave")



# ---------
# PROCESAR

procesar_dengue <- function(df, excluir_municipio = FALSE) {
  
  # Asegurar fecha y crear semana_año
  df <- df %>%
    mutate(
      fecha_inicio_sintomas = as.Date(fecha_inicio_sintomas, format = "%d/%m/%Y"),
      semana_calc = lubridate::isoweek(fecha_inicio_sintomas),
      año_calc = lubridate::year(fecha_inicio_sintomas),
      semana_año = paste0("Semana_", semana_calc, "_", año_calc)
    )
  
  # Detectar categóricas
  categ <- df %>% select(where(is.character)) %>% colnames()
  
  # Omitir municipio si se pide
  if (excluir_municipio) {
    categ <- setdiff(categ, "municipio")
  }
  
  # Excluir semana_año y cualquier columna que empiece con "fecha_"
  categ <- categ[!grepl("^fecha_", categ)]
  
  
  # 🔒 Proteger semana_año: excluirla del one-hot encoding
  categ <- setdiff(categ, "semana_año")
  
  # One-hot encoding solo para las categóricas seleccionadas
  df_dummy <- dummy_cols(df, select_columns = categ, remove_first_dummy = FALSE, remove_selected_columns = TRUE)
  
  # Agrupar por semana y resumir
  resumen <- df_dummy %>%
    group_by(semana_año) %>%
    summarise(
      n_casos = n(),
      edad_media = mean(edad_años, na.rm = TRUE),
      across(starts_with(paste0(categ, "_")), sum, .names = "{.col}"),
      .groups = "drop"
    )
  
  return(resumen)
}

# ----
# Colombia
res_clasico_col <- procesar_dengue(col_clasico, excluir_municipio = TRUE)
res_grave_col <- procesar_dengue(col_grave, excluir_municipio = TRUE)

# Atlántico
res_clasico_atl <- procesar_dengue(atl_clasico, excluir_municipio = FALSE)
res_grave_atl <- procesar_dengue(atl_grave, excluir_municipio = FALSE)


#____________
# Guardar resumen 
write_csv(res_clasico_col, "C:/Users/Hp/DENGUE/Data/resumen_col_clasico.csv")
write_csv(res_clasico_atl, "C:/Users/Hp/DENGUE/Data/resumen_atl_clasico.csv")
write_csv(res_grave_col, "C:/Users/Hp/DENGUE/Data/resumen_col_grave.csv")
write_csv(res_grave_atl, "C:/Users/Hp/DENGUE/Data/resumen_atl_grave.csv")


# ----
# periodos
resumir_por_año <- function(df_semanal) {
  
  df <- df_semanal %>%
    mutate(
      año = as.integer(str_extract(semana_año, "\\d{4}$"))
    )
  
  df_año <- df %>%
    group_by(año) %>%
    summarise(
      casos_total = sum(n_casos, na.rm = TRUE),
      edad_promedio = weighted.mean(edad_media, w = n_casos, na.rm = TRUE),
      across(
        .cols = where(is.numeric),
        .fns = ~ sum(., na.rm = TRUE),
        .names = "{.col}"
      ),
      .groups = "drop"
    ) %>%
    select(-edad_media, -n_casos)  # Ya se resumen aparte
  
  return(df_año)
}

res_año_col_clasico <- resumir_por_año(res_clasico_col)
res_año_col_grave <- resumir_por_año(res_grave_col)
res_año_atl_clasico <- resumir_por_año(res_clasico_atl)
res_año_atl_grave <- resumir_por_año(res_grave_atl)