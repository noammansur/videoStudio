function [ OutputFrame ] = addBoundaryToFrame(I, S, W)
    % add boundary box to frame                    
    OutputFrame = I; 
    
    %getting the maximal particle filter
    [~, Index] = max(W);
    maximal_filter = S(:,Index);
    half_width = maximal_filter(3);
    half_height = maximal_filter(4);

    x_first_coor = maximal_filter(1) - half_width;
    y_first_coor = maximal_filter(2) - half_height;

    maximal_rect = [x_first_coor y_first_coor half_width*2 half_height*2];
    OutputFrame = insertShape(OutputFrame,...
                              'rectangle', maximal_rect,...
                              'LineWidth', 2, 'color', 'red');

    %getting the average particle filter
    average_filter = mean(S, 2);

    x_first_coor = average_filter(1) - half_width;
    y_first_coor = average_filter(2) - half_height;

    average_rect = [x_first_coor y_first_coor half_width*2 half_height*2];
   
    OutputFrame = insertShape(OutputFrame,...
                          'rectangle', average_rect,...
                          'LineWidth', 2, 'color', 'green');
end

