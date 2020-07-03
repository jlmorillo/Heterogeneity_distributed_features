# Heterogeneity_distributed_features
 KAIS - Dealing with heterogeneity in the context of distributed feature selection

Matlab R2020a code for KAIS article "Dealing with heterogeneity in the context of distributed feature selection"

Folders:

Codigo: code for the experiments. Main.m is the main file to run.
cabeceras: head files for datasets
datasets: microarray and regular datasets for experiments
Pruebas_PhD: auxiliar folders and results in log_classifiers_total.csv

log_classifiers_total.csv
- Dataset : regular  {'Connect4', 'Musk2', 'Nomao', 'Isolet', 'Ozone', 'Spambase', 'Weight'} and microarray { 'Brain', 'CNS', 'Colon', 'Ovarian', 'Gli85'}
- Distribution: Centralizado (Centralized), Aleatoria (Random) and Homogenea (Homogeneous)
- Round: number of round
- SmoteMin: SMOTE percentage in the minority class or Calculate for Auto option
- SmoteMax: SMOTE percentage in the majority class	
- RUS: option of SMOTE in minority class and Random undersampling in the majority class. 1 if it is applied or 0 if not
- Filter: {'CFS', 'InfoGain', 'ReliefF', 'Consistency'}
- Classifier: {'C4.5' 'Naive-Bayes' 'IB1' 'SVM'}
- AccuracyTrain: percentage of classification accuracy in the train partition of the original dataset
- AccuracyTest: percentage of classification accuracy in the test partition of the original dataset	
- kStat: Kappa value of the test partition classification of the original dataset
- tMeanFilter: average time by rounds of packets filtering 
- tClassifier: average time by rounds of classification
- noPackets: number of packets generated	
- dataPartition: number of elements of partition
- partitiontype: type of partition -  0 by features, 1 by instances
- nFeatWithClass: number of best features including the class

