function seleccion = seleccionRanker(entrada)

t=findstr('Ranked attributes:',entrada);
v=findstr('Selected attributes:',entrada);
entrada=entrada(t+18:v-1);
t=strfind(entrada,'at');
%filtervars=entrada(t+2:t+7);
[temp,fin]=size(t);
iniAtributo=1;
descartados=0;
atributosRank='';
for i=1:fin
    if i==1
        extra=0;
    else
        extra=1;
    end
    
    cadena=strread(entrada(iniAtributo:t(i)),'%s');
    rankTemp=str2num(cadena{1+extra});
    
    if rankTemp>0        
        atributo=cadena{2+extra};
        if i==1
            atributosRank=strcat(atributosRank,atributo);
        else
            atributosRank=strcat(atributosRank,strcat(',',atributo));
        end
        
    else
        break;
    end
    iniAtributo=t(i)+2;
    
end

seleccion=[ '[' atributosRank ']'];
%selection = ['[' filtervars ']'];

end
