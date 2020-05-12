% LSTM para probar epocas y learning rate
function [YPred]=LSTM_Hyperparam(y,nSim,epocas,learningrate)
            %LSTM
            dataTrainaux=y;
            dataTrain=y;
            mu = mean(dataTrain);
            sig = std(dataTrain);
            dataTrainStandardized = (dataTrain - mu) / sig;
            XTrain = dataTrainStandardized(1:end-1);
            YTrain = dataTrainStandardized(2:end);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% DEFINICION DE RED
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            numFeatures = 1;
            numResponses = 1;
            numHiddenUnits = 100;
            layers = [ ...
                sequenceInputLayer(numFeatures)
                lstmLayer(numHiddenUnits)
                fullyConnectedLayer(numResponses)
                regressionLayer];
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% OPCIONES
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % optimVars = [
            %     optimizableVariable('MaxEpochs',[50 100],'Type','integer')
            %     optimizableVariable('InitialLearnRate',[1e-2 1],'Transform','log')
            %     optimizableVariable('Momentum',[0.8 0.98])
            %     optimizableVariable('L2Regularization',[1e-10 1e-2],'Transform','log')];
            %
            % BayesObject = bayesopt(ObjFcn,optimVars, ...
            %     'MaxTime',14*60*60, ...
            %     'IsObjectiveDeterministic',false, ...
            %     'UseParallel',false);
            
            options = trainingOptions('adam', ...
                'MaxEpochs',epocas, ...
                'GradientThreshold',1, ...
                'InitialLearnRate',learningrate, ...
                'LearnRateSchedule','piecewise', ...
                'LearnRateDropPeriod',5, ...
                'LearnRateDropFactor',0.05, ...
                'Verbose',0);%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% ENTRENAMIENTO
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            net = trainNetwork(XTrain,YTrain,layers,options);
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%% PREDICCION
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            net = predictAndUpdateState(net,XTrain);
            [net,YPred] = predictAndUpdateState(net,YTrain(end));
            for i = 2:nSim
                [net,YPred(:,i)] = predictAndUpdateState(net,YPred(:,i-1),'ExecutionEnvironment','cpu');
            end
            YPred = sig*YPred + mu;
            YPred=max(YPred,0);
            YPredTotal=[dataTrainaux YPred];
            %LSTM
    
    
end