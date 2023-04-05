## Autores: 
- Cruz del Cid [CruzdelCid](https://github.com/CruzdelCid)
- Daniel Behar [dan-behar](https://github.com/dan-behar)

# Machine Learning as a Service

## Sección I: Descripcion de la Data.

El dataset `german_credit_data.csv` es un dataset de informacion acerca de los clientes de una red crediticia alemana.
Dicho dataset contiene las siguientes variables:
  * `Age`: variable de tipo entera que contiene la edad de la persona.
  * `Sex`: variable de tipo string que contiene el sexo de la persona. Esta debe ordenarse por factor.
  * `Job`: variable de tipo entera que contiene un numero que representa la categoria de trabajo que desempeña la                persona.
  * `Housing`: variable de tipo string que indica el estado de la casa de la persona. Esta debe ordenarse por factor.
  * `Saving Accounts`: variable de tipo string que indica si la persona tiene una cuenta de ahorro o una descripcion
           de cuanto tiene, que puede ser little, moderate, quite rich o rich. Esta debe ordenarse por factor.
  * `Checking Account`: variable de tipo string que indica si la persona tiene una cuenta monetaria y una descripcion
           de cuanto tiene, que puede ser little, moderate, quite rich o rich. Esta debe ordenarse por factor.
  * `Credit Amount`: variable de tipo entera que indica la cantidad de credito asignada a la persona.
  * `Duration`: variable de tipo entera que indica la cantidad de credito asignada a la persona.
  * `Purpose`: variable de tipo string que detalla el uso que se le dara al prestamo. Esta debe ordenarse por factor.
  * `Risk`: resultado que los evaluadores bancarios le asignaron a la persona. Esta debe ordenarse por factor.

## Sección II: Descripcion del Modelo.

El modelo recibe todos los valores descritos anteriormente y retorna si la persona es "buena" o "mala" para pagar el prestamo que esta solicitando. El modelo consiste en un bosque de arboles de regresion. Este tipo de modelo contiene una cantidad determinada de arboles, donde cada arbol predice si la persona es buena o no. Para determinar el resultado, los arboles "debaten" entre si sus hallazgos y definen si es o no buena la persona, es decir, llegan a un consenso. El modelo retorna si la persona es buena (good) o no (bad).
    
## Sección III: Documentacion de los Endpoints.

### Connection-status

Este endpoint solamente nos sirve para validar que el servicio esta activo y funcionando. Debe responder a un request con un codigo tipo 200.

### Predict

Este endpoint recibe un JSON con solamente 1 paquete de informacion necesaria para predecir si la persona es buena o no. Retorna el valor "good" o "bad" una vez haya terminado la prediccion.

### Batches

Este endpoint recibe un JSON con varios paquetes de informacion necesaria para predecir si las personas son buenas o no. Retorna el valor "good" o "bad" para cada prediccion que se solicito al modelo.

### Metricas

Este endpoint recibe un dataset tipo "test" para validar que el modelo si este prediciendo correctamente, es decir, que si tome las variables correctas y que no haya caido en `Overfitting` o en `Underfitting`. Retorna un PNG con:
  * La matriz de confusion
  * Una grafica detallando el ROC y AOC del modelo
  * Una tabla con: Accuracy, Recall, Precision y Specificity
