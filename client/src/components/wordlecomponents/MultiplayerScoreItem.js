function MultplayerScoreItem(props) {
    //take in the score of the other players
  
    return (
      <div className="flex flex-row items-center text-base mx-1">
        <div className="flex flex-col items-center">
          <h3 className="m-0 p-0 text-purple-500 h-6 md:text-2xl md:h-7">{props.score}</h3>
          <h5 className="text-sm inline-block">{props.playerName}</h5>
        </div>
        <h5 className={"text-xs text-center h-4 w-4 rounded-full flex items-center justify-center self-end mb-0.5 " +
          (props.state === "correct" ? "bg-tteal" : (props.state === "ran out" ? "bg-torange" : "bg-tgray"))}>
          {props.state === "start" ? "0" : props.state === "correct" ? "✔" : props.state === "ran out" ? "✖" : props.state === "joined" || props.state === "ready" ? " " : props.state}</h5>
      </div>
    );
  }
  
  export default MultplayerScoreItem