function [head] = getHead(dataset)

switch dataset 
    case 'Arrhythmia'
        head = 'cabeceras/cabecera1-16.txt';
    case 'Brain'
        head = 'cabeceras/cabecera1-2.txt';
    case 'CNS'
        head = 'cabeceras/cabecera1-2.txt';        
    case 'Colon'
        head = 'cabeceras/cabecera1-2.txt';
    case 'Connect4'
        head = 'cabeceras/cabecera0-2.txt';
    case 'Gli85'
        head = 'cabeceras/cabecera1-2.txt'; 
    case 'Musk2'
        head = 'cabeceras/cabecera0-1.txt';   
    case 'Nomao'
        head = 'cabeceras/cabecera-1-1.txt';
    case 'Ovarian'
        head = 'cabeceras/cabecera1-2.txt';     
    case 'Ozone'
        head = 'cabeceras/cabecera0-1.txt';      
    case 'Spambase'
        head = 'cabeceras/cabecera0-1.txt';        
    case 'Weight'
        head = 'cabeceras/cabecera1-5.txt';
    case 'Isolet'
        head = 'cabeceras/cabecera1-26.txt';
otherwise
        disp('Error');
           
end

end        