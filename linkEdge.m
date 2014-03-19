 function [edge2, visit_map2] = linkEdge(edg, local_max, theta, i, j, visit_map, thre_low)
% CIS 581 Project 1 - Written by Zimeng YANG
% LINKEDGE - Search the pixels in the edge direction and link edges

% visit_map is used to show whether the pixels have been visited

% Initialization
 edge2 = edg;
 visit_map2 = visit_map;
 visit_map2(i, j) = 1;
 
 % Search the pixels along the edge direction. If their gradient magnitudes
 % are larger than the lower threshold, the pixels are the edge, and make
 % those pixels as the new centers, start linking again. When there are no
 % nearby pixels that meet the requists, stop linking
 if (theta(i,j)>=0) && (theta(i,j)<45)
     % For each pixel, search in two opposite directions along the edge
     % direction
     for idx = j:j+1
         if (local_max(i-1,idx)>thre_low) && (visit_map2(i-1,idx) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, i-1, idx, visit_map2, thre_low);
        end
     end
     for idx = j-1:j
        if (local_max(i+1,idx)>thre_low) && (visit_map(i+1,idx) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, i+1, idx, visit_map2, thre_low);
        end
     end
     
 elseif (theta(i,j)>=45) && (theta(i,j)<90)
      for idx = i-1:i
         if (local_max(idx,j+1)>thre_low) && (visit_map(idx,j+1) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, idx, j+1, visit_map2, thre_low);
        end
     end
     for idx = i:i+1
        if (local_max(idx,j-1)>thre_low) && (visit_map(idx,j-1) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, idx, j-1, visit_map2, thre_low);
        end
     end    
     
 elseif (theta(i,j)>=-45) && (theta(i,j)<0)
      for idx = j:j+1
         if (local_max(i+1,idx)>thre_low) && (visit_map(i+1,idx) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, i+1, idx, visit_map2, thre_low);
        end
     end
     for idx = j-1:j
        if (local_max(i-1,idx)>thre_low) && (visit_map(i-1,idx) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, i-1, idx, visit_map2, thre_low);
        end
     end
 else
     for idx = i-1:i
         if (local_max(idx,j-1)>thre_low) && (visit_map(idx,j-1) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, idx, j-1, visit_map2, thre_low);
        end
     end
     for idx = i:i+1
        if (local_max(idx,j+1)>thre_low) && (visit_map(idx,j+1) == 0)
            edge2(i,j) = 1;
            [edge2, visit_map2] = linkEdge(edge2, local_max, theta, idx, j+1, visit_map2, thre_low);
        end
     end       
 end
 
     
 
