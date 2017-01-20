%% This is visual motion perception CAPTCHA code 
% We have everything done, the only issue that remains is that the
% trajectory dot is hard to see. As of right now we have it going straight
% downwards hard coded so that you can spot it more easily when testing. 

% First we define our variables and adjust the settings of the image
clear
clc
close all


numDots = 500; %Number of dots, should be able to change freely
matrixSize = 400; %Width and height of the matrix we image
numFrames = 400; %Number of frames, should also be flexible and independent
dotSpeed = 3; %How quickly the dots move 
radius = matrixSize/2; %We will use this for the aperture and target dot 

f1 = figure;
flexScreen = get(0,'ScreenSize'); %Get the size of the screen from root 
set(f1, 'position',flexScreen); %Set figure to the size of the screeen
set(f1,'color',[1 1 1]) %make the background white

%% Make the intial dots 

temp = int16(ceil(rand(numDots,2).*matrixSize)); %These are the initial 
                            %starting positions of the dots, in x and y.

%% Create all frames "movement" and take care of wrap around 

motMat = (int8(randi(3,[numDots,2,numFrames]))-2); %Future motion of all d
                                        %dots, creates 500x2 "movement" 
                                        %values for all 500 frames. 
allFrames = uint8(zeros(matrixSize,matrixSize,3,numFrames)); %This is the 
                                    %empty shell that will contain all of
                                    %the frames with the aperture and dot
                                    %movement

 %Idea: Update the dot position for a given frame, then put it in the
 %matrix. Rinse, repeat   
for ff = 1:numFrames %Make the frames
  
    temp = temp + int16(motMat(:,:,ff)); %Update the position of all dots
    
    findoutliers = find(temp < 1);
    temp(findoutliers) = 1; %Make them 1. Can't have 0 indices in Matlab.
    
    %***** WRAP AROUND *****
    %What needs to happen here is the wrap-around. Otherwise you will get
    %errors. Check 4 things: x too large, y too large, x too small, y too
    %small 
    %x too large?
    temp2 = find(temp(:,1) > matrixSize);
    temp(temp2,1) = 1;
    %x too small?
    temp2 = find(temp(:,1) < 1);
    temp(temp2,1) = matrixSize;
    %y too large?
    temp2 = find(temp(:,2) > matrixSize);
    temp(temp2,2) = 1;
    %y too small?
    temp2 = find(temp(:,2) < 1);
    temp(temp2,2) = matrixSize;
    
    %Update a given frame
    for ii = 1:numFrames
        allFrames(temp(ii,1),temp(ii,2),:,ff) = 255; %Make them white
    end
    
end



%% Add the aperture 

    %Add the apperture to all frames 
for ff = 1:numFrames
    for jj= 1:matrixSize % Check the matrix vertically
    for kk = 1:matrixSize % Check the matrix horizontally 
        xc = -radius + jj-1; %Establish x radius
        yc = -radius + kk-1; %Establich y radius 
        if sqrt(xc^2+yc^2) > radius %Check if within radius 
          allFrames(jj,kk,:,ff) = 255; %If not, make it white.
        end
    end
    end
end 
    
  
    
%% Add the trajectory dot 

directionx = (int8(randi(3))-2); %Chooses random x movement 
directiony = (int8(randi(3))-2); %Chooses random y movement 
if directionx && directiony == 0
    directiony = 1; 
end %This ensures that direction x and y will not both equal 0. 
dotx = radius; % Dot starts at the radius, make this initial x point
doty = radius; % Dot starts at the radius, make this initial y point

for ff = 1:numFrames
         dotx = dotx + 1; % Start dot in middle, increase by 
                                   %random direction on at a time
         doty = doty + 0; % Start dot in middle, increase by 
                                   %random direction on at a time
      
         if dotx > matrixSize %check if dotx gets too big
             dotx = matrixSize; %hold at end of matrix
         end 
         if dotx < 1 %Check if dotx gets too small 
             dotx = 1; %Hold at end of matrix
         end
         if doty > matrixSize %check if doty gets too big
             doty = matrixSize; %hold at end of matrix
         end
         if doty < 1 %Check if doty gets too small 
             doty = 1;%Hold at end of matrix
         end
         
         allFrames(dotx,doty,:,ff) = 255;%Update the frame with the 
                                   %trajectory dot 
end
       

%% Show all frames 

for ff = 1:numFrames %Display all the frames
image(allFrames(:,:,:,ff))  
axis square
axis off
pause(1/60); %Pause at framerate
end

%% Get input from user 

[y, x] = ginput(1);
x = ceil(x); %Make it an int from a float
y = ceil(y); %Make it an int from a float 

%% Test that x,y match where the dot left the circle 
% 
xlow = dotx - 10; %Lower boundary of x 
xhigh = dotx + 10; %Upper boudary of x
ylow = dotx - 10; %Lower boudary of y 
yhigh = doty + 10; %Upper boudary of y

if (x > xlow && x < xhigh)
    if (y > ylow) && (y < yhigh) %Check if input is within boundaries 
        %This is where in a GUI there would be a next step
    end 
end

    




