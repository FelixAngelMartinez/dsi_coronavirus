
% entrenamiento de rede LSTM
% numero de dias a predecir
nSim=7;
[YPred,dataTrainaux,YPredTotal]=LSTM(y,nSim)
plot(YPredTotal,'--*')
