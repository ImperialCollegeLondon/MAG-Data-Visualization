classdef IsField < matlab.unittest.constraints.Constraint & mag.mixin.SetGet & ...
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

    methods (Hidden, Access = protected)

        function args = getInputArguments(constraint)
            args = {constraint.Field};
        end
    end
end
