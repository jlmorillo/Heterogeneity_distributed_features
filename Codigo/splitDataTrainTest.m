function [trainCSV, testCSV, head, ndatapartition, partitiontype]= splitDataTrainTest(dataset, withRept)


fprintf('\n*** Dividiendo dataset ***\n');

datasetfile = strcat('datasets\',dataset,'.csv');
trainCSV =strcat('datasets\',dataset,'Train.csv');
testCSV = strcat('datasets\',dataset,'Test.csv');
head = getHead(dataset);

dtst = csvread(datasetfile);
%datasetfileArff = strcat('datasets\',dataset,'.arff');
%mat2arff(datasetfileArff, dtst, ' -cp "C:\Program Files\Weka-3-6\*" ');

[nInst, nFeat] = size(dtst);
ind=[1:nInst];

%randperm(nInst,round(2*nInst/3)) to select index whithout repetitions
%randi(nInst,1,round(2*nInst/3)) to select index with repetitions

% 2/3 instances for training
if (withRept) 
    trIdx = randi(nInst,1,round(2*nInst/3));
else
    trIdx = randperm(nInst,round(2*nInst/3));
end

trIdx=sort(trIdx); %
teIdx =setdiff(ind,trIdx);  % 1/3 instances for testing

trSet = dtst(trIdx,:);

teSet = dtst(teIdx,:);

[ndatapartition, partitiontype]=partition(trSet);% calcular en cuanto dividir los paquetes


fidTrain = fopen(trainCSV, 'w');                     
[nInst nFeat]= size(trSet);
    for i=1:nInst
        for j=1:nFeat
            aux = trSet(i,j);
            if j==nFeat
                     aux = int2str(aux); %para convertir la clase a int
                    fprintf(fidTrain,'%s\n',aux);

            else
                fprintf(fidTrain,'%g',aux);
                fprintf(fidTrain,',');
            end
        end
    end
    fclose(fidTrain);


 fidTest = fopen(testCSV, 'w');
    [nInst nFeat]= size(teSet);
    for i=1:nInst
        for j=1:nFeat
            aux = teSet(i,j);
            if j==nFeat
                     aux = int2str(aux);
                    fprintf(fidTest,'%s\n',aux);

            else
                fprintf(fidTest,'%g',aux);
                fprintf(fidTest,',');
            end
        end
    end    
    fclose(fidTest);

end