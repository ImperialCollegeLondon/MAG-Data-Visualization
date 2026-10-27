classdef ToolboxSetting < matlab.unittest.fixtures.Fixture
% TOOLBOXSETTING Temporarily change value of MAG toolbox setting.

    properties (SetAccess = immutable)
        % NAME Name of setting.
        Name (1, 1) string
        % VALUE Temporary value of setting.
        Value
    end

    properties (Access = private)
        % PREVIOUSVALUE Temporary value before setup, if any.
        PreviousValue cell = {}
    end

    methods

        function fixture = ToolboxSetting(name, value)

            fixture.Name = name;
            fixture.Value = value;
        end

        function setup(fixture)

            % Make sure setting exists.
            mag.internal.ToolboxSettings.getSettingValue(fixture.Name);

            setting = fixture.getSetting();

            if setting.hasTemporaryValue()
                fixture.PreviousValue = {setting.TemporaryValue};
            end

            setting.TemporaryValue = fixture.Value;

            fixture.SetupDescription = compose("Set MAG toolbox setting ""%s"" to temporary value.", fixture.Name);
        end

        function teardown(fixture)

            setting = fixture.getSetting();

            if ~isempty(fixture.PreviousValue)
                setting.TemporaryValue = fixture.PreviousValue{1};
            elseif setting.hasTemporaryValue()
                setting.clearTemporaryValue();
            end

            fixture.TeardownDescription = compose("Restored MAG toolbox setting ""%s"".", fixture.Name);
        end
    end

    methods (Access = protected)

        function bool = isCompatible(fixture, otherFixture)
            bool = isequal(fixture.Name, otherFixture.Name) && isequal(fixture.Value, otherFixture.Value);
        end
    end

    methods (Access = private)

        function setting = getSetting(fixture)

            s = settings();
            setting = s.MAG.Toolbox.(fixture.Name);
        end
    end
end
