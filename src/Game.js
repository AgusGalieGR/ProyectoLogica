import React, { useEffect, useState } from 'react';
import PengineClient from './PengineClient';
import Board from './Board';

let pengine;

function Game() {

  // State
  const [grid, setGrid] = useState(null);
  const [rowsClues, setRowsClues] = useState(null);
  const [colsClues, setColsClues] = useState(null);
  const [rowsSat, setRowsSat] = useState(null);
  const [colsSat, setColsSat] = useState(null);
  const [waiting, setWaiting] = useState(false);
  const [resultado, setResultado] = useState(null);

  //const [status, setStatus] = useState(false);
  var content;
  const [pintar, setPintar] = useState(false);
  

  useEffect(() => {
    // Creation of the pengine server instance.    
    // This is executed just once, after the first render.    
    // The callback will run when the server is ready, and it stores the pengine instance in the pengine variable. 
    PengineClient.init(handleServerReady);
  }, []);

  function handleServerReady(instance) {
    pengine = instance;
    const queryS = 'init(RowClues, ColumClues, Grid, Sat)';
    pengine.query(queryS, (success, response) => {
      if (success) {
        setGrid(response['Grid']);
        setRowsClues(response['RowClues']);
        setColsClues(response['ColumClues']);
        setRowsSat(response['Sat']);
        setColsSat(response['Sat']);
        setPintar(true);
      }
    });
  }

  function handleClick(i, j) {
    // No action on click if we are waiting.
    if (waiting) {
      return;
    }
    var cambio = document.getElementById('cambio');
    cambio.addEventListener('click', () => {
    cambioDeEstado();
    });
    
    function cambioDeEstado(){
      if(pintar){
        setPintar(false);
      }else{
        setPintar(true);
      }
    }
    // Build Prolog query to make a move and get the new satisfacion status of the relevant clues.    
    const squaresS = JSON.stringify(grid).replaceAll('"_"', '_'); // Remove quotes for variables. squares = [["X",_,_,_,_],["X",_,"X",_,_],["X",_,_,_,_],["#","#","#",_,_],[_,_,"#","#","#"]]
    const rowsCluesS = JSON.stringify(rowsClues);
    const colsCluesS = JSON.stringify(colsClues);
    const pintarS = pintar;
    //content = '#';
    if(!pintarS){
      content = 'X';
    }else{
      content = '#'
    }
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

  }
  if (!grid) {
    return null;
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
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        rowsSat = {rowsSat}
        colsSat = {colsSat}
        onClick={(i, j) => handleClick(i, j)}
        
      />
      <div id="cambio">
        <button className='button-content'>{statusText}</button> 
      </div>
      <div>
        <div>{texto}</div> 
      </div>
    </div>
  );
}

export default Game;