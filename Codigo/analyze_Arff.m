function [porcentaje, claseMayoritaria, numeroClasses] = analyze_Arff(archivo_Arff)
% ANALYZE_ARFF Analiza el paquete en formato arff para obtener la proporción de cada clase



numeroClasses={};
clases=false;
vectorClasses={};

fid_arff = fopen(archivo_Arff);

tline = fgetl(fid_arff);
m=0;
while ischar(tline)
    if clases
        nombreclase=tline(strfind(tline,'class'):end);
        if (isempty(nombreclase))
             %hay un espacio
        else            
            if(m==0)      %Primera clase
                vectorClasses{1}=nombreclase;
                numeroClasses{1}=1;
                m=1;
            else          %Ya hay más clases
                ind = find(strcmp(vectorClasses,nombreclase));
                if isempty(ind)             %Nueva clase
                    vectorClasses{m+1}=nombreclase;
                    numeroClasses{m+1}=1;
                    m=m+1;
                else                        %CLASE YA EXISTENTE
                    numeroClasses{ind}=numeroClasses{ind}+1;
                end
            end
            nInst=nInst+1;
        end
    end    
     if strncmp(tline,'@data',5)
        clases=true;
        nInst=0;
    end    
    tline = fgetl(fid_arff);
end
 
numeroclasesMayoritaria = 0;
claseMayoritaria = 1;
for j=1:m
     if (numeroClasses{j} > numeroclasesMayoritaria) 
        numeroclasesMayoritaria = numeroClasses{j};
        claseMayoritaria = j;
    end
end

% fprintf('Clase mayoritaria: %i, Size(vectorClasses):%i\n',claseMayoritaria, size(vectorClasses));
% fprintf('Clase mayoritaria: %s\n',vectorClasses{claseMayoritaria});

% Para devolver el porcentaje de SMOTE necesario para igualar las ocurrencias de la clase minoritaria con las de la clase mayoritaria
numOcurrenciasClaseMinoritaria=min(cell2mat(numeroClasses));
numOcurrenciasClaseMayoritaria=max(cell2mat(numeroClasses));
porcentaje= (round(numOcurrenciasClaseMayoritaria/numOcurrenciasClaseMinoritaria)-1)*100;

fclose(fid_arff);
end
