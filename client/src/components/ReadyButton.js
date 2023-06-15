import { useTimer } from "use-timer";
import { useState } from "react";

function ReadyButton(props) {
//   const { time, start } = useTimer({
//     initialTime: 4,
//     timerType: "DECREMENTAL",
//   });
  
  const [clicked, setClicked] = useState(false);

  if (props.allReady) {
    return <h3 className="text-tpurple text-xl md:text-2xl">Game starting now...</h3>;
  }
  if (props.isReady) {
    return <h3 className="text-tpurple text-xl md:text-2xl">Waiting for other players...</h3>;
  } else {
    return (
      <button className="button bg-tteal" onClick={() => { setClicked(true); }} onTransitionEnd={() => { if (clicked) props.readyHandler(); }}>
        Ready
      </button>
    );
  }
}

export default ReadyButton;
