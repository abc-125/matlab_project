classdef loadData < handle
   % Object to hold processed data from file
   properties
        data;
        standardDeviation = 0;
        meanValue = 0;
        medianValue = 0;
        quartile1 = 0;
        quartile3 = 0;
        size = 0;
   end
       
   methods
        % constructor
        function obj = loadData(filename)
            try
                data = readmatrix(filename);
                if length(data) < 2
                    errordlg('Not enough data in file', 'Error');
                else
                    calculateAll(obj, data);
                end
            catch
                errordlg('Cannot read file', 'File Error');
            end

        end
       
        % helper function to calculate all variables while creating object
        function calculateAll(obj, data)
            obj.data = data;
            obj.standardDeviation = std(data);
            if length(obj.standardDeviation) > 1
                errordlg('Too much data in file', 'Error');
                obj.size = -1;
                return;
            end
            obj.meanValue = mean(data);
            obj.medianValue = median(data);
            [obj.quartile1, obj.quartile3] = calculateFirstAndThirdQuartile(obj);
            obj.size = length(data);
        end
        
        % helper function to calculate first and third quartile 
        % without Statistical Toolbox
        function [q1, q3] = calculateFirstAndThirdQuartile(obj)
            sorted = sort(obj.data);
            medianIndex = find(sorted == obj.medianValue, 1);
            sortedFirsthalf = sorted(1:medianIndex);
            sortedSecondhalf = sorted(medianIndex+1:end);
            q1 = median(sortedFirsthalf);
            q3 = median(sortedSecondhalf);
        end
        
        % turns object to string
        function str = toString(obj)
            str = 'Standard deviation: ' ...
                    + string(obj.standardDeviation) + newline + ...
                'Mean: ' + string(obj.meanValue) + newline + ...
                'Median: ' + string(obj.medianValue) + newline + ...
                'First quartile: ' + string(obj.quartile1) + newline + ...
                'Third quartile: ' + string(obj.quartile3) + newline + ...
                'Size: ' + string(obj.size) + newline;            
        end
   end
    
end