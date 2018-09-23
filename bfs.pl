:- consult(counter).
:- consult(eightPuzzle).
:- consult(queues).

% solution list only the best path is taken
% everything that has already been considered so that no duplicates are added to the BFS
:- dynamic pendingOrExploredStates/1.
:- dynamic parentOf/2.
% every state that we have visited.

% consulting the other programs needed to run.
:- consult(counter).
:- consult(eightPuzzle).
:- consult(queues).

breadthFirstSearch(InitialState, Solution) :-
	retractall(pendingOrExploredStates(_)),
	retractall(parentOf(_,_)),
	make_queue(InitialOpenList),
	breadthFirstSearch_aux(InitialState, Solution, InitialOpenList).

% Base case
breadthFirstSearch_aux(CurrentState, Solution, CurrentOpenList):-
	goal8(CurrentState),
	assert(pendingOrExploredStates(CurrentState)).
	
% Recursive case
breadthFirstSearch_aux(CurrentState, Solution, CurrentOpenList):-
	assert(pendingOrExploredStates(CurrentState)),
	succ8(CurrentState, AllNeighbours),
	openListSearch(AllNeighbours, CurrentOpenList, ExpandedOpenList, CurrentState),
	serve_queue(ExpandedOpenList, NextState, ExpandedOpenListHeadRemoved),
	breadthFirstSearch_aux(NextState, Solution, ExpandedOpenListHeadRemoved).
	
% Base case
openListSearch([], OldOpenList, ExpandedOpenList, _):-
	jump_queue(_, OldOpenList, TempOpenList),
	serve_queue(TempOpenList, _, ExpandedOpenList).
	
% Recursive case
openListSearch([(_, NeighbourState)|Tail], OldOpenList, NewOpenList, Parent) :-
	pendingOrExploredStates(NeighbourState),
	openListSearch(Tail, OldOpenList, NewOpenList, Parent).

% Recursive case
openListSearch([(_, NeighbourState)|Tail], OldOpenList, NewOpenList, Parent) :-
	not(pendingOrExploredStates(NeighbourState)),
	not(pendingOrExploredStates(NeighbourState)),
	assert(pendingOrExploredStates(NeighbourState)),
	assert(parantOf(Parent, NeighbourState)),
    join_queue(NeighbourState, ExpandedOldOpenList, NewOpenList),
    openListSearch(Tail, OldOpenList, ExpandedOldOpenList, Parent).
	