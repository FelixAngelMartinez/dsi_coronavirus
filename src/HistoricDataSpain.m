function [output, name_ccaa, iso_ccaa, data_spain] = HistoricDataSpain()

missingDataText = 'NA';

cod_ccaa_cell = {'AN', 'Andalucía';
            'AR', 'Aragón';
            'AS', 'Principado de Asturias';
            'IB', 'Islas Baleares';
            'CN', 'Canarias';
            'CB', 'Cantabria';
            'CM', 'Castilla-La Mancha';
            'CL', 'Castilla y León';
            'CT', 'Cataluña';
            'CE', 'Ceuta';
            'VC', 'Comunidad Valenciana';
            'EX', 'Extremadura';
            'GA', 'Galicia';
            'MD', 'Comunidad de Madrid';
            'ML', 'Melilla';
            'MC', 'Región de Murcia';
            'NC', 'Comunidad Foral de Navarra';
            'PV', 'País Vasco';
            'RI', 'La Rioja'};

if ~isfolder('data')        
    mkdir('data');
end

    
%% Import data
results_url = 'https://cnecovid.isciii.es/covid19/resources/agregados.csv';
websave("data/ccaa_data_isciii.csv", results_url);
ccaa_data = readcell("data/ccaa_data_isciii.csv", 'DatetimeType', 'text');


