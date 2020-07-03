function [k, Data, Data2] = splitdata(Input,n,cflag1,flag2)

if strcmp(cflag1, 'Centralizado')
    flag1 = 1;
elseif strcmp(cflag1, 'Aleatoria')
    flag1 = 2;
elseif strcmp(cflag1, 'Homogenea')
    flag1 = 3;
else
    disp('Error: Distribution not correct in splitdata.');
    Data = {};
    return;
end

%flag1
F_NORANDOM  = 1;
F_RANDOM    = 2;
F_HOMOGENEO = 3;

%flag2
F_FEATURES = 0;
F_INSTANCES = 1;

if nargin == 1      % One argument
    disp('Error: The function needs at least two arguments.');
    Data = {};
    return;
elseif nargin == 2  % Two arguments
    flag1 = 1;       % The flag that selects the random process is activated
    flag2 = 1;       % The flag that selects the partition by instances is activated
elseif nargin == 3  % Three arguments
    if flag1 ~= F_NORANDOM && flag1 ~= F_RANDOM && flag1 ~= F_HOMOGENEO
        disp('Error: The flag argument has not a valid value.');
        Data = {};
        return;
    end
    flag2 = 1;       % The flag that selects the partition by instances is activated
elseif nargin == 4  % Four arguments
    if flag2 ~= F_INSTANCES && flag2 ~= F_FEATURES
        disp('Error: The flag argument has not a valid value.');
        Data = {};
        return;
    end
end



[NIns,NVars] = size(Input);        % Obtains the dimensions of the data 

if flag2 == F_INSTANCES
    NData = NIns;
    k = floor(NIns/n);
else
    NData = NVars-1;
    k = floor((NVars-1)/n);
    % ATENCION A QUE HAI QUE CONSERVAR A CLASE
end
%% ******VARIACIONES EN EL NUMERO DE PAQUETES******************

%% CASO NORMAL
Data_per_packet = n;
Remainder = rem(NData,k);

%% CASO 10 PAQUETES
% k=10;
% Data_per_packet= floor(NIns/k);
% Remainder= rem (NData, k);

%% CASO OPTIMO PARA HOMOGENEA - ELSE NORMAL
% if flag1== F_HOMOGENEO
%     k=0;
% else
%     Data_per_packet = n;
%     Remainder = rem(NData,k);
% end


if flag1 == F_RANDOM                    
    rand('state',sum(100*clock));   % Resets the random generator to a different state each time
    %analyze(Input);
    rand_indices = randperm(NData); % Generates a random permutation of the indices from the dataset
    %rand_indices = 1:NData;
    
else
    if flag1 == F_NORANDOM || flag2 == F_FEATURES % no tiene sentido hacer distribucion homogenea y dividir por caracteristicas           
        rand_indices = 1:NData;
    else
        %DISTRIBUCION HOMOGENEA
        [rand_indices, Data_per_packet] = analyzedatasetH(Input,k);
        Remainder=0; %El numero de elementos por paquete es exacto, la proporcion de elementos/clase es constante
        k = floor(NData/Data_per_packet);
    end
end
%k
%Data_per_packet

Packet_beg = 1;
Packet_end = Data_per_packet;



for index = 1:k    
    if Remainder
        Inc = 1;
        Remainder = Remainder - 1;
    else 
        Inc = 0;
    end
    if flag2 == F_INSTANCES

        Data{index} = Input(rand_indices(Packet_beg:Packet_end+Inc),:); 
    else
        auxData = Input(:,rand_indices(Packet_beg:Packet_end+Inc));
        Data{index} = [auxData Input(:,NVars)]; 
    end
        
    Packet_beg = Packet_beg + Data_per_packet + Inc;
    Packet_end = Packet_end + Data_per_packet + Inc;
end
if flag2 == F_INSTANCES
    Data2=Input(rand_indices,:); 
else
    Data21=Input(:,rand_indices); 
    Data2=[Data21 Input(:,NVars)];
end
end