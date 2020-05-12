%% BORRAR GR�FICAS MEMORIA Y CONSOLA %%
close all, clear, clc   % cerrar ventanas graficas, borrar memoria y consola
% Gestionar Directorio: path , pwd, cd, ls
%% Llamamiento a la funci�n HistoricDataSpain() %%
[output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()

dia_actual = 56; %empezamos desde el dia 56, correspondiente al 15 de abril
nSim = 7; %hacemos predicciones a 7 d�as vista

for dia = 1 : 15
    %valores del vector resultado inicial, donde guardamos las predicciones
    %del d�a para todas las CCAA
    resultado = ["CCAA", "Fecha", "AcumulatedPRC", "Hospitalized", "Critical", "Deaths", "AcumulatedRecoveries"];
    CCAAs=["AN", "AR", "AS", "IB", "CN", "CB", "CM", "CL", "CT", "CE", "VC", "EX", "GA", "MD", "ML", "MC", "NC", "PV", "RI"];
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
        
        %Creacion de la columna fechas y comunidades autonomas, para
        %posteriormente asociarla a los datos predichos
        for j = 1:nSim
            Fecha(j)=output.historic{j}.label_x(dia_actual+j+dia-1);
            CCAA(j)=CCAAs(i);
        end
        % Guardamos todos los resultados en Y_Pred_CCAA, y transponemos la
        % matriz resultante para guardarla en la matriz resultados
        Y_Pred_CCAA = [CCAA; Fecha; YPred_PCR; YPred_Hospitalized; YPred_Critical; YPred_Deaths; YPred_AcumulatedRecoveries]';
        resultado = [resultado;Y_Pred_CCAA];
        sprintf('Iteracción: %d CCAA: %d', dia, i)
    end
    
    % Personalizar el nombre del fichero
    file = "predicciones/MCB_FMM_" + strrep(output.historic{i}.label_x(dia_actual+dia), '-', '_') + ".csv";
    % Guardamos el resultado de la iteraci�n a fichero
    writematrix(resultado, file);
end

