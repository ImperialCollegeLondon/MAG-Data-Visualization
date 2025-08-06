classdef ToolboxSettings
% TOOLBOXSETTINGS Class to manage MAG Data Visualization toolbox settings.

    properties (Constant)
        % FIGURERESOLUTION Resolution for MAG figures.
        FigureResolution (1, 1) struct = struct(Default = 300, Type = "double")
    end

    properties (Constant, Access = private)
        % MAGGROUP Name of MAG settings group.
        MAGGroup = "MAG"
        % TOOLBOXGROUP Name of toolbox group (sub-group of MAG).
        ToolboxGroup = "Toolbox"
    end

    methods (Static)

        function value = getSettingValue(name)

            settings = mag.internal.ToolboxSettings();
            value = settings.getValue(name);
        end
    end

    methods

        function value = getValue(this, name)

            % Retrieve settings.
            toolboxSettings = this.getOrCreateToolboxSettings();
            settingProperties = this.getSettingProperties(name);

            % Look for requested settings or create them.
            if toolboxSettings.hasSetting(name)
                setting = toolboxSettings.(name);
            else
                setting = toolboxSettings.addSetting(name);
            end

            % If no value is set, add a default one.
            if ~toolboxSettings.(name).hasActiveValue()
                setting.PersonalValue = settingProperties.Default;
            end

            value = setting.ActiveValue;

            % Make sure type is correct.
            if ~isa(value, settingProperties.Type)
                error("mag:settings:IncompatibleType", "MAG toolbox setting ""%s"" shouble be of type ""%s"".", name, settingProperties.Type);
            end
        end
    end

    methods (Access = private)

        function toolboxSettings = getOrCreateToolboxSettings(this)

            s = settings();

            if s.hasGroup(this.MAGGroup)
                magSettings = s.(this.MAGGroup);
            else
                magSettings = s.addGroup(this.MAGGroup);
            end

            if magSettings.hasGroup(this.ToolboxGroup)
                toolboxSettings = magSettings.(this.ToolboxGroup);
            else
                toolboxSettings = magSettings.addGroup(this.ToolboxGroup);
            end
        end

        function settingProperties = getSettingProperties(this, name)

            % Find constant public properties.
            mc = metaclass(this);
            mp = mc.PropertyList;

            locProperties = [mp.Constant] & ismember({mp.GetAccess}, "public") & ismember({mp.Name}, name);
            settingMetaProperty = mp(locProperties);

            if isempty(settingMetaProperty)
                error("mag:settings:UnknownSetting", "MAG toolbox setting ""%s"" is not recognized.", name);
            end

            settingProperties = this.(settingMetaProperty.Name);
        end
    end
end
