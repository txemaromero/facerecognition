function neuralnetworks (databaseNeuralNetworks, trainNumber, rangeInputNeuralNet, K, H)
%
% NEURALNETWORKS implements a neural network architecture. The Neural Network has a general feed-forward structure with three layers.
% Syntax:
%   NEURALNETWORKS (databaseNeuralNetworks, trainNumber, rangeInputNeuralNet, K, H)
% Input arguments:
%   databaseNeuralNetworks: It is a cell array of m rows and n columns. It contains the neural input and its class.
%   trainNumber: Number of training examples (see databaseNeuralNetworks).
%   rangeInputNeuralNet: It is an array of 1 row and 2 columns which corresponds with the range of input neural net.
%   K: Number of input neurals.
%   H: Number of nodes in the hidden layer.
% Output:
%   Saves the resultant information (neural network architecture), such as databaseNeuralNetworks, trainNumber, valuesInputNet,
%   targetOutputNet, K and H in databaseNeuralNetworks.dat.
%
% License: GNU GPL (General Public License). See http://www.gnu.org/licenses/#GPL for details.
%

    classList={};
    foundClass=false;
    
    for i=1:1:trainNumber
        j=1;
        foundClass=false;
        while (foundClass==false)&&(j<=length(classList))
            if (strcmp(databaseNeuralNetworks{i,2},classList{j})==1)
                foundClass=true;
                targetOutputNet(i,j)=1;
            else
                targetOutputNet(i,j)=0;
            end
            j=j+1;
        end
        if (foundClass==false)
            classList{j}=databaseNeuralNetworks{i,2};
            targetOutputNet(i,j)=1;
        end
    end
    
    if (trainNumber>0)
        
        for i=1:1:K
            rangeInputNet(i,:)=rangeInputNeuralNet;
        end
        net=newff(rangeInputNet,[H length(classList)],{'logsig','logsig'});
                            
        valuesInputNet=zeros(trainNumber,K);
        for i=1:1:trainNumber
            valuesInputNet(i,:)=databaseNeuralNetworks{i,1};
        end
        valuesInputNet=valuesInputNet';
        targetOutputNet=targetOutputNet';
        
        save('databaseNeuralNetworks.dat', 'databaseNeuralNetworks', 'trainNumber', 'valuesInputNet', 'targetOutputNet', 'K', 'H');
        save net;
        save classList;
        
    else
        
        messageRecognize=strcat('Neural network architecture. There are 0 training examples. K=', num2str(K), ' node/s. H=', num2str(H), ' node/s.');
        msgbox(messageRecognize, 'Recognize the face using neural networks', 'help');
        delete('databaseNeuralNetworks.dat');
    end
    
end
