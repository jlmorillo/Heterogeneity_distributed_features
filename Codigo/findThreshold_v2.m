function threshold = findThreshold_v2(votes,alpha,trSet,path,path_dir_pruebas,nameDataSet,optionSelect,optionFilter,classifier,optionClassifier,media,std, partitiontype)

minVote = floor(media-0.5*std);
maxVote = ceil(media+0.5*std);

%path_dir_pruebas='D:\Personal\doctorado\PhD\Smote\pruebas_PhD';

logFile =[path_dir_pruebas '/pruebas_logs/' nameDataSet '/findTheshold' int2str(optionSelect) '.txt'];
fidTh = fopen(logFile, 'a');

[sizetrSetX sizeTrSetY]=size(trSet);
fprintf(fidTh, '\n*** %s ***',optionClassifier);
fprintf(fidTh,'\n\nsizetrSetX= %d sizeTrSetY= %d\n',sizetrSetX,sizeTrSetY);
% We use 10% of the dataset so as to speed up the process
[trSizex,trSizeY]=size(trSet);

% **********A VECES teIdx CONTIENE SOLO UNA CLASE Y DA ERROR******************
% PARA EVITARLO, REPETIMOS HASTA QUE TENGA AL MENOS DOS
if (partitiontype==1)

repetir=true;
intentos=0;
while(repetir)
    CV10 = cvpartition(size(trSet,1),'kfold',10); % divido el Train en k (k=10) particiones
    trIdx = CV10.training(1); % 90% de las muestras (k-1 particiones)
    teIdx = CV10.test(1); % 10% de las muestras (1 partición)
    [sizetrIdx sizetrIdy]=size(trIdx);
    [sizeteIdx sizeteIdy]=size(teIdx);


    %Controlar que en la seleción del 1% haya al menos 2 clases
    %[sizeX,sizeY]=size(unique(trSet(trIdx,73)));   ->73????? POR????
    [sizeX,sizeY]=size(unique(trSet(teIdx,trSizeY)));
    fprintf(fidTh,'\n\nNúmero de clases: %d\n',sizeX);    
    if (sizeX<2)
        repetir=true;
        intentos=intentos+1;
    else
        repetir=false;
    end
    if (intentos>10)
        repetir = false;
    end
end
fprintf(fidTh,'\n\nNúmero de intentos para conseguir al menos 2 clases: %d\n',intentos);    
fprintf(fidTh,'\n\nsizetrIdx=%d sizetrIdy= %d\n',sizetrIdx,sizetrIdy);
fprintf(fidTh,'\n\nsizeteIdx=%d sizeteIdy= %d\n',sizeteIdx,sizeteIdy);
%training = trSet(trIdx,:); %findTh con el 90% de las muestras
training = trSet(teIdx,:); %findTh con el 10% de las muestras

else
    training = trSet;
end

% Formula to minimize

%f = zeros(1,minVote+1:maxVote);
f = zeros(1,maxVote);

     
fprintf(fidTh,'\n\noptionFilter= %s\n',optionFilter);   
fprintf(fidTh,'\n minVote= %d \n maxVote=%d \n',minVote,maxVote);
    
%     for v=1:minVote
%         f(v)=9999999;
%     end

f(:)=999;%inicializo a un valor muy grande el vector de votos
for v = minVote+1:5:maxVote % de 5 en 5, +1 por si minVote=0

    v;
    car = find((votes==v)|(votes>v));
    noCar = setdiff(1:size(training,2),car);
    
    newTraining = training(:,noCar);
    [sizeNewTrainingX sizeNewTrainingY]=size(newTraining);
    
    fprintf(fidTh,'\n\nsizeNewTrainingX=%d sizeNewTrainingY= %d\n',sizeNewTrainingX,sizeNewTrainingY);
    
    
    %fileNameTrain = strcat(strcat(strcat(strcat('pruebas/',nameDataSet),'classifier'),optionSelec),'.arff');
    fileNameTrain = [path_dir_pruebas  '/dataaux/' nameDataSet,'classifier_findTh_' int2str(optionSelect)  '.arff'];
    mat2arff(fileNameTrain,newTraining,path);
    
    [s,result] = classifierTrain(classifier, fileNameTrain, path);
    error = 100 - result;    
    featPercentage = (size(noCar,2)/size(training,2))*100;
    
    
 %   fprintf(fidTh,'\n s= %s\n',s);
    
 
 

    fprintf(fidTh,'error= %f\n',error);
    
    fprintf(fidTh,'featPercentaje= %f\n',featPercentage);
    
    
    % Formula
    f(v) = (alpha*error) + ((1 - alpha)*featPercentage);
    
    
    fprintf(fidTh,'f(%d)= %f\n\n',v,f(v));
    
end
%Y esto para que?
f;
%
[y i] = min(f);

fprintf(fidTh,'\n [y i]= [%f %f] \n',y,i);

fclose(fidTh);

threshold = i;
%threshold = i+minVote;
end