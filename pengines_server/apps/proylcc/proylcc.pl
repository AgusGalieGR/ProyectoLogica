:- module(proylcc,
	[  
		%verificar_pre/6, 
		ganar_anticipado/5,
		put/8,
		ganar_juego/3,
		show/3
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
ganar_anticipado(Grid, [RowN, ColN], RowsClues, ColsClues, Status):- %Comienzo
	ganar_anticipado2(Grid, RowN, RowsClues, 1), %Pasan filas
	
	transpose(Grid, GridTranspose), 

	ganar_anticipado2(GridTranspose, ColN, ColsClues, 1), %Pasan cols
	Status is 1.
	
ganar_anticipado2(Grid, RowN, RowsClues, Status):-
	RowN<4,
	obtener_N(Grid, RowN, RowToCheck), 
	obtener_N(RowsClues, RowN, CluesToCheck),
	check_lista(RowToCheck, CluesToCheck, 1).
	%NewRowN is RowN+1,
	%ganar_anticipado2(Grid, NewRowN, RowsClues, Status).

/*ganar_anticipado2(Grid, RowN, RowsClues, Status):- %Final bueno filas
	obtener_N(Grid, RowN, RowToCheck), 
	obtener_N(RowsClues, RowN, CluesToCheck),
	check_lista(RowToCheck, CluesToCheck, Status),
	Status is 1.	
*/
ganar_anticipado2(Grid, RowN, RowsClues, Status):- %Final bueno filas
	obtener_N(Grid, RowN, RowToCheck), 
	obtener_N(RowsClues, RowN, CluesToCheck),
	check_lista(RowToCheck, CluesToCheck, 0),
	Status is 0,
	ganar_anticipado2(Grid, RowN, RowsClues, 0).

ganar_anticipado2(_, _, _, 0).


show([RowN, ColN], GridAux, Content):-
	obtener_N(GridAux, RowN, RowToCheck),
	%transpose(GridAux, GridAuxTranspose),
	%obtener_N(GridAuxTranspose, ColN, ColToCheck),
	encontrar(RowToCheck, ColN, NewContent),
	Content = NewContent.

encontrar([_PrimerElemento|Resto], N, NContent):-
	Number is N - 1,
	Number > -1,
	encontrar(Resto, Number, NContent).
encontrar([PrimerElemento|_Resto], N, NContent):-
	N == 0,
	NContent = PrimerElemento.

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
	obtener_N(NewGrid, RowN, RowToCheck), 
	obtener_N(RowsClues, RowN, CluesToCheck),
	check_lista(RowToCheck, CluesToCheck, RowSat),

	transpose(NewGrid, GridTranspose), 

	obtener_N(GridTranspose, ColN, ColToCheck),
	obtener_N(ColsClues, ColN, CluesToCheck2),
	check_lista(ColToCheck,CluesToCheck2, ColSat).

obtener_N([_First|Rest], N, ToCheck):- %Este predicado te da el enesimo elemento de las filas (Ya sea pistas o filas)
	Number is N - 1,
	Number > -1,
	obtener_N(Rest, Number, ToCheck).

obtener_N([First|_Rest], N, ToCheck):-
	N == 0,
	ToCheck = First.


check_lista([],[], 1).

check_lista([],[Clue|_ResClue], 0):-
	Clue>0.

check_lista([PrimerElemento|_], [], Sat):-
	PrimerElemento == "#",
	Sat is 0.

check_lista([_|RestToCheck], [], Sat):-
	check_lista(RestToCheck, [], Sat).

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

check_pista(Pista, [], _, Status):-
	Pista == 0,
	Status is 1.

sol_linea(ListaFoC, Pista, LS):-
	crear_lista_sol_FoC(ListaFoC, Pista, LS).


crear_lista_sol_FoC([],[], _).

crear_lista_sol_FoC([PrimerElemento|[]], [], [ListaSolucion|"X"]):-
	PrimerElemento \== "#".

crear_lista_sol_FoC([PrimerElemento|RestToCheck], [], [ListaSolucion|"X"]):-
	PrimerElemento \== "#",
	crear_lista_sol_FoC(RestToCheck, [], ListaSolucion).

crear_lista_sol_FoC([_|RestToCheck], [], ListaSolucion):-
	change_pista(0, RestToCheck, RestoDeResto, ListaSolucion),
	crear_lista_sol_FoC(RestoDeResto, [], ListaSolucion).

crear_lista_sol_FoC(ToCheck,[Clue|ResClues], ListaARetornar):-
	change_pista_init(Clue, ToCheck, RestoListaReturn, ListaSol),
	my_append(ListaSol, ListaSolucion, ListaARetornar),
	crear_lista_sol_FoC(RestoListaReturn,ResClues, ListaSolucion).

my_append([], Cs, Cs).
my_append([A|As],Bs, [A|Cs]):-
	my_append(As,Bs,Cs).
crear_lista_sol_FoC(_,[_|_]).

change_pista_init(Clue, [PrimerElemento|RestoLista], RestoListaReturn, ListaSolucion):-
	PrimerElemento == "#",
	NewClue is Clue-1,
	my_append(ListaSolucion, ["#"], LS),
	change_pista(NewClue, RestoLista, RestoListaReturn, LS).

change_pista_init(Clue, [PrimerElemento|RestoLista], RestoListaReturn, [ListaSolucion|"#"]):-
	PrimerElemento \== "#",
	PrimerElemento \== "X",
	NewClue is Clue-1,
	NewClue > -1,
	change_pista(NewClue, RestoLista, RestoListaReturn, ListaSolucion).

change_pista_init(Clue, [PrimerElemento|RestoLista], RestoListaReturn, [ListaSolucion|"X"]):-
	PrimerElemento \== "#",
	PrimerElemento \== "X",
	change_pista(Clue, RestoLista, RestoListaReturn, ListaSolucion).

change_pista_init(Clue, [PrimerElemento|RestoLista], RestoListaReturn, [ListaSolucion|"X"]):-
	PrimerElemento == "X",
	change_pista(Clue, RestoLista, RestoListaReturn, ListaSolucion).

change_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, [ListaSolucion|"#"]):-
	PrimerElemento == "#",
	PistaAux is Pista - 1,
	PistaAux > -1,
	change_pista(PistaAux, RestoLista, RestoListaReturn, ListaSolucion). 

change_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, [ListaSolucion|"X"]):-
	PrimerElemento == "X",
	change_pista(Pista, RestoLista, RestoListaReturn, ListaSolucion). 

change_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, [ListaSolucion|"#"]):-
	PrimerElemento \== "#",
	PrimerElemento \== "X",
	NewClue is Pista-1,
	NewClue > -1,
	change_pista(NewClue, RestoLista, RestoListaReturn, ListaSolucion).


change_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, [_|"X"]):-
	PrimerElemento \== "#",
	PrimerElemento \== "X",
	Pista == 0,
	RestoListaReturn = RestoLista.	

change_pista(Pista, [PrimerElemento|RestoLista], RestoListaReturn, [_|"X"]):-
	PrimerElemento == "X",
	Pista == 0,
	RestoListaReturn = RestoLista.	

change_pista(Pista, [], _, _):-
	Pista == 0.



