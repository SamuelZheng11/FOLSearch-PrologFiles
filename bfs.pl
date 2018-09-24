% consult (importing) from all the locations that the BFS program is dependant on
:- consult(counter).
:- consult(eightPuzzle).
:- consult(queues).

% everything that has already been considered so that no duplicates are added to the BFS
% both from the closed and open list (storing it like this reduces lines of coded need to)
% check if a state is duplicate
:- dynamic openAndClosedStates/1.
% used to identify who is the parent of a state and what G level that state is at
:- dynamic parentOf/3.

/*
	BreadthFirstSearch
	===========================
	
	breadthFirstSearch 
		This method has three arguements +InitalState, -Solution, -Statistics
		This Prolog function performs a BFS search from the inital state and
		outputs a solution (sets of arrays representing the game states after seach move)
		and the Statistics which contains information about each level
		breadthFirstSearch(+InitalState, -Solution, -Statistics)
		
	breadthFirstSearch_aux
		This method is used to support the breadthFirstSearch method call and should not
		be used by external callers.
		Its job is to recursivly call until a base case has been found (the goal state)
		and then generate a Solution and Statistic using the generateOutput method
	
	openListSearch
		This method is used to recursivly append non explored (not on the open or closed lists)
		children states to the queue
		This method should never be used by external callers
		
	generateOutput
		This method is used to recursivly generate a queue that repesents that states after each
		Move in order to get the the goal state. This method also returns a statistics array which 
		is formatted 
				"stat(GLevel,Generated, Duplicated, Expanded), where GLevel is the
				g-value of the node doing the 'action'. So, (3,23,7, 16) says there were 23
				nodes with a g-value of 3 generated, 7 of them were duplicates and 16 of
				the non-duplicates"
		This method should never be used by external callers
		
*/
breadthFirstSearch(InitialState, Solution, Statistics) :-
	% clear memory of previous run
	retractall(openAndClosedStates(_)),
	retractall(parentOf(_,_,_)),
	retractall(count(_,_,_)), 
	retractall(stat(_,_,_,_)),
	removeCounter(_,_),
	
	% generate for intial state
	assert(parentOf(_, InitialState, 0)),
	make_queue(InitialOpenList),
	
	% find the solution
	breadthFirstSearch_aux(InitialState, Solution, InitialOpenList, InitialState, [], Statistics).

% Base case
breadthFirstSearch_aux(CurrentState, Solution, _, InitialState, InitalStatistic, Statistics):-
	%check if the current state is the solution
	goal8(CurrentState),
	make_queue(InputQueue),
	
	% generate the statistics and Solution
	generateOutput(CurrentState, InitialState, InputQueue, OutputQueue, InitalStatistic, Statistics),
	
	% turn the solution from a queue to a list
	queue_to_list(OutputQueue, Solution).

% Recursive case
breadthFirstSearch_aux(CurrentState, Solution, CurrentOpenList, InitialState, InitalStatistic, Statistics):-
	% put the state on the open and closed list hibrid (the case of duplicates are handled when 
	% items are to be considered to be pushed on the openListQueue)
	assert(openAndClosedStates(CurrentState)),
	
	% increment the counter corresponding to the number of nodes expanded in the current state's GLevel
	parentOf(_, CurrentState, GValue),
	incrementCounter(GValue, expandedNodesInGLevel),
	
	% get all children states and add them to the openListQueue (one Glevel down from current)
	succ8(CurrentState, AllNeighbours),
	openListSearch(AllNeighbours, CurrentOpenList, ExpandedOpenList, CurrentState),
	
	% remove a state from the head of the queue and recursivly call with it
	serve_queue(ExpandedOpenList, NextState, ExpandedOpenListHeadRemoved),
	breadthFirstSearch_aux(NextState, Solution, ExpandedOpenListHeadRemoved, InitialState, InitalStatistic, Statistics).
	
% Base case
openListSearch([], OldOpenList, ExpandedOpenList, _):-
	% when there are no more children states to expand join old and new open lists queues
	% in the base case the new open list queue is empty
	jump_queue(_, OldOpenList, TempOpenList),
	serve_queue(TempOpenList, _, ExpandedOpenList).
	
% Recursive case
openListSearch([(_, NeighbourState)|Tail], OldOpenList, NewOpenList, Parent) :-
	% if 'this' child state (NeighbourState) has already been considered (on the open
	% closed list) increment the counter for duplicates on the GLevel and 
	% move on with the next child state
	openAndClosedStates(NeighbourState),
	parentOf(_, Parent, GValue),
	Value is GValue + 1,
	incrementCounter(Value, duplicateNodesInGLevel),
	incrementCounter(Value, nodesInGLevel),
	openListSearch(Tail, OldOpenList, NewOpenList, Parent).

% Recursive case
openListSearch([(_, NeighbourState)|Tail], OldOpenList, NewOpenList, Parent) :-
	% if the child state is not on the open closed list then add it to the 
	% open list queue, increment the appropirate counters and move on with the
	% next child state
	not(openAndClosedStates(NeighbourState)),
	assert(openAndClosedStates(NeighbourState)),
	parentOf(_, Parent, GValue),
	Value is GValue + 1,
	assert(parentOf(Parent, NeighbourState, Value)),
	incrementCounter(Value, nodesInGLevel),
    join_queue(NeighbourState, ExpandedOldOpenList, NewOpenList),
    openListSearch(Tail, OldOpenList, ExpandedOldOpenList, Parent).
	
% Base case
generateOutput(CurrentState, CurrentState, InputQueue, OutputQueue, InputStats, OutputStats):-
	% base case is where the inital state is the current state
	% in this state we get the appropirate counters and append it ot the Statistics
	parentOf(_, CurrentState, CurrentGLevel),
	getValueCounter(CurrentGLevel, nodesInGLevel, Nodes),
	getValueCounter(CurrentGLevel, duplicateNodesInGLevel, Dups),
	getValueCounter(CurrentGLevel, expandedNodesInGLevel, Expanded),
	append(InputStats, [stat(CurrentGLevel, Nodes, Dups, Expanded)], OutputStats),
	% join the InputQueue (should still be empty at this point) with the inital state
	% and return the qeueue to the caller
	join_queue(CurrentState, InputQueue, OutputQueue).

% Recursive case
generateOutput(CurrentState, GoalState, InputQueue, OutputQueue, InputStats, OutputStats):-
	% get the appropirate counter values and append to the stats array
	parentOf(Parent, CurrentState, CurrentGLevel),
	getValueCounter(CurrentGLevel, nodesInGLevel, Nodes),
	getValueCounter(CurrentGLevel, duplicateNodesInGLevel, Dups),
	getValueCounter(CurrentGLevel, expandedNodesInGLevel, Expanded),
	% join the input queue with the output from the recursive call and return to caller
	join_queue(CurrentState, ExpandedQueue, OutputQueue),
    generateOutput(Parent, GoalState, InputQueue, ExpandedQueue, InputStats, NewOutputStats),
	append(NewOutputStats, [stat(CurrentGLevel, Nodes, Dups, Expanded)], OutputStats).

	