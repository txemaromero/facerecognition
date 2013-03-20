
clear all;
clc;

optionMain=0;
exitMain=6;
while optionMain~=exitMain
    
    optionMain=menu('PCA and Neural Networks applied to Face Recognition', '[Step 1] Images ...', 'Image projection onto Eigenspace', '[Step 2] Recognize the face using neural networks ...', 'Learn about application ...', 'License', 'Exit');

    if optionMain==1 %[Step 1] Images ...
    
        optionMainImages=0;
        exitMainImages=4;
        while optionMainImages~=exitMainImages
            
            optionMainImages=menu('Images', '[Step 1] Load images to database ...', 'Information about database', 'Delete database', 'Return to Main menu');
                
            if  optionMainImages==1 %Load images to database ...
                
                optionMainImagesLoad=0;
                exitMainImagesLoad=3;
                while optionMainImagesLoad~=exitMainImagesLoad
                    
                    optionMainImagesLoad=menu('Load images to database', 'From selected file', 'From selected directory', 'Return to Images menu');
                        
                    if  optionMainImagesLoad==1 %From selected file
                            
                        [nameFile, pathName]=uigetfile('*.*', 'Select an image');
                        if nameFile~=0
                            clc;
                            disp('Input image has been selected.');
                            
                            if (exist('databaseImages.dat')==2)
                                load('databaseImages.dat', '-mat');
                                msgbox('Images database already exists. Image added.', 'Database result', 'help');
                            else
                                faceNumber=0;
                                msgbox('Images database was empty. Database has just been created. Image added.', 'Database result', 'help');
                            end

                            faceNumber=faceNumber+1;
                            databaseImagesListPath{faceNumber}=pathName;
                            databaseImagesName{faceNumber}=nameFile;
                            disp(strcat('It was added to database: ', char(databaseImagesListPath{faceNumber}), databaseImagesName{faceNumber}));
                            save('databaseImages.dat', 'databaseImagesListPath', 'databaseImagesName', 'faceNumber');
                            
                            if (exist('databaseNeuralNetworks.dat')==2)
                                delete('databaseNeuralNetworks.dat');
                                msgbox('Therefore, NeuralNetworks database was removed from the current directory.', 'Database removed', 'help');
                            end
                            
                        else
                            warndlg('Input image must be selected.', ' Warning ');
                        end

                    elseif  optionMainImagesLoad==2 %From selected directory
                        
                        nameDirectory = uigetdir;
                        if nameDirectory~=0
                            
                            messageImagesNumber={strcat('Insert the number of images to read from: ', nameDirectory, '\')};
                            msgbox(messageImagesNumber, 'Load images to database', 'help');
                    
                            prompt='The number must be a positive integer <= 500';
                            title='Number of images';
                            lines=1;
                            def={'25'};
                            answer=inputdlg(prompt, title, lines, def);
                            parameter=double(str2num(char(answer)));
                            if size(parameter, 1)~=0
                                imagesNumber=parameter(1);
                                if (imagesNumber<=0)||(floor(imagesNumber)~=imagesNumber)||(~isa(imagesNumber, 'double'))
                                    warndlg('The number must be a positive integer <= 500', ' Warning ');
                                else
                                    imagesName=input('Basename database images (by default, mu, without number nor suffix): ', 's');
                                    if isempty(imagesName)
                                        imagesName='mu';
                                    end
                                    imagesFormat=input('Images format (by default, jpg): ','s');
                                    if isempty(imagesFormat)
                                        imagesFormat='jpg';
                                    end    

                                    if (exist('databaseImages.dat')==2)
                                        load('databaseImages.dat', '-mat');
                                        msgbox('Images database already exists. Image added.', 'Database result', 'help');                                        
                                    else
                                        faceNumber=0;
                                        msgbox('Images database was empty. Database has just been created. Image added.', 'Database result', 'help');
                                    end   
                                    
                                    faceNumber=faceNumber+1;
                                    databaseImagesListPath{faceNumber}=strcat(nameDirectory, '\');
                                    databaseImagesName{faceNumber}=strcat(imagesName, num2str(1), '.', imagesFormat);
                                    disp(strcat('It was added to database: ', char(databaseImagesListPath{faceNumber}), databaseImagesName{faceNumber}));
                                    i=2;
                                    
                                    while (i<=imagesNumber)
                                        faceNumber=faceNumber+1;
                                        databaseImagesListPath{faceNumber}=strcat(nameDirectory, '\');
                                        databaseImagesName{faceNumber}=strcat(imagesName, num2str(i), '.', imagesFormat);
                                        disp(strcat('It was added to database: ', char(databaseImagesListPath{faceNumber}), databaseImagesName{faceNumber}));
                                        i=i+1;
                                    end
                                    
                                    save('databaseImages.dat', 'databaseImagesListPath', 'databaseImagesName', 'faceNumber');
                            
                                    if (exist('databaseNeuralNetworks.dat')==2)
                                        delete('databaseNeuralNetworks.dat');
                                        msgbox('Therefore, NeuralNetworks database was removed from the current directory.', 'Database removed', 'help');
                                    end
                                end       
                            else
                                warndlg('The number must be a positive integer <= 500', 'Warning');
                            end
                        else
                            warndlg('Input directory must be selected.', 'Warning');
                        end
                    end
                end
                    
            elseif  optionMainImages==2 %Information about database
                
                if (exist('databaseImages.dat')==2)
                    
                    load('databaseImages.dat', '-mat');
                    image=imread(strcat(databaseImagesListPath{1}, databaseImagesName{1}));
                    [m n]=size(image);
                    A=zeros(m*n, faceNumber);
                    A(:,1)=double(image(:));
                    
                    i=2;
                    differentSizeImage=false;
                    while (differentSizeImage==false)&&(i<=faceNumber)
                        image=imread(strcat(databaseImagesListPath{i}, databaseImagesName{i}));
                        if (size(image)~=[m n])
                            differentSizeImage=true;
                        else
                            A(:,i)=double(image(:));
                            i=i+1;
                        end
                    end
                    
                    if (differentSizeImage)
       
                        warndlg(strcat('Input image must have the same size: ', num2str(m), 'x', num2str(n)), ' Warning ');
                        figure('Name', strcat('Input image: ', databaseImagesListPath{i}, databaseImagesName{i}));
                        imshow(image);
                        clc;
                        disp(strcat('Sorry, the size is different to reference dimension: ', num2str(m), 'x', num2str(n), '. Therefore, no was added to database.'));
                        imshow(image);
                        msgbox('For that reason, Images database was removed from the current directory.', 'Database removed', 'help');
                        delete('databaseImages.dat');
                        
                    else
                        
                        msgbox(strcat('Images database has ', num2str(faceNumber),' image/s. Input images have the same size (', num2str(m), 'x', num2str(n), ').'), 'Database result', 'help'); 
                        
                        figure('Name', 'Images database');
                        for i=1:1:faceNumber
                            subplot(ceil(sqrt(faceNumber)), ceil(sqrt(faceNumber)), i);
                            imshow(uint8(reshape(A(:,i), [m n])));
                        end
                    end
                    
                    clear A;
                    
                else
                    msgbox('Images database is empty. See Load images to database.', 'Database result', 'help');
                end
                
            elseif  optionMainImages==3 %Delete database
                
                close all;
                if (exist('databaseImages.dat')==2)
                    button=questdlg('Do you really want to remove the database?', 'Images database');
                    if strcmp(button, 'Yes')
                        delete('databaseImages.dat');
                        msgbox('Images database was successfully removed from the current directory.', 'Database removed', 'help');
                        
                        if (exist('databaseNeuralNetworks.dat')==2)
                            delete('databaseNeuralNetworks.dat');
                            msgbox('Therefore, NeuralNetworks database was removed from the current directory.', 'Database removed', 'help');
                        end    
                    end
                else
                    warndlg('Images database is empty.', ' Warning ');
                end
            end            
        end  
    
    elseif  optionMain==2 %Image projection onto Eigenspace
        
        if (exist('databaseImages.dat')==2)
            [nameFile,pathName]=uigetfile('*.*', 'Select an image');
            
            if nameFile~=0
                load('databaseImages.dat', '-mat');
                
                messageInputK='Insert the number of eigenvectors K (corresponding to the K largest eigenvalues). The training set can be represented as a linear combination of the best K eigenvectors. More important, eigenvectors with bigger eigenvalues provide more information on the face variation than those with smaller eigenvalues. After the eigenfaces are extracted from the covariance matrix (A) of a set of faces, input image is projected onto the eigenface space and represented by a linear combination of the eigenfaces, or has a NEW FACE DESCRIPTOR corresponding to a point inside the high dimensional space with the eigenfaces as axes. It is clear that we should use eigenfaces with higher eigenvalues to reconstruct the input face because they provide much more information on the face variation. We use the K eigenfaces with the highest eigenvalues. The face which we try to recognize is projected onto the K eigenfaces first. It produces a new description of the face with only K real numbers. One approach to find the face pattern is to calculate the Euclidean distance between the input face descriptor and each known face model in the database. All faces of the same individual are supposed to be closed to each other while different persons have different face clusters. But actually we do not have any prior knowledge on the distribution of the new face descriptors. [Jiang 01] has found that usage of this method is not sufficient in real tests. A better approach is to recognize the face in unsupervised manner using NEURAL NETWORKS architecture.';
                msgbox(messageInputK, 'Projection of input image onto face space', 'help');
                    
                prompt={strcat('K number must be a positive integer <= ', num2str(faceNumber-1))};
                title='K number';
                lines=1;
                def={'1'};
                answer=inputdlg(prompt, title, lines, def);
                parameter=double(str2num(char(answer)));
                
                if size(parameter, 1)~=0
                    K=parameter(1);
                    if (K<=0)||(K>faceNumber)||(floor(K)~=K)||(~isa(K, 'double'))
                        warndlg(strcat('K number must be a positive integer <= ', num2str(faceNumber-1)), ' Warning ');
                    else
                        inputImageOntoEigenSpaceURL=strcat(pathName, '\', nameFile);
                        pca(databaseImagesListPath, databaseImagesName, databaseImagesName, K, inputImageOntoEigenSpaceURL);
                        
                        if (exist('databaseEigenfaces.dat')==2)
                            load('databaseEigenfaces.dat', '-mat');
                            
                            figure('Name', strcat('Projection of input image onto face space: eigenfaces with a linear combination of the best K=', num2str(K), ' eigenvectors'));
                            for i=1:1:K
                                subplot(ceil(sqrt(K)), ceil(sqrt(K)), i);
                                imshow(uint8(reshape(eigenFaces(:,i)*representingFaces(i)+average,dimension)));
                            end
                        end
                    end    
                else
                    warndlg(strcat('K number must be a positive integer <= ', num2str(faceNumber-1)), 'Warning');
                end
            else
                warndlg('Input image must be selected.', ' Warning ');
            end
        else
            warndlg('Images database is empty. It is impossible.', ' Warning ');
        end
        
    elseif optionMain==3 %[Step 2] Recognize the face using neural networks ...

        if (exist('databaseImages.dat')==2)
            
            messageRecognize=strcat('A good approach is to recognize the face in unsupervised manner using neural network architecture. The NEURAL NETWORK has a general structure with three layers. The input layer has K nodes from the NEW FACE DESCRIPTORS. The hidden layer has H nodes. The output unit gives a result from 0.0 to 1.0 telling how much the input face can be thought as the network host. In order to make the TRAINING of neural network easier, one output neural is created for each person. Neural net identifies whether the input face is the network host or not. The recognition algorithm selects the output neural with the MAXIMUM OUTPUT.');
            msgbox(messageRecognize, 'Recognize the face using neural networks', 'help');
            
            optionMainRecognize=0;
            exitMainRecognize=7;
            while optionMainRecognize~=exitMainRecognize
                
                optionMainRecognize=menu('Recognize the face using neural networks', '[Step 1] Initialize the neural network architecture', '[Step 2] Prepare the training examples', 'Delete the neural network architecture', 'Information about neural network', '[Step 3] Train the neural network', '[Step 4] Simulate with a face', 'Return to Main menu');
        
                if optionMainRecognize==1 %[Step 1] Initialize the neural network architecture
                    
                    if (exist('databaseNeuralNetworks.dat')==0)
                        
                    	load('databaseImages.dat', '-mat');
                        
                        messageInputK='Insert the number of eigenvectors K (corresponding to the K largest eigenvalues).';
                        msgbox(messageInputK, 'Set parameters to neural network architecture', 'help');
                        prompt={strcat('K number must be a positive integer <= ', num2str(faceNumber-1))};                        
                                                
                        title='K number.';
                        lines=1;
                        def={'1'};
                        answer=inputdlg(prompt, title, lines, def);
                        parameter=double(str2num(char(answer)));
                        if size(parameter, 1)~=0
                        	K=parameter(1);
                            if (K<=0)||(K>faceNumber)||(floor(K)~=K)||(~isa(K, 'double'))                        
                            	warndlg(strcat('K number must be a positive integer <= ', num2str(faceNumber-1)), ' Warning ');
                            else
                                messageInputK='The hidden layer will have H nodes.';
                                msgbox(messageInputK, 'Set parameters to neural network architecture', 'help');                                
                                prompt={strcat('H number must be a positive integer <= ', num2str(K))};
                                title='Set parameters to neural network architecture: H number.';
                                lines=1;
                                def={'1'};
                                answer=inputdlg(prompt, title, lines, def);
                                parameter=double(str2num(char(answer)));
                                if size(parameter, 1)~=0
                                    H=parameter(1);
                                    if (H<=0)||(H>K)||(floor(H)~=H)||(~isa(H, 'double'))
                                        warndlg(strcat('H number must be a positive integer <= ', num2str(K)), ' Warning ');
                                    else
                                        databaseNeuralNetworksTrainingExamples={};
                                        trainNumber=0;
                                        valuesInputNet=[];
                                        targetOutputNet=[];
                                        msgbox('NeuralNetworks database already exists. See Information about neural network.', 'Database result', 'help');
                                        save('databaseNeuralNetworks.dat', 'databaseNeuralNetworksTrainingExamples', 'trainNumber', 'valuesInputNet', 'targetOutputNet', 'K', 'H');
                                    end
                                end
                            end
                                            
                        end
                    else
                        warndlg('NeuralNetworks database exists with its parameters. See Information about neural network.', ' Warning ');
                    end
                    
                elseif optionMainRecognize==2 %[Step 2] Prepare the training examples
                    
                    if (exist('databaseImages.dat')==2)                        
                        if (exist('databaseNeuralNetworks.dat')==2)
                                
                            [nameFile,pathName]=uigetfile('*.*', 'Select an image');
                                      
                            if nameFile~=0
                                clc;
                                disp('Input image has been selected.');
                                inputImageOntoEigenSpaceURL=strcat(pathName, '\', nameFile);
                                load('databaseImages.dat', '-mat');
                                load('databaseNeuralNetworks.dat', '-mat');
                                pca(databaseImagesListPath, databaseImagesName, databaseImagesName, K, inputImageOntoEigenSpaceURL);
                                
                                if (exist('databaseEigenfaces.dat')==2)
                                    load('databaseEigenfaces.dat', '-mat');
                                    trainNumber=trainNumber+1;
                                    databaseNeuralNetworks{trainNumber,1}=representingFacesInputImage';
                                
                                    messageInputClass='Insert the name of the person:';            
                                    msgbox(messageInputClass, 'Input image', 'help');            
                                    prompt={'Name:'};
                                    title='Prepare the training examples';
                                    lines=1;
                                    def={'Mikel'};
                                    answer=inputdlg(prompt, title, lines, def);
                                    class=answer;
                                        
                                    databaseNeuralNetworks{trainNumber,2}=class;
                                    rangeInputNeuralNetValue=[-10000 10000];
                                    neuralnetworks(databaseNeuralNetworks, trainNumber, rangeInputNeuralNetValue, K, H);
                                    msgbox('Therefore, Neural network was removed from the current directory.', 'Database removed', 'help');
                                    
                                    clc;
                                    %Shows the training examples
                                    
                                    disp('It was added to NeuralNetworks database.');
                                    for i=1:1:trainNumber
                                        disp(strcat('Training example (', num2str(i), ')'));
                                        disp('Name of the person:');
                                        disp(databaseNeuralNetworks{i,2});
                                        disp('Weight:')
                                        disp(databaseNeuralNetworks{i,1});
                                    end
                                    
                                end
                            else
                                warndlg('Input image must be selected.', ' Warning ');
                            end
                            
                        else
                            msgbox('NeuralNetworks database not found. See Initialize the neural network architecture.', 'Database result', 'help');
                        end
                    else
                        warndlg('Images database not found.', ' Warning ');
                    end
                    
                elseif optionMainRecognize==3 %Delete the neural network architecture
                    
                    if (exist('databaseNeuralNetworks.dat')==2)
                        
                        button=questdlg('You will remove the database ...', 'NeuralNetworks');
                        if strcmp(button, 'Yes')
                            delete('databaseNeuralNetworks.dat');
                            msgbox('NeuralNetworks database was successfully removed from the current directory.', 'Database removed', 'help');
                        end
                        
                    else
                        warndlg('NeuralNetworks database not found.', ' Warning ');
                    end
                
                elseif optionMainRecognize==4 %Information about neural network
                    
                    if (exist('databaseNeuralNetworks.dat')==2)
                        load('databaseNeuralNetworks.dat', '-mat');
                        
                        messageRecognize=strcat('Information about neural network architecture. There are ', num2str(trainNumber), ' training examples. K=', num2str(K), ' node/s. H=', num2str(H), ' node/s.');
                        msgbox(messageRecognize, 'Recognize the face using neural networks', 'help');
                        
                        clc;
                        %Shows the training examples
                        
                        for i=1:1:trainNumber
                            disp(strcat('Training example (', num2str(i), ')'));
                            disp('Name of the person:');
                            disp(databaseNeuralNetworks{i,2});
                            disp('Weight:')
                            disp(databaseNeuralNetworks{i,1});
                        end
                    else
                        warndlg('NeuralNetworks database not found. See Initialize the neural network architecture.', ' Warning ');
                    end
                
                elseif optionMainRecognize==5 %[Step 3] Train the neural network
                    
                    if (exist('databaseNeuralNetworks.dat')==2)
                        load('databaseNeuralNetworks.dat', '-mat');
                            
                        rangeInputNeuralNetValue=[-10000 10000];
                        neuralnetworks(databaseNeuralNetworks, trainNumber, rangeInputNeuralNetValue, K, H);
                            
                        if (exist('databaseNeuralNetworks.dat')==2)
                            
                            load('databaseNeuralNetworks.dat', '-mat');
                            load net;
                            output=sim(net,valuesInputNet);
                            output
                            net=train(net,valuesInputNet,targetOutputNet);
                            output=sim(net,valuesInputNet);
                            output
                            save('databaseNeuralNetworks.dat', 'databaseNeuralNetworks', 'trainNumber', 'valuesInputNet', 'targetOutputNet', 'K', 'H');
                            save net;
                            
                        end
  
                    else
                        warndlg('NeuralNetworks database not found. See Initialize the neural network architecture.', ' Warning ');
                    end
                
                elseif optionMainRecognize==6 %[Step 4] Simulate with a face
                    
                    if (exist('databaseNeuralNetworks.dat')==2)
                        
                        [nameFile,pathName]=uigetfile('*.*', 'Select an image');
                                      
                        if nameFile~=0
                            image=imread(strcat(pathName, nameFile));
                            clc;
                            disp('Input image has been selected to recognize.');
                            
                            inputImageOntoEigenSpaceURL=strcat(pathName, '\', nameFile);
                            load('databaseNeuralNetworks.dat', '-mat');
                            load('databaseImages.dat', '-mat');
                            pca(databaseImagesListPath, databaseImagesName, databaseImagesName, K, inputImageOntoEigenSpaceURL);                            

                            if (exist('databaseEigenfaces.dat')==2)
                                load('databaseEigenfaces.dat', '-mat');
                                
                                rangeInputNeuralNetValue=[-10000 10000];
                                neuralnetworks(databaseNeuralNetworks, trainNumber, rangeInputNeuralNetValue, K, H);
                                
                                if (exist('databaseNeuralNetworks.dat')==2)
                                    load('databaseNeuralNetworks.dat', '-mat');
                                    load net;
                                    load classList;
                                    output=sim(net,representingFacesInputImage);
                                    output
                                    %target=[0; 0; 1; 0; 0];
                                    %plot(target, 'o');
                                    %hold on;
                                    plot(output, '+r');
                                    
                                    %The recognition algoritm selects the maximum output
                                    
                                    maxValueClass=0;
                                    indexValueClass=1;
                                    for i=1:1:length(output)
                                        if (output(i)>maxValueClass)
                                            maxValueClass=output(i);
                                            indexValueClass=i;
                                        end
                                    end
                                    
                                    %Predefined threshold (0.8)
                                    
                                    if maxValueClass<0.8
                                        messageRecognizeClass='Test fails to pass the predefined threshold (0.8)';
                                    else
                                        messageRecognizeClass=strcat('I think that is', ' ', char(classList{indexValueClass}), '.');
                                    end
                                    
                                    msgbox(messageRecognizeClass, 'What is the name of this person?', 'help');                                    
                                    
                                end    
                            end
                        else
                            warndlg('Input image must be selected.', ' Warning ');
                        end    
                    else
                        warndlg('NeuralNetworks database not found. See Initialize the neural network architecture.', ' Warning ');
                    end
                end
            end    
        else
            warndlg('Images database is empty. Then, it is impossible to recognize the face using neural networks. See Load images to database.', ' Warning ');
        end

    elseif optionMain==4 %Learn about application ...
        
        close all;
        helpwin explanationEigenfacesAndNeuralNetworks;
    
    elseif optionMain==5 %License
        
        close all;
        web http://www.gnu.org/licenses/gpl.html;
        
    end
end

close all;



