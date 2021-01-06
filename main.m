function main()
    % UI:
    screenSize = get(groot, 'ScreenSize');
    figSize = [1000, 600];
    window = uifigure('Position', [(screenSize(3:4) - figSize)/2 figSize], ...
        'Name', 'Statistical Analysis');
    
    menuFile = uimenu(window, 'Text', 'File  ');
    menuOpen = uimenu(menuFile, 'Text', 'Open...');
    menuOpen.MenuSelectedFcn = @menuOpenSelected;
    menuClose = uimenu(menuFile, 'Text', 'Close', 'Enable', 'off');
    menuClose.MenuSelectedFcn = @menuCloseSelected;
    menuSave = uimenu(window, 'Text', 'Save result  ', 'Enable', 'off');
    menuSaveToTxt = uimenu(menuSave, 'Text', 'Save to txt');
    menuSaveToTxt.MenuSelectedFcn = @menuSaveToTxtSelected;
    menuCopy = uimenu(menuSave, 'Text', 'Copy to buffer');
    menuCopy.MenuSelectedFcn = @menuCopySelected;
    menuAbout = uimenu(window, 'Text', 'About  ');
    menuAbout.MenuSelectedFcn = @menuAboutSelected;
    
    % 8 rows on the left, 1 on the right:
    layout = uigridlayout(window, [1 2]);
    layout.ColumnWidth = {200, '1x'};
    leftSide = uigridlayout(layout, [1 8]);
    leftSide.RowHeight = {22, 22, 22, 22, 22, 22, 22, 22};
    leftSide.ColumnWidth = {150};
    
    labelStandardDeviation = uilabel(leftSide, 'Text', 'Standard deviation:');
    labelStandardDeviation.Layout.Row = 1;
    labelStandardDeviation.Layout.Column = 1;
    labelMean = uilabel(leftSide, 'Text', 'Mean:');
    labelMean.Layout.Row = 2;
    labelMean.Layout.Column = 1;
    labelMedian = uilabel(leftSide, 'Text', 'Median:');
    labelMedian.Layout.Row = 3;
    labelMedian.Layout.Column = 1;
    labelFirstQuartile = uilabel(leftSide, 'Text', 'First quartile:');
    labelFirstQuartile.Layout.Row = 4;
    labelFirstQuartile.Layout.Column = 1;
    labelThirdQuartile = uilabel(leftSide, 'Text', 'Third quartile:');
    labelThirdQuartile.Layout.Row = 5;
    labelThirdQuartile.Layout.Column = 1;
    labelSize = uilabel(leftSide, 'Text', 'Size:');
    labelSize.Layout.Row = 6;
    labelSize.Layout.Column = 1;
    
    dropdownGraph = uidropdown(leftSide, 'Items',{'Probability density', ...
        'Cumulative distribution', 'Disperse'}, ...
        'ValueChangedFcn', @updateDropdownGraph, ...
        'Enable', 'off');
    dropdownGraph.Layout.Row = 8;
    dropdownGraph.Layout.Column = 1;
    
    axesDistr = uiaxes(layout);
    disableDefaultInteractivity(axesDistr);

    
    % CALLBACK FUNCTIONS:
    
    % opens file, creates object d with all data from file,
    % enables closing, saving and changing graph,
    % calls fillInfo()
    function menuOpenSelected(~, ~)
        filename = uigetfile({'*.xlsx'; '*.xls'; '*.xlsb'; '*.xlsm'; ...
            '*.xltm'; '*.xltx'; '*.csv'; '*.txt'});
        if filename ~= 0
            d = loadData(filename);
            % if files was loaded correctly:
            if d.size > 1
                setappdata(window, 'd', d);
                fillInfo();
                menuClose.Enable = 'on';
                menuSave.Enable = 'on';
                dropdownGraph.Enable = 'on';
                dropdownGraph.Value = 'Probability density';
                ylabel(axesDistr, 'Probability density function');
            end
        else
            errordlg('Cannot open file', 'File Error');
        end
    end

    % disables closing, saving and changing graph,
    % calls cleanInfo()
    function menuCloseSelected(~, ~)
        cleanInfo();
        menuClose.Enable = 'off';
        menuSave.Enable = 'off';
        dropdownGraph.Enable = 'off';
    end

    % saves object d as string to output.txt
    function menuSaveToTxtSelected(~, ~)
        d = getappdata(window, 'd');
        str = toString(d);
        fileID = fopen('output.txt','w');
        fprintf(fileID, str);
        fclose(fileID);
        msgbox('Saved to output.txt', 'Done');
    end

    % copies object d as string to buffer
    function menuCopySelected(~, ~)
        d = getappdata(window, 'd');
        str = toString(d);
        clipboard('copy', str);
        msgbox('Copied to buffer', 'Done');
    end

    % short info message about program
    function menuAboutSelected(~, ~)
        message = {'This is a simple app this allows you to load data ', ...
        'and calculate and display statistical parameters.'};
        msgbox(message, 'About');
    end

    % changing graph on the screen
    % (Probability density, Cumulative distribution or Disperse)
    function updateDropdownGraph(src, ~)
        val = src.Value;
        d = getappdata(window, 'd');
        if isequal(val, 'Probability density')
            plotProbabilityDensity();
            ylabel(axesDistr, 'Probability density function');
        elseif isequal(val, 'Cumulative distribution')
            histogram(axesDistr, d.data, 'Normalization', 'cdf');
            ylabel(axesDistr, 'Cumulative distribution function');
        elseif isequal(val, 'Disperse')
            y = zeros(d.size, 1) + d.meanValue;
            errorbar(axesDistr, y, power((d.data-d.meanValue), 2));
            ylabel(axesDistr, 'Disperse function');
        end
    end


    % OTHER FUNCTIONS:
    % helper function to fill info on the screen
    function fillInfo()
        d = getappdata(window, 'd');
        labelStandardDeviation.Text = 'Standard deviation: ' ...
                + string(d.standardDeviation);
        labelMean.Text = 'Mean: ' + string(d.meanValue);
        labelMedian.Text = 'Median: ' + string(d.medianValue);
        labelFirstQuartile.Text = 'First quartile: ' + string(d.quartile1);
        labelThirdQuartile.Text = 'Third quartile: ' + string(d.quartile3);
        labelSize.Text = 'Size: ' + string(d.size);
        plotProbabilityDensity();
        figure(window);
    end

    % helper function to remove all info from the screen
    function cleanInfo()
        labelStandardDeviation.Text = 'Standard deviation:';
        labelMean.Text = 'Mean:';
        labelMedian.Text = 'Median:';
        labelFirstQuartile.Text = 'First quartile:';
        labelThirdQuartile.Text = 'Third quartile:';
        labelSize.Text = 'Size:';
        cla(axesDistr);
        ylabel(axesDistr, '');
        rmappdata(window, 'd');
    end

    % count and show Probability Density as a histogram
    % and Normal Distribution as a line
    function plotProbabilityDensity()
        d = getappdata(window, 'd');
        histogram(axesDistr, d.data, 'Normalization', 'pdf');
        % Normal Distribution:
        x = min(d.data):1:max(d.data);
        y = (1/(d.standardDeviation*sqrt(2*pi)))*exp(-0.5*(((x-d.meanValue)/d.standardDeviation).^2));
        line(axesDistr, x, y, 'Color', 'm');
    end

end

