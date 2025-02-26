clear all

% Prompt the user to select a TIFF image file for analysis
[file, path] = uigetfile({'*.tif';'*.tiff';}, 'Select a File', 'MultiSelect', 'off');
if isequal(file, 0)
    disp('User selected Cancel');
else
    disp(['User selected ', fullfile(path, file)]);
end

% Construct the full file path
img_path = fullfile(path, file);
img_info = imfinfo(img_path);  % Get metadata about the image file
max_num_images = numel(img_info);  % Get the number of images (slices) in the stack

% Control flags and parameters
connectivity = 4;  % Connectivity for component labeling (4 or 8)
minimum_qualifying_component_size_px = 0;  % Minimum size of features to include (0 to accept all features)
slice_start = 1;  % First slice to process
slice_end = 110;  % Last slice to process
dist_step = 1;  % Step size in nm for distance transform

% Initialize the image dimensions and other parameters
first_slice = imread(img_path, 1);  % Read the first slice of the image
img_width = size(first_slice, 2);  % Width of the image (in pixels)
img_height = size(first_slice, 1);  % Height of the image (in pixels)
num_materials = 1;  % Number of materials in the MIB model (set to match your TIFF model)
slices = slice_start:slice_end;  % List of slices to process
num_slices = length(slices);  % Number of slices to process

bm_material = 1;  % Index for basement membrane material in the image
pixel_nm_scale = 6;  % Scale factor to convert pixels to nanometers
max_thicknesses = zeros(num_slices, 1);  % Array to store max thicknesses for each slice
mean_thicknesses = zeros(num_slices, 1);  % Array to store mean thicknesses for each slice
raw_thicknesses = cell(num_slices, 1);  % Cell array to store raw thickness values for each slice

% Start timing the processing
tic

% Loop through the slices to process each one
for i = slices
    index = i - slice_start + 1;  % Adjust the index for the slice range
    this = imread(img_path, i);  % Load the current slice from the TIFF file
    slice_binary_img = false(img_height, img_width);  % Initialize a binary image for basement membrane
    
    % Create a binary image where the basement membrane is represented as 'true'
    for y = 1:img_height
        for x = 1:img_width
            value = this(y, x);
            if(value == bm_material)
                slice_binary_img(y, x) = true;
            end
        end
    end
    
    % Invert the binary image and compute the Euclidean distance transform
    slice_binary_img = ~slice_binary_img;
    dist_transform_img = bwdist(slice_binary_img, "euclidean");  % Distance transform image
    skeleton_img = bwmorph(~slice_binary_img, "thin", Inf);  % Thin the binary image to create a skeleton
    
    ls = [];  % List to store the thickness values for this slice
    
    % Initialize the result image for thicknesses
    Result = zeros(img_height, img_width); 
    
    % Extract the thickness values along the skeleton and store them
    for y = 1:img_height
        for x = 1:img_width
            value = skeleton_img(y, x);
            if(value > 0)
                Result(y, x) = dist_transform_img(y, x);  % Store distance in pixels
                ls(end+1) = dist_transform_img(y, x) * pixel_nm_scale;  % Store thickness in nm
            end
        end
    end
    
    % If no thickness values were found, set them as NaN
    if isempty(ls)
        raw_thicknesses{index} = NaN;
        mean_thicknesses(index) = NaN;
        max_thicknesses(index) = NaN;
    else
        % Otherwise, store the raw, mean, and max thickness values for this slice
        raw_thicknesses{index} = sort(ls);
        mean_thicknesses(index) = mean(ls);
        max_thicknesses(index) = max(ls);
    end
    
    % Display visualizations for the skeleton, distance transform, and thickness result
    figure
    imagesc(skeleton_img * pixel_nm_scale);
    shading flat;
    set(gca, 'ydir', 'reverse');
    colormap('hot');
    colorbar;
    
    figure
    imagesc(dist_transform_img * pixel_nm_scale);
    shading flat;
    set(gca, 'ydir', 'reverse');
    colormap('hot');
    colorbar;
    
    figure
    imagesc(Result * pixel_nm_scale);
    shading flat;
    set(gca, 'ydir', 'reverse');
    colormap('hot');
    colorbar;
    
    toc  % End timing for this slice
end

% Plot the mean thicknesses across all slices
figure
plot(slices, mean_thicknesses);

% Plot the thickness distribution for the last slice processed
figure
plot(1:length(ls), ls);

% Example of the thickness distribution for the first slice
figure
plot(1:length(raw_thicknesses{1, 1}), raw_thicknesses{1, 1});

% Find the slice with the maximum thickness and display it
max_thick = -1; 
max_thick_slice = -1;
for i = slices
    index = i - slice_start + 1;  % Adjust the index for the slice range
    thick = max_thicknesses(index);  % Get the max thickness for this slice
    if(thick > max_thick)
        max_thick = thick;
        max_thick_slice = i;
    end
end

% Display the maximum thickness and the slice it was found in
disp(max_thick);
disp(max_thick_slice);