function [archivoSmotizado_arff] = undersampling(archivoEntrenamiento_arff,path)


  
    archivoSmotizado_arff=strcat(archivoEntrenamiento_arff(1:max(strfind(archivoEntrenamiento_arff,'.'))-1),'_under.arff');
  %  comandoSmote = ['!java ', path, ' -Xmx4g weka.filters.supervised.instance.SMOTE -C ',int2str(claseMayoritaria),' -K 5 -S 1 -P ',smotemax,' -i ', archivoEntrenamiento_arff, ' -o ',archivoSmotizado_arff ,' -c last'];
    res = evalc(['!java ', path, ' -Xmx4g weka.filters.supervised.instance.SpreadSubsample -M 1.0 -X 0.0 -S 1 -i ', archivoEntrenamiento_arff, ' -o ',archivoSmotizado_arff ,' -c last']);
    if (res)
        archivoSmotizado_arff = archivoEntrenamiento_arff;
    end
end