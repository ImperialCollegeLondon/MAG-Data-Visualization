classdef (Abstract) Data < handle & matlab.mixin.Copyable & matlab.mixin.Heterogeneous & mag.mixin.SetGet
% DATA Abstract base class for MAG science and HK data.

    properties (GetAccess = public, SetAccess = protected)
        % METADATA Metadata.
        Metadata (1, :) mag.meta.Data
    end

    properties (Abstract, Dependent)
        % INDEPENDENTVARIABLE Independent variable of data.
        IndependentVariable (:, 1)
        % DEPENDENTVARIABLES Dependent variables of data.
        DependentVariables
    end

    methods (Sealed)

        function value = get(this, varargin)
        % GET Customize getting property values. The method also accepts
        % many string values or a vector of string values.

            % Vector of strings as property names.
            if (nargin() == 2) && (isstring(varargin{1}) && isvector(varargin{1}))

                value = cell.empty(0, numel(varargin{1}));

                for i = 1:numel(varargin{1})
                    value{i} = get@mag.mixin.SetGet(this, varargin{1}(i));
                end

                value = horzcat(value{:});

            % Individual strings as property names.
            elseif all(cellfun(@isStringScalar, varargin))

                value = cell.empty(0, numel(varargin));

                for i = 1:numel(varargin)
                    value{i} = get@mag.mixin.SetGet(this, varargin{i});
                end

                value = horzcat(value{:});

            % Anything else.
            else
                value = get@mag.mixin.SetGet(this, varargin{:});
            end
        end
    end

    methods (Access = protected)

        function copiedThis = copyElement(this)

            copiedThis = copyElement@matlab.mixin.Copyable(this);
            copiedThis.Metadata = copy(this.Metadata);
        end
    end
end
