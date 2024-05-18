:- module(init, [ init/4 ]).

/**
 * init(-RowsClues, -ColsClues, Grid).
 * Predicate specifying the initial grid, which will be shown at the beginning of the game,
 * including the rows and columns clues.
 */

init(
[[3,2], [2,1], [4], [5], [5]],	% RowsClues

[[2], [3], [3], [5], [4]], 	% ColsClues

[["X", _ , _ , _ , _ ], 		
 ["X", _ ,"X", _ , _ ],
 ["X", _ , _ , _ , _ ],		% Grid
 ["#","#","#", _ , _ ],
 [ _ , _ ,"#","#","#"]
],
[0, 0, 0, 0, 0] %RowSat y ColSat
).