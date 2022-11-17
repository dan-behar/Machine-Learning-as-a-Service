library(plumber)
library(vcd)
library(pROC)
library(dplyr)
library(rpart)
library(readr)
library(lubridate)
library(jsonlite)
library(randomForest)
library(gridExtra)
library(grid)


# Utilise post method to send JSON unseen data, in the same 
# format as our dataset

#Lectura del modelo--------------------------------
modelo <- readRDS("random_forest.rds")
modelo$modelInfo

train <- readRDS("metricas/train.rds")[1,]
#--------------------------------------------------

#Generador de Logs
logge <- function(req, res){
  # boole <- length(req$args)
  d <- Sys.time()
  y <-list('usuario' = Sys.getenv("USERNAME"),
           'end_point' = req$PATH_INFO,
           'user_agent'=req$HTTP_USER_AGENT,
           'time' = d, 
           'payload'=req$body, 
           'output' = res$body
  )
  
  archivo <- toJSON(y, auto_unbox = TRUE)
  
  wd <- getwd()
  
  dir <- paste0(wd,"/logs","/year=", year(d), "/month=", month(d), "/day=", day(d))
  
  dir.create(dir, recursive = TRUE)
  
  write(archivo, file = paste0(dir,"/",as.integer(d),".json"), append = TRUE)
}

#Generador de metricas
mediciones = function(CM)
{
  TN = CM[1,1]
  TP = CM[2,2]
  FP = CM[2,1]
  FN = CM[1,2]
  
  recall = TP/(TP+FN)
  accuracy = (TP+TN)/(TN+TP+FP+FN)
  presicion = TP/(TP+FP)
  f1 = (2*presicion*recall)/(presicion+recall)
  
  values = c(
    round(recall,2), round(accuracy,2), round(presicion,2), round(f1,2), 0
  )
  names = c("RECALL", "ACCURACY", "PRECISION", "SPECIFICITY", "AUC")
  
  result = cbind(names, values)
}


#* Test connection
#* @get /connection-status
function(){
  list(status = "Connection to Stranded Patient API successful", 
       time = Sys.time(),
       username = Sys.getenv("USERNAME"))
}



#* Predice si un cliente es "bueno" o "malo" para pagar su prestamo
#* @serializer json
#* @post /predict
function(req, res){
  data <- as.data.frame(req$body)
  data$Risk <- "bad"
  info <- rbind(train, data)
  info <- info[-1,]
  
  result <- data.frame(predict(modelo, info))
  
  res$body <- result
  
  logge(req,res)
  
  result
}



#* Predice si varios clientes son "buenos" o "malos" para pagar sus prestamos
#* @serializer json
#* @post /batches
function(req, res){
  data <- as.data.frame(req$body)
  data$Risk <- "bad"
  info <- rbind(train, data)
  info <- info[-1,]
  
  result <- data.frame(predict(modelo, info))
  
  res$body <- result
  
  logge(req,res)
  
  result
}


#* Metricas del modelo respecto un dataset de pruebas
#* @serializer png
#* @post /metricas
function(req, res){
  test <- as.data.frame(req$body$file$parse)
  test <- rbind(train, test)
  test <- test[-1,]
  
  result <- data.frame(predict(modelo, test))
  
  res$body <- result
  req$body <- toJSON(test)
  
  logge(req,res)
  
  #Prediccion
  rf.pred = predict(modelo, test)
  test$Predicted = rf.pred
  
  #Creando Matriz de confusion
  matrix = with(test, table(Predicted, Risk))
  
  layout(matrix(c(1, 2,  # First, second
                  3, 3), # and third plot
                nrow = 2,
                ncol = 2,
                byrow = TRUE))

  rocaoc = roc(test$Risk ~ test$Duration)
  tabla = mediciones(matrix)
  tabla[5,2] = round(rocaoc$auc,4)
  
  mosaicplot(matrix, main = "Confusion Matrix", shade = FALSE, legend = FALSE, 
                       cex.axis = 0.85, color = 2:3)
  plot(rocaoc)
  pushViewport(viewport(y=.25,height=.5))
  grid.table(tabla)

}


#* @plumber
function(pr){
  pr %>% 
    pr_set_api_spec(yaml::read_yaml("openapi.yaml"))
  
}
