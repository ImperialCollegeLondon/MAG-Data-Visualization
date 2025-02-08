classdef tPSD < MAGViewTestCase
% TPSD Unit tests for "mag.imap.view.PSD" class.

    methods (Test)

        % Test that PSD is generated correctly when start and duration are
        % provided.
        function psdStartDuration(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();

            psdStart = instrument.Primary.Time(1);
            psdDuration = minutes(5);

            [expectedInputs, mockTransformation] = testCase.generateExpectedInputs(instrument, psdStart, psdDuration);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.PSD(instrument, Start = psdStart, Duration = psdDuration, ...
                Transformation = mockTransformation, Factory = mockFactory);

            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that PSD is generated correctly when only primary sensor is
        % available.
        function psd_primaryOnly(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();
            instrument.Secondary.Data(:, :) = [];

            psdStart = instrument.Primary.Time(1);
            psdDuration = minutes(5);

            [expectedInputs, mockTransformation] = testCase.generateExpectedInputs(instrument, psdStart, psdDuration);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.PSD(instrument, Start = psdStart, Duration = psdDuration, ...
                Transformation = mockTransformation, Factory = mockFactory);

            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that PSD is generated correctly when only secondary sensor
        % is available.
        function psd_secondaryOnly(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();
            instrument.Primary.Data(:, :) = [];

            psdStart = instrument.Secondary.Time(1);
            psdDuration = minutes(5);

            [expectedInputs, mockTransformation] = testCase.generateExpectedInputs(instrument, psdStart, psdDuration);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.PSD(instrument, Start = psdStart, Duration = psdDuration, ...
                Transformation = mockTransformation, Factory = mockFactory);

            view.visualize();

            % Verify.
            testCase.verifyEqual(view.Figures, expectedOutput, "Returned figure should match expectation.");
        end

        % Test that PSD is not generated when no science data is available.
        function psd_noScience(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();
            instrument.Primary.Data(:, :) = [];
            instrument.Secondary.Data(:, :) = [];

            mockTransformation = testCase.createMock(?mag.transform.PSD, Strict = true);
            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);

            % Exercise.
            view = mag.imap.view.PSD(instrument, Transformation = mockTransformation, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyNotCalled(withAnyInputs(factoryBehavior.assemble()), "Figure should not be assembled.");
            testCase.verifyEmpty(view.Figures, "Returned figure should be empty.");
        end
    end

    methods (Access = private)

        function [expectedInputs, mockTransformation] = generateExpectedInputs(testCase, instrument, psdStart, psdDuration, options)

            arguments
                testCase
                instrument (1, 1) mag.imap.Instrument
                psdStart (1, 1) datetime
                psdDuration (1, 1) duration
                options.Title (1, 1) string = "Start: %s - Duration: %s - (64, 8)"
                options.Name (1, 1) string = "Burst (64, 8) PSD (%s)"
            end

            expectedInputs = {};
            arrangement = [0, 1];

            primaryPSD = mag.PSD(table.empty());
            secondaryPSD = mag.PSD(table.empty());

            yLine = mag.graphics.chart.Line(Axis = "y", Value = 0.01, Style = "--", Label = "10 pT Hz^{-0.5}");
            [mockTransformation, transformationBehavior] = testCase.createMock(?mag.transform.PSD, Strict = false);

            % Primary.
            if instrument.Science(2).HasData

                testCase.assignOutputsWhen(transformationBehavior.apply(instrument.Primary), primaryPSD);

                arrangement(1) = arrangement(1) + 1;

                expectedInputs{end + 1} = primaryPSD;
                expectedInputs{end + 1} = mag.graphics.style.Default(Title = "FIB PSD", XLabel = "frequency [Hz]", YLabel = "PSD [nT Hz^{-0.5}]", XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                    Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]);
            end

            % Secondary.
            if instrument.Science(1).HasData

                testCase.assignOutputsWhen(transformationBehavior.apply(instrument.Secondary), secondaryPSD);

                arrangement(1) = arrangement(1) + 1;

                expectedInputs{end + 1} = secondaryPSD;
                expectedInputs{end + 1} = mag.graphics.style.Default(Title = "FOB PSD", XLabel = "frequency [Hz]", YLabel = "PSD [nT Hz^{-0.5}]", XScale = "log", YScale = "log", Legend = ["x", "y", "z"], ...
                    Charts = [mag.graphics.chart.Plot(XVariable = "Frequency", YVariables = ["X", "Y", "Z"]), yLine]);
            end

            psdStart.Format = "dd-MMM-uuuu HHmmss";

            expectedInputs = [expectedInputs, { ...
                "Title", compose(options.Title, psdStart, psdDuration), ...
                "Name", compose(options.Name, psdStart), ...
                "Arrangement", arrangement, ...
                "WindowState", "maximized"}];
        end
    end
end
