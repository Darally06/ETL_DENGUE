
# ***Sobre los Datos [Fuentes y ETL]***


## ➡️ **[Datos Requeridos](https://github.com/Darally06/DATOS_DENGUE)**

- Registros de casos de dengue por unidad geográfica.  
- Proyección poblacional en el periodo estudiado.  
- Variables meteorológicas.  

### *Fuentes de datos utilizadas en el estudio*

| **Fuente** | **Unidad geográfica** | **Periodo** | **Descripción** |
|-------------|------------------------|--------------|------------------|
| SIVIGILA | Colombia | 2013–2023 | Registro de casos. |
| SIVIGILA | Atlántico | 2017–2023 | Registro de casos. |
| DHIME | Atlántico | 2017–2023 | Variables climáticas. |
| DANE | Colombia | 2013–2023 | Proyección poblacional y mapa geográfico. |
| DANE | Atlántico | 2017–2023 | Proyección poblacional y mapa geográfico. |

---

## ➡️ **[Preprocesamiento](https://github.com/Darally06/ETL_DENGUE)**

### *SIVIGILA*

#### Para Colombia

1. Se descargaron de la página los archivos por año y por evento.  
2. Se comparó la cantidad de variables disponibles de los 22 archivos con los ‘Datos_2012_210’, que variaba entre 120–140.  
3. Se convirtieron el nombre de algunas variables abreviadas por temas de interpretabilidad.  
4. Se tomó el departamento y municipio de ocurrencia como unidad geográfica referencial.  
5. Se descartaron 70 variables que representaban poca o nula información o fueron consideradas no relevantes para este estudio.  
6. Se unieron los datasets en uno solo.  
7. Se creó la variable `evento` [Grave, Clásico] a partir de `cod_eve`.  
8. Se obtuvieron 22 variables de estudio, que luego de revisar registros duplicados, representaban 947,810 casos.  

#### Para Atlántico

1. Se obtuvieron los datos, un archivo por año con ambos eventos.  
2. Se comparó la cantidad de variables disponibles en los 7 archivos con los datos en ‘2019’, entre 71 y 134 columnas.  
3. Se convirtieron los nombres de algunas variables abreviadas por temas de interpretabilidad.  
4. Se descartaron en total 140 variables que representaban poca o nula información o fueron consideradas no relevantes para este estudio.  
5. Se unieron los datasets en uno solo.  
6. Se tomaron solo los registros donde el departamento de ocurrencia fuera ‘ATLÁNTICO’.  
7. Se creó la variable `evento` [Grave, Clásico] a partir de `cod_eve`.  
8. Se corrigieron diferencias en los strings de municipio.  
9. Se obtuvieron 19 variables de estudio, que luego de revisar registros duplicados, representaban 31,800 casos.  

### *Variables del conjunto de datos de dengue en Colombia*

| **Categoría** | **Variables** |
|----------------|----------------|
| *Demográficas* | Edad, ciclo vital, sexo, grupo étnico, régimen de salud. |
| *Espaciales* | Departamento (Colombia), municipio (Atlántico), área, localidad (Barranquilla). |
| *Temporales* | Año, semana, fecha de inicio de síntomas, fecha de consulta. |
| *Evento* | Evento, tipo de caso, hospitalización, muerte. |

---

#### En General

1. Se creó la variable `edad_años` para representar la edad de acuerdo con la unidad de medida y estandarizarla en años. Los valores desconocidos o `NA` se tomaron como 0, realizando posteriormente una revisión con la fecha de nacimiento.  
2. Se creó la variable `ciclo_vital` para categorizar los grupos etarios.  
3. Se realizaron correcciones en la escritura de los nombres propios de las unidades geográficas.  
4. Se mapearon las variables categóricas numéricas a su correspondiente significado textual, de acuerdo con la ficha técnica del sistema SIVIGILA.  
5. Se tomó la fecha de inicio de síntomas como referencia temporal para el análisis.  
6. Se tuvieron en cuenta las fechas de hospitalización, nacimiento y notificación.  
7. Se creó la variable `grupo_etnico` a partir de `pertenencia_etnica`, conforme a la Constitución colombiana, donde se reconocen tres etnicidades.  

---

### *DHIME*

1. Se descargaron los datos de diferentes estaciones ubicadas en el departamento del Atlántico que contaban con registros de las variables de interés durante el periodo de estudio.  
2. Las mediciones se tomaron con base en el registro medio diario de cada estación.  
3. Se concatenaron los registros provenientes de todos los *datasets*.  
4. A partir de la fecha de medición, se pivotó una tabla para obtener un único registro por fecha y por estación.  
5. Se corroboró que existiera al menos un registro por fecha dentro del periodo analizado.  
6. En total, se obtuvieron 14,418 registros.  

#### Variables climáticas de IDEAM

| **Categoría** | **Variables** |
|----------------|----------------|
| *Identificadoras* | Código Estación, Nombre Estación. |
| *Mediciones* | Fecha, Humedad relativa máxima/mínima, Precipitación, Temperatura máxima/mínima. |
| *Ubicación* | Latitud, Longitud, Altitud. |

---

### *DANE*

1. Se descargaron los archivos de proyección de población municipal correspondientes a los periodos 2005–2017 y 2018–2042.  
2. Se filtraron los años de interés considerando únicamente el área geográfica total.  
3. Para el caso de Colombia, se sumaron los totales de población de cada municipio con el fin de obtener el valor agregado por departamento.  
4. Para el caso del departamento del Atlántico, se seleccionaron únicamente los municipios correspondientes a su jurisdicción.  
5. Se realizó un pivotado de la tabla para que cada fila representara una unidad geográfica y cada columna un año de estudio, de manera que cada celda contuviera el valor poblacional respectivo.  
6. Se agregó una columna adicional con el total estimado de población para el periodo analizado.  
