import React from 'react';
import Square from './Square';
import Clue from './Clue';

function BoardSolution({grid}) {
    const numOfRows = grid.length;
    const numOfCols = grid[0].length;
    return (
        <div className="vertical">
            <div
                className="colClues"
                style={{
                    gridTemplateRows: '60px',
                    gridTemplateColumns: `60px repeat(${numOfCols}, 40px)`
                    /*
                       60px  40px 40px 40px 40px 40px 40px 40px   (gridTemplateColumns)
                      ______ ____ ____ ____ ____ ____ ____ ____
                     |      |    |    |    |    |    |    |    |  60px
                     |      |    |    |    |    |    |    |    |  (gridTemplateRows)
                      ------ ---- ---- ---- ---- ---- ---- ---- 
                     */
                }}
            >
                <div>{/* top-left corner square */}</div>
                
            </div>
            <div className="horizontal">
                <div
                    className="rowClues"
                    style={{
                        gridTemplateRows: `repeat(${numOfRows}, 40px)`,
                        gridTemplateColumns: '60px'
                        /* IDEM column clues above */
                    }}
                >
                    
                </div>
                <div className="board"
                    style={{
                        gridTemplateRows: `repeat(${numOfRows}, 40px)`,
                        gridTemplateColumns: `repeat(${numOfCols}, 40px)`
                    }}>
                    {grid.map((row, i) =>
                        row.map((cell, j) =>
                            <Square
                                value={cell}
                                key={i + j}
                            />
                        )
                    )}
                </div>
            </div>
        </div>
    );
}

export default BoardSolution;