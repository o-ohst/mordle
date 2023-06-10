function PlayerReady(props) {

  return (
    <div className="readydisplay">
      {props.players.map((player) => {
        return (
          <div key={player[0]} className={"rounded-xl p-1 md:p-3 w-56 md:w-64 flex mb-2 flex-row items-center justify-center" + (player[2] === "ready" ? " bg-tteal" : " bg-slate-600")}>
          <svg width="40" height="40">
              <circle className={player[2] === "ready" ? "fill-tpink": "fill-slate-800"} cx="20" cy="20" r="15" stroke="white" strokeWidth="2" />
          </svg>
          <div className="text-lg text-white mx-auto select-none">{player[1] + ": " + player[2]}</div>
        </div> )
      })}
    </div>
  );
}

export default PlayerReady;
