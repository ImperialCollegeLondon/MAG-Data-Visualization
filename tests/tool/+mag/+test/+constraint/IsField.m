classdef IsField < matlab.unittest.constraints.BooleanConstraint & ...
                   matlab.unittest.internal.constraints.HybridDiagnosticMixin & ...
                   matlab.unittest.internal.constraints.HybridCasualDiagnosticMixin
% ISFIELD Constraint for fields of structs.

    properties (GetAccess = public, SetAccess = immutable)
        % FIELD Field name.
        Field (1, 1) string
    end

    methods

        function constraint = IsField(field)
            constraint.Field = field;
        end

        function tf = satisfiedBy(constraint, actual)
            tf = (isscalar(actual) && isstruct(actual)) & isfield(actual, constraint.Field);
        end
    end

    methods (Hidden, Sealed)

        function diag = getConstraintDiagnosticFor(constraint, actual, isNegative)

            if isNegative
                sense = matlab.unittest.internal.diagnostics.DiagnosticSense.Negative;
            else
                sense = matlab.unittest.internal.diagnostics.DiagnosticSense.Positive;
            end

            if constraint.satisfiedBy(actual)
                diag = matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, sense, actual);
            else
                diag = matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, sense, actual);
            end
        end
    end

    methods (Access = protected)

        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual, true);
        end
    end

    methods (Hidden, Access = protected)

        function args = getInputArguments(constraint)
            args = {constraint.Field};
        end
    end
end