%% Historic data
historic = cell(1,3); % (# countries, 3)

%% Replace nonexistent values

ccaa_data = cellfun(@(el) getReplacedNonexistentValues(el), ccaa_data, 'UniformOutput', false);

    function val = getReplacedNonexistentValues(element)
        if ischar(element) && strcmp(element, missingDataText)
            val = 0;
        else
            val = element;
        end
    end

%% CSV Data
for ix_ccaa = 2 : size(ccaa_data, 1)
    
    ccaa = ccaa_data{ix_ccaa, 1};
    
    if ismissing(ccaa)
        break;
    end
    
    if isempty(find(ismember(cod_ccaa_cell(:, 1), ccaa)))
        break;
    end
    
    ix_ccaa_rep = [];
    
    if ~isempty(historic{1, 1})
        ix_ccaa_rep = find(ismember(historic(:, 1), ccaa));
    else
        historic(1, :) = [];
    end
        
    row_data = ccaa_data(ix_ccaa, 2:end);
    
    Day = cellstr(datetime(row_data{1}, 'InputFormat', 'dd/MM/yyyy', 'Format', 'dd-MM-yyyy'));
    
    AcumulatedCases = row_data{2};
    if ismissing(AcumulatedCases)
        AcumulatedCases = 0;
    end
    
      AcumulatedPRC = row_data{3};
    if ismissing(AcumulatedPRC)
        AcumulatedPRC = 0;
    end
      AcumulatedTestAc = row_data{4};
    if ismissing(AcumulatedTestAc)
        AcumulatedTestAc = 0;
    end
    Hospitalized = row_data{5};
    if ismissing(Hospitalized)
        Hospitalized = 0;
    end
    
    Critical = row_data{6};
    if ismissing(Critical)
        Critical = 0;
    end
    
    Deaths = row_data{7};
    if ismissing(Deaths)
        Deaths = 0;
    end
    
    AcumulatedRecoveries = row_data{8};
    if ismissing(AcumulatedRecoveries)
        AcumulatedRecoveries = 0;
    end
    
    

    
    if isempty(ix_ccaa_rep)

        data = struct;
       
        data.AcumulatedCases = AcumulatedCases;
        data.AcumulatedPRC = AcumulatedPRC;
        data.AcumulatedTestAc = AcumulatedTestAc;
        data.Hospitalized = Hospitalized;
        data.Critical = Critical;
        data.Deaths = Deaths;
        data.AcumulatedRecoveries = AcumulatedRecoveries;
        data.label_x = Day;

        historic{end+1, 1} = ccaa;
        historic{end, 2} = cod_ccaa_cell{find(ismember(cod_ccaa_cell(:, 1), ccaa)), 2};
        historic{end, 3} = data;  

        continue;
        
    end
    
    data = historic{ix_ccaa_rep, 3};
    
    data.AcumulatedCases(end+1) = AcumulatedCases;
    data.AcumulatedPRC(end+1) = AcumulatedPRC;
    data.AcumulatedTestAc(end+1) = AcumulatedTestAc;
    data.Hospitalized(end+1) = Hospitalized;
    data.Critical(end+1) = Critical;
    data.Deaths(end+1) = Deaths;
    data.AcumulatedRecoveries(end+1) = AcumulatedRecoveries;
    data.label_x(end+1) = Day;
    
    historic{ix_ccaa_rep, 3} = data;
           
end


%% Cases and Daily data
for ix_ccaa = 1 : size(historic, 1)

    data = historic{ix_ccaa, 3}; 
    
    for idx_day = 1 : length(data.label_x)
         if(data.AcumulatedCases(idx_day) == 0 )
            data.Cases(idx_day) = data.AcumulatedPRC(idx_day) - data.Deaths(idx_day) - data.AcumulatedRecoveries(idx_day);
         else
            data.Cases(idx_day) = data.AcumulatedCases(idx_day) - data.Deaths(idx_day) - data.AcumulatedRecoveries(idx_day);
        end
    end
    data.DailyCases = data.AcumulatedCases(1);
    data.DailyDeaths = data.Deaths(1);
    data.DailyRecoveries = data.AcumulatedRecoveries(1);
    
    for idx_day = 1 : length(data.label_x) - 1
        
        NextAcumulatedCases = data.AcumulatedCases(idx_day+1);
        if( NextAcumulatedCases == 0)
            NextAcumulatedCases = data.AcumulatedPRC(idx_day+1);
        end
        ActualAcumulatedCases = data.AcumulatedCases(idx_day);
        if( ActualAcumulatedCases == 0)
            ActualAcumulatedCases = data.AcumulatedPRC(idx_day);
        end
        
        data.DailyCases(idx_day+1) = NextAcumulatedCases - ActualAcumulatedCases;
        data.DailyCases(find(data.DailyCases<0)) = 0;
        
        data.DailyDeaths(idx_day+1) = data.Deaths(idx_day+1) - data.Deaths(idx_day);
        data.DailyDeaths(find(data.DailyDeaths<0)) = 0;
        
        data.DailyRecoveries(idx_day+1) = data.AcumulatedRecoveries(idx_day+1) - data.AcumulatedRecoveries(idx_day);
        data.DailyRecoveries(find(data.DailyRecoveries<0)) = 0;
        
    end
    
    historic{ix_ccaa, 3} = data;
    
end


%% Aggregated data for Spain
data_spain = {};

for ix_ccaa = 1 : size(historic, 1)

    data_aux = historic{ix_ccaa, 3};
    
    if ix_ccaa == 1
    
        data_spain.AcumulatedCases = data_aux.AcumulatedCases;
        data_spain.AcumulatedPRC = data_aux.AcumulatedPRC;
        data_spain.AcumulatedTestAc = data_aux.AcumulatedTestAc;
        data_spain.Hospitalized = data_aux.Hospitalized;
        data_spain.Critical = data_aux.Critical;
        data_spain.Deaths = data_aux.Deaths;
        data_spain.AcumulatedRecoveries = data_aux.AcumulatedRecoveries;
        data_spain.label_x = data_aux.label_x;
        
        data_spain.DailyCases = data_aux.DailyCases;
        data_spain.DailyDeaths = data_aux.DailyDeaths;
        data_spain.DailyRecoveries = data_aux.DailyRecoveries;
        data_spain.Cases = data_aux.Cases;
        
        continue;
        
    end

    data_spain.AcumulatedCases = data_spain.AcumulatedCases + data_aux.AcumulatedCases;
    data_spain.AcumulatedPRC = data_spain.AcumulatedPRC + data_aux.AcumulatedPRC;
    data_spain.AcumulatedTestAc = data_spain.AcumulatedTestAc + data_aux.AcumulatedTestAc;

    data_spain.Hospitalized = data_spain.Hospitalized + data_aux.Hospitalized;
    data_spain.Critical = data_spain.Critical + data_aux.Critical;
    data_spain.Deaths = data_spain.Deaths + data_aux.Deaths;
    data_spain.AcumulatedRecoveries = data_spain.AcumulatedRecoveries + data_aux.AcumulatedRecoveries;
    
    data_spain.DailyCases = data_spain.DailyCases + data_aux.DailyCases;
    data_spain.DailyDeaths = data_spain.DailyDeaths + data_aux.DailyDeaths;
    data_spain.DailyRecoveries = data_spain.DailyRecoveries + data_aux.DailyRecoveries;
    data_spain.Cases = data_spain.Cases + data_aux.Cases;
    
end


%% Only data
output = struct;
output.historic = historic(:, 3);

iso_ccaa = historic(:, 1);
name_ccaa = historic(:, 2);

end