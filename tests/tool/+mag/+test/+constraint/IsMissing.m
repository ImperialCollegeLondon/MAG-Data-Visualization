classdef IsMissing < matlab.unittest.constraints.Constraint & ...
                     matlab.unittest.internal.constraints.HybridDiagnosticMixin & ...
                     matlab.unittest.internal.constraints.HybridCasualDiagnosticMixin
% ISMISSING Constraint for missing values.

    methods

        function tf = satisfiedBy(~, actual)
            tf = all(ismissing(actual));
        end
    end

    methods (Hidden, Sealed)

        function diag = getConstraintDiagnosticFor(constraint, actual)

            if constraint.satisfiedBy(actual)

                diag = matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    matlab.unittest.internal.diagnostics.DiagnosticSense.Positive, actual);
            else

                diag = matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    matlab.unittest.internal.diagnostics.DiagnosticSense.Positive, actual);
            end
        end
    end
end
