% drawBox
% Used to draw the red dashed box for the zoom In function
% This is the WindowButtonMotionFcn of the figure
%
% Pass the following parameters:
%   patchHandle : guiel.dragBox
%   startPoint : vars.CurrentPoint
%   axlims : vars.axlims - ([Xmin Xmax Ymin Ymax]) {current axes limits}
%   endPoint : get(guiel.hAX(1),'CurrentPoint');

function XYLims = drawBox(patchHandle,startPoint,axlims,endPoint)
    % Xvalue

    if endPoint(1,1) >= axlims(1) && endPoint(1,1) <= axlims(2)
        if endPoint(1,2) >= axlims(3) && endPoint(1,2) <= axlims(4)
            % Within Y and X Limits
            YData = [min(startPoint(1,2),endPoint(1,2)) max(startPoint(1,2),endPoint(1,2))];
        else
            % Within X Limits
            if endPoint(1,2) < axlims(3)
                % y-
                YData = [axlims(3) startPoint(1,2)];
            else
                % y+
                YData = [startPoint(1,2) axlims(4)];
            end
        end
        XData = [min(startPoint(1,1),endPoint(1,1)) max(startPoint(1,1),endPoint(1,1))];
    else    % Outside XLims
        if endPoint(1,2) >= axlims(3) && endPoint(1,2) <= axlims(4)
            % Within Y Limits
            if endPoint(1,1) < axlims(1)
                % x-
                XData = [axlims(1) startPoint(1,1)];
            else
                % x+
                XData = [startPoint(1,1) axlims(2)];
            end
        YData = [min(startPoint(1,2),endPoint(1,2)) max(startPoint(1,2),endPoint(1,2))];
        else
            % Outside Limits
            if endPoint(1,2) < axlims(3)
                if endPoint(1,1) < axlims(1)
                    % x- y-
                    XData = [axlims(1) startPoint(1,1)];
                    YData = [axlims(3) startPoint(1,2)];
                else
                    % x+ y-
                    XData = [startPoint(1,1) axlims(2)];
                    YData = [axlims(3) startPoint(1,2)];
                end
            else
                    % x- y+
                if endPoint(1,1) < axlims(1)
                    XData = [axlims(1) startPoint(1,1)];
                    YData = [startPoint(1,2) axlims(4)];
                else
                    % x+ y+
                    XData = [startPoint(1,1) axlims(2)];
                    YData = [startPoint(1,2) axlims(4)];
                end
            end
            % End YLims
        end
        % End XLims
    end
    
    XYLims = [XData(1) XData(2) YData(1) YData(2)];
    
    XData = [XData(1) XData(1) XData(2) XData(2)];
    YData = [YData(1) YData(2) YData(2) YData(1)];
    
    set(patchHandle,'XData',XData,'YData',YData); drawnow
