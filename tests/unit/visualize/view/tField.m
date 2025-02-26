classdef tField < MAGViewTestCase
% TFIELD Unit tests for "mag.imap.view.Field" class.

    properties (TestParameter)
        AddHK = {false, true}
    end

    methods (Test)

        % Test that science and HK view is generated correctly.
        function field_scienceHK(testCase, AddHK)

            % Set up.
            instrument = testCase.createTestInstrument(AddHK = AddHK);

            expectedInputs = testCase.generateExpectedInputs(instrument);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that when only primary sensor is available view is generated
        % correctly.
        function field_primaryOnly(testCase)

            % Set up.
            instrument = testCase.createTestInstrument(AddHK = false);
            instrument.Primary.Data(:, :) = [];

            expectedInputs = testCase.generateExpectedInputs(instrument);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that when only secondary sensor is available view is generated
        % correctly.
        function field_secondaryOnly(testCase)

            % Set up.
            instrument = testCase.createTestInstrument(AddHK = false);
            instrument.Secondary.Data(:, :) = [];

            expectedInputs = testCase.generateExpectedInputs(instrument);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that when no science is available empty figure is returned.
        function field_noScience(testCase)

            % Set up.
            instrument = testCase.createTestInstrument(AddHK = false);
            instrument.Science(1).Data(:, :) = [];
            instrument.Science(2).Data(:, :) = [];

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);

            % Exercise.
            view = mag.imap.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyNotCalled(withAnyInputs(factoryBehavior.assemble()), "Figure should not be assembled.");
            testCase.verifyEmpty(view.Figures, "Returned figure should be empty.");
        end

        % Test that custom names are used when provided.
        function customNameTitle(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();

            title = "This is the title";
            name = "This is the name";

            expectedNameValues = {"Title", title, "Name", name};
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyNameValuesAndAssignOutput(expectedOutput, expectedNameValues, varargin)));

            % Exercise.
            view = mag.imap.view.Field(instrument, Title = title, Name = name, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that if no sensor setup is provided, only the sensor name is
        % used.
        function nonIntegerDataFrequency(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();

            instrument.Science(1).Metadata.DataFrequency = 0.25;
            instrument.Science(2).Metadata.DataFrequency = 2/3;
            instrument.Science(2).Metadata.Timestamp = datetime(2024, 3, 14, 15, 9, 27, TimeZone = "UTC");

            expectedInputs = testCase.generateExpectedInputs(instrument, Title = "Burst (2/3, 1/4)", Name = "Burst (2/3, 1/4) Time Series (14-Mar-2024 150927)");
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that if no sensor setup is provided, only the sensor name is
        % used.
        function fieldTitle_noSensorSetup(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();

            instrument.Science(1).Metadata.Setup = mag.meta.Setup();
            instrument.Science(2).Metadata.Setup = mag.meta.Setup.empty();

            expectedInputs = testCase.generateExpectedInputs(instrument, PrimaryTitle = "FIB", SecondaryTitle = "FOB");
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that if no events are specified, and compression changes in
        % the data set, compression event is shown.
        function events_autoCompression(testCase)

            % Set up.
            instrument = testCase.createTestInstrument(AddHK = false);

            instrument.Primary.Data.compression(7:end) = true;
            instrument.Secondary.Data.compression(7:end) = true;

            expectedInputs = testCase.generateExpectedInputs(instrument, Events = "Compression");
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Field(instrument, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end
    end

    methods (Static, Access = private)

        function expectedInputs = generateExpectedInputs(instrument, options)

            arguments
                instrument (1, 1) mag.imap.Instrument
                options.PrimaryTitle (1, 1) string = "FIB (FEE4 - LM2 - Some)"
                options.SecondaryTitle (1, 1) string = "FOB (FEE2 - EM4 - None)"
                options.Title (1, 1) string = "Burst (64, 8)"
                options.Name (1, 1) string = "Burst (64, 8) Time Series (NaT)"
                options.Events (1, 1) string = missing()
            end

            expectedInputs = {};
            arrangement = [3, 0];

            if instrument.Science(2).HasData

                arrangement(2) = arrangement(2) + 1;

                expectedInputs{end + 1} = instrument.Science(2);
                expectedInputs{end + 1} = mag.graphics.style.Stackedplot(Title = options.PrimaryTitle, YLabels =  ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], Layout = [3, 1], ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = instrument.Science(2).Quality.isPlottable()));
            end

            if instrument.Science(1).HasData

                arrangement(2) = arrangement(2) + 1;

                expectedInputs{end + 1} = instrument.Science(1);
                expectedInputs{end + 1} = mag.graphics.style.Stackedplot(Title = options.SecondaryTitle, YLabels = ["x [nT]", "y [nT]", "z [nT]", "|B| [nT]"], YAxisLocation = "right", Layout = [3, 1], ...
                    Charts = mag.graphics.chart.Stackedplot(YVariables = ["X", "Y", "Z", "B"], Filter = instrument.Science(1).Quality.isPlottable()));
            end

            if instrument.HasHK && any(instrument.HK.isPlottable())

                arrangement(1) = arrangement(1) + 1;

                if instrument.Science(2).HasData

                    expectedInputs{end + 1} = instrument.HK(1);
                    expectedInputs{end + 1} = [ ...
                        mag.graphics.style.Default(Title = "FIB & ICU Temperatures", YLabel = "T [°C]", Legend = ["FIB", "ICU"], ...
                        Charts = mag.graphics.chart.Plot(YVariables = ["FIB", "ICU"] + "Temperature"))];
                end

                if instrument.Science(1).HasData

                    expectedInputs{end + 1} = instrument.HK(1);
                    expectedInputs{end + 1} = [ ...
                        mag.graphics.style.Default(Title = "FOB & ICU Temperatures", YLabel = "T [°C]", YAxisLocation = "right", Legend = ["FOB", "ICU"], ...
                        Charts = mag.graphics.chart.Plot(YVariables = ["FOB", "ICU"] + "Temperature"))];
                end
            end

            switch options.Events
                case "Compression"

                    arrangement(1) = arrangement(1) + 1;
                    expectedInputs = [expectedInputs, {instrument.Primary, mag.graphics.style.Default(Title = "FIB Compression", YLabel = "compressed [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Compression")), ...
                        instrument.Secondary, mag.graphics.style.Default(Title = "FOB Compression", YLabel = "compressed [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Compression"))}];

                case "Mode"

                    arrangement(1) = arrangement(1) + 1;
                    expectedInputs = [expectedInputs, {instrument.Primary.Events, mag.graphics.style.Default(Title = "FIB Modes", YLabel = "mode [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = instrument.Primary.Time(end))), ...
                        instrument.Secondary.Events, mag.graphics.style.Default(Title = "FOB Modes", YLabel = "mode [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "DataFrequency", EndTime = instrument.Secondary.Time(end)))}];

                case "Range"

                    arrangement(1) = arrangement(1) + 1;
                    expectedInputs = [expectedInputs, {instrument.Primary, mag.graphics.style.Default(Title = "FIB Ranges", YLabel = "range [-]", YLimits = "manual", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", IgnoreMissing = false, YOffset = 0.25)), ...
                        instrument.Secondary, mag.graphics.style.Default(Title = "FOB Ranges", YLabel = "range [-]", YLimits = "manual", YAxisLocation = "right", Charts = mag.graphics.chart.custom.Event(EventOfInterest = "Range", IgnoreMissing = false, YOffset = 0.25))}];
            end

            expectedInputs = [expectedInputs, { ...
                "Title", options.Title, ...
                "Name", options.Name, ...
                "Arrangement", arrangement, ...
                "LinkXAxes", true, ...
                "WindowState", "maximized"}];
        end
    end
end
