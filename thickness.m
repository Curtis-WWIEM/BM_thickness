clear all
[file,path] = uigetfile({'*.tif';'*.tiff';},'Select a File','MultiSelect','off');
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected ', fullfile(path,file)]);
end

img_path = fullfile(path,file);
img_info = imfinfo(img_path);
max_num_images = numel(img_info);

%control flags/parameters%
connectivity = 4; %either 4 or 8.
minimum_qualifying_component_size_px = 0; %set to 0 to accept all features.
slice_start = 1;
slice_end = 110;
dist_step = 1; %nm

first_slice = imread(img_path,1);
img_width =size(first_slice,2);
img_height=size(first_slice,1);
num_materials = 1; %match with the number in your MIB model tif.
slices = slice_start:slice_end;
num_slices = length(slices);

bm_material = 1;
pixel_nm_scale = 6;
max_thicknesses = zeros(num_slices,1);
mean_thicknesses = zeros(num_slices,1);
raw_thicknesses = cell(num_slices,1);
tic
%slice = 50
for i = slices
    index = i-slice_start+1; % needed when you don't use the entire stack.
   
    this = imread(img_path,i); %loads the file at slice i. 
    slice_binary_img = false(img_height,img_width);
    
    
    for y = 1:img_height
       for x = 1:img_width
           value = this(y,x);
           if(value == bm_material)
               slice_binary_img(y,x) = true;
           end
       end
    end
    slice_binary_img = ~slice_binary_img;
    dist_transform_img = bwdist(slice_binary_img,"euclidean");
    skeleton_img = bwmorph(~slice_binary_img,"thin",Inf);
    ls = [];
    
    Result = zeros(img_height,img_width); 
    for y = 1:img_height
       for x = 1:img_width
           value = skeleton_img(y,x);
           if(value > 0)
               Result(y,x) = dist_transform_img(y,x); % in px
               ls(end+1) =  dist_transform_img(y,x) * pixel_nm_scale; % in nm
           end
       end
    end
    
    if(isempty(ls))
        raw_thicknesses{index} = NaN;
        mean_thicknesses(index) = NaN;
        max_thicknesses(index) = NaN;
        
    else
        raw_thicknesses{index} = sort(ls);
        mean_thicknesses(index) = mean(ls);
        max_thicknesses(index) = max(ls);
    end
    
    
    
    
    %figure
    h = imagesc(skeleton_img*pixel_nm_scale);
    shading flat;
    set(gca, 'ydir', 'reverse');
    colormap('hot')
    colorbar
    
    %figure
    h = imagesc(dist_transform_img*pixel_nm_scale);
    shading flat;
    set(gca, 'ydir', 'reverse');
    colormap('hot')
    colorbar
    
    %figure
    h = imagesc(Result*pixel_nm_scale);
    shading flat;
    set(gca, 'ydir', 'reverse');
    colormap('hot')
    colorbar
    toc
end
    
%f = figure();
plot(slices,mean_thicknesses)

%f = figure();
plot(1:length(ls),ls)

%example of the thickness distribution. 
%f = figure();
plot(1:length(raw_thicknesses{1,1}),raw_thicknesses{1,1})

%find slice with max thickness
max_thick = -1; 
max_thick_slice = -1;
for i = slices
    index = i-slice_start+1; % needed when you don't use the entire stack.
    thick = max_thicknesses(index);
    if(thick > max_thick)
        max_thick = thick;
        max_thick_slice = i;
    end
end
disp(max_thick)
disp(max_thick_slice)
