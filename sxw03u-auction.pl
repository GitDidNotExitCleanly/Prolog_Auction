auction(Is,Bs,Ss) :-
	pickBestSubset(Bs,Ss),	% extension 1 - maximise return 
	isNotRepeated(Ss),			% extension 2 - multiple bids
	isSoldOut(Is,Ss).		
		
%% find all subsets of one set , in the order of total return	
pickBestSubset(Xs,BestSubset) :-
	bagof(Ys,isASubset(Xs,Ys),Xss),
	select([],Xss,Yss),
	mergeSort(Yss,Zss),		
	maxReturn(Zss,BestSubset).
	
	% is an element one of the subsets?
	% e.g. isASubset([item(a,10)],[]) or ([item(a,10)],[item(a,10)])
isASubset([], []).
isASubset([X|Xs], [X|Ys]):-
  isASubset(Xs, Ys).
isASubset([_|Xs], Ys):-
  isASubset(Xs, Ys).

	% mergeSort , in the order of total return
	% e.g. mergeSort([[],[bid(_,_,10)]],[[bid(_,_,10)],[]])
mergeSort([],[]).
mergeSort([X],[X]).
mergeSort([X,Y|Xs],Ys) :-
	divide([X,Y|Xs],L,R),mergeSort(L,Ls),mergeSort(R,Rs),merge(Ls,Rs,Ys).

divide([],[],[]).
divide([X],[X],[]).
divide([Y,Z|Xs],[Y|Ys],[Z|Zs]) :-
	divide(Xs,Ys,Zs).

merge([],[],[]).
merge([],Ys,Ys).
merge(Xs,[],Xs).
merge([X|Xs],[Y|Ys],[X|Zs]) :-
	sum(X,N1),sum(Y,N2),N1 >= N2,!,
	merge(Xs,[Y|Ys],Zs).
merge([X|Xs],[Y|Ys],[Y|Zs]) :-
	sum(X,N1),sum(Y,N2),N1 < N2,!,
	merge([X|Xs],Ys,Zs).

	% sum of a list of bids 
	% e.g. sum([bid(_,_,100),bid(_,_,20)],120)
sum([],0).	
sum([bid(_,_,X)|Xs],Y) :-
	sum(Xs,Z),
	Y is X+Z.

	% based on a sorted list, return the head of the list
	% e.g. maxReturn([[bid(_,_,10)],[bid(_,_,5)],[]],[bid(_,_,10)])
maxReturn([],[]).
maxReturn([Xs|_],Xs).
maxReturn([_|Xss],Ys) :-
	maxReturn(Xss,Ys).
	
%% check whether result has same buyer
isNotRepeated([]).
isNotRepeated([bid(_,_,_)]).
isNotRepeated([bid(X,_,_),bid(Y,_,_)|Xs]) :-
	X \= Y,
	isNotRepeated([bid(Y,_,_)|Xs]).	  
  
%% check whether the sum of all elements in Ss is equal to Is
isSoldOut([I|Is],[S|Ss]) :-
	sum([I|Is],[S|Ss],Ls),
	permutation([I|Is],Ls).

	% take a list of items and a list of bids , get totoal sum
	% result : [item(a,0),item(b,5),item(c,10)...]
sum([],_,[]).
sum([item(X,_)|Xs],[bid(_,[item(Y,Z)|Ys],_)|Zs],[S|Ss]) :-
	sumOfOneItemInAllBids(item(X,_),[bid(_,[item(Y,Z)|Ys],_)|Zs],S),
	sum(Xs,[bid(_,[item(Y,Z)|Ys],_)|Zs],Ss).
	
	% take one item and a list of bids , get sum of this type in this list
	% result : item(a,10),no bid -> item(a,0)
sumOfOneItemInAllBids(item(X,_),[],item(X,0)).	
sumOfOneItemInAllBids(item(X,_),[bid(_,[item(Y,Z)|Xs],_)|Ys],item(X,N)) :-
	sumOfOneItemInOneBid(item(X,_),bid(_,[item(Y,Z)|Xs],_),item(X,N1)),
	sumOfOneItemInAllBids(item(X,_),Ys,item(X,N2)),
	N is N1+N2.
	
	% take one item type and one bid , get sum of this type in this bid
	% result : buy 5 of item a -> item(a,5) , no item in bid -> item(a,0)	
sumOfOneItemInOneBid(item(X,_),bid(_,[],_),S):-
	S = item(X,0).
sumOfOneItemInOneBid(item(X,_),bid(_,[item(X,Y)|_],_),S):-
	S = item(X,Y).
sumOfOneItemInOneBid(item(X,_),bid(_,[item(Y,_)|Xs],_),S) :-
	X \= Y,
	sumOfOneItemInOneBid(item(X,_),bid(_,Xs,_),S).