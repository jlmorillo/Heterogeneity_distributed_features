function [s,resTrain,resTest, kStat] = classifierTrainTest(which, inputTrain, inputTest, path)
% function [] = classifier(which, inputTrain,
% inputTest, logFile, classifierOutput)
%
% Inputs:
%
% which - Number to select one of the following kinds of
% classifiers:
%
%       1 - C4.5
%       2 - Naive Bayes
%       3 - IB1
%       4 - SVM
%
% input - Input dataset
%
% Outputs:
%

% Log file
    switch(which)
        case 'C4.5',
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.trees.J48 -i -C 0.50 -M 2 -t ', inputTrain, ' -T ', inputTest, ' -d j48.model']);
        case 'Naive-Bayes',
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.bayes.NaiveBayes -i -t ', inputTrain, ' -T ', inputTest, ' -d nb.model']); %
        case 'IB1',
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.lazy.IB1 -i -t ', inputTrain, ' -T ', inputTest, ' -d ib1.model']);
        case 'SVM',
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.functions.SMO -i -t ', inputTrain, ' -T ', inputTest, ' -d smo.model']);
        otherwise
            error('classifier:incorrectClassifier', 'Incorrect classifier');
    end;

% Mostrar para comprobar que son correctos
% inputTrain
% inputTest
% s

if ~isempty(strfind(s,'Weka exception'))
    % error('classifier:wekaProblem', 'Weka exception in classifier');
    resTest = 0;
    resTrain = 0;
    kStat = 0;
else

    t1=strfind(s, '=== Error on training data ===');
    s2=s(t1+30:length(s));
    t=strfind(s2,'%');
    if (isempty(t))
        resTrain = 0;
    else
        resultChar = s2(t(1)-9:t(1)-1);
        resTrain = str2double(resultChar);
    end

    t1=strfind(s,'=== Error on test data ===');
    s2=s(t1+26:length(s));
    t=strfind(s2,'%');
    if (isempty(t))
        resTest = 0;
    else
        resultChar = s2(t(1)-9:t(1)-1);
        resTest = str2double(resultChar);
    end
    iniKappa=strfind(s,'Kappa statistic');
    if (isempty(iniKappa))
        kStat=0;
    else
        kStat =str2double(strtok(s(iniKappa+15:length(s))));
    end
end

end




