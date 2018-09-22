% Rule: MotherOf(X, Y)
% Tries to identify if person X is the mother of person Y
motherOf(X, Y) :- female(X), childOf(Y, X).

% Rule: SisterOf(X, Y)
% Tries to identify if person X is a sister of person Y though the parent Z
sisterOf(X, Y) :- female(X), childOf(X, _), childOf(Y, _).

% Rule: ancestor(X)
% gets the root node of the input X
% base case
ancestor(X, Y) :- parentOf(X, Y).
% recursive case
ancestor(X, Y) :- parentOf(X, Z), ancestor(Z, Y).

% inSameTree(X, Y)
% tries to identify if X and Y are in the same tree or forest depending on
% whether they share the same parent or parents
inSameTree(X, Y) :- ancestor(X, Y);
					ancestor(Y, X);
					ancestor(X, Z), ancestor(Y, Z);
					ancestor(Z, X), ancestor(Z, Y).
