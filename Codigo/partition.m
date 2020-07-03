function [ndatapartition partitiontype]= partition(set)

%% LOG: FECHA_partition.txt
Tiempo=clock;
% log_resumen='C:/pruebas_PFC/';
% log_resumen=strcat(log_resumen,int2str(Tiempo(1)));
% log_resumen=strcat(log_resumen,int2str(Tiempo(2)));
% log_resumen=strcat(log_resumen,int2str(Tiempo(3)));
% log_resumen=strcat(log_resumen,'_');
% log_resumen=strcat(log_resumen,int2str(Tiempo(4)));
% log_resumen=strcat(log_resumen,int2str(Tiempo(5)));
% name_txt=['_partition.txt'];
% log_txt=strcat(log_resumen,name_txt);
% fid_p = fopen(log_txt, 'a');

%% INICIO VARIABLES
partitiontype = 1; % 1 if it is made by instances, 0 by features
[nInst nFeat]=size(set);
proportion=nInst/nFeat;

%% ALGORITMO
if(proportion>10000)&& ((nInst/10000) >3)
    ndatapartition=10000; %caso KDD
else
    if(proportion>1000) && ((nInst/1000) >3)
        ndatapartition=1000; %caso connect4,..
    else
        n=[100, 50,20, 10, 5 ,2 ,1, 0.5, 0.25]; %paquetes de 100 veces el nFeat,voy disminuyendo hasta que se cumpla una condición
        i=1;
        while(i>0 && i<10) 
            if((nInst/(nFeat*n(i)))>3) %al menos 3 paquetes siempre
                ndatapartition=nFeat*n(i);
                i=0; % si he entrado alguna vez pongo i=0
            else
                i=i+1;
            end          
        end
        
        if (i>0) %no cumplió ninguna anterior-> intento dividir por características
            partitiontype=0;
            
            %hago la misma division, ahora por caracteristicas
            n=[100, 50,20, 10, 5 ,2 ,1, 0.5, 0.25]; %paquetes de 100 veces el nInst,voy disminuyendo hasta que se cumpla una condición
            i=1;
            while(i>0 && i<10) 
                if((nFeat/(nInst*n(i)))>3) %al menos 3 paquetes siempre
                    ndatapartition=nInst*n(i);
                    i=0; % si he entrado alguna vez pongo i=0
                else
                    i=i+1;
                end          
            end
            if i>0
                ndatapartition = nInst;
            end
            fprintf('** División por características***\n');
        end
    end
end
% nPaquetes=floor(nInst/ndatapartition);
%% LOG: Impresion de resultados
% fprintf(fid_p,'\n---------------------------------------------');
% fprintf(fid_p,'\nnMuestras= %d', nInst);
% fprintf(fid_p,'\nnCaracteristicas= %d', nFeat);
% fprintf(fid_p,'\nproporcionDataset= %d', proportion);        
% fprintf(fid_p,'\ndatosPorParticion= %d',ndatapartition);   
% fprintf(fid_p,'\nnPaquetes= %d',nPaquetes);   
% fprintf(fid_p,'\n---------------------------------------------');

%% CERRAR ARCHIVOS        
% fclose(fid_p);    

end