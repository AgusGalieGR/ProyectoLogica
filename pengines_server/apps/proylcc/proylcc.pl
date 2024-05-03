:- module(proylcc,
	[  
		put/8
	]).

:-use_module(library(lists)).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% replace(?X, +XIndex, +Y, +Xs, -XsY)
%
% XsY is the result of replacing the occurrence of X in position XIndex of Xs by Y.

replace(X, 0, Y, [X|Xs], [Y|Xs]).

replace(X, XIndex, Y, [Xi|Xs], [Xi|XsY]):-
    XIndex > 0,
    XIndexS is XIndex - 1,
    replace(X, XIndexS, Y, Xs, XsY).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% put(+Content, +Pos, +RowsClues, +ColsClues, +Grid, -NewGrid, -RowSat, -ColSat).
%

put(Content, [RowN, ColN], RowsClues, _ColsClues, Grid, NewGrid, 0, 0):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)),
	ganar_juego(RowsClues, NewGrid).
	
ganar_juego(PistasFila, Tablero):-
	primer_contador(PistasFila, Tablero).

recursiva([],[]):-
	writeln('¡Felicidades! Has ganado el juego.').
recursiva(PF,T):-
	quedarse_con_primer_lista(T, FilaN, RestoT), % Lee y guarda la Fila N del tablero
	quedarse_con_primer_elemento(PF, PistaFilaN, RestoPista), % Lee y guarda la Pista N de las pistas
	primer_contador(PistaFilaN, FilaN), % Ahora das la fila y la pista de la fila N
	recursiva(RestoPista, RestoT).

primer_contador(PFb,[]):-
	segundo_contador(PFb). % Pasamos solo la pista y la lista de filasvamos a utilizar la listaFilas para contar
primer_contador(PFa,F):-
	nth0(0, F, Contenido), % Guardamos el contenido del elemento N en la fila
	agregar_elemento(Contenido), % A medida de que va pasando por contenido los va guardando
	quedarse_con_primer_elemento(F, _, RestoF),  % Separamos el primer elemento de F del resto
	primer_contador(PFa, RestoF). % Vuelve a guardar el contenido pero esta vez de la segunda cuadrilla

segundo_contador(PFc):- % Predicado no recursivo para verificar si la cantidad de pistas es igual 
	contar_pintados(Cantidad),
	quitar_todos_elementos(listaFilas),
	(   Cantidad =\= PFc ->
		write('La cantidad de celdas pintadas no coincide con PFc.'),
		nl,
		fail % Fallar para terminar el recorrido
	;   true % Si la condición es verdadera, continuar
	).

contar_pintados(Cantidad):-% Predicado utilizado para contar la cantidad de # en listaFilas 
	listaFilas(Lista),
    count('#', Lista, Cantidad).


quitar_todos_elementos([]).

quitar_todos_elementos(Lista):- % Predicado recursivo utilizado para vaciar la listaFilas una vez que fue usada
	quedarse_con_primer_elemento(Lista, PrimerElemento, RestoLista),
	quitar_elemento(PrimerElemento),
	quitar_todos_elementos(RestoLista).


:- dynamic listaFilas/1.

agregar_elemento(Contenido) :-
	assert(listaFilas(Contenido)).

quitar_elemento(Contenido) :-
	retract(listaFilas(Contenido)).

% Caso base: si la lista de listas está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_lista([], [], []).

% Caso recursivo: dividir la lista de listas en el primer elemento y el resto.
quedarse_con_primer_lista([PrimeraLista|RestoListas], PrimeraLista, RestoListas).

% Caso base: si la lista está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_elemento([], [], []).

% Caso recursivo: dividir la lista en el primer elemento y el resto.
quedarse_con_primer_elemento([PrimerElemento|RestoElementos], PrimerElemento, RestoElementos).

% Predicado que cuenta las ocurrencias de un elemento en una lista
count(_, [], 0).
count(X, [X|T], N) :-
    count(X, T, N1),
    N is N1 + 1.
count(X, [_|T], N) :-
    count(X, T, N).