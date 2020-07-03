function [selection] = filters(which, inputTrain, path, maxFeat)

%maxFeat solo necesario para ReliefF e InfoGain

%path = ' -cp "C:\Program Files\Weka-3-8-4\*" ';

selection = [];

fprintf('================== Aplicando filtro selección %s ==================\n',which);
Tiempo=clock;
%fprintf('%s:%s:%s;Filter pre:%s\n',int2str(Tiempo(4)),int2str(Tiempo(5)),int2str(Tiempo(6)),which);

switch(which)
    case 'CFS', % CFS- BestFirst
        s = evalc(['!java ', path, ' -Xmx4g weka.attributeSelection.AttributeSelection weka.attributeSelection.CfsSubsetEval -s "weka.attributeSelection.BestFirst -N 5" -c last -i ',inputTrain]);
    case 'InfoGain', % Info Gain
        s = evalc(['!java ', path, ' -Xmx4g weka.attributeSelection.AttributeSelection weka.attributeSelection.InfoGainAttributeEval -s "weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N ', int2str(maxFeat), '" -c last -i ', inputTrain]);            
    case 'ReliefF', % ReliefF
        s = evalc(['!java ', path, ' -Xmx4g weka.attributeSelection.AttributeSelection weka.attributeSelection.ReliefFAttributeEval -s "weka.attributeSelection.Ranker -T -1.7976931348623157E308 -N ', int2str(maxFeat), '" -c last -i ', inputTrain]);
     case 'Consistency' % Cons BestFirst
        s = evalc(['!java ', path, ' -Xmx4g weka.attributeSelection.AttributeSelection weka.attributeSelection.ConsistencySubsetEval -s "weka.attributeSelection.BestFirst -N 5" -c last -i ',inputTrain]);            
     otherwise
        error('filters:incorrectFilter', 'Incorrect filter');
end;
Tiempo=clock;
%fprintf('%s:%s:%s;Filter pos:%s\n',int2str(Tiempo(4)),int2str(Tiempo(5)),int2str(Tiempo(6)),which);

if ~isempty(strfind('Weka exception', s))
    error('classifier:wekaProblem', 'Weka exception in filter');
end;


if (strcmp(which,'InfoGain')||strcmp(which, 'ReliefF')) % Es InfoGain o ReliefF, con metodos Ranker
    
 %% CODIGO PARA ESCOGER LAS CARACTERISTICAS SELECCIONADAS POR PARA EL METODO RANKER
 Tiempo=clock;
%fprintf('%s:%s:%s;Filter pre ranker:%s\n',int2str(Tiempo(4)),int2str(Tiempo(5)),int2str(Tiempo(6)),which);
 
 selection=seleccionRanker(s);

 Tiempo=clock;
%fprintf('%s:%s:%s;Filter pos ranker:%s\n',int2str(Tiempo(4)),int2str(Tiempo(5)),int2str(Tiempo(6)),which);

 else
    
    % Se descomponen la salida que devuelve weka para quedarnos solo con
    %las variables seleccionadas por el filtro
    t=strfind(s, 'Selected attributes:');
    result2=s(t+20:length(s));
    t=strfind(result2,':');
    filtervars=result2([1:t-1]);
    selection = ['[' filtervars ']'];
end
 

end




