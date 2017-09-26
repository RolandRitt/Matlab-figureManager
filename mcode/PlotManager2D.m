classdef PlotManager2D < handle
    
    properties
        % Figure and axes handels
        figureH ;
        axesH ;
        
        % Plot information
        plotH;
        xDataOriginal ;
        yDataOriginal ;
        userData;
        plotType;
        %
        xLimOriginal ;
        yLimOriginal ;
        % reduced data
        xDataReduced ;
        yDataReduced ;
        %
        busy = false;
        preferences ;
        %
        decimationType ;
        reductionRate ;
    end
    
    methods
        %---------------------------------------
        function o = PlotManager2D( figueManagerH, plotH )
            o.preferences = figueManagerH.preferences;
            % Deal with plot types ---------------------
            % Is the plot handel to a type we support
            try
                o.plotType = lower(validatestring(plotH.Type,...
                    o.preferences.plotTypes));
            catch
                warning('Plot type is not supported');
            end
            % a special case when a line plot only has markers
            lineStyle = get(plotH, 'LineStyle' );
            if strcmp( o.plotType, 'line' ) &&...
                    strcmp( lineStyle, 'none' )
                o.plotType = 'marker' ;
            end
            % get the used data if it is a string
            if ischar( plotH.UserData )
                o.userData = strtrim(lower(plotH.UserData)) ;
            else
                o.userData = '';
            end
            %
            % set default decimation type
            ind = find( strcmp( o.plotType, ...
                o.preferences.plotTypes) );
            o.decimationType = o.preferences.decimationType{ ind };
            o.reductionRate = o.preferences.reductionFactor( ind );
            % test if used data defines an alternative decimation
            % function.
            %
            if ~isempty( o.userData )
                ind = find( strcmp( o.userData, ...
                    o.preferences.decimationFunction) );
                if ~isempty( ind )
                    o.decimationType = ...
                        o.preferences.decimationFunction{ ind };
                end
            end
            % Save the handels --------------------
            o.plotH = plotH;
            o.axesH = get( plotH, 'Parent' );
            o.figureH = get( o.axesH, 'Parent' );
            %
            % Collect the original data ----------------
            %
            o.xDataOriginal = plotH.XData;
            o.yDataOriginal = plotH.YData;
            o.xLimOriginal = o.axesH.XLim;
            o.yLimOriginal = o.axesH.YLim;
            %
            % Add a listner to the Xlim and YLim of the axes
            %
            addlistener(...
                o.axesH, 'XLim', 'PostSet',...
                @(~, ~) o.reCalculateData );
            % Add a listner to the reset and refresh broadcast
            addlistener(...
                figueManagerH, 'plotReset', ...
                @(~,~) o.plotResetData );
            addlistener(...
                figueManagerH, 'plotRefresh', ...
                @(~,~) o.reCalculateData );
            addlistener(...
                figueManagerH, 'plotResetLims', ...
                @(~,~) o.plotReset );
            %
            o.plotReset;
        end
        %--------------------------------------------------
        function reCalculateData( o )
            
            if o.busy
                return
            else
                o.busy = true;
            end
            % DO the real work ---------------------------
            % determine size of axes
            figureUnits = o.figureH.Units;
            if ~strcmp( figureUnits, 'centimeters' )
                set( o.figureH, 'Units', 'centimeters' );
            end
            figurePos = o.figureH.Position;
            figureWcm = figurePos(3);
            %
            axesUnits = o.axesH.Units;
            if ~strcmp( figureUnits, 'centimeters' )
                set( o.axesH, 'Units', 'normalized' );
            end
            axesPos = o.axesH.Position;
            axesW = axesPos(3);
            set( o.figureH,'Units', figureUnits );
            set( o.axesH, 'Units',  axesUnits );
            %
            axesWcm = figureWcm * axesW;
            % we now have the width in cm, this is converted to
            % number of dots required goiven the DPI desired
            %
            DPcm = o.preferences.DPI / 2.5;
            nrDots = round(axesWcm * DPcm);
            
            % find indices to points within the range of the
            % plot.
            xLim = o.axesH.XLim ;
            inds = find( (o.xDataOriginal >= xLim(1)) &...
                (o.xDataOriginal <= xLim(2)));
            
            if ( length(inds) > nrDots)
                bRecalc = true;
            else
                bRecalc = false;
                % if too few points do nothing
            end
            %---------------------------------
            %Alternative binary indexing
            
            %             inds =  (o.xDataOriginal >= xLim(1)) &...
            %                 (o.xDataOriginal <= xLim(2));
            %
            %             if ( sum(inds) > nrDots)
            %
            %                 bRecalc = true;
            %             else
            %                 bRecalc = false;
            %                 % if too few points do nothing
            %             end
            %--------------------------------------------------------------
            
            %
            switch o.decimationType
                % Deal with lines and markers
                case {'integery'}
                    if bRecalc
                        [o.xDataReduced, o.yDataReduced] = ...
                            FMdownSampleIntegerY(...
                            o.xDataOriginal(inds), o.yDataOriginal(inds),...
                            nrDots);
                    else
                        o.xDataReduced = o.xDataOriginal ;
                        o.yDataReduced = o.yDataOriginal ;
                    end
                    %-----------------------------------
                case {'minmax'}
                    if bRecalc
                        [o.xDataReduced, o.yDataReduced] = ...
                            FMdownSampleMinMax(...
                            o.xDataOriginal(inds), o.yDataOriginal(inds),...
                            nrDots);
                    else
                        o.xDataReduced = o.xDataOriginal ;
                        o.yDataReduced = o.yDataOriginal ;
                    end
                    %-----------------------------------
                case {'downsample'}
                    if bRecalc
                        [o.xDataReduced, o.yDataReduced] = ...
                            FMdownSample(...
                            o.xDataOriginal(inds), o.yDataOriginal(inds),...
                            nrDots);
                    else
                        o.xDataReduced = o.xDataOriginal ;
                        o.yDataReduced = o.yDataOriginal ;
                    end
                    %-----------------------------------
                    %
                otherwise
            end
            
            % Finished with the work  --------------------
            o.plotRedraw;
            o.busy = false;
        end
        %------------------------------------------------
        function plotRedraw( o )
            set( o.plotH, 'XData', o.xDataReduced);
            set( o.plotH, 'YData', o.yDataReduced);
        end
        %------------------------------------------------
        function plotResetData( o )
            o.xDataReduced = o.xDataOriginal ;
            o.yDataReduced = o.yDataOriginal ;
            set( o.plotH, 'XData', o.xDataReduced);
            set( o.plotH, 'YData', o.yDataReduced);
        end
        %------------------------------------------------
        function plotReset( o )
            set( o.axesH, 'YLim', o.yLimOriginal );
            set( o.axesH, 'XLim', o.xLimOriginal );
        end
    end
end