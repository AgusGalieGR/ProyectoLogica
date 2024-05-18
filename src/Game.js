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
        let newRowsSat =[]; // Crea una copia del estado actual
        let RSat = response['RowSat']; // Actualiza la fila específica
        for(let k=0;k< rowsSat.length;k++){
          if(k == i){
            newRowsSat[k] = RSat;
            alert("Se actualizo RowSat: "+response['RowSat']);
          }else{
            newRowsSat[k] = rowsSat[k];
          }
          
        }
        setRowsSat(newRowsSat);
        //rowsSat[i] = response['RowSat']; //Cuidao
        colsSat[j] = response['ColSat'];
        //setRowsSat()
        // ROWSAT se actualiza usando en indice i
        // COLSAT se actualiza usando el indice j
        // INMEDIATAMENTE DESPUES DE HACER EL PUT CHEQUEAR SI GANAMOS CON PROLOG 
        // UTILIZANDO UN PREDICADO QUE TOME POR PARAMETRO LAS DOS LISTAS QUE TENEMOS EN REACT
        //setStatus(response['Status']);
      }
      setWaiting(false);
    });
    const RowSatS = JSON.stringify(rowsSat);
    const ColSatS = JSON.stringify(colsSat);
    const queryS2 = `ganar_juego(${RowSatS}, ${ColSatS}, Resultado)`;
    alert("Filas: "+RowSatS);
    setWaiting(true);
    
    pengine.query(queryS2, (success, response) => {
      if (success) {
        setResultado(response['Resultado']);
      }
      setWaiting(false);
    });
  }

  if(resultado){
    alert("Has ganado");
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
  return (
    <div className="game">
      <Board
        grid={grid}
        rowsClues={rowsClues}
        colsClues={colsClues}
        onClick={(i, j) => handleClick(i, j)}
      />
      <div id="cambio">
        <button className='button-content'>{statusText}</button> 
      </div>
    </div>
  );
}

export default Game;