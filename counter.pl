/* -*-prolog-*- */

:- dynamic count/3.

/*
counter predicates
====================

count(Index, Type, Count):

Index is basically the key used to access the counter.
Type allows us to distinguish between different types of counters.
Count is the count.

ex.:
count(3, gvalue, 5) could be saying that 5 nodes were generated with a
gvalue  of 3.

count(2, expanded, 7) could be used to say that that there were 2
nodes expanded with a gvalue of 2.

examples of use:
- To add addend to counter:
addToCounter(+Index, +Type, +Addend)

- To create a counter (with an initial value of 0)
initialiseCounter(Index, Type)

- To increment (add 1 to) a counter
    (if counter doesn't exist then create it)
incrementCounter(Index, Type)

- To add an arbitrary amount to a counter
    (if counter doesn't exist then create it)
addToCounter(Index, Type, Addend)

- To decrement (subtract 1 from) a counter
    (if count becomes 0 then counter is removed)
decrementCounter(Index, Type)

- To get a the value of a counter (if no counter exists then binds
Value  to 0)
getValueCounter(+Index, +Type, -Value)


- To remove all counters with a certain id
removeCounter(Index, Type)
*/

removeCounter(Index, Type) :-
	retractall(counter(Index, Type, _)).

initialiseCounter(Index, Type) :-
	removeCounter(Index, Type),
	assert(counter(Index, Type, 0)).

incrementCounter(Index, Type) :-
	(retract(counter(Index, Type, N))
	->
	    NewCount is N + 1,
	    assert(counter(Index, Type, NewCount))
	;
	    assert(counter(Index, Type, 1))).

addToCounter(Index, Type, Addend) :-
	(retract(counter(Index, Type, N))
	->
	    NewCount is N + Addend,
	    assert(counter(Index, Type, NewCount))
	;
	    assert(counter(Index, Type, Addend))).

decrementCounter(Index, Type) :-
    retract(counter(Index, Type, N)),
    NewCount is N - 1,
    (NewCount > 0
    ->
	assert(counter(Index, Type, NewCount))
    ;   true).

getValueCounter(Index, Type, Value) :-
    (counter(Index, Type, Value) ->
	 true
    ;    Value = 0).
    
