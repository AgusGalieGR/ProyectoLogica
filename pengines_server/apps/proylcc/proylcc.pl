:- module(proylcc,
	[  
		put/8
		%gameStatus/3
	]).

:-use_module(library(lists)).
:- use_module(library(clpfd)).
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

put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, 0, 0):-
	% NewGrid is the result of replacing the row Row in position RowN of Grid by a new row NewRow (not yet instantiated).
	replace(Row, RowN, NewRow, Grid, NewGrid),

	% NewRow is the result of replacing the cell Cell in position ColN of Row by _,
	% if Cell matches Content (Cell is instantiated in the call to replace/5).	
	% Otherwise (;)
	% NewRow is the result of replacing the cell in position ColN of Row by Content (no matter its content: _Cell).			
	(replace(Cell, ColN, _, Row, NewRow),
	Cell == Content
		;
	replace(_Cell, ColN, Content, Row, NewRow)
	),
	ganar_juego(RowsClues, ColsClues, NewGrid).

ganar_juego(RowsClues, ColsClues, NewGrid):-
	verificar_pistas_totales(RowsClues, NewGrid), % Verifico las pistas totales de las filas
	transpose(NewGrid, GridTranspose), % Matriz transpuesta
	verificar_pistas_totales(ColsClues, GridTranspose). % Verifico las pistas totales de las columnas

verificar_pistas_totales([], []).

verificar_pistas_totales(Pistas, Tablero):-
	quedarse_con_primer_lista(Pistas, PrimerPista, RestoPistas), % Me quedo con la primer lista de pistas
	quedarse_con_primer_lista(Tablero, PrimerLista, RestoListas), % Me quedo con la primer fila/columna del tablero
	verificar_pistas(PrimerPista, PrimerLista), % Verifica la primer pista con la primer fila/columna
	verificar_pistas_totales(RestoPistas, RestoListas). % Usando recursion volvemos a revisar las demas pistas con las demas filas/columnas

verificar_pistas([], []).

verificar_pistas(Pista, []):-
	fail.
verificar_pistas(Pista, Lista):-
	quedarse_con_primer_elemento(Pista, PrimerElementoPista, RestoElementosPistas), % Debido a que la pista puede ser doble la separamos
	quedarse_con_primer_elemento(Lista, Cuadricula, RestoElementosListas), % Separamos el primer cuadradito de los demas
	es_pintado(PrimerElementoPista, Cuadricula, RestoElementosPistas, RestoElementosListas). % Verificamos si el primer cuadrado es pintado

es_pintado(Pista, Cuadricula, RestoPista, RestoLista):-
	(   Cuadricula == "#" -> verificar_pistas_aux(Pista, RestoPista, RestoLista) % Si es igual verifico si se cumple para todas las pistas contiguas 
    ;   verificar_pistas([Pista|RestoPista], RestoLista) % Si es diferente a # pasamos a verificar la prox cuadricula
	).

verificar_pistas_aux([], [], []).

verificar_pistas_aux(Pista, RestoPista, RestoLista):-
	quedarse_con_primer_elemento(RestoLista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	
	(	Pista == 0 -> verificar_final_pista(RestoPista, RestoLista) % Si llega a 0 la pista da true y corta ahi
		; 
		NuevoValor is Pista - 1), % Si no llego a 0 aun, decremento la pista en 1
	% Ahora si el siguiente elemento vuelve a ser un # entonces seguimos hasta que la pista sea 0
	(	PrimerElementoLista == "#" -> verificar_pistas_aux(NuevoValor, RestoPista, RestoElementosListas); false).
	% En el caso de que no sea # el siguiente, devuelve false

verificar_final_pista(RestoPista, RestoLista):-
	quedarse_con_primer_elemento(RestoLista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	(	PrimerElementoLista == "#" -> false
		;
		verificar_pistas(RestoPista, RestoElementosListas)
	).

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



