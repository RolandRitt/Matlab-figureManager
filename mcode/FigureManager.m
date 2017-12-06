classdef FigureManager < handle
    %
    % This class defines a structure to manage axes and plots
    % being added to a figure. Combined with the PlotManager2D
    % it enables the plotting of data with very large number
    % of data points.
    %
    % The data in each plot object is decimated so as to
    % correspond to 200 dpi when printing. As you zoom or pan
    % additional data is displayed. At the deepest level of
    % zoom you see the original data.
    %
    % Currently the following decimation methods are
    % implemented:
    %
    % # 'MinMax': Selects the minimum and maximum values in the
    % subdivision for plotting. This works well with line plots,
    % ensuring that there is no visual difference between the
    % original data and the decimated data when plotted.
    %
    % # 'downSample': Performs a simple reduction of the number
    % of points used, i.e., one point per subdivision.
    %
    % # 'IntegerY': This decimation was introduced to deal with
    % y-variable which are integers. Such data is common when
    % acquiring data with an analogue to digital converter
    % (ADC). In this case the histogram with integer bins is
    % computed for each sub-interval and all bins whihc are not
    % empthy are plotted. In this manner structure in the
    % integer data is maintained when decimated.
    %
    % The manager define a default decimation alogrithm.
    % However, the user may override this decision by defining
    % the 'UserData' to have the string corresponding the the
    % name of the devimation algorithm, e.g.
    %
    %  plot( x, y, 'k.', 'UserData', 'IntegerY' );
    %
    % Each graphical object associated with an axes has a
    % seperate manager object created to handel the decimation
    % of the
    %
    % The figure manager is simple to use, after generating
    % the figure to be managed the Figure manager is started
    % and noting else is required, e.g.,
    %
    %   fig = figure;
    %   PM = FigureManager
    %   plot( x, y, 'k.', 'UserData', 'IntegerY' );
    %
    % The file manager also adds a button to the fighure menu:
    % with the lable "Plot Control" its submenues
    %
    %  Plot control:
    %     Reset data: reset the plot to the un decimated data.
    %     Reset limits: reset the XLim and YLim of the axes
    %       back to its original values befor zooming.
    %     Save 2 PDF: save the current figure to a PDF file.
    %
    % History:
    %   Date: 09.06.2017          Comment: add save to PNG button
    properties
        figureH ; % Handel to the figure whihc is being managed
        hMenu; % Handel to additional button on figure menu
        
        axesListH = []; % a list of handels to the axes in figure
        plots = []; % a list of handels to the plots bein managed
        plotManagers = []; % Array of handels to the plot managers
        %
        preferences ;
        %
        shouldAdd = true;
    end;
    
    events
        % event to reset all plots
        plotReset % Return to un-reduced data
        plotResetLims % reset limits
        plotRefresh  % recalcalculate and redraw all plots
    end
    
    methods
        %
        function o = FigureManager( figureH )
            %
            o.setPreferences;
            % GET FIGURE HANDEL ---------------------
            % get a handel to the figure to be managed if it is
            % available
            %
            if (nargin == 0)
                % test if figure exists
                if isempty( findobj( 'type', 'figure' ))
                    error('No figure available to manage');
                else
                    figureH = gcf;
                end;
            end;
            o.figureH = figureH;
            % CHECK IF TEH FIGURE ALREADY HAS CHILDREN ------
            % then warn user, only later added children are
            % managed.
            %
            if ~isempty( o.figureH.Children )
                warning( 'The figure is not empty when starting.');
            end;
            % SET CREATE and DELETE FUNCTIONS ----------
            % for Figure
            set( figureH, 'defaultAxesCreateFcn',...
                @(src, evn) o.axesAdd( src, evn ));
            % assign figuremanager to it
            if ~isempty(figureH.UserData)
                warning('FigureManager can not be assigned to figureH');
            else
                figureH.UserData = o;
            end
            
            % for Plot, Stairs, Stem, Bar
            set( o.figureH, 'defaultLineCreateFcn',...
                @o.plotAdd);
            set( figureH, 'defaultStairCreateFcn',...
                @o.plotAdd);
            set( o.figureH, 'defaultStemCreateFcn',...
                @o.plotAdd);
            set( o.figureH, 'defaultBarCreateFcn',...
                @o.plotAdd);
            
            
            %
            % Figure size change call back
            %
            set( o.figureH, 'SizeChangedFcn',...
                @(~,~) o.plotRefreshAll );
            
            % EXTEND THE MENU --------------------------
            % Add a RESET button to the menu
            %
            hMenu = uimenu( gcf, 'Label', 'Plot Control' );
            uimenu( hMenu, ...
                'Label', 'Reset Data',...
                'Callback', @(~,~) o.plotResetAll );
            uimenu( hMenu, ...
                'Label', 'Reset Limits',...
                'Callback', @(~,~) o.plotResetLimsAll );
            uimenu( hMenu, ...
                'Label', 'Save to PDF',...
                'Callback', @(~,~) o.plotSave,...
                'Separator','on','Accelerator','P');
            uimenu( hMenu, ...
                'Label', 'Save to PNG',...
                'Callback', @(~,~) o.plotSavePNG,...
                'Accelerator','P');
            o.hMenu = hMenu ;
            %
        end;
        %-------------------------------------------
        % add the handel to the object to the list of axes
        function axesAdd(o, src, evn )
            o.axesListH = [o.axesListH; src];
        end;
        %-------------------------------------------
        % Add a managed plot to the manager
        function plotAdd( o, src, evn )
            % start a plotManager for each plot
            if o.shouldAdd
                plotManager = PlotManager2D( o, src );
                o.plotManagers = [o.plotManagers; plotManager];
                %
                tempH = get( src, 'Parent' );
                set( tempH, 'XLim', get(tempH, 'XLim'));
            end;
        end;
        %-------------------------------------------
        % reset to data to non devimated values
        function plotRefreshAll( o )
            notify(o,'plotRefresh');
        end;
        %-------------------------------------------
        % reset to data to non devimated values
        function plotResetAll( o )
            notify(o,'plotReset');
        end;
        %-------------------------------------------
        % reset to data to non devimated values
        function plotResetLimsAll( o )
            notify(o,'plotResetLims');
        end;
        %-------------------------------------------
        % reset to data to non devimated values
        function plotSave( o )
            H = gcf;
            %
            filterSpec = '*.pdf';
            dialogTitle = 'File name to save figure';
            defaultName = ...
                ['figure',datestr(now,'dd-mm-yyyy'),'.pdf'];
            [fileName,filePath] = ...
                uiputfile(filterSpec,dialogTitle,defaultName);
            %
            fullFileName = [filePath, fileName];
            %
            if (fileName ~= 0 )
                figureSave( H, fullFileName );
            end;
        end;
        
        function plotSavePNG( o )
            H = gcf;
            %
            filterSpec = '*.png';
            dialogTitle = 'File name to save figure';
            defaultName = ...
                ['figure',datestr(now,'dd-mm-yyyy'),'.png'];
            [fileName,filePath] = ...
                uiputfile(filterSpec,dialogTitle,defaultName);
            %
            fullFileName = [filePath, fileName];
            %
            if (fileName ~= 0 )
                figureSave( H, fullFileName, '-png' );
            end;
        end;
        
        %------------------------------------------------
        function setPreferences( o )
            % set the default preferences
            o.preferences.maxNrPts = 1000;
            o.preferences.DPI = 150;
            o.preferences.plotTypes = lower({'Line'; 'Area'; 'Stem';...
                'Stair'; 'Bar'; 'Marker' });
            o.preferences.decimationType = lower({'MinMax';...
                'downSample'; 'downSample';...
                'MinMax'; 'downSample'; 'downSample' });
            o.preferences.reductionFactor = [1; 1; 10; 1; 1; 5];
            o.preferences.decimationFunction = lower({'downSample';...
                'MinMax'; 'IntegerY' });
        end;
        %
        function stopAdding( o )
            o.shouldAdd = false;
        end;
        %
        function startAdding( o )
            o.shouldAdd = true;
        end;
        %
    end;
end