function [outputARFF] = mat2arff(name,matInput,path, class)
%function [outputARFF] = mat2arff(name,matInput)
tstart=tic;
%fprintf('\n**** Convirtiendo csv a arff: %s ****\n',name);
outputCSV = 'auxcsv.csv';
outputARFF = name;

[x y] = size(matInput);


fid = fopen(outputCSV, 'w');

%Primera fila, en la que ira la cabecera
for i=1:(y-1)
    r = strcat('at', int2str(i));
    fprintf(fid,'%s,',r);
end
fprintf(fid,'%s\n','class');

%Comprobamos si la clase es numerica. En caso de que lo sea, habra que
%pasarla a nominal
class = matInput(1,y);
isclassnum = isnumeric(class);

%INTENTAR PARALELIZAR EL BUCLE, P.EJ DIVIDIENDO EL DATASET EN BLOQUES
for i=1:x
    for j=1:y
            aux = matInput(i,j);
            if (iscell(aux))
                aux = aux{1};
            end
            if j==y             
                if isclassnum
                    aux = int2str(aux);
                    s = strcat('class', aux);
                    fprintf(fid,'%s\n',s);
                else
                    fprintf(fid,'%s\n',aux);

                end
            else
                fprintf(fid,'%g',aux);
                fprintf(fid,',');
            end
    end
end
%fprintf(fid,texto);

fclose(fid);

tfin=toc(tstart);
%fprintf('Tiempo creacion archivo csv: %f segundos\n', tfin); 
% Pasamos el fichero .csv a .arff
stringeval=strcat( ['!java ', path, ' -Xmx4096m weka.core.converters.CSVLoader ', outputCSV, ' > ',outputARFF]);

eval(stringeval);
%LO QUITO DE LA CONSOLA
tfinish=toc(tstart);
%fprintf('Tiempo total mat2arff: %f segundos\n', tfinish); 
end


