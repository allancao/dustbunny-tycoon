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

    
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%This first half concerns when the box is drawn within the xlimits of the
%axis
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    if endPoint(1,1) >= axlims(1) && endPoint(1,1) <= axlims(2)     %endpoint x is  between Axis Xmax and Xmin 
        if endPoint(1,2) >= axlims(3) && endPoint(1,2) <= axlims(4) %endpoint y is between Axis Ymax and Ymin
            % Within Y and X Limits
            YData = [min(startPoint(1,2),endPoint(1,2)) max(startPoint(1,2),endPoint(1,2))];        %puts the lower of the start and end y values first in the vector
        else
            % Within X Limits
            if endPoint(1,2) < axlims(3) %endpoint is below axis
                % y min will be bottom of axis
                YData = [axlims(3) startPoint(1,2)];
            else
                % y max will be top of axis
                YData = [startPoint(1,2) axlims(4)];
            end
        end
        XData = [min(startPoint(1,1),endPoint(1,1)) max(startPoint(1,1),endPoint(1,1))];    %we are within the X axis, so startpoint and endpoint are the x lims
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%This second half concerns when the box is not completely within the x
%limits of the axis
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++        
    else    % Outside XLims
        if endPoint(1,2) >= axlims(3) && endPoint(1,2) <= axlims(4)
            % Within Y Limits
            if endPoint(1,1) < axlims(1)
                % x min will be left edge of axis
                XData = [axlims(1) startPoint(1,1)];
            else
                % x max will be right edge of axis
                XData = [startPoint(1,1) axlims(2)];
            end
        YData = [min(startPoint(1,2),endPoint(1,2)) max(startPoint(1,2),endPoint(1,2))];
        else
            % Outside Y Limits
            if endPoint(1,2) < axlims(3)
                if endPoint(1,1) < axlims(1) %endpoint is below the axis
                    % xmin and ymin are edges of axis
                    XData = [axlims(1) startPoint(1,1)];
                    YData = [axlims(3) startPoint(1,2)];
                else
                    % xmax and ymin are edges of axis
                    XData = [startPoint(1,1) axlims(2)];
                    YData = [axlims(3) startPoint(1,2)];
                end
            else    %endpoint is above the axis
                    % xmin and ymax are edges of axis
                if endPoint(1,1) < axlims(1)
                    XData = [axlims(1) startPoint(1,1)];
                    YData = [startPoint(1,2) axlims(4)];
                else
                    % xmax and ymax are edges of the axis
                    XData = [startPoint(1,1) axlims(2)];
                    YData = [startPoint(1,2) axlims(4)];
                end
            end
            % End YLims
        end
        % End XLims
    end
    
    XYLims = [XData(1) XData(2) YData(1) YData(2)];   %This is the output of the function and will be used to set the new axis limits if the button is released
    
    XData = [XData(1) XData(1) XData(2) XData(2)];
    YData = [YData(1) YData(2) YData(2) YData(1)];
    
    set(patchHandle,'XData',XData,'YData',YData); drawnow