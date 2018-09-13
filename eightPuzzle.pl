/* -*-prolog-*- */
:- use_module(library(lists)).

	
/*
goal8(+State)

hGround8(+State, -H)

sameState8(+State, +State)

succ8(+State, -Successors)
*/

/*
8 puzzle state representation
------------------------------
list of 9 elements, each element represents a location
on the puzzle, the first element represents the upper
left-hand location, etc.

the value of element represents which tile is in that
location, the empty location has a value of zero, the
other have the value of the tile at that location

the list [1,3,7,2,4,5,6,0,8] represents the puzzle state:
1 3 7
2 4 5
6   8

the list will have predicates that allow it to be viewed as a
2-dimensional matrix.  The upper left-hand location has the coords
(0,0) and the lower right-hand is (2,2).

contents(State, Tile, Coord).

blankAt(State, Coord)

swap(State, FromCoord, ToCoord, NewState).

*/

goal8([1,2,3,4,5,6,7,8,0]).

hGround8Zero(_, 0).

hGround8Manhattan(State, H) :-
	goal8(GoalState),
	manhattanDist(State, GoalState, 0, H).

manhattanDist([ ], _, H, H).
manhattanDist([Tile | Rest], GoalState, InH, OutH) :-
	(Tile = 0 ->
	    manhattanDist(Rest, GoalState, InH, OutH)
	;
	    length(Rest, InCount),
	    length(GoalState, OrigCount),
	    TileCurLocation is OrigCount - InCount,
	    nth1(TileGoalLocation, GoalState, Tile),
	    count2Coords(TileCurLocation, CurCoords),
	    count2Coords(TileGoalLocation, GoalCoords),
	    manDist(CurCoords, GoalCoords, Dist),
	    NewInH is Dist + InH,
	    manhattanDist(Rest, GoalState, NewInH, OutH)).
	    

manDist((CurX, CurY), (GoalX, GoalY), ManDist) :-
	ManDist is abs(GoalX - CurX) + abs(GoalY - CurY).
		   
sameState8(S, S).

succ8(State, Successors) :-
	findall((1, Neighbor), neighbor8(State, Neighbor), Successors).

neighbor8(State, Neighbor) :-
	blankAt(State, BlankCoord),
	legalNeighbor(BlankCoord, NeighborCoord),
	swap(State, BlankCoord, NeighborCoord, Neighbor).

blankAt(State, Coords) :-
	append(Prefix, [0 | _], State),
	length(Prefix, PrecedingEltsCount),
	count2Coords(PrecedingEltsCount, Coords).

tileAt(State, Coords, Tile) :-
	coords2Count(Coords, Count),
	nth0(Count, State, Tile).

count2Coords(Count, (X, Y)) :-
	X is Count rem 3,
	Y is Count // 3.

coords2Count((X, Y), Count) :-
	Count is X + Y * 3.

legalNeighbor((BlankX, BlankY), (NeighborX, BlankY)) :-
	BlankX > 0,
	NeighborX is BlankX - 1.

legalNeighbor((BlankX, BlankY), (NeighborX, BlankY)) :-
	BlankX < 2,
	NeighborX is BlankX + 1.

legalNeighbor((BlankX, BlankY), (BlankX, NeighborY)) :-
	BlankY > 0,
	NeighborY is BlankY - 1.

legalNeighbor((BlankX, BlankY), (BlankX, NeighborY)) :-
	BlankY < 2,
	NeighborY is BlankY + 1.

swap(State, BlankCoord, NeighborCoord, Neighbor) :-
	coords2Count(BlankCoord, BlankCount),
	coords2Count(NeighborCoord, NeighborCount),
	MinCount is min(BlankCount, NeighborCount),
	MaxCount is max(BlankCount, NeighborCount),
	/* move beginning
	   move MinCount
	   move middle
	   move MaxCount
	   move end
	*/
	length(State, StateSize),
	length(Neighbor, StateSize),
	length(FirstPart, MinCount),
	append(FirstPart, [MinTile | FirstRem], State),
	MidCount is MaxCount - MinCount - 1,
	length(MidPart, MidCount),
	append(MidPart, [MaxTile | LastPart], FirstRem),
	append([FirstPart, [MaxTile], MidPart, [MinTile], LastPart],
	       Neighbor).

solve8(InitialState, Heuristic, Solution) :-
	idastar(InitialState, succ8, goal8, Heuristic, Solution, sameState8).