function stateOut = feature(name, stateIn)
% FEATURE Retrieve feature state, or enable/disable feature.

    arguments (Input)
        name (1, 1) string {mustBeMember(name, "LimitDisplay")}
        stateIn matlab.lang.OnOffSwitchState {mustBeScalarOrEmpty} = matlab.lang.OnOffSwitchState.empty()
    end

    arguments (Output)
        stateOut (1, 1) matlab.lang.OnOffSwitchState
    end

    s = settings();

    magGroup = getSettingsGroup(s, "MAG");
    toolboxGroup = getSettingsGroup(magGroup, "Toolbox");

    featureSetting = getSetting(toolboxGroup, name);

    if featureSetting.hasActiveValue()
        stateOut = featureSetting.ActiveValue;
    else
        stateOut = matlab.lang.OnOffSwitchState.off;
    end

    if ~isempty(stateIn)
        featureSetting.PersonalValue = stateIn;
    end
end

function group = getSettingsGroup(s, groupName)

    if s.hasGroup(groupName)
        group = s.(groupName);
    else
        group = s.addGroup(groupName);
    end
end

function setting = getSetting(s, settingName)

    if s.hasSetting(settingName)
        setting = s.(settingName);
    else
        setting = s.addSetting(settingName);
    end
end
