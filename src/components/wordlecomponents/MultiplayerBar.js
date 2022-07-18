import { useContext } from "react";
import { MultiplayerContext } from "../../contexts/MultiplayerContext";
import MessageDisplay from "./MessageDisplay";
import MultplayerScoreItem from "./MultiplayerScoreItem";

function MultiplayerBar(props) {
  const { channel, players, roundEnd, gameEnd, round, finalScores } =
    useContext(MultiplayerContext);
  
  function formatTime(seconds) {
    return (seconds / 60 < 1 ? "0" : Math.floor(seconds / 60)) + (seconds % 60 < 10 ? ":0" : ":") + (seconds % 60);
  }
  
  return (
    <div>
        <div className="multiplayerbar flex flex-row text-white items-center justify-center mt-3 mb-2 gap-2 overflow-x-scroll no-scrollbar">
        <div className="flex flex-col items-center">
          <div className="h-5">{round === 0 ? "" : "Round " + round}</div>
          <div className="text-tpink text-xl">{formatTime(props.time)}</div>
        </div>
        <div className="flex flex-row items-center">
          {finalScores
            .sort((a, b) => (a[2] < b[2]) ? 1 : (b[2] > a[2]) ? -1 : 0)
            .map((p, i) => {
            return (
              <MultplayerScoreItem
                key={i}
                playerName={p[1]}
                score={p[2]}
                state={players.filter((x) => p[0] === x[0])[0][2]}
              />
            );
          })}
        </div>
        <div></div>
        </div>
    </div>
  );
}

export default MultiplayerBar;
