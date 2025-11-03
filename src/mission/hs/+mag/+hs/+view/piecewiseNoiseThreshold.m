function y = piecewiseNoiseThreshold(x)
% PIECEWISENOISETHRESHOLD Calculate noise threshold as a piecewise function
% of frequency.

    y(x <= 1) = 1500;
    y((x > 1) & (x <= 2)) = 15;
    y(x > 2) = 7.5;
end
