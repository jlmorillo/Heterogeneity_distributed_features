function [outputCsv] = delClass(InputName)

outputCsv = 'delClass.csv';



% convert file .arff to csv
stringeval=strcat( ['!java ', path, ' -Xmx4096m weka.core.converters.CSVSaver -H -i ', arffInput, ' -o ',outputCsv]);

eval(stringeval);

end


