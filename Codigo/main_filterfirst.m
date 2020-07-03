% MAIN process

% new PC work
path = ' -cp "C:\Program Files\Weka-3-6\*" ';
path_dir_pruebas='C:\Personal\doctorado\PhD\pruebas_PhD';

%result log
log_csv=[path_dir_pruebas '\Results\log_results.csv'];
fid_csv=fopen(log_csv,'w');
fprintf(fid_csv,'%s;%s;%s;%s;%s;%s;%s;%s;%s;%s\n', 'Dataset', 'SmoteMin', 'SmoteMax', 'Filter', 'Classifier', 'MeanAccuracyTrain', 'DevAccuracyTrain', 'MeanAccuracyTest', 'DevAccuracyTest', 'MeanKStat');

log_classes=[path_dir_pruebas '\Results\log_classes.csv'];
fid_classes=fopen(log_classes,'w');
fprintf(fid_classes,'%s;%s;%s;%s;%s\n', 'Dataset', 'Round', 'SmoteMin', 'SmoteMax', 'Classes');

log_classifiers=[path_dir_pruebas '\Results\log_classifiers.csv'];
fid_classifiers=fopen(log_classifiers,'w');
fprintf(fid_classifiers,'Dataset;Round;SmoteMin;SmoteMax;Filter;Classifier;AccuracyTrain;AccuracyTest;kStat;\n');

%split dataset with repetitions (1) without repetitions(0)

withRept = 0;

%{'Arrhythmia' 'Brain' 'CNS' 'Colon' 'Connect4' 'Gli85' 'Musk2' 'Nomao' 'Ovarian' 'Ozone' 'Spambase'  'Weight' }
Datasets = {'Brain' 'CNS' 'Colon' 'Connect4' 'Gli85' 'Musk2' 'Nomao' 'Ovarian' 'Ozone' 'Spambase'  };
Filters = {'CFS' 'InfoGain' 'ReliefF' 'Consistency'}; % {'CFS' 'InfoGain' 'ReliefF' 'Consistency'}
Classifiers = {'C4.5' 'Naive-Bayes' 'IB1' 'SVM'}; % {'C4.5' 'Naive-Bayes' 'IB1' 'SVM'}
SmoteMin = { '0' '100' '300' '600' 'Calculate'}; % {'0' '100' '300' '600' 'Calculate'}
SmoteMax = { '0' '20' '40' '100'}; % {'0' '20' '40' '100'}
Repetitions = 5;
AccuracyTrainResults = zeros(size(Datasets,2), size(SmoteMin,2), size(SmoteMax,2), size(Filters,2), size(Classifiers,2), Repetitions);
AccuracyTestResults = zeros(size(Datasets,2), size(SmoteMin,2), size(SmoteMax,2), size(Filters,2), size(Classifiers,2), Repetitions);
kStatResults = zeros(size(Datasets,2), size(SmoteMin,2), size(SmoteMax,2), size(Filters,2), size(Classifiers,2), Repetitions);

