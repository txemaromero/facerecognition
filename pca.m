function pca (databaseListPath, databaseNameImages, spaceNameImages, K, inputImageURL)

    numDatabaseImages=length(databaseNameImages);
    dim=length(spaceNameImages);
    % If subDim is not given, dim - 1 dimensions are retained, where dim is the number of space images

    if nargin < 4
        K=dim - 1;
    end
    
    if (numDatabaseImages==0)
        warndlg('There are 0 images in the database.', ' Warning ');
        delete('databaseEigenfaces.dat');
    else if (dim==0)
        warndlg('There are 0 images in the space images.', ' Warning ');
        delete('databaseEigenfaces.dat');
    else
        image=imread(strcat(databaseListPath{1}, databaseNameImages{1}));
        [m n]=size(image);
        dimension=[m n];
        databaseImages=uint8(zeros(m*n,numDatabaseImages));
        databaseImages(:,1)=reshape(double(image), m*n, 1);
        clear image;

        noLoadImages=0;
        for j=2:numDatabaseImages
            image=imread(strcat(databaseListPath{1}, databaseNameImages{j}));
            if (size(image)~=[m n])
                noLoadImages=noLoadImages+1;
                warndlg(strcat('Input image must have the same size: ', num2str(m), 'x', num2str(n)), ' Warning ');
                figure('Name', strcat('Input image: ', databaseListPath{1}, databaseNameImages{j}));
                imshow(image);
                clc;
                disp(strcat('Sorry, the size is different to reference dimension: ', num2str(m), 'x', num2str(n), '. Therefore, no was added to database.'));
                imshow(image);
            else
                databaseImages(:,j)=reshape(double(image), m*n, 1);
            end
        end
    
        if (noLoadImages>0)
            warndlg(strcat(num2str(noLoadImages), ' image/s have not been loaded.'), ' Warning ');
        end
        
        clear numDatabaseImages;

        % Creating training images space

        spaceImages=zeros(m*n, dim);
        for i=1:1:dim
            for j=1:1:length(databaseNameImages)
                if (strcmp(spaceNameImages{i}, databaseNameImages{j}))
                    spaceImages(:,i)=databaseImages(:,j);
                end
            end    
        end

        % Calculating mean face from training images

        average=mean(spaceImages')';

        % Zero mean
    
        zeroMeanSpace=zeros(size(spaceImages));
        for i=1:dim
            zeroMeanSpace(:,i)=double(spaceImages(:,i)) - average;
        end

        % Eigenfaces

        L=zeroMeanSpace' * zeroMeanSpace;
        [eigenVectors, eigenValues]=eig(L);

        diagonal=diag(eigenValues);
        [diagonal, order]=sort(diagonal);
        order=flipud(order);
 
        eigenValuesBestK=zeros(size(eigenValues));
        for i=1:1:size(eigenValues,1)
            eigenValuesBestK(i,i)=eigenValues(order(i),order(i));
            eigenVectorsBestK(:,i)=eigenVectors(:,order(i));
        end

        eigenValuesBestK=diag(eigenValuesBestK);
        eigenValuesBestK=eigenValuesBestK / (dim-1);

        % Retaining only the largest K ones

        eigenValuesBestK=eigenValuesBestK(1:K);
        eigenVectorsBestK=zeroMeanSpace * eigenVectorsBestK;

        % Normalisation to unit length

        for i=1:dim
            eigenVectorsBestK(:,i)=eigenVectorsBestK(:,i) / norm(eigenVectorsBestK(:, i));
        end

        % Creating lower dimensional subspace

        eigenFaces=eigenVectorsBestK(:,1:K);

        % Subtract mean face from all images

        zeroMeanDatabase=zeros(size(databaseImages));
        for i=1:1:size(databaseImages, 2)
            zeroMeanDatabase(:, i) = double(databaseImages(:, i)) - average;
        end

        % Project all images onto a new lower dimensional subspace

        representingFaces=eigenFaces' * zeroMeanDatabase;

        %figure('Name', strcat('Projection of input image onto face space: eigenfaces with a linear combination of the best K=', num2str(K), ' eigenvectors'));
        %for i=1:1:K
        %    subplot(ceil(sqrt(K)), ceil(sqrt(K)), i);
        %    imshow(uint8(reshape(eigenFaces(:,i)*representingFaces(i)+average,[m, n])));
        %end

        % Project input image onto a new lower dimensional subspace
        
        if nargin == 5
            inputImage=imread(inputImageURL);
            figure('Name', strcat('Input image: ', inputImageURL));
            imshow(inputImage);
            
            if (size(inputImage)~=[m n])
                warndlg(strcat('Projection of input image onto face space: Input image must have the same size: ', num2str(m), 'x', num2str(n)), ' Warning ');
            else
                representingFacesInputImage=eigenFaces'*(reshape(double(inputImage), m*n, 1)-average);

                figure('Name', strcat('Projection of input image onto face space: eigenfaces with a linear combination of the best K=', num2str(K), ' eigenvectors'));
                imshow(uint8(reshape(eigenFaces*representingFacesInputImage+average, [m n])));
                delete('databaseEigenfaces.dat');
                save('databaseEigenfaces.dat', 'representingFaces', 'eigenFaces', 'average', 'dimension', 'representingFacesInputImage');
            end
            
        else    
            delete('databaseEigenfaces.dat');
            save('databaseEigenfaces.dat', 'representingFaces', 'eigenFaces', 'average', 'dimension');
        end
    end
end
