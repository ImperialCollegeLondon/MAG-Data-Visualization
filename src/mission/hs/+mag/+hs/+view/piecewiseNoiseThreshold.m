function y = piecewiseNoiseThreshold(x)
% PIECEWISENOISETHRESHOLD Generate noise as a piecewise function.

    y(x <= 1) = 1500;
    y((x > 1) & (x <= 2)) = 15;
    y(x > 2) = 7.5;
end
