#'*|----------------------------------------------------------------------------|*
#'*|--|Anonimización de: NASC 2022, community listing                           |*
#'*|--| Autheur: NBS                                                             |*
#'*|--| Date: 2025-09-18                                                        |*
#'*|----------------------------------------------------------------------------|*
#'*|--| Conjunto de datos: Phase2=>12_c8b_loan_ano.dta                                    |*
#'*|----------------------------------------------------------------------------|*

rm(list =ls()) # Limpiar el entorno de las variables

library(dplyr)
library(agrisvyr)
library(tidyr)
library(questionr)
library(labelled)
library(readxl)
library(tidyr)
library(haven)

# Cargar el objeto agrisvy y los demás archivos (funciones) que pueda haber en la carpeta "_R"
purrr::walk(file.path("_R",list.files(path="_R",pattern = ".R$")),source)

preprocMessage("Phase2=>12_c8b_loan_ano.dta")

# Lectura del conjunto de datos
data=read_dta(file.path(data_path,"Phase2/12_c8b_loan_ano.dta"))

# Carga del archivo de clasificación de variables
variable_classification=read_excel(path="01.Classificacao de variaveis/Phase2_VarClas.xlsx",sheet  = "12_c8b_loan_ano") %>% select(Name:Questions)

#Carga del archivo que contiene las etiquetas de las variables, tanto las antiguas como las nuevas
variable_labels=read_excel(path="07.Descripcion de archivos/Phase2_labels.xlsx",sheet ="12_c8b_loan_ano")

# Añadir las etiquetas de las variables antes de un posible cambio de nombre de las variables
data=data %>% agrisvyr::assignNewVarLabels(variable_labels)

#********************************************************************************
# Tratamiento/exploración de los datos antes de la eliminación de las variables *
#                        clasificadas como ID o D                               *
#********************************************************************************

#  Verificación de duplicados
# is_id(data,c())
# COMENTARIOS:

#*******************************************************************************
#----------- ELIMINACIÓN DE LAS VARIABLES CLASIFICADAS COMO ID O D -------------
#*******************************************************************************
variables_to_delete=variable_classification %>% filter(Classification %in% c("DI","D")) %>% pull(Name)

variables_to_delete=variables_to_delete[!is.na(variables_to_delete)]

# Lista de las variables a eliminar
variables_to_delete

# Eliminación de las variables
data=data %>% dplyr::select(-any_of(variables_to_delete))

#*******************************************************************************
# --------------- Cambio de nombre de las variables, en su caso ----------------
#*******************************************************************************

data=data %>% dplyr::rename()

#*******************************************************************************
# Etiquetado de los valores o corrección de las etiquetas de valores, en su caso *
#*******************************************************************************

data=data %>% set_value_labels()

#*******************************************************************************
#---- Definición o corrección de las etiquetas de las variables, en su caso ----
#*******************************************************************************

# Reintegración de las etiquetas de las variables si han sido eliminadas
# durante el tratamiento, especialmente al utilizar funciones como
# dplyr::mutate, etc.
data=data %>% agrisvyr::assignNewVarLabels(variable_labels)

#*******************************************************************************
#---------------    Registro de los datos procesados   -------------------------
#*******************************************************************************

# Escanear la base de datos (etiquetas de las variables y de los valores)
labelled::look_for(data)

# Guardado de los datos procesados
write_dta(data,"03.Datos preprocesados/Phase2/12_c8b_loan_ano_proc.dta")
