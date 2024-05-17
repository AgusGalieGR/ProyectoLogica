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

verificar_pistas_totales([], []). % Juego se queda sin pistas y sin fila/col

verificar_pistas_totales(Pistas, Tablero):-
	quedarse_con_primer_lista(Pistas, PrimerPista, RestoPistas), % Me quedo con la primer lista de pistas
	quedarse_con_primer_lista(Tablero, PrimerLista, RestoListas), % Me quedo con la primer fila/columna del tablero
	verificar_pistas(PrimerPista, PrimerLista), % Verifica la primer pista con la primer fila/columna
	verificar_pistas_totales(RestoPistas, RestoListas). % Usando recursion volvemos a revisar las demas pistas con las demas filas/columnas

verificar_pistas([], []). % Juego sin pistas y llego a la ultima cuadricula


verificar_pistas([],Lista):- % Juego sin pistas y quedan cuadriculas
	quedarse_con_primer_elemento(Lista, Cuadricula, RestoElementosListas), % Separamos el primer cuadradito de los demas
	es_pintado([], Cuadricula, RestoElementosListas). % Verificamos si el primer cuadrado es pintado
% Preguntar ambos
verificar_pistas(Pistas, []) :- % Entra si las pistas son mayores a 0 y no queda lista
	Pistas == [].
	%false.

% Hasta aca tiene sentido
verificar_pistas(Pista, Lista):-
	quedarse_con_primer_elemento(Lista, Cuadricula, RestoElementosListas), % Separamos el primer cuadradito de los demas
	es_pintado(Pista, Cuadricula, RestoElementosListas). % Verificamos si el primer cuadrado es pintado

es_pintado([], "#", ListaSinCuadricula):- % Si no quedan pistas y encuentra un # devuelve false
	ListaSinCuadricula == [].
	%false.
es_pintado([], "_", ListaSinCuadricula):- % En cambio sigue leyendo la lista si no es #
	verificar_pistas([], ListaSinCuadricula). % Devuelve la lista sin la cuadricula ya sabiendo que no es pintada

es_pintado([], "X", ListaSinCuadricula):-
	verificar_pistas([], ListaSinCuadricula). % Devuelve la lista sin la cuadricula ya sabiendo que no es pintada
	
es_pintado(Pista, "#", ListaSinCuadricula):-
	quedarse_con_primer_elemento(Pista, PrimerElementoPista, RestoPistas), % Debido a que la pista puede ser doble la separamos
	verificar_pistas_aux(PrimerElementoPista, RestoPistas, ListaSinCuadricula).  % Si es igual verifico si se cumple para todas las pistas contiguas 

es_pintado(Pista, "_", ListaSinCuadricula):-
	verificar_pistas(Pista, ListaSinCuadricula). % Devuelve la lista sin la cuadricula ya sabiendo que no es pintada

es_pintado(Pista, "X", ListaSinCuadricula):-
	verificar_pistas(Pista, ListaSinCuadricula). % Devuelve la lista sin la cuadricula ya sabiendo que no es pintada
	
verificar_pistas_aux([], [], []). % no hay mas pistas ni resto de pistas ni cuadriculas

verificar_pistas_aux([], RestoPista, Lista):-
	verificar_pistas_aux(RestoPista, [], Lista). % Al usar listas de dos elementos en la pista el RestoPista se vuelve la Pista al ser 0 la Pista 
	%verificar_final_pista(RestoPista, RestoLista).

