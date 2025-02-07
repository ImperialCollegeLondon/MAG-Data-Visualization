function emptyTime = emptyTime(varargin)
% EMPTYTIME Generate empty datetime object with correct TimeZone.

    emptyTime = datetime.empty(varargin{:});
    emptyTime.TimeZone = mag.time.Constant.TimeZone;
end
