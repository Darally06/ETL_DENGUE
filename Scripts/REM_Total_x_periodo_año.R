library(readr)
library(dplyr)
library(tidyr)

# --------------------------------------------------------
# 1. Cargar datos
# --------------------------------------------------------
casos_periodo <- read_csv("C:/ETL_DENGUE/DATA/casos_x_periodo.csv")
poblacion <- read_csv("C:/ETL_DENGUE/DATA/poblacion_depart.csv")

# Asegurar nombre "municipio"
casos_periodo <- casos_periodo %>% rename(municipio = municipio)
poblacion <- poblacion %>% rename(municipio = municipio)

# Renombrar población a pob_YYYY si es necesario
poblacion <- poblacion %>%
  rename_with(~ paste0("pob_", .x), matches("^[0-9]{4}$"))

# --------------------------------------------------------
# 2. Añadir población por año a la tabla de periodos
# --------------------------------------------------------
casos_periodo <- casos_periodo %>%
  left_join(
    poblacion %>% 
      pivot_longer(cols = starts_with("pob_"),
                   names_to = "año",
                   values_to = "poblacion") %>%
      mutate(año = as.numeric(gsub("pob_", "", año))),
    by = c("municipio", "año")
  )

# --------------------------------------------------------
# 3. Calcular tasa departamental por año-periodo
# --------------------------------------------------------
tasa_departamental <- casos_periodo %>%
  group_by(año, periodo) %>%
  summarise(
    casos_dep = sum(casos, na.rm = TRUE),
    pob_dep = sum(poblacion, na.rm = TRUE),
    tasa = casos_dep / pob_dep,
    .groups = "drop"
  )

# --------------------------------------------------------
# 4. Calcular ESPERADO y REM por municipio-año-periodo
# --------------------------------------------------------
casos_periodo <- casos_periodo %>%
  left_join(tasa_departamental, by = c("año", "periodo")) %>%
  mutate(
    esperado = poblacion * tasa,
    REM = casos / esperado
  )

casos_periodo <- casos_periodo %>% select(-total,-casos_dep,-pob_dep)


# --------------------------------------------------------
# 5. Guardar resultados
# --------------------------------------------------------
write_csv(casos_periodo, "C:/ETL_DENGUE/ARCHIVOS/REM/REM_periodo_municipio.csv")




