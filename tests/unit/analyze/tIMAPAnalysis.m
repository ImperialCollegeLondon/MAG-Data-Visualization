classdef tIMAPAnalysis < matlab.unittest.TestCase
% TIMAPANALYSIS Unit tests for "mag.imap.Analysis" class.

    properties (TestParameter)
        AliasName = {"mag.IMAPAnalysis", "mag.IMAPTestingAnalysis", "mag.AutomatedAnalysis"}
    end

    methods (Test)

        % Test that aliases are defined.
        function alias(testCase, AliasName)
            testCase.verifyClass(feval(AliasName), "mag.imap.Analysis", sprintf("Alias ""%s"" should exist.", AliasName));
        end
    end
end
