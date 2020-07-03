function [s,result] = classifierTrain(which, inputTrain, path)


%  Es usada por la funcion findThreshold
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


if (isnumeric(which))
    switch(which)
        case 1, %C4.5
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.trees.J48 -i -C 0.50 -M 2 -t ', inputTrain, ' -d j48.model']);
        case 2, % Naive Bayes
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.bayes.NaiveBayes -i -t ', inputTrain, ' -d nb.model']);
        case 3, % IB1
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.lazy.IB1 -i -t ', inputTrain, ' -d ib1.model']);
        case 4, % SVM
            s = evalc(['!java ', path, ' -Xmx4g weka.classifiers.functions.SMO -i -t ', inputTrain, ' -d smo.model']);
        otherwise
            error('classifier:incorrectClassifier', 'Incorrect classifier');
    end;
else
    error('classifier:incorrectClassifier', 'Incorrect classifier');
end;

if ~isempty(findstr(s, 'Weka exception'))
    error('classifier:wekaProblem', 'Weka exception in classifier');
end;
s
inputTrain

t1=findstr('=== Stratified cross-validation ===',s)
s2=s([t1+35:length(s)])
t2=findstr('Correctly Classified Instances',s2)
t=findstr('%',s2)
if (t~=0)
    resultChar = s2([t(1)-9:t(1)-1])
else
    fprintf('ERROR en classifierTrain');
    %error('classifier:unaryClassError', 'Error: Unary class');
    resultChar = '0';
    %pause;
end

result = str2double(resultChar);





