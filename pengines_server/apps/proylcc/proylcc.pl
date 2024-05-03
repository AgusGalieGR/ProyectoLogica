:- module(proylcc,
	[  
		put/9
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
	
ganar_juego(PistasFila, Tablero):-
	primer_contador(PistasFila, Tablero).

recursiva():-
	writeln('¡Felicidades! Has ganado el juego.').
recursiva(PF,T):-
	quedarse_con_primer_lista(T, FilaN, RestoFila), 
	quedarse_con_primer_elemento(PF, PistaFilaN, RestoPista),
	primer_contador(PistaFilaN, FilaN, RestoFila, RestoPista), % Ahora das la fila y la pista de la fila N

primer_contador(PFa,F, RestoFila, RestoPista):-
	contador(0). % Iniciar el contador desde 0
	contador(N) :-
		nth0(N, F, Contenido),  %Guardamos el contenido del elemento N en la fila
		agregar_elemento(Contenido), % A medida de que va pasando por contenido los va guardando
		% Ahora queria poner tipo un if que compare PFa con contenido (Osea que verifique si hay esa cantidad de  '#')
		if(N == length(F), segundo_contador(PFa, F, RestoFila, RestoPista)). % Osea si llegamos al ultimo cuadradito solo entra al if
		NuevoN is N + 1,   % Incrementa el contador
		contador(NuevoN).  % Llama recursivamente al contador con el nuevo valor	
		% Ahora tengo que ver si la cantidad de pintados es igual a la cant de pistas. 


segundo_contador(PFb, Fila, RestoFila, RestoPista):-
	contador(0, 0). % Iniciar el contador desde 0
	contador(N, Cont) :-
		nth0(N, listaFilas, Content).
		quitar_elemento(Content),
		if(Content == '#', NuevoCont is Cont + 1).
		if(N == length(Fila), if(PFb == NuevoCont, recursiva(RestoFila, RestoPista))). %Che que hacemos, le pongo algo que sea true?
		NuevoN is N + 1,   % Incrementa el contador
		contador(NuevoN, NuevoCont).

if(Condicion, Entonces) :-
	Condicion, 
	!,
	Entonces.

:- dynamic listaFilas/1.

agregar_elemento(Contenido) :-
	assert(listaFilas(Contenido)).

quitar_elemento(Content) :-
	retract(listaFilas(Content)).

% Caso base: si la lista de listas está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_lista([], [], []).

% Caso recursivo: dividir la lista de listas en el primer elemento y el resto.
quedarse_con_primer_lista([PrimeraLista|RestoListas], PrimeraLista, RestoListas).

% Caso base: si la lista está vacía, el primer elemento y el resto son ambos vacíos.
quedarse_con_primer_elemento([], [], []).

% Caso recursivo: dividir la lista en el primer elemento y el resto.
quedarse_con_primer_elemento([PrimerElemento|RestoElementos], PrimerElemento, RestoElementos).
