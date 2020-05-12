%% Clase para obtencion mejor hiperparámetros
close all, clear, clc   % cerrar ventanas graficas, borrar memoria y consola
[output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()
nSim = 7; % Días a predecir.
dia_actual=70; % día hasta desde el que partiremos para obtener los datos de test.
rmse=0; % Inicializacion rmse.

accumulative_rmse=0;    % Inicializacion Error acumulado medio al cuadrado de todas las comunidades autónomas
min_error=1000000000; % Inicializacion Menor error encontrado entre las predicciones y lo real, inicializado con un alto valor.
best_epocas=0;  %  Inicializacion Mejor epoca encontrada
best_learningrate=0;    % Inicializacion Mejor learning rate encontrado

for epocas=[140 180] %Tested: 70 80 90 100 110 120 130 140 150 200
    for learningrate= [ 0.005 ] %Tested 0.003  0.010
        fprintf("Epoca a probar: %d\n Learning rate a probar: %d\n",epocas,learningrate);
        for ccaa=1:19
            
            y = output.historic{ccaa,1}.AcumulatedPRC(1:dia_actual);
            [YPred_PCR] = LSTM_Hyperparam(y, nSim,epocas , learningrate);
            YTest_PCR = output.historic{ccaa,1}.AcumulatedPRC(dia_actual+1:dia_actual+nSim);
            rmse = rmse + sqrt(mean((YPred_PCR-YTest_PCR).^2));
            
            y = output.historic{ccaa,1}.Hospitalized(1:dia_actual);
            [YPred_Hospitalized] = LSTM_Hyperparam(y, nSim,epocas , learningrate);
            YTest_Hospitalized = output.historic{ccaa,1}.Hospitalized(dia_actual+1:dia_actual+nSim);
            rmse = rmse + sqrt(mean((YPred_Hospitalized-YTest_Hospitalized).^2));
            
            y = output.historic{ccaa,1}.Critical(1:dia_actual);
            [YPred_Critical] = LSTM_Hyperparam(y, nSim,epocas , learningrate);
            YTest_Critical = output.historic{ccaa,1}.Critical(dia_actual+1:dia_actual+nSim);
            rmse = rmse + sqrt(mean((YPred_Critical-YTest_Critical).^2));
            
            y = output.historic{ccaa,1}.Deaths(1:dia_actual);
            [YPred_Deaths] = LSTM_Hyperparam(y, nSim,epocas , learningrate);
            YTest_Deaths = output.historic{ccaa,1}.Deaths(dia_actual+1:dia_actual+nSim);
            rmse = rmse + sqrt(mean((YPred_Deaths-YTest_Deaths).^2));
            
            y = output.historic{ccaa,1}.AcumulatedRecoveries(1:dia_actual);
            [YPred_Critical] = LSTM_Hyperparam(y, nSim,epocas , learningrate);
            YTest_Critical = output.historic{ccaa,1}.AcumulatedRecoveries(dia_actual+1:dia_actual+nSim);
            rmse = rmse + sqrt(mean((YPred_Critical-YTest_Critical).^2));
            
            %% Imagenes
            %         figure
            %         subplot(2,1,1)
            %         plot(YTest)
            %         hold on
            %         plot(YPred,'.-')
            %         hold off
            %         legend(["Observed" "Predicted"])
            %         ylabel("Cases")
            %         title("Forecast with Updates")
            %
            %         subplot(2,1,2)
            %         stem(YPred - YTest)
            %         xlabel("Días futuros")
            %         ylabel("Error")
            %         title("RMSE = " + rmse)
            accumulative_rmse=accumulative_rmse+rmse;
            % Si no vamos a obtener una parametrización mejor, que se salga
            if accumulative_rmse>min_error
                fprintf("  Error: %f es mayor a: %f -> No mejora\n",accumulative_rmse,min_error);
                break;
            end
            rmse=0; % Restauramos el rmse para la siguiente ccaa
        end% Fin ccaa
  
        if accumulative_rmse<min_error
            min_error=accumulative_rmse; % Actualizamos el mejor valor
            best_learningrate=learningrate; % Actualizamos el mejor nivel de aprendizaje
            best_epocas=epocas; % Actualizamos el mejor nivel de epocas            
            fprintf("Nuevo mejor error encontrado: %f\n",min_error);
            fprintf("--------------------------------\n",min_error);
        end
        accumulative_rmse=0; % Reseteamos el valor del error acumulado, para que las proximas iteracciones.
    end %Learning rate
end %Fin Epocas
fprintf("Error mínimo encontrado ha sido de: %f\n",min_error);
fprintf("El mejor nivel de learning rate es: %d\n",best_learningrate);
fprintf("El mejor nivel de épocas es: %d",best_epocas);