verificar_pistas_aux([], [], Lista):-
	quedarse_con_primer_elemento(Lista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	PrimerElementoLista == "_",
	PrimerElementoLista == "X", % Si es X o _ el sigte entonces es true. 
	verificar_pistas_aux([], [], RestoElementosListas). % Verifica el resto de la lista hasta que sea vacia

verificar_pistas_aux(Pista, [], Lista):-
	quedarse_con_primer_elemento(Lista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	NuevoValor is Pista - 1, % Si no llego a 0 aun, decremento la pista en 1
	% Ahora si el siguiente elemento vuelve a ser un # entonces seguimos hasta que la pista sea 0
	PrimerElementoLista == "#",
	verificar_pistas_aux(NuevoValor, [], RestoElementosListas).

verificar_pistas_aux(Pista, [], []):-
	Pista == [].
	%false. % Corta la ejecucion si siguen habiendo pistas

verificar_pistas_aux(Pista, RestoPista, RestoLista):- 
	quedarse_con_primer_elemento(RestoLista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	%NuevoValor is Pista - 1, % Si no llego a 0 aun, decremento la pista en 1
	% Ahora si el siguiente elemento vuelve a ser un # entonces seguimos hasta que la pista sea 0
	%PrimerElementoLista == "#", %Le molesta esto. % ACA SE TRABA
	verificar(Pista, RestoPista, PrimerElementoLista, RestoElementosListas). % ACA SE TRABA
	%verificar_pistas_aux(NuevoValor, RestoPista, RestoElementosListas).

verificar(Pista, RestoPista, "#", RestoElementosListas):-
	NuevoValor is Pista - 1,
	verificar_pistas_aux(NuevoValor, RestoPista, RestoElementosListas).

% Tal vez aca deberia guardar y pasar la pista original junto con la lista original.
verificar(Pista, RestoPista, "X", RestoElementosListas):-
	Pista == [],
	RestoPista == [].

verificar(Pista, RestoPista, "_", RestoElementosListas):-
	Pista == [],
	RestoPista == [].

%Cambiar
verificar_final_pista(RestoPista, RestoLista):-
	quedarse_con_primer_elemento(RestoLista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	(	PrimerElementoLista == "#" -> false
		;
		verificar_pistas(RestoPista, RestoElementosListas)
	).
	% En el caso de que no sea # el siguiente, devuelve false


%es_pintado(Pista, Cuadricula, RestoPista, RestoLista):-	
	%(   Cuadricula == "#" -> verificar_pistas_aux(Pista, RestoPista, RestoLista) % Si es igual verifico si se cumple para todas las pistas contiguas 
    %;   verificar_pistas([Pista|RestoPista], RestoLista) % Si es diferente a # pasamos a verificar la prox cuadricula
	%).

/*verificar_pistas_aux([], [], []).

verificar_pistas_aux(Pista, RestoPista, RestoLista):-
	quedarse_con_primer_elemento(RestoLista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	
	(	Pista == 0 -> verificar_final_pista(RestoPista, RestoLista) % Si llega a 0 la pista da true y corta ahi
		; 
		NuevoValor is Pista - 1), % Si no llego a 0 aun, decremento la pista en 1
	% Ahora si el siguiente elemento vuelve a ser un # entonces seguimos hasta que la pista sea 0
	(	PrimerElementoLista == "#" -> verificar_pistas_aux(NuevoValor, RestoPista, RestoElementosListas)
		;
		verificar_pistas_aux(Pista, RestoPista, RestoElementosListas)).
	% En el caso de que no sea # el siguiente, devuelve false

verificar_final_pista(RestoPista, RestoLista):-
	quedarse_con_primer_elemento(RestoLista, PrimerElementoLista, RestoElementosListas), % Separamos el primer cuadradito de los demas
	(	PrimerElementoLista == "#" -> false
		;
		verificar_pistas(RestoPista, RestoElementosListas)
	).
*/
% Caso base: si la lista de listas está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_lista([], [], []).

% Caso recursivo: dividir la lista de listas en el primer elemento y el resto.
quedarse_con_primer_lista([PrimeraLista|RestoListas], PrimeraLista, RestoListas).

% Caso base: si la lista está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_elemento([], [], []).

% Caso recursivo: dividir la lista en el primer elemento y el resto.
quedarse_con_primer_elemento([PrimerElemento|RestoElementos], PrimerElemento, RestoElementos).
