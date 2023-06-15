import axios from "axios";
import { useContext, useEffect, useState } from "react";
import Wordle from "../components/wordlecomponents/Wordle";
import Title from "../components/Title";
import WordleModal from "../components/wordlecomponents/WordleModal";
import { AppContext } from "../contexts/AppContext";
import { WordleContext } from "../contexts/WordleContext";
import { useTimer, useStopwatch } from "react-timer-hook";

// import { useTimer } from "use-timer";

function SingleplayerPage() {
  const { loggedIn, playedToday, setPlayedToday } = useContext(AppContext);
  const {
    setGuesses,
    history,
    setHistory,
    setRow,
    setCurrentGuess,
    setDisableGrid,
    setUsedLetters,
    setMessage,
    receivedColors,
    setReceivedColors,
  } = useContext(WordleContext);

  const [gameEnd, setGameEnd] = useState(false);
  const [topMessage, setTopMsg] = useState("");
  const url = process.env.REACT_APP_API_URL;

  const { minutes, seconds, start, pause, reset } = useStopwatch({});

  useEffect(() => {
    if (loggedIn && !playedToday) {
      axios.get(url + "/played-today").then((res) => {
        setPlayedToday(res.played);
      });
    }
  }, [loggedIn, playedToday, setPlayedToday, url]);

  useEffect(() => {
    if (playedToday) {
      setDisableGrid(true);
      setTopMsg("You have played once today, come back tomorrow!");
    } else {
      start();
    }
  }, [playedToday]);

  //   useEffect(() => {
  //     if (!timerActive && !playedToday) {
  //         setDisableGrid(true);
  //         start();
  //         setTimerActive(true);
  //     }
  //   }, [timerActive, playedToday]);

  function colorFunction(currGuess, func) {
    axios
      .post(url + "/guess", {
        guess: currGuess,
      })
      .then((res) => {
        console.log("Received colors: " + res.data.score);
        func(res.data.score);
      });
    return;
  }

  useEffect(() => {
    if (receivedColors === "22222") {
      if (!playedToday) {
        pause();
        setDisableGrid(true);
        axios
          .post(url + "/end-game", {
            scores: history[1],
            timeTaken: minutes * 60 + seconds,
          })
          .then((res) => {
            setTopMsg("The word was: " + res.data.word);
            setGameEnd(true);
          });
        setPlayedToday(true);
      }
      setTimeout(() => {
        if (loggedIn) {
          setTopMsg("View your history on homepage.");
        }
      }, 3000);
    }

    if (history[0].length === 6) {
      if (!playedToday) {
        pause();
        setDisableGrid(true);
        axios
          .post(url + "/end-game", {
            scores: history[1],
            timeTaken: minutes * 60 + seconds,
          })
          .then((res) => {
            setTopMsg(
              "The word was: " + res.data.word + ". Better luck next time!"
            );
            setGameEnd(true);
          });
        setPlayedToday(true);
      }
      setTimeout(() => {
        if (loggedIn) {
          setTopMsg("View your history on homepage.");
        }
      }, 3000);
    }

    return;
  }, [history]);

  return (
    <div className="h-screen">
      <div className="flex-none flex justify-center items-center pt-3 md:pt-8">
        <div className="flex">
          <img className="my-auto w-8 h-8 md:w-16 md:h-16 animate-spin hover:animate-bounce" src="/M.png" alt="logo"></img>
          <img className="my-auto w-16 h-8 md:w-32 md:h-16 " src="/ordle.png" alt="logo"></img>
        </div>
        </div>
        <div className="my-1 md:my-3">
      {gameEnd ? (
        <h2>{topMessage}</h2>
      ) : (

        <h3 className="text-center text-tpink md:text-2xl">
          {minutes +
            ":" +
            (seconds < 10 ? "0" + seconds : seconds)}
        </h3>
      )}
        </div>
        <Wordle colorFunction={colorFunction} />
      </div>
  );
}

export default SingleplayerPage;
