import React from 'react';

function Clue({ clue, sat }) {
    return (
        <div className={sat? "clue clueSat" : "clue"} >
            {clue.map((num, i) =>
                <div key={i}>
                    {num}
                </div>
            )}
        </div>
    );
}



export default Clue;