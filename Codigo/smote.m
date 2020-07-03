function [archivoSmotizado_arff] = smote(archivoEntrenamiento_arff,path,smoted,porcentajeCalculado, claseMayoritaria)


if strcmp(smoted, 'Calculate')
    smoted = int2str(porcentajeCalculado);
end
  
if (claseMayoritaria)
    archivoSmotizado_arff=strcat(archivoEntrenamiento_arff(1:max(strfind(archivoEntrenamiento_arff,'.'))-1),'_smote_may.arff');
  %  comandoSmote = ['!java ', path, ' -Xmx4g weka.filters.supervised.instance.SMOTE -C ',int2str(claseMayoritaria),' -K 5 -S 1 -P ',smotemax,' -i ', archivoEntrenamiento_arff, ' -o ',archivoSmotizado_arff ,' -c last'];
    evalc(['!java ', path, ' -Xmx4g weka.filters.supervised.instance.SMOTE -C ',int2str(claseMayoritaria), ' -K 5 -S 1 -P ',smoted,' -i ', archivoEntrenamiento_arff, ' -o ',archivoSmotizado_arff ,' -c last']);
else
    archivoSmotizado_arff=strcat(archivoEntrenamiento_arff(1:max(strfind(archivoEntrenamiento_arff,'.'))-1),'_smote.arff');
  %  comandoSmote = ['!java ', path, ' -Xmx4g weka.filters.supervised.instance.SMOTE -K 5 -S 1 -P ',smotemin,' -i ', archivoEntrenamiento_arff, ' -o ',archivoSmotizado_arff ,' -c last'];
    res = evalc(['!java ', path, ' -Xmx4g weka.filters.supervised.instance.SMOTE -K 5 -S 1 -P ',smoted,' -i ', archivoEntrenamiento_arff, ' -o ',archivoSmotizado_arff ,' -c last']);
   % en el caso de que la clase solo tenga una instancia, no tiene vecinos,
   % por los que SMOTE devuelve un error, en ese caso mantengo el mismo
   % archivo de entrada
    if (res)
        archivoSmotizado_arff = archivoEntrenamiento_arff;
    end
end

end