% Description:
%   This script reads an image file, resizes it to 640x480, converts each
%   pixel to a 12-bit RGB color value (4 bits per channel), and writes the
%   hexadecimal representation to a text file for use in a Verilog testbench.

% --- Configuration ---
input_image_file = 'source_image.png'; % Change this to your image file
output_hex_file = 'image_data.hex';
width = 640;
height = 480;

% --- Script Body ---
fprintf('Starting image to hex conversion...\n');

% Check if the input image exists
if ~exist(input_image_file, 'file')
    fprintf('Error: Input file "%s" not found.\n', input_image_file);
    fprintf('Creating a default placeholder image.\n');
    % Create a gradient image if the source is not found
    [X, Y] = meshgrid(1:width, 1:height);
    img_original = uint8(cat(3, X/width*255, Y/height*255, ones(height,width)*128));
else
    % Read the source image
    img_original = imread(input_image_file);
end


% Resize the image to the target resolution
fprintf('Resizing image to %d x %d...\n', width, height);
img_resized = imresize(img_original, [height, width]);

% Open the output file for writing
fid = fopen(output_hex_file, 'w');
if fid == -1
    error('Cannot open file for writing: %s', output_hex_file);
end

fprintf('Converting pixels and writing to %s...\n', output_hex_file);

% Iterate over each pixel of the resized image
for y = 1:height
    for x = 1:width
        % Get the 8-bit R, G, B values
        pixel_8bit = img_resized(y, x, :);
        r_8bit = pixel_8bit(1);
        g_8bit = pixel_8bit(2);
        b_8bit = pixel_8bit(3);

        % Convert to 4-bit values by taking the most significant 4 bits
        r_4bit = bitshift(r_8bit, -4);
        g_4bit = bitshift(g_8bit, -4);
        b_4bit = bitshift(b_8bit, -4);

        % Combine into a single 12-bit number (RRRRGGGGXXXX)
        % Note: Verilog's $readmemh expects each character to be a nibble.
        % We will format it as a 3-character hex string: RGB.
        % Example: R=0xA, G=0xB, B=0xC -> "ABC"
        
        % Combine into a 12-bit integer
        rgb_12bit = bitor(bitshift(uint16(r_4bit), 8), ...
                      bitor(bitshift(uint16(g_4bit), 4), uint16(b_4bit)));

        % Write the 3-digit hex value to the file
        fprintf(fid, '%03X\n', rgb_12bit);
    end
end

% Close the file
fclose(fid);

fprintf('Conversion complete.\n');
imshow(img_resized);
title('Preview of Converted Image');