function handGestureDataset()
% function of handGestureDataset()
%   A GUI based framework for extract hand depth Image
%

    % initialize the kinect setting
    depthVid = videoinput('kinect', 2);
    triggerconfig(depthVid, 'manual');
    depthVid.FramesPerTrigger = 1;
    depthVid.TriggerRepeat = inf;
    set(getselectedsource(depthVid), 'TrackingMode', 'Skeleton');
    alphabet=char(65:90);
    
    % timer handler for continuous operation
    t = timer('TimerFcn', @dispDepth, 'Period', 0.05, ...
        'executionMode', 'fixedRate');
    window=figure('Color',[0.9255 0.9137 0.8471],'Name','Depth Camera',...
                  'DockControl','off','Units','Pixels',...
                  'toolbar','none',...
                  'Position',[50 50 800 600]);
             
    startb=uicontrol('Parent',window,'Style','pushbutton','String',...
                        'START',...
                        'FontSize',11 ,...
                        'Units','normalized',...
                        'Position',[0.22 0.02 0.16 0.08],...
                        'Callback',@startCallback);
    %create stop button which calls the stopbCallback fctn
    stopb=uicontrol('Parent',window,'Style','pushbutton','String',...
                        'STOP',...
                        'FontSize',11 ,...
                        'Units','normalized',...
                        'Position',[0.5 0.02 0.16 0.08],...
                        'Callback',@stopCallback);
    i = 0;
    m=100;
    % main function for displaying depth
    function dispDepth(obj, event)
       % generate depth frame and rescale it in 0~4096
       trigger(depthVid);
       [depthMap, ~, depthMetaData] = getdata(depthVid);
       idx = find(depthMetaData.IsSkeletonTracked);
       subplot(2,2,1);
       imshow(depthMap, [0 4096]);
       
       if idx ~= 0
           % Extract right hand position
           rightHand = depthMetaData.JointDepthIndices(12,:,idx);
           
           % Extract right hand realword position
           zCoord = 1e3*min(depthMetaData.JointWorldCoordinates(12,:,idx));
           
           radius = round(90 - zCoord / 50);
           rightHandBox = [rightHand-0.5*radius 1.2*radius 1.2*radius];

           % Define the region of interests (ROI) in right hand and segmented it
           rectangle('position', rightHandBox, 'EdgeColor', [1 1 0]);
           handDepthImage = imcrop(depthMap,rightHandBox);
           subplot(2,2,3);
           imshow(handDepthImage, [0 4096]);
           
           if ~isempty(handDepthImage)
               
               % preprocessing for background segmentation
               imageSize = size(handDepthImage);
               for k = 1:imageSize(1)
                   for j = 1:imageSize(2)
                       if handDepthImage(k, j) > 2300
                           handDepthImage(k, j) = 0;
                       end
                   end
               end
                
               % Generate the Dataset of hand depth Image
               i = i+1; 
               if (mod(i,5)==1)
                  imwrite(handDepthImage, strcat('backup/X/X','_',num2str(m),'.png'),'png');
                  m=m+1;
               end
           end
       end
    end

    % Callback handler for windows
    function startCallback(obj, event)
       start(depthVid);
       start(t);
    end

    function stopCallback(obj, event)
       stop(t);
       stop(depthVid);
    end
end

