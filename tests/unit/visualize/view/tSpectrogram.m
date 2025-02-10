classdef tSpectrogram < MAGViewTestCase
% TSPECTROGRAM Unit tests for "mag.imap.view.Spectrogram" class.

    methods (Test)

        % Test that spectrogram is generated correctly when start and
        % duration are provided.
        function psdStartDuration(testCase)

            % Set up.
            instrument = testCase.createTestInstrument();

            [expectedInputs, mockTransformation] = testCase.generateExpectedInputs(instrument);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Spectrogram(instrument, Transformation = mockTransformation, Factory = mockFactory);
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

            [expectedInputs, mockTransformation] = testCase.generateExpectedInputs(instrument);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Spectrogram(instrument, Transformation = mockTransformation, Factory = mockFactory);
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

            [expectedInputs, mockTransformation] = testCase.generateExpectedInputs(instrument);
            expectedOutput = figure();

            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);
            when(withAnyInputs(factoryBehavior.assemble()), matlab.mock.actions.Invoke(@(~, varargin) testCase.verifyInputsAndAssignOutput(expectedOutput, expectedInputs, varargin)));

            % Exercise.
            view = mag.imap.view.Spectrogram(instrument, Transformation = mockTransformation, Factory = mockFactory);
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

            mockTransformation = testCase.createMock(?mag.transform.Spectrogram, Strict = true);
            [mockFactory, factoryBehavior] = testCase.createMock(?mag.graphics.factory.Factory, Strict = true);

            % Exercise.
            view = mag.imap.view.Spectrogram(instrument, Transformation = mockTransformation, Factory = mockFactory);
            view.visualize();

            % Verify.
            testCase.verifyNotCalled(withAnyInputs(factoryBehavior.assemble()), "Figure should not be assembled.");
            testCase.verifyEmpty(view.Figures, "Returned figure should be empty.");
        end
    end

    methods (Access = private)

        function [expectedInputs, mockTransformation] = generateExpectedInputs(testCase, instrument, options)

            arguments
                testCase
                instrument (1, 1) mag.imap.Instrument
                options.Title (1, 1) string = "Burst (64, 8)"
                options.Name (1, 1) string = "Burst (64, 8) Frequency (%s)"
            end

            expectedInputs = {};
            arrangement = [9, 0];

            primarySpectrum = mag.Spectrum(datetime.empty(), double.empty(), double.empty(), double.empty(), double.empty());
            secondarySpectrum = mag.Spectrum(datetime.empty(), double.empty(), double.empty(), double.empty(), double.empty());

            [mockTransformation, transformationBehavior] = testCase.createMock(?mag.transform.Spectrogram, Strict = false);

            % Primary.
            if instrument.Science(2).HasData

                testCase.assignOutputsWhen(transformationBehavior.apply(instrument.Primary), primarySpectrum);

                arrangement(2) = arrangement(2) + 1;

                for a = ["X", "Y", "Z"]

                    expectedInputs{end + 1} = instrument.Primary; %#ok<*AGROW>
                    expectedInputs{end + 1} = mag.graphics.style.Default(Title = compose("FIB %s", lower(a)), YLabel = "[nT]", Charts = mag.graphics.chart.Plot(YVariables = a));

                    expectedInputs{end + 1} = primarySpectrum;
                    expectedInputs{end + 1} = mag.graphics.style.Colormap(YLabel = "frequency [Hz]", CLabel = "power [dB]", YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = a));
                end
            end

            % Secondary.
            if instrument.Science(1).HasData

                testCase.assignOutputsWhen(transformationBehavior.apply(instrument.Secondary), secondarySpectrum);

                arrangement(2) = arrangement(2) + 1;

                for a = ["X", "Y", "Z"]

                    expectedInputs{end + 1} = instrument.Secondary; %#ok<*AGROW>
                    expectedInputs{end + 1} = mag.graphics.style.Default(Title = compose("FOB %s", lower(a)), YLabel = "[nT]", YAxisLocation = "right", Charts = mag.graphics.chart.Plot(YVariables = a));

                    expectedInputs{end + 1} = secondarySpectrum;
                    expectedInputs{end + 1} = mag.graphics.style.Colormap(YLabel = "frequency [Hz]", CLabel = "power [dB]", YLimits = "tight", Layout = [2, 1], Charts = mag.graphics.chart.Spectrogram(YVariables = a));
                end
            end

            startTime = instrument.Primary.MetaData.Timestamp;
            startTime.Format = "dd-MMM-uuuu HHmmss";

            expectedInputs = [expectedInputs, { ...
                "Title", options.Title, ...
                "Name", compose(options.Name, startTime), ...
                "Arrangement", arrangement, ...
                "LinkXAxes", true, ...
                "TileIndexing", "columnmajor", ...
                "WindowState", "maximized"}];
        end
    end
end
