:- module(proylcc,
	[  
		put/9
		%gameStatus/3
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

put(Content, [RowN, ColN], _RowsClues, _ColsClues, Grid, NewGrid, 0, 0, Status):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)).
	ganar_juego(RowsClues, ColsClues, NewGrid).

ganar_juego(RowsClues, ColsClues, NewGrid):-
	verificar_pistas_totales(RowsClues, NewGrid),
	transpose(NewGrid, GridTranspose),
	verificar_pistas_totales(ColsClues, GridTranspose).

verificar_pistas_totales(Pistas, Tablero):-
	quedarse_con_primer_lista(Pistas, PrimerPista, RestoPistas),
	quedarse_con_primer_lista(Tablero, PrimerLista, RestoListas),
	verificar_pistas(PrimerPista, PrimerLista).


verificar_pistas(Pista, Lista):-
	quedarse_con_primer_elemento(Pista, PrimerElementoPista, RestoElementosPistas),
	quedarse_con_primer_elemento(Lista, PrimerElementoLista, RestoElementosListas),
	es_pintado(PrimerElementoPista, PrimerElementoLista, RestoElementosPistas, RestoElementosListas).
es_pintado(Pista, Elemento, RestoPistas, RestoElementos):-
	(   Elemento =\= "#" ->
        verificar_pistas(Pista, RestoElementos) % Descartamos el elemento que no nos sirve
    ;   % Si si nos sirve:
		Pista = Pista - 1,
		(   Pista =\= 0 -> 
			% Si no es 0, seguimos con la misma pista 
        	verificar_pistas(Pista, RestoElementos) % Descartamos el elemento que no nos sirve
    	;   % Si es 0, nos movemos a la otra pista:
			verificar_pistas(RestoPistas, RestoElementos)
		).
	).
% Creo que me falta el caso en el que no sea contiguo o que si lo sea 

% Caso base: si la lista de listas está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_lista([], [], []).

% Caso recursivo: dividir la lista de listas en el primer elemento y el resto.
quedarse_con_primer_lista([PrimeraLista|RestoListas], PrimeraLista, RestoListas).

% Caso base: si la lista está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_elemento([], [], []).

% Caso recursivo: dividir la lista en el primer elemento y el resto.
quedarse_con_primer_elemento([PrimerElemento|RestoElementos], PrimerElemento, RestoElementos).

/*
ganar_juego(PistasFila, Tablero, Status):- 
	recursiva(PistasFila, Tablero, Status).

recursiva([],[], Status):-
	Status = true.
recursiva(PF,T, Status):-
	quedarse_con_primer_lista(T, FilaN, RestoT), % Lee y guarda la Fila N del tablero
	quedarse_con_primer_elemento(PF, PistaFilaN, RestoPista), % Lee y guarda la Pista N de las pistas
	primer_contador(PistaFilaN, FilaN, RestoT, RestoPista, Status). % Ahora das la fila y la pista de la fila N

primer_contador([], [], [], [],  _).
primer_contador(PFb,[],RestoT, RestoPista, Status):-
	segundo_contador(PFb, RestoT, RestoPista, Status). % Pasamos solo la pista y la lista de filasvamos a utilizar la listaFilas para contar
primer_contador(PFa,F, RestoT, RestoPista, Status):-
	nth0(0, F, Contenido), % Guardamos el contenido del elemento N en la fila
	assert(listaP(Contenido)), % A medida de que va pasando por contenido los va guardando
	quedarse_con_primer_elemento(F, _, RestoF),  % Separamos el primer elemento de F del resto
	primer_contador(PFa, RestoF, RestoT, RestoPista, Status). % Vuelve a guardar el contenido pero esta vez de la segunda cuadrilla

segundo_contador([], [], [], _).
segundo_contador(PFc, RestoT, RestoPista, Status):- % Predicado no recursivo para verificar si la cantidad de pistas es igual 
	contar_pintados(Cantidad),
	%length(list, Longitud),
	retractall(listaP),
	(   Cantidad =\= PFc ->
        Status = false
        %fail % Fallar para terminar el recorrido
    ;   recursiva(RestoPista, RestoT, Status) % Llamamos recursiva para el resto de las pistas y tablero
	).

contar_pintados(Cantidad):-
    findall(Contenido, listaP(Contenido), ListaXd), % Aquí listaP es el predicado que contiene la lista
    count('#', ListaXd, Cantidad).



:- dynamic listaP/1.

agregar_elemento(Contenido) :-
	assert(listaP(Contenido)).

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
*/



