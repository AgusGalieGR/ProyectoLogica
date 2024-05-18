:- module(proylcc,
	[  
		put/8,
		ganar_juego/3
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

% PONER LOS DOS PARAMETROS RowSat y ColSat EN EL PREDICADO
put(Content, [RowN, ColN], RowsClues, ColsClues, Grid, NewGrid, RowSat, ColSat):-
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
	% INSTANCIAL EL VALOR DE COL SAT
	% INSTANCIAL EL VALOR DE ROW SAT
	% HAY QUE HACER UN PREDICADO QUE OBTENGA LA FILA N
	% UNA VEZ TENGAMOS LA LISTA LLAMAMOS AL PREDICADO QUE YA ESTA DEFINIDO
	obtener_N(NewGrid,RowN,RowToCheck), 
	obtener_N(RowsClues,RowN,CluesToCheck), %HASTA ACA ANDA
	check_lista(RowToCheck,CluesToCheck, RowSat), %No permitir que falle el predicado put

	transpose(NewGrid, GridTranspose), 

	obtener_N(GridTranspose, ColN, ColToCheck),
	obtener_N(ColsClues, ColN, CluesToCheck2),
	check_lista(ColToCheck,CluesToCheck2, ColSat).
	%ganar_juego(RowsClues, ColsClues, NewGrid).

obtener_N([_First|Rest], N, ToCheck):- %Este predicado te da el enesimo elemento de las filas (Ya sea pistas o filas)
	Number is N - 1,
	Number > -1,
	obtener_N(Rest, Number, ToCheck).

obtener_N([First|_Rest], N, ToCheck):-
	N == 0,
	ToCheck = First.

%check_lista(ToCheck,[0|[]], 1).

check_lista([],[], 1).

check_lista([],[Clue|_ResClue], 0):-
	Clue>0.

check_lista([PrimerElemento|_], [], Sat):-
	PrimerElemento == "#",
	Sat is 0.

check_lista([_|RestToCheck], [], Sat):-
	check_lista(RestToCheck, [], Sat).

/*check_lista([],[_Clue|ResClue], 0):-
	ResClue>0.
*/
check_lista(ToCheck,[Clue|ResClues], Sat):-
	check_pista_init(Clue, ToCheck, RestoListaReturn, Status),
	Status == 1,
	check_lista(RestoListaReturn,ResClues, Sat).

check_lista(_,[_|_], 0).

ganar_juego([],[],1).
ganar_juego([0|_],[1|_],0).
ganar_juego([0|_],[0|_],0).
ganar_juego([1|_],[0|_],0).
ganar_juego([1|RestoPistasFilas],[1|RestoPistasColumnas],Resultado):-
	ganar_juego(RestoPistasFilas,RestoPistasColumnas,Resultado).



% LUEGO DE HACER EL PUT EN REACT LLAMAN A UN PREDICADO EN PROLOG "ganar_juego"
% EL PREDICADO VA A RECORRER LAS LISTAS QUE SE ARMARON EN REACT PARA VER SI GANO
/*ganar_juego(RowsClues, ColsClues, NewGrid):-
	verificar_pistas_totales(RowsClues, NewGrid), % Verifico las pistas totales de las filas
	transpose(NewGrid, GridTranspose), % Matriz transpuesta
	verificar_pistas_totales(ColsClues, GridTranspose). % Verifico las pistas totales de las columnas
*/

/*check_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, Status):-
	PrimerElemento \== "#",
	Pista>0,
	check_pista(Pista, RestoLista, RestoListaReturn, Status).
*/
check_pista_init(Clue, [PrimerElemento|RestoLista], RestoListaReturn, Status):-
	PrimerElemento == "#",
	check_pista(Clue, [PrimerElemento|RestoLista], RestoListaReturn, Status).

check_pista_init(Clue, [PrimerElemento|RestoLista], RestoListaReturn, Status):-
	PrimerElemento \== "#",
	check_pista_init(Clue, RestoLista, RestoListaReturn, Status).

check_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, Status):-
	PrimerElemento == "#",
	PistaAux is Pista - 1,
	PistaAux > -1,
	check_pista(PistaAux, RestoLista, RestoListaReturn, Status). % Aca se traba

check_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, Status):-
	PrimerElemento \== "#",
	Pista == 0,
	Status is 1,
	RestoListaReturn = RestoLista.

check_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, Status):-
	PrimerElemento == "#",
	Pista == 0,
	Status is 0,
	RestoListaReturn = RestoLista.




