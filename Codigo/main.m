% MAIN process

% new PC work
path = ' -cp "C:\Program Files\Weka-3-6\*" ';
path_dir_pruebas='C:\Users\JOSE\Documents\doctorado\Articulo_distribuido\Pruebas_PhD';

%result log
log_csv=[path_dir_pruebas '\Results\log_results.csv'];
fid_csv=fopen(log_csv,'w');
fprintf(fid_csv,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n', 'Dataset', 'Distribution', 'SmoteMin', 'SmoteMax', 'RUS', 'Filter', 'Classifier', 'MeanAccuracyTrain', 'DevAccuracyTrain', 'MeanAccuracyTest', 'DevAccuracyTest', 'MeanKStat', 'tMeanFilter' , 'tDevFilter' , 'tMeanClassifier', 'tDevClassifier');

log_classifiers=[path_dir_pruebas '\Results\log_classifiers.csv'];
fid_classifiers=fopen(log_classifiers,'w');
fprintf(fid_classifiers,'Dataset;Distribution;Round;SmoteMin;SmoteMax;RUS;Filter;Classifier;AccuracyTrain;AccuracyTest;kStat;tMeanFilter;tClassifier;noPackets;dataPartition;partitiontype;nFeatWithClass\n');

%split dataset with repetitions (1) without repetitions(0)

withRept = 0;

%{'Arrhythmia' 'Brain' 'CNS' 'Colon' 'Connect4' 'Gli85' 'Musk2' 'Nomao' 'Isolet'  'Ozone' 'Spambase'  'Weight' }
Datasets = { 'Brain' 'CNS' 'Colon' 'Ovarian' 'Gli85' }; %, 'Isolet'};
Distributed = {'Centralizado' 'Aleatoria' }; % 0 - Centralizado, 1 - Aleatoria, 2 - Homogenea
Filters = {'CFS' 'InfoGain' 'ReliefF' 'Consistency'}; % {'CFS' 'InfoGain' 'ReliefF' 'Consistency'}
Classifiers = {'C4.5' 'Naive-Bayes' 'IB1' 'SVM'}; % {'C4.5' 'Naive-Bayes' 'IB1' 'SVM'}
%SmoteMin = {'0' '100' '300' '600'}; % normal {'0' '100' '300' '600' 'Calculate'}
SmoteMin = {'0' '20' '40' '100'}; %microarrays {'0' '20' '40' '100' 'Calculate'}
SmoteMax = {'0'}; % {'0' '20' '40' '100'}
Repetitions = 5;
Rounds = 5;
Rus = 1; %Random Undersampling, 0 - No, 1 - Yes
% partitiontype = 1; % 0 - Features, 1 - Instances
% alpha  z<vparameter
alpha = 0.75;


nDatasets = size(Datasets,2);
nDistributed = size(Distributed,2);
nFilters = size(Filters,2);
nClassifiers = size(Classifiers,2);
nSmoteMin = size(SmoteMin,2);
nSmoteMax = size(SmoteMax,2);


%% Vectors
% Features selected 
car = cell(nDatasets,nFilters,Rounds);
% Thresholds
thresholds = zeros(nDatasets,nFilters);
AccuracyTrainResults = zeros(nDatasets, nDistributed, nSmoteMin, nSmoteMax, nFilters, nClassifiers, Repetitions);
AccuracyTestResults = zeros(nDatasets, nDistributed, nSmoteMin, nSmoteMax, nFilters, nClassifiers, Repetitions);
kStatResults = zeros(nDatasets, nDistributed, nSmoteMin, nSmoteMax, nFilters, nClassifiers, Repetitions);
trMeanFilter = zeros(nDatasets, nDistributed, nSmoteMin, nSmoteMax, nFilters, nClassifiers, Repetitions);
trDevFilter = zeros(nDatasets, nDistributed, nSmoteMin, nSmoteMax, nFilters, nClassifiers, Repetitions);
trClassifier = zeros(nDatasets, nDistributed, nSmoteMin, nSmoteMax, nFilters, nClassifiers, Repetitions);

for i_d=1:nDatasets
    
 for i_dd = 1:nDistributed 
    
     fprintf('Distribucion:%s\n', char(Distributed(i_dd)));
     
  for i_r=1:Repetitions
    %train and test dataset division
    [datasetTrain, datasetTest, cabecera, ndatapartition, partitiontype] = splitDataTrainTest(char(Datasets(i_d)), withRept);
    
    trSet = csvread(datasetTrain);
    [nInst, nFeat] = size(trSet);
    teSet = csvread(datasetTest);
    
    fileNameTrain = [path_dir_pruebas '/dataaux/' char(Datasets(i_d)) '_Train.arff'];                    
    mat2arff(fileNameTrain,trSet,path);
    
      
    % in centralized only one packet 
    if strcmp(Distributed(i_dd), 'Centralizado')
        Rounds = 1;
        partitiontype = 1; % always by instances
        ndatapartition = nInst;
    end
    
    for i_s=1:nSmoteMin

      for i_m=1:nSmoteMax
          % smote majority class
          
          % Number of features selected by CFS
          featCFS = 0;
          huboCFS = 0;

          votes = zeros(nFilters,nFeat-1);
          
          for i_f=1:nFilters
                    
          tPerRound = zeros(1,Rounds);  
            for i_rr=1:Rounds

            %split train dataset in packets 

            [noPackets,splitted,trSet] = splitdata(trSet,ndatapartition,char(Distributed(i_dd)),partitiontype); %partitiontype=1 if it is made by instances, 0 by features
            aux = cell(1,noPackets);
            auxTimes = zeros(1,noPackets);                         

            for i_pk = 1:noPackets
                tiempo = tic;
                datapacket =  splitted{i_pk};    
                filepacketTrain = [path_dir_pruebas '\dataaux\' char(Datasets(i_d)) '_' int2str(i_dd) '_' int2str(i_r) '_' int2str(i_rr) '_' int2str(i_pk) '.arff'];
               
                mat2arff(filepacketTrain,datapacket,path);
               
                %% SMOTE by packets
                
                [porcentajeCalculado, claseMayoritaria, numeroClasses]=analyze_Arff(filepacketTrain);

                if not(strcmp(SmoteMax(i_m) , '0'))
                   filepacketTrain = smote(filepacketTrain, path, char(SmoteMax(i_m)), porcentajeCalculado, claseMayoritaria);              
                   [porcentajeCalculado, claseMayoritaria, numeroClasses ]=analyze_Arff(filepacketTrain);
                end

                    %smote minority class
                if not(strcmp(SmoteMin(i_s) , '0'))
                    filepacketTrain = smote(filepacketTrain,path,char(SmoteMin(i_s)), porcentajeCalculado,0);
                    [porcentajeCalculado, ~, numeroClasses ]=analyze_Arff(filepacketTrain);
                end  

                if not(strcmp(Rus, '0'))
                    filepacketTrain = undersampling(filepacketTrain, path);
                    [~, ~, numeroClasses ]=analyze_Arff(filepacketTrain);
                end
                  [nInstPacket, nFeatPacket] = size(datapacket);
                  if huboCFS==0
                    featCFS=nFeatPacket-1;
                  else
                    featCFS;
                  end

                  selecCar = filters(char(Filters(i_f)),filepacketTrain, path, featCFS);
                  aux{1,i_pk} = eval(selecCar);

                  noCar = setdiff(1:(nFeat-1),aux{1,i_pk});                        
                  votes(i_f,noCar)= votes(i_f,noCar) + 1;
                  auxTimes(1, i_pk) = toc(tiempo);
                 
            end %for packets
            
             car{i_d,i_f,i_rr} = aux; %feat by round
             
             tPerRound(1,i_rr) = mean(auxTimes);
             
           end %for rounds

           num_votes_no_null=sum(find(votes(i_f,:))>0);
           num_votes_null2=nFeat-1-num_votes_no_null;
           media=sum(votes(i_f,:))/num_votes_no_null; %Media sin tener en cuenta las FEAT que han sido seleccionado siempre (voto=0)
           votes2 = zeros(nFilters,nFeat-(num_votes_null2+1));
           j=1;
            for i=1:nFeat-1                                    
                if (votes(i_f,i)>0)                 
                    votes2(i_f,j)=votes(i_f,i);                
                    j=j+1;                                      
                end                    
            end
            desv_tip=std(votes(i_f,:));
            desv_tip2=std(votes2(i_f,:)); %STD sin tener en cuenta las FEAT que han sido seleccionado siempre (voto=0)
           
            
            tMeanFilter = mean(tPerRound);

                  for i_c=1:nClassifiers
                    tClassifier = tic;  
                    
                    th = findThreshold_v2(votes(i_f,:),alpha,trSet,path,path_dir_pruebas,char(Datasets(i_d)),i_dd,char(Filters(i_f)),i_c,char(Classifiers(i_c)),media,desv_tip2, partitiontype);
                      
                    thresholds(i_d,i_f) = th;   
                    carToEliminate = find((votes(i_f,:)==th)|(votes(i_f,:)>th));
                    carToRetain = setdiff(1:size(trSet,2),carToEliminate);                      
                    if (partitiontype == 1)
                        carToRetainWithClass = union(carToRetain,nFeat);% hay que concatenarle la clase       
                    else
                        carToRetainWithClass = carToRetain;
                    end
                    if(i_f==1)%CFS, ALMACENAMOS NUMERO DE CARACTERISTICAS SELECCIONADAS
                        featCFS=size(carToRetainWithClass,2) - 1;
                        huboCFS=1;
                    end      

                    %% Se cogen solo las caracteristicas seleccionadas por los paquetes y 
                    % se aplican para todo el dataset de entrenamiento
                    
                    newTrSet = trSet(:,carToRetainWithClass); 
                
                    fileNameTrain = [path_dir_pruebas '/dataaux/datasetTrain' char(Datasets(i_d)) '_' char(Distributed(i_dd)) '_' char(Filters(i_f)) '_' int2str(i_c) '_' int2str(i_s) '_' int2str(i_m)  '.arff'];
                    mat2arff(fileNameTrain,newTrSet,path);
                    
                    %% SMOTE DEL CONJUNTO ORIGINAL DE ENTRENAMIENTO FILTRADO CON LAS
                    % CARACTERISTICAS SELECCIONADAS
                    
                    [porcentajeCalculado, claseMayoritaria, numeroClasses]=analyze_Arff(fileNameTrain);

                    if not(strcmp(SmoteMax(i_m) , '0'))
                       fileNameTrain = smote(fileNameTrain, path, char(SmoteMax(i_m)), porcentajeCalculado, claseMayoritaria);              
                       [porcentajeCalculado, claseMayoritaria, numeroClasses ]=analyze_Arff(fileNameTrain);
                    end

                        %smote minority class
                    if not(strcmp(SmoteMin(i_s) , '0'))
                        fileNameTrain = smote(fileNameTrain,path,char(SmoteMin(i_s)), porcentajeCalculado,0);
                        [~, ~, numeroClasses ]=analyze_Arff(fileNameTrain);
                    end  
                     
                    if not(strcmp(Rus, '0'))
                        fileNameTrain = undersampling(fileNameTrain, path);
                        [~, ~, numeroClasses ]=analyze_Arff(fileNameTrain);
                    end
                    
                    newTeSet = teSet(:,carToRetainWithClass);
                    fileNameTest = [path_dir_pruebas '/dataaux/datasetTest' char(Datasets(i_d)) '_' char(Distributed(i_dd)) '_' char(Filters(i_f))  '_' int2str(i_c) '_' int2str(i_s) '_' int2str(i_m)  '.arff'];
                    mat2arff(fileNameTest,newTeSet,path);
                    
                    % Same declaration 
                    auxfiletest= [path_dir_pruebas '/ftestnew/' char(Datasets(i_d)) '_' char(Distributed(i_dd)) '_' char(Filters(i_f))  '_' int2str(i_c) '_' int2str(i_s) '_' int2str(i_m) '.arff' ];
                    auxfiletrain= [path_dir_pruebas '/ftrainnew/' char(Datasets(i_d)) '_' char(Distributed(i_dd)) '_' char(Filters(i_f)) '_' int2str(i_c) '_' int2str(i_s) '_' int2str(i_m) '.arff' ];     
                    [ftrain, ftest]= cabecerasArff2(fileNameTrain,fileNameTest,cabecera,auxfiletest,auxfiletrain);
                                    
                    
                    Tiempo=clock;
                    [ss,accuracyTrain,accuracyTest,kStat] = classifierTrainTest(char(Classifiers(i_c)), ftrain, ftest, path);
                    
                    tClassifier = toc(tClassifier);
                    
                    fprintf('%s:%s:%s;Dataset:%s;Distribution:%s;Round:%i;SmoteMin:%s;SmoteMax:%s;RUS:%i;Filter:%s;Classifier:%s;AccuracyTrain:%-2.2f;AccuracyTest:%-2.2f;kStat:%-2.3f;tMeanFilter:%f; tClassifier:%f; nPacktes:%i; ndataPartition:%i; partitiontype:%i; featwithclass:%i\n',int2str(Tiempo(4)),int2str(Tiempo(5)),int2str(Tiempo(6)), char(Datasets(i_d)),char(Distributed(i_dd)),i_r, char(SmoteMin(i_s)), char(SmoteMax(i_m)), Rus, char(Filters(i_f)), char(Classifiers(i_c)), accuracyTrain, accuracyTest, kStat, tMeanFilter, tClassifier, noPackets, ndatapartition, partitiontype, size(carToRetainWithClass,2));
                    fprintf(fid_classifiers,'%s;%s;%i;%s;%s;%i;%s;%s;%-2.2f;%-2.2f;%-2.3f;%f;%f;%i;%i;%i;%i;\n', char(Datasets(i_d)),char(Distributed(i_dd)),i_r,char(SmoteMin(i_s)), char(SmoteMax(i_m)), Rus, char(Filters(i_f)), char(Classifiers(i_c)), accuracyTrain, accuracyTest, kStat, tMeanFilter, tClassifier,noPackets, ndatapartition,partitiontype, size(carToRetainWithClass,2)); 
                    clear accuracyTrain;  
                    clear accuracyTest;
                    clear kStat;
                    clear ss;
                    clear tClassifier;
                  end %for classifiers
                  clear tMeanFilter;
                  clear tDevFilter;
           end %for filters
             
      end %for smotemax
    end %for smotemin
  end %for repetitions 
end %for Distributed
 fprintf('end Dataset:%s',char(Datasets(i_d)));
end %for dataset


%fclose(fid_classes);
fclose(fid_classifiers);
fclose(fid_csv);
fprintf('-----end test----');

beep

fclose all;
close all;