for i_d=1:size(Datasets,2)
    for i_r=1:Repetitions
    %train and test dataset division
    [datasetTrain, datasetTest, cabecera] = splitDataTrainTest(char(Datasets(i_d)), withRept);
    trSet = csvread(datasetTrain);
    [nInst, nFeat] = size(trSet);
    teSet = csvread(datasetTest);
    
    fileNameTrain = [path_dir_pruebas '/dataaux/' char(Datasets(i_d)) '_Train.arff'];                    
    mat2arff(fileNameTrain,trSet,path);
 
    
    
    
        % Number of features selected by CFS
        featCFS = 0;
        huboCFS = 0;
    for i_f=1:size(Filters,2)
          if huboCFS==0
            featCFS=nFeat-1;
          else
            featCFS;
            fprintf('features SIN CFS=%d \n',featCFS);            
          end
         
          selecCar = filters(char(Filters(i_f)),fileNameTrain, path, featCFS);
          aux = eval(selecCar);
          
          if(strcmp(char(Filters(i_f)),'CFS'))%CFS, ALMACENAMOS NUMERO DE CARACTERISTICAS SELECCIONADAS
            featCFS = length(aux);
            fprintf('featCFS=%d \n',featCFS);
            huboCFS=1;
          end                      
          carToRetain=aux;
          carToRetainWithClass = union(carToRetain,nFeat);% hay que concatenarle la clase
         
          iter_name = [char(Datasets(i_d)) '_' char(Filters(i_f))];
          
          newTrSet = trSet(:,carToRetainWithClass);
          newfileNameTrain = [path_dir_pruebas '/datasetTrain/' iter_name '.arff'];
          mat2arff(newfileNameTrain,newTrSet,path);
          newTeSet = teSet(:,carToRetainWithClass);
          newfileNameTest = [path_dir_pruebas '/datasetTest/' iter_name  '.arff'];
          mat2arff(newfileNameTest,newTeSet,path);
          
         % ftrain = newfileNameTrain;
         % ftest = newfileNameTest;
          auxfiletest= [path_dir_pruebas '/ftestnew/' iter_name '.arff' ];
          auxfiletrain= [path_dir_pruebas '/ftrainnew/' iter_name '.arff' ];    
          [ftrain, ftest]= cabecerasArff2(newfileNameTrain,newfileNameTest,cabecera,auxfiletest,auxfiletrain);     
       [porcentajeCalculado, claseMayoritaria, numeroClasses]=analyze_Arff(ftrain);
      for i_s=1:size(SmoteMin,2)
           
        for i_m=1:size(SmoteMax,2)
          % smote majority class
          newFileNameTrain = ftrain;
        if not(strcmp(SmoteMax(i_m) , '0'))
           newFileNameTrain = smote(newFileNameTrain, path, char(SmoteMax(i_m)), porcentajeCalculado, claseMayoritaria);              
           [porcentajeCalculado, claseMayoritaria, numeroClasses ]=analyze_Arff(newFileNameTrain);
        end

        %smote minority class
        if not(strcmp(SmoteMin(i_s) , '0'))
            newFileNameTrain = smote(newFileNameTrain,path,char(SmoteMin(i_s)), porcentajeCalculado,0);
            [~, ~, numeroClasses ]=analyze_Arff(newFileNameTrain);
        end  
        
     %   if (not(strcmp(SmoteMax(i_m) , '0')) || not(strcmp(SmoteMax(i_m) , '0')))
     %       [dataName,attributeName, attributeType, smotetrSet]= arffread(newFileNameTrain); 
     %       trSet = smotetrSet;
     %   end
        
        fprintf(fid_classes, '%s;%i;%s;%s;', char(Datasets(i_d)), i_r, char(SmoteMin(i_s)), char(SmoteMax(i_m)));
        for i_cl=1:size(numeroClasses,2)
            fprintf(fid_classes,'%i;',numeroClasses{i_cl});
        end
        fprintf(fid_classes,'\n');
            
          
          for i_c=1:size(Classifiers,2)
            Tiempo=clock;
            fprintf('%s:%s:%s;Dataset:%s\n',int2str(Tiempo(4)),int2str(Tiempo(5)),int2str(Tiempo(6)),char(Datasets(i_d)));
            [ss,accuracyTrain,accuracyTest,kStat] = classifierTrainTest(char(Classifiers(i_c)), newFileNameTrain, ftest, path);
            AccuracyTrainResults(i_d, i_s, i_m, i_f, i_c, i_r) = accuracyTrain;
            AccuracyTestResults(i_d, i_s, i_m, i_f, i_c, i_r) = accuracyTest;
            kStatResults(i_d, i_s, i_m, i_f, i_c, i_r) = kStat;      
            Tiempo=clock;
            fprintf('%s:%s:%s:;Dataset:%s;Round:%i;SmoteMin:%s;SmoteMax:%s;Filter:%s;Classifier:%s;AccuracyTrain:%-2.2f;AccuracyTest:%-2.2f;kStat:%-2.3f;\n',int2str(Tiempo(4)),int2str(Tiempo(5)),int2str(Tiempo(6)), char(Datasets(i_d)),i_r, char(SmoteMin(i_s)), char(SmoteMax(i_m)), char(Filters(i_f)), char(Classifiers(i_c)), accuracyTrain, accuracyTest, kStat);
            fprintf(fid_classifiers,'%s;%i;%s;%s;%s;%s;%-2.2f;%-2.2f;%-2.3f;\n', char(Datasets(i_d)),i_r,char(SmoteMin(i_s)), char(SmoteMax(i_m)), char(Filters(i_f)), char(Classifiers(i_c)), accuracyTrain, accuracyTest, kStat);         
            clear accuracyTrain;  
            clear accuracyTest;
            clear kStat;
            clear ss;
          end
        end
      end
     end
    end


% write results to log file

   for l_s=1:size(SmoteMin,2)
        for l_m=1:size(SmoteMax,2)
            for l_f=1:size(Filters,2)
                for l_c=1:size(Classifiers,2)
                    
                    meanAccuracyTrain = mean(AccuracyTrainResults(i_d, l_s, l_m, l_f, l_c, 1:Repetitions));
                    meanAccuracyTest = mean(AccuracyTestResults(i_d, l_s, l_m, l_f, l_c, 1:Repetitions));
                    meankStat = mean(kStatResults(i_d, l_s, l_m, l_f, l_c, 1:Repetitions));
                    stddevAccuracyTrain=std(AccuracyTrainResults(i_d, l_s, l_m, l_f, l_c, 1:Repetitions));
                    stddevAccuracyTest=std(AccuracyTestResults(i_d, l_s, l_m, l_f, l_c, 1:Repetitions));
                    fprintf(fid_csv,'%s;%s;%s;%s;%s;%-2.2f;%-2.2f;%-2.2f;%-2.2f;%-2.3f\n', char(Datasets(i_d)),char(SmoteMin(l_s)), char(SmoteMax(l_m)), char(Filters(l_f)), char(Classifiers(l_c)), meanAccuracyTrain, stddevAccuracyTrain, meanAccuracyTest, stddevAccuracyTest, meankStat);
                     
                end
            end
        end
    end
 fprintf('end Dataset:%s',char(Datasets(i_d)));
end
fclose(fid_classes);
fclose(fid_classifiers);
fclose(fid_csv);
fprintf('-----end test----');

beep

fclose all;
close all;

