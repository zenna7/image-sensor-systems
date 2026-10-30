function wb_gains = calculateWhiteBalance(wb_input)

    % TO DO: Implement your code here
    % Always make the function return a vector, at least an empty one!

    % If the function returns an empty vector, the simulator will use 
    % pre-determined WB gains instead
    
    

    %% 2 Extracting pixel values per area
    
    % Brute force approach to find the squares coordinates
    %{
    imshow(rescale(wb_input));
    hold on
    rectangle('Position', [1815 1873 185 185], 'EdgeColor', 'r', 'LineWidth', 2)
    rectangle('Position', [2095 1873 185 185], 'EdgeColor', 'r', 'LineWidth', 2)
    hold off
    drawnow
    %}


    % Starting coordinates and size of the two squares
    x0_21   = 1815;         
    x0_22   = 2095;
    y0      = 1873;
    sz    = 185;


    % Square 21
    R_21 = []; G_21 = []; B_21 = [];

    for i = 0:sz-1
        for j = 0:sz-1
            v = wb_input(y0+i, x0_21+j);
            if mod(i,2) == 0 && mod(j,2) == 1
                B_21(end+1) = v;
            elseif mod(i,2) == 1 && mod(j,2) == 0
                R_21(end+1) = v;
            else
                G_21(end+1) = v;
            end
        end
    end


    % Square 22
    R_22 = []; G_22 = []; B_22 = [];

   for i = 0:sz-1
        for j = 0:sz-1
            v = wb_input(y0+i, x0_22+j);
            if mod(i,2) == 0 && mod(j,2) == 1
                B_22(end+1) = v;
            elseif mod(i,2) == 1 && mod(j,2) == 0
                R_22(end+1) = v;
            else
                G_22(end+1) = v;
            end
        end
    end
        

    %% 3 Compute the average per color channel
    % Square 21
    R_avg_21 = mean(double(R_21));
    G_avg_21 = mean(double(G_21));
    B_avg_21 = mean(double(B_21));

    % Square 22
    R_avg_22 = mean(double(R_22));
    G_avg_22 = mean(double(G_22));
    B_avg_22 = mean(double(B_22));

    

    %% 4 Computing the gain per square 
    % Square 21
    gain_R_21 = G_avg_21 / R_avg_21;
    gain_G_21 = 1;
    gain_B_21 = G_avg_21 / B_avg_21;

    % Square 22
    gain_R_22 = G_avg_22 / R_avg_22;
    gain_G_22 = 1;
    gain_B_22 = G_avg_22 / B_avg_22;



    %% 5 Average the squares 
    
    gain_R = (gain_R_21+gain_R_22)/2;
    gain_G = 1;
    gain_B = (gain_B_21+gain_B_22)/2;
    
    
    %% 6 Return the gain 
    wb_gains = [gain_R, gain_G, gain_B];

end

