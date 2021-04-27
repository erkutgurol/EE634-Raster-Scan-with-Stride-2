tic
%% Read Images
current_frame = imread('current.png');
previous_frame = imread('reference.png');
%% Convert to YCbCr
current_frame_grayscale = current_frame;
previous_frame_grayscale = previous_frame;
[h,w,ch] = size(current_frame);
if(ch == 3)
    current_frame_grayscale = rgb2ycbcr(current_frame);
end
[h,w,ch] = size(previous_frame);
if(ch == 3)
    previous_frame_grayscale = rgb2ycbcr(previous_frame);
end
%% Convert to double
current_frame_grayscale = double(current_frame_grayscale(:,:,1));
previous_frame_grayscale = double(previous_frame_grayscale(:,:,1));
curr_completeframe = zeros(h+8,w);
prev_completeframe = zeros(h+8,w);
%% Copy current and previous
for y = 1:1:h
    for x= 1:1:w
        curr_completeframe(y,x) = current_frame_grayscale(y,x);
        prev_completeframe(y,x) = previous_frame_grayscale(y,x);
    end
end
%% Start Constructing the block
Block_Distance_xarray = zeros(68,120);
Block_Distance_yarray = zeros(68,120);
prev_block_zeropadded = zeros(1104,1936);
prev_block_zeropadded(9:1096,9:1928)=prev_completeframe;
for y = 1:16:1073
    for x = 1:16:1905
        current_window = curr_completeframe(y:y+15,x:x+15);
        %current_window = current_window(y:y+15,x:x+15);
        %prev_frame = zeros(512,512);
        prev_frame = prev_block_zeropadded(y:y+31,x:x+31);
        [xcoord, ycoord] = BestFrameCalculator(prev_frame,current_window);
        Block_Distance_xarray((y+15)/16,(x+15)/16) = xcoord;
        Block_Distance_yarray((y+15)/16,(x+15)/16) = ycoord;
        %fprintf('y and x pair is: %d %d \n',y,x)
    end
end
%% Reconstruction
curr_frame_reconstructed = zeros(1088,1920);
for y = 1:16:1073
    for x = 1:16:1905
        prev_frame_xcoord = Block_Distance_xarray((y+15)/16,(x+15)/16);
        prev_frame_ycoord = Block_Distance_yarray((y+15)/16,(x+15)/16);
        curr_frame_reconstructed(y:y+15,x:x+15) = prev_block_zeropadded(y+8+prev_frame_ycoord:y+23+prev_frame_ycoord,x+8+prev_frame_xcoord:x+23+prev_frame_xcoord);
    end
end
img1 = imgaussfilt(uint8(curr_frame_reconstructed));
rgb1(:,:,1) = img1;
rgb1(:,:,2) = img1;
rgb1(:,:,3) = img1;
ycbcr11 = double(rgb2ycbcr(rgb1));
img2 = medfilt2(uint8(curr_frame_reconstructed));
rgb2(:,:,1) = img2;
rgb2(:,:,2) = img2;
rgb2(:,:,3) = img2;
ycbcr12 = double(rgb2ycbcr(rgb2));
ycbcr1 = ycbcr11(:,:,1);
ycbcr2 = ycbcr12(:,:,1);
figure
imshow(uint8(curr_completeframe))
title('Current Frame')
figure
imshow(uint8(prev_completeframe))
title('Previous Frame')
figure
imshow(uint8(curr_frame_reconstructed))
title('Reconstructed Frame')
figure
imshow(imgaussfilt(uint8(curr_frame_reconstructed)))
title('Gaussian Filtered')
figure
imshow(medfilt2(uint8(curr_frame_reconstructed)))
title('Median Filtered')
figure
imshow(uint8(abs(curr_completeframe - curr_frame_reconstructed)))
title('Current Frame - Reconstructed Frame')
figure
imshow(uint8(abs(curr_completeframe - ycbcr1)))
title('Current Frame - Gaussian Filtered Frame')
figure
imshow(uint8(abs(curr_completeframe - ycbcr2)))
title('Current Frame - Median Filtered Frame')
figure
imshow(uint8(abs(curr_completeframe - prev_completeframe)))
title('Current Frame - Previous Frame')
%% Print overall SAD
fprintf("Current - Reconstructed is: %d \n",sum(sum(abs(curr_completeframe-curr_frame_reconstructed))))
fprintf("Current - Gauss Filtered is: %d \n",sum(sum(abs(curr_completeframe-ycbcr1))))
fprintf("Current - Median Filtered is: %d \n",sum(sum(abs(curr_completeframe-ycbcr2))))
fprintf("Current - Previous is: %d",sum(sum(abs(curr_completeframe-prev_completeframe))))
time = toc
