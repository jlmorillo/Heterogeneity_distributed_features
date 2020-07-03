function [ftrainnew, ftestnew]= cabecerasArff2(ftrain,ftest,cabecera,auxfiletest,auxfiletrain)

fid1 = fopen(auxfiletest,'w');
fid2 = fopen(auxfiletrain,'w');
fid3 = fopen(ftest, 'r');
fid4 = fopen(ftrain, 'r');
fid5 = fopen(cabecera, 'r');

cabeceraLine = fgetl(fid5);
fclose(fid5);


% Fichero de test
while (~feof(fid3))
    line = fgetl(fid3);
    t = findstr('@attribute class', line);
    if t==1
        fprintf(fid1, '%s\n', cabeceraLine);
    else
        fprintf(fid1, '%s\n', line);
    end
end


% Fichero de train
while (~feof(fid4))
    line = fgetl(fid4);
    t = findstr('@attribute class', line);
    if t==1
        fprintf(fid2, '%s\n', cabeceraLine);
    else
        fprintf(fid2, '%s\n', line);
    end
end




fclose(fid1);
fclose(fid2);
fclose(fid3);
fclose(fid4);

ftestnew = auxfiletest;
ftrainnew = auxfiletrain;
