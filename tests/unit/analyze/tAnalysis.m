classdef (TestTags = ["Unit", "Parallel"]) tAnalysis < matlab.unittest.TestCase
% TANALYSIS Unit tests for "mag.Analysis" class, shared by all missions.

    properties (TestParameter)
        AnalysisClass = {"mag.bart.Analysis", "mag.henon.Analysis", "mag.hs.Analysis", "mag.imap.Analysis", "mag.vigil.Analysis"}
        ForwardingProperty = {struct(Class = "mag.bart.Analysis", Property = "ScienceProcessing", Steps = "ScienceSteps"), ...
            struct(Class = "mag.henon.Analysis", Property = "PerFileProcessing", Steps = "PerFileSteps"), ...
            struct(Class = "mag.henon.Analysis", Property = "WholeDataProcessing", Steps = "WholeDataSteps"), ...
            struct(Class = "mag.hs.Analysis", Property = "PerFileProcessing", Steps = "PerFileSteps"), ...
            struct(Class = "mag.hs.Analysis", Property = "WholeDataProcessing", Steps = "WholeDataSteps"), ...
            struct(Class = "mag.hs.Analysis", Property = "ScienceProcessing", Steps = "ScienceSteps"), ...
            struct(Class = "mag.hs.Analysis", Property = "HKProcessing", Steps = "HKSteps")}
    end

    methods (Test)

        % Test that each analysis has its own processing steps, and does
        % not share them with other analyses.
        function processing_notShared(testCase, AnalysisClass)

            % Set up.
            other = feval(AnalysisClass);
            other.Processing.HKSteps = mag.process.Sort();

            % Exercise.
            analysis = feval(AnalysisClass);

            % Verify.
            testCase.verifyNotSameHandle(analysis.Processing, other.Processing, "Processing should not be shared.");
            testCase.verifyEmpty(analysis.Processing.HKSteps, "Processing steps of other analysis should not be used.");
        end

        % Test that processing steps of one mission do not affect others.
        function processing_notSharedAcrossMissions(testCase)

            % Set up.
            mag.vigil.Analysis();

            % Exercise.
            analysis = mag.imap.Analysis();

            % Verify.
            testCase.verifyEmpty(analysis.Processing.ScienceSteps, "Vigil processing steps should not be used by IMAP.");
        end

        % Test that file names are empty before files are detected.
        function fileNames_beforeDetect(testCase, AnalysisClass)

            % Set up.
            analysis = feval(AnalysisClass);
            fileNameProperties = string(properties(analysis));
            fileNameProperties = fileNameProperties(endsWith(fileNameProperties, "FileNames"));

            % Exercise and verify.
            for p = fileNameProperties'
                testCase.verifyEmpty(analysis.(p), compose("""%s"" should be empty before detection.", p));
            end
        end

        % Test that forwarding properties get and set processing steps.
        function processing_forwardingProperty(testCase, ForwardingProperty)

            % Set up.
            analysis = feval(ForwardingProperty.Class);
            steps = [mag.process.Sort(), mag.process.Duplicates()];

            % Exercise.
            analysis.(ForwardingProperty.Property) = steps;

            % Verify.
            testCase.verifyEqual(analysis.Processing.(ForwardingProperty.Steps), steps, "Processing steps should be set.");
            testCase.verifyEqual(analysis.(ForwardingProperty.Property), steps, "Forwarding property should return processing steps.");
        end

        % Test that forwarding properties can be set on construction.
        function processing_forwardingPropertyConstructor(testCase, ForwardingProperty)

            % Set up.
            steps = mag.process.Sort();

            % Exercise.
            analysis = feval(ForwardingProperty.Class, (ForwardingProperty.Property), steps);

            % Verify.
            testCase.verifyEqual(analysis.Processing.(ForwardingProperty.Steps), steps, "Processing steps should be set.");
        end
    end
end
