function E = cannyEdge(I)
% CIS 581 Project 1 - Written by Zimeng YANG
% CANNYEDGE - Do edge detection given image I.

% If the input I is RGB image, then convert I to grayscale
if numel(I(1,1,:)) == 3
    Ig = rgb2gray(I);
else
    Ig = I;
end
Ig = double (Ig);

%% Extrapolate the image by reflecting across the edges
% Set the width to do reflection 
boarder = 40;

[m,n] = size(Ig);
Ig_big = zeros(m + 2 * boarder, n + 2 * boarder);
Ig_big(boarder+1:boarder+m, boarder+1:boarder+n) = Ig;
% Extrapolate for the left corner
for i = 1:boarder
    for j = 1:boarder
        Ig_big(i, j) = Ig(boarder-i+1, boarder-j+1);
    end
end
% Extrapolate for the right corner
for i = 1:boarder
    for j = n+boarder+1:n+2*boarder
        Ig_big(i, j) = Ig(boarder-i+1, 2*n+boarder-j+1);
    end
end
% Extrapolate for the bottom left corner
for i = m+boarder+1:m+2*boarder
    for j = 1:boarder
        Ig_big(i, j) = Ig(2*m+boarder-i+1, boarder-j+1);
    end
end
% Extrapolate for the bottom right corner
for i = m+boarder+1:m+2*boarder
    for j = n+boarder+1:n+2*boarder
        Ig_big(i, j) = Ig(2*m+boarder-i+1, 2*n+boarder-j+1);
    end
end
% Extrapolate for the upper part
for i = 1 : boarder
        Ig_big(i, boarder+1:boarder+n) = Ig(boarder-i+1, 1:n);
end
% Extrapolate for the bottom part
for i = m+boarder+1 : m+2*boarder
        Ig_big(i, boarder+1:boarder+n) = Ig(2*m+boarder-i+1, 1:n);
end
% Extrapolate for the left part
for j = 1 : boarder
        Ig_big(boarder+1:boarder+m, j) = Ig(1:m, boarder-j+1);
end
% Extrapolate for the right side
for j = boarder+n+1 : n+2*boarder
        Ig_big(boarder+1:boarder+m, j) = Ig(1:m, 2*n+boarder-j+1);
end

%% Filter the image and compute the gradient magnitude and direction
[M,N] = size(Ig_big);
% Design a Gaussian kernel
G =  fspecial('gaussian',[10 10],2);
% Compute the smoothed derivative filter
[dx,dy] = gradient(G); 

Ix = conv2(Ig_big, dx, 'same');
Iy = conv2(Ig_big, dy, 'same');
% Compute gradient magnitude and direction
Im = sqrt(Ix.*Ix + Iy.*Iy);
theta = atand(Iy./Ix);

%% Non-maximum suppression
% Define a vector to store the result of non-maximum suppression
local_max = zeros(M, N);   

 for i = 2:M-1
     for j = 2:N-1
         % For each pixel, interpolate to compute the gradient magnitute of
         % its previous and next pixels along the direction of gradient
         if (theta(i,j)>=-45) && (theta(i,j)<0)  
             Im_before = Im(i-1, j+1) * tand(-theta(i,j)) + Im(i, j+1) * (1 - tand(-theta(i,j)));
             Im_next = Im(i+1, j-1) * tand(-theta(i,j)) + Im(i, j-1) * (1 - tand(-theta(i,j)));
         
         elseif (theta(i,j)>=-90) && (theta(i,j)<-45)    
             Im_before = Im(i-1, j+1) * tand(90+theta(i,j)) + Im(i-1, j) * (1 - tand(90+theta(i,j)));
             Im_next = Im(i+1, j-1) * tand(90+theta(i,j)) + Im(i+1, j) * (1 - tand(90+theta(i,j)));
         
         elseif (theta(i,j)>=0) && (theta(i,j)<45)
             Im_before = Im(i+1, j+1) * tand(theta(i,j)) + Im(i, j+1) * (1 - tand(theta(i,j)));
             Im_next = Im(i-1, j-1) * tand(theta(i,j)) + Im(i, j-1) * (1 - tand(theta(i,j)));
        
         elseif (theta(i,j)>=45) && (theta(i,j)<90)
             Im_before = Im(i-1, j-1) * tand(90-theta(i,j)) + Im(i-1, j) * (1 - tand(90-theta(i,j)));
             Im_next = Im(i+1, j+1) * tand(90-theta(i,j)) + Im(i+1, j) * (1 - tand(90-theta(i,j)));
         end 
         % If the pixel's gradient magnitude is larger than its previous
         % and next ones, the pixel is a local maximum
         if (Im_before < Im(i,j)) && (Im_next < Im(i,j))   
             local_max(i,j) = Im(i,j);
         end
     end
 end
 
%% Deciding the thresholds for edge linking
% Using Histogram of the local maximum map to decide the higher threshold

% First, count the number of pixels corresponding to different gradient magnitude
% Second, count how many edge pixels there are
ratio = 0.55;
hist = zeros(1,1000);
edge_sum = 0;
for i = 1:M
    for j = 1:N
        if local_max(i,j)>0
            % Here, multiply the gradient magnitude by 10 is just to
            % count in one decimal to make the threshold more precise
            hist(round(local_max(i,j)*10)+1) = hist(round(local_max(i,j)*10)+1) + 1;
            edge_sum = edge_sum+1;
        end
    end
end
% Third, choose the threshold of the gradient magnitude so that the 
% pixels having smaller gradient magnitude count up to a ratio of the number 
% of all edge pixels 
edge_thre = edge_sum * ratio;
edge_thre_sum = 0;
i = 0;
while edge_thre_sum < edge_thre
    i = i + 1;
    edge_thre_sum = edge_thre_sum + hist(i);
end
% The gradient magnitude was multipied by 10, so here when finding
% the threshold, it should be divided by 10
thre_high = i/10;

% There is a different condition, when the input is not a natural image and
% the image's histogram has some sudden changes and the gradient magnitude 
% tend to gather around some specific values. If using this method we will 
% miss some important details. So in this case, we choose the high
% threshold to be the location of the first sharp peak in the histogram
for j=1:1000
    if (hist(j)>100) && (j<thre_high*10) && (hist(j+1)<50)
        thre_high = j/10;
        break;
    end
end

% Choosing the lower threshold to be a proportion of the higher one
thre_low = 0.4 * thre_high;

%% Linking the edges
% Define a vector to store the edges
edg = zeros(M, N); 
% visit_map is used to decide whether the pixel has been visited
visit_map = zeros(M, N);
% For each local maximum pixels, if it has not been visited and
% its gradient magnitude is larger than the higher threshold, starting
% linking from this pixel
for i = 2:M-1
    for j =2:N-1
        if (visit_map(i,j) == 0) && (local_max(i,j) > thre_high)
            [edg, visit_map] = linkEdge(edg, local_max, theta, i, j, visit_map, thre_low) ;
        end
    end
end

%% Cut the image to its original size
edge_canny = edg(boarder+1:m+boarder, boarder+1:boarder+n);
E = logical(edge_canny);
