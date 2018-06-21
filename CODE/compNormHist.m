function normHist = compNormHist(I,s)

Xc = round(s(1));
Yc = round(s(2));
halfW = round(s(3));
halfH = round(s(4));

% Crop required rectangle
rectangle = I(max(Yc-halfH, 1):min(Yc+halfH, size(I, 1)), ...
              max(Xc-halfW, 1):min(Xc+halfW, size(I, 2)), :); 

% Quantize
rectangle = bitshift(rectangle, -4);

% Create a unique value for each RGB value
rectangle = uint16(rectangle);

hist = zeros(16,16,16);
for i = 1:size(rectangle,1)
    for j = 1:size(rectangle,2)
        idxR = rectangle(i,j,1)+1;
        idxG = rectangle(i,j,2)+1;
        idxB = rectangle(i,j,3)+1;
        hist(idxR, idxG, idxB) = hist(idxR, idxG, idxB) + 1;
    end
end
normHist = hist(:)/sum(hist(:));


end


