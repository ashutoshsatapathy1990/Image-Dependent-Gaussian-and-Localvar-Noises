%....................................................................
% // Calculate Mean and Variance of An Input Image [M x N].         |
% // Compute Local Variance of Size [M x N]  from The above Image.  |
% // Use Mean and Variance to Introduce Gaussian Noise.             |
% // Use Local Variance to Introduce Localvar Noise in The Image.   |
%...................................................................|

%// Read an Image from The Given Path
img = imread('input/img.bmp');

% // Extract Red, Green and Blue Channels of Input 
Rframe = img(:, :, 1);
Gframe = img(:, :, 2);
Bframe = img(:, :, 3);
Rframe = double(Rframe);
Gframe = double(Gframe);
Bframe = double(Bframe);

% // Normalized Intensities of Each Channel [0, 1]
Rframe = Rframe - min(Rframe(:));
Rframe = Rframe / max(Rframe(:));
Gframe = Gframe - min(Gframe(:));
Gframe = Gframe / max(Gframe(:));
Bframe = Bframe - min(Bframe(:));
Bframe = Bframe / max(Bframe(:));

% // Compute Mean and Variance of 3 Channels [Red, Green, Blue]
mean_R = 0.2 * mean(Rframe(:));
mean_G = 0.2 * mean(Gframe(:));
mean_B = 0.2 * mean(Bframe(:));
var_R = 0.2 * var(Rframe(:));
var_G = 0.2 * var(Gframe(:));
var_B = 0.2 * var(Bframe(:));

% // Specify Kernel Size for Local Variance Calculation
K = 5;
Half_K = floor(K/2);

% // Prepare The Input Matrices with Zero Padding
Pad_Rframe = padarray(Rframe, [Half_K Half_K]);
Pad_Gframe = padarray(Gframe, [Half_K Half_K]);
Pad_Bframe = padarray(Bframe, [Half_K Half_K]);

% // Initialize Output matrices to Store Local Variance of Each Channel.
LocalvarR = zeros(size(Rframe));
LocalvarG = zeros(size(Gframe));
LocalvarB = zeros(size(Bframe));

% // Evaluate Local Variance E[X^2]-(E[X])^2
for m  =  1 : size(Pad_Rframe, 1) - 2 * Half_K
    for n =  1 : size(Pad_Rframe, 2) - 2 * Half_K
        TargetR = Pad_Rframe(m : m - 1 + K, n : n - 1 + K);
        TargetG = Pad_Gframe(m : m - 1 + K, n : n - 1 + K);
        TargetB = Pad_Bframe(m : m - 1 + K, n : n - 1 + K);
        
        % // Mean and Variance Computation for Each Patches
        LocalvarR(m, n) = mean(TargetR(:).^2) - (mean(TargetR(:))).^2;
        LocalvarG(m, n) = mean(TargetG(:).^2) - (mean(TargetG(:))).^2;
        LocalvarB(m, n) = mean(TargetB(:).^2) - (mean(TargetB(:))).^2;
    end
end

% // Add Gaussian Noise with [mean_R, meanG, meanB] and [var_R, var_G, var_B]
R_GNoisy = imnoise(Rframe, 'gaussian', mean_R, var_R);
G_GNoisy = imnoise(Gframe, 'gaussian', mean_G, var_G);
B_GNoisy = imnoise(Bframe, 'gaussian', mean_B, var_B);

% // Add localvar Noise with [LocalvarR, LocalvarG, LocalvarB]
R_LNoisy = imnoise(Rframe, 'localvar', abs(LocalvarR));
G_LNoisy = imnoise(Gframe, 'localvar', abs(LocalvarG));
B_LNoisy = imnoise(Bframe, 'localvar', abs(LocalvarB));

% // Construct Noisy Images from Three Noisy Channels
Img_GNoisy = cat(3, R_GNoisy, G_GNoisy, B_GNoisy);
Img_LNoisy = cat(3, R_LNoisy, G_LNoisy, B_LNoisy);

% // Display Images
figure
subplot(1, 3, 1), imshow(img), title('Original image')
subplot(1, 3, 2), imshow(Img_GNoisy), title('Noisy image, Noise = Gaussian')
subplot(1, 3, 3), imshow(Img_LNoisy), title('Noisy image, Noise = Localvar')

% // Save Images to .bmp Files
imwrite(Img_GNoisy, 'output/Noise_Gaus.bmp');
imwrite(Img_LNoisy, 'output/Noise_Lvar.bmp');
