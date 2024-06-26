import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';
import BoardSolution from './BoardSolution';

let pengine;

function Game() {

  // State
  const [grid, setGrid] = useState(null);
  const [gridAux, setGridAux] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [rowsSat, setRowsSat] = useState(null);
  const [colsSat, setColsSat] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [resultado, setResultado] = useState(null);
  const [completar, setCompletar] = useState(false);

  //const [status, setStatus] = useState(false);
  var content;
  const [pintar, setPintar] = useState(true);
  const [revelar, setRevelar] = useState(false);

  useEffect(() => {
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
  }, []);

  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid, GridAux, Sat)';
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setGridAux(response['GridAux']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setRowsSat(response['Sat']); //HAY QUE CAMBIARLO
        setColsSat(response['Sat']); //HAY QUE CAMBIARLO
        //setPintar(true);
        //setContent2('#');


      }
      
    });
    
  }
  useEffect(() => {
    if(rowsClues && colsClues){
      funcionNueva(0,0);
      
    }
  }, [rowsClues, colsClues]);

  function funcionNueva(i,j){
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    const queryS2 = `ganar_anticipado(${squaresS}, [${i},${j}], ${rowsCluesS}, ${colsCluesS}, Status)`;
    pengine.query(queryS2, (success, response) => {
        if(success){
          setResultado(response['Status']);   
          if(response['Status']){
            let newRowsSat = [1,1,1,1,1]; // Crea una copia del estado actual
            let newColsSat = [1,1,1,1,1];
            setRowsSat(newRowsSat);
            setColsSat(newColsSat); 
          }
        }
    });
  }
  
  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting) {
      return;
    }
      // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    
    //content = '#';
    if(revelar){
      funcionRevelar(i,j, rowsCluesS, colsCluesS, squaresS);
      
    }else{
      if(!pintar){
        content = "X";
      }else{
        content = "#";
      }
      put(i, j, content, rowsCluesS, colsCluesS, squaresS);
    }
    const RowSatS = JSON.stringify(rowsSat);
    const ColSatS = JSON.stringify(colsSat);
    const queryS2 = `ganar_juego(${RowSatS}, ${ColSatS}, Resultado)`;
    setWaiting(true);
    //cambiar_pistas_col(ColSatS);
    pengine.query(queryS2, (success, response) => {
      if (success) {
        setResultado(response['Resultado']);

      }
      setWaiting(false);
    });

    function funcionRevelar(i,j, colsCluesS, rowsCluesS, squaresS){
      const squaresAux = JSON.stringify(gridAux).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
      const queryContent = `show([${i},${j}], ${squaresAux}, ContentAux)`; // queryS = put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
      setWaiting(true);
      pengine.query(queryContent, (success, response) => {
        if (success) {
          content = response['ContentAux'];
          /*if(contentAux == "#"){
            setPintar(true);
          }else{
            setPintar(false);
          }*/
        }
        setWaiting(false);

        put(i, j, content, colsCluesS, rowsCluesS, squaresS); 
      });
      
    }
  }

  function put(i, j, content, rowsCluesS, colsCluesS, squaresS){
    const queryS = `put("${content}", [${i},${j}], ${rowsCluesS}, ${colsCluesS}, ${squaresS}, ResGrid, RowSat, ColSat)`; // queryS = put("#",[0,1],[], [],[["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]], GrillaRes, FilaSat, ColSat)
        setWaiting(true);
        
        pengine.query(queryS, (success, response) => {
          if (success) {
            setGrid(response['ResGrid']);
            //
            // 
            // TOMAR LOS VALORES DE COLSAT Y ROWSAT Y ACTUALIZAR LAS LISTAS DE REACT
            let newRowsSat = [...rowsSat]; // Crea una copia del estado actual
            let newColsSat =[...colsSat]; // Crea una copia del estado actual
            let RSat = response['RowSat']; // Actualiza la fila específica
            let CSat = response['ColSat']; // Actualiza la col específica

            newRowsSat[i] = RSat;
            newColsSat[j] = CSat;

            setRowsSat(newRowsSat);
            setColsSat(newColsSat);
            
            //colsClues[0].style.backgroundColor = "green";
          }
          setWaiting(false);
        });
  }
  if (!grid) {
    return null;
  }
  var cambio = document.getElementById('cambio');
  if(cambio != null){
    
      cambio.addEventListener('click', () => {
      cambioDeEstado();
    });
  }

  function cambioDeEstado(){
    setRevelar(false);
    if(pintar){
      setPintar(false);
    }else{
      setPintar(true);
    }
  }

  var solucion = document.getElementById('solucion');
  if(solucion != null){
    
    solucion.addEventListener('click', () => {
      cambioDeGrilla();
    });
  }

  function cambioDeGrilla(){
    if(!completar){
      setCompletar(true);
    }else{
      setCompletar(false);
      
    }
  }

  var solucion_especifica = document.getElementById('solucion-especifica');
  if(solucion_especifica != null){
    
    solucion_especifica.addEventListener('click', () => {
      revelarCelda();
    });
  }

  function revelarCelda(){
    if(revelar){
      setRevelar(false);
    }else{
      setRevelar(true);
    } 
  }
  let statusText;
  if (pintar) {
    statusText = '#';
  } else {
    statusText = 'X';
  }
  let texto;
  if(resultado){
    texto = "Felicidades, Ganaste!";
  }else{
    texto = "Segui jugando!";
  }
  return (
    <div className="game">
      <div className='boards'>
        <div className='boardOG'>
          <Board
            grid={grid}
            rowsClues={rowsClues}
            colsClues={colsClues}
            rowsSat = {rowsSat}
            colsSat = {colsSat}
            onClick={(i, j) => handleClick(i, j)}
            
          />
        </div>
        <div className={completar ? 'boardSolutionActivo' : 'boardSolutionInactivo'}> 
          <BoardSolution
            grid={gridAux}
            
          />
        </div>


        
      </div>
      
      <div className="button-container">
        <div id="cambio">
          <button className='button-content'>{statusText}</button> 
        </div>
        <div id="solucion">
          <button className='button-solution'>Completar</button> 
        </div>
        <div id="solucion-especifica">
          <button className='button-specific-solution'>Pista</button> 
        </div>
      </div>
      <div>
        <div>{texto}</div> 
      </div>
    </div>
  );
}

export default Game;