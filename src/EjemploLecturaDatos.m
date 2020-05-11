%% BORRAR GRÁFICAS MEMORIA Y CONSOLA %%
close all, clear, clc   % cerrar ventanas graficas, borrar memoria y consola

%% Llamamiento a la función HistoricDataSpain() %%
[output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()

dia_actual = 56; %empezamos desde el dia 56, correspondiente al 15 de abril
nSim = 7; %hacemos predicciones a 7 días vista

for dia = 0 : 16
    %valores del vector resultado inicial, donde guardamos las predicciones
    %del día para todas las CCAA
    resultado = ["AcumulatedPRC", "Hospitalized", "Critical", "Deaths", "AcumulatedRecoveries"];
    
    %Recorremos todas las CCAA
    for i = 1 : size(output.historic,1)
        %Casos PCR
        y = output.historic{i,1}.AcumulatedPRC(1:dia_actual + dia);
        [YPred_PCR,dataTrainaux,YPredTotal] = LSTM(y, nSim);
        
        %Hospitalizados
        y = output.historic{i,1}.Hospitalized(1:dia_actual + dia);
        [YPred_Hospitalized,dataTrainaux,YPredTotal] = LSTM(y, nSim);
        
        %UCI
        y=output.historic{i,1}.Critical(1:dia_actual+dia);
        [YPred_Critical,dataTrainaux,YPredTotal] = LSTM(y, nSim);
        
        %Fallecidos
        y = output.historic{i,1}.Deaths(1:dia_actual+dia);
        [YPred_Deaths,dataTrainaux,YPredTotal] = LSTM(y ,nSim);
        
        %Recuperados
        y = output.historic{i,1}.AcumulatedRecoveries(1:dia_actual + dia);
        [YPred_AcumulatedRecoveries,dataTrainaux,YPredTotal] = LSTM(y, nSim);
        
        % Guardamos todos los resultados en Y_Pred_CCAA, y transponemos la
        % matriz resultante para guardarla en la matriz resultados
        Y_Pred_CCAA = [YPred_PCR; YPred_Hospitalized; YPred_Critical; YPred_Deaths; YPred_AcumulatedRecoveries]';
        resultado = [resultado;Y_Pred_CCAA];
        sprintf('CCAA %d', i)
         
    end
    
    % Personalizar el nombre del fichero
    file = "src\predicciones\MCB_FMM_" + strrep(output.historic{i}.label_x(dia_actual+dia), '-', '_') + ".csv";
    % Guardamos el resultado de la iteración a fichero
    writematrix(resultado, file);
end

%output.historic{1,1}.Cases(1:56)

% id_comunidad=7 % id comunidad: 7=CLM
% name_ccaa{id_comunidad}   % nombre de comunidad
% output.historic{id_comunidad} % estrucutura
% y=output.historic{id_comunidad}.Cases% serie temporal de
% plot(y) %dibuja casos activos
