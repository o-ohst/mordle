import { useState, useContext, useEffect } from "react";
import { WordleContext } from "../../contexts/WordleContext";
import Grid from "./Grid";
import Keyboard from "./Keyboard";

function Wordle(props) {
  const {
    guesses,
    setGuesses,
    history,
    setHistory,
    row,
    setRow,
    currentGuess,
    setCurrentGuess,
    disableGrid,
    setDisableGrid,
    usedLetters,
    setUsedLetters,
    receivedColors,
    setReceivedColors,
    message,
    setMessage
  } = useContext(WordleContext);
  const allowed_words = require("../data/allowed_words.json").allowed_words;

  function addGuess(formattedGuess) {
    setGuesses((prevGuesses) => {
      let newGuesses = [...prevGuesses];
      newGuesses[row] = formattedGuess;
      return newGuesses;
    });
    setHistory((prevHistory) => {
      return [
        [...prevHistory[0], currentGuess],
        prevHistory[1]
      ];
    });
    console.log(history[0]);
    console.log(history[1]);
    setRow((prevRow) => {
      console.log("increasing row");
      return prevRow + 1;
    });
    setUsedLetters((prev) => {
      let newKeys = { ...prev };

      formattedGuess.forEach((letter) => {
        const currColor = newKeys[letter.key];

        if (letter.color === "green") {
          newKeys[letter.key] = "green";
          return;
        }
        if (letter.color === "yellow" && currColor !== "green") {
          newKeys[letter.key] = "yellow";
          return;
        }

        if (
          letter.color === "grey" &&
          currColor !== "green" &&
          currColor !== "yellow"
        ) {
          newKeys[letter.key] = "grey";
          return;
        }
      });
      return newKeys;
    });
    if (receivedColors === "22222") {
      setDisableGrid(true);
      setMessage("You've won!");
    }
    setCurrentGuess("");
    setDisableGrid(false);
  }

  function formatGuess(colors) {
    setHistory(prevHistory => {
      return [prevHistory[0],
    [...prevHistory[1], colors]]
    });
    setReceivedColors(colors);
    const splitReceivedColors = [...colors];
    const format_guess = [...currentGuess].map((letter, index) => {
      let color = "grey";
      if (splitReceivedColors[index] === "2") {
        color = "green";
      } else if (splitReceivedColors[index] === "1") {
        color = "yellow";
      }
      return { key: letter, color };
    });
    addGuess(format_guess);
  }

  function handleKeyUp({ key }) {
    if (disableGrid) {
      return;
    }
    if (row > 5) {
      setMessage("You ran out of guesses!");
      return;
    }
    if (key === "Enter") {
      if (currentGuess.length !== 5) {
        setMessage("Too short!");
        return;
      }
      if (history[0].includes(currentGuess)) {
        setMessage("Why try the same word?");
        return;
      }
      if (!allowed_words.includes(currentGuess)) {
        setMessage("This word does not exist!");
        return;
      }
      setDisableGrid(true);
      props.colorFunction(currentGuess, formatGuess);
    }
    if (key === "Backspace") {
      setCurrentGuess((prev) => {
        return prev.slice(0, -1);
      });
      return;
    }
    if (/^[A-Za-z]$/.test(key)) {
      if (currentGuess.length < 5) {
        setCurrentGuess((prev) => {
          return prev + key;
        });
      }
    }
  }

  useEffect(() => {
    window.addEventListener("keyup", handleKeyUp);

    return () => window.removeEventListener("keyup", handleKeyUp);
  }, [handleKeyUp]);

  return (
    <div className="flex flex-col items-center flex-none">
      <Grid currentGuess={currentGuess} guesses={guesses} row={row} />
      <Keyboard
        usedLetters={usedLetters}
        message={message}
        handleKeyUp={handleKeyUp}
      />
    </div>
  );
}

export default Wordle;
