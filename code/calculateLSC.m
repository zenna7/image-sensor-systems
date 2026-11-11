function lsc = calculateLSC(illuminant)   
    % STUDENT: DO NOT REMOVE
    addpath(fullfile(pwd, 'Measurement data', 'Illuminant spectral distribution'));
    addpath(fullfile(pwd, 'Measurement data','Camera spectral response'));
    %

    %% Define defect pixel correction and black level correction here
    %{
        Defect pixel correction identifies abnormal sensor pixels and replaces
        their values using nearby pixels, reducing isolated bright or dark spots.
        Black level correction subtracts the sensor's black offset so that
        pixels recorded with no light are represented closer to zero.
    %}

    % TO DO: Implement your code here

    %% 2.Select correct SPD based on the input parameter illuminant 
    switch illuminant
        case "D65"
            measure_SPD = readtable("CIE_D65_1000lux.json");
        case "A"
            measure_SPD = readtable("CIE_A_100lux.json");
        case "F11"
            measure_SPD = readtable("CIE_LED4000K_500lux.json");
    end

    %% 3.Sample every 10nm and convert in matrix
    SPD = measure_SPD.Live(1:10:end, :);


    %% 4.Read spatial spectral response
    SSR = readmatrix("spatial_spectral_response.xlsx");


    %% 5.Empty LSC vector per color channel
    LSC_R = [];
    LSC_Gr = [];
    LSC_Gb = [];
    LSC_B = [];
    x = [];


    %% 6-7.Local area response for each spatial response subarea 
    for k = 1:4
        for i = 1:13
            for j = 1:17
                idx = 1 + k + (j-1)*4 + (i-1)*4*17;
                R = sum(SPD(1:41,2)) * sum(SSR(1:41,idx)) * 10;
                
                switch k
                    case 1, LSC_R(end+1) = R;
                    case 2, LSC_Gr(end+1) = R;
                    case 3, LSC_Gb(end+1) = R;
                    case 4, LSC_B(end+1) = R; x(end+1) = numel(x)+1;
                end
            end
        end
    end
    

    %% 8.Gains for each color channel per spatial spectral response subarea
    R_gains = LSC_R(111) ./ LSC_R;
    Gr_gains = LSC_Gr(111) ./ LSC_Gr;
    Gb_gains = LSC_Gb(111) ./ LSC_Gb;
    B_gains = LSC_B(111) ./ LSC_B;


    %% 9-10.Create a 3D matrix with the subarea gains and reshape to 13x17x4
    mat = zeros(13, 17, 4);
    mat(:, :, 1) = reshape(R_gains, 17, 13)';
    mat(:, :, 2) = reshape(Gr_gains, 17, 13)';
    mat(:, :, 3) = reshape(Gb_gains, 17, 13)';
    mat(:, :, 4) = reshape(B_gains, 17, 13)';

    % The operations needed
    %{ 
        The operations needed to rightly arrange the elements in the matrix 
        are reshape and permute: 
        - Reshape fills the matrix column by column, so it turns each 1x221 
          gain vector into a 17x13 grid in the same order the values were 
          computed.
        - Permute then is needed to get the required 13x17 orientation 
          without modifying the values; in this case, since we are
          working on a 2D matrix, the permute operation is equal to a 
          transpose operation.        
        This double process is needed since reshaping directly to
        13x17 would place the values in the wrong order.
     %}


    %% 11.Save to the lsc variable
    % Always make the function return a matrix, at least an empty one!

    % If the function returns an empty matrix, the simulator will use 
    % pre-determined LSC instead
    lsc = mat;


    %% 12. Comparison
    % Run the simulator for each illuminant with both the lens shading
    % correction turned on and turned off
    %{
        Generally, for all three illuminants, the image without lens 
        shading correction darkens around the edges of the images, with a 
        radial shape. This attenuation of brightness intensity can 
        perceptually appear more or less noticeable depending on the 
        condition: the image exposed at 100 lux (CIE_A) appears darker on 
        the edges than the 1000 lux image (CIE_D65), while the image at 500
        lux (CIE_LED4000K) sets in between the two. This is only a 
        perceptual difference, caused probably by the different SNR between
        the images.
        Applying lens shading correction remove the vignetting effect we 
        were observing. After this process, none of the images shows darker
        areas along the edges. The only noticeable difference at this point 
        is the different white tint, caused by the different illuminant
        conditions. 
        Lens shading correction operates on different channels to correct 
        the different per-channel falloff. In our testing on the dots chart
        image, no color cast was visible along the edges even without LSC, 
        so we cannot report a difference in this aspect before and after 
        applying the algorithm.
    %}
    
end

