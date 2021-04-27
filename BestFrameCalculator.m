function [xcoord, ycoord] = BestFrameCalculator(previous_frame,current_block)
sad = -1;
xcoord = -1;
ycoord = -1;
for y = 1:2:17 %Also check y = 1:1:17 and y = 1:4:17
    for x = 1:2:17 %Also check x = 1:1:17 and x = 1:4:17
        prev_block = previous_frame(y:y+15,x:x+15);
        sad_new = abs(prev_block-current_block);
        sad_new_val = sum(sum(sad_new));
        if(sad < 0)
            sad = sad_new_val;
            xcoord = x;
            ycoord = y;
        elseif(sad > 0 && sad > sad_new_val)
            sad = sad_new_val;
            xcoord = x;
            ycoord = y;
        end
    end
end
xcoord = xcoord - 9;
ycoord = ycoord - 9;
end