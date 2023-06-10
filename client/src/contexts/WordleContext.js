import { createContext, useState } from "react";

export const WordleContext = createContext();

export function WordleProvider({children}) {
    const [guesses, setGuesses] = useState([...Array(6)]);
    const [history, setHistory] = useState([[], []]);
    const [row, setRow] = useState(0);
    const [currentGuess, setCurrentGuess] = useState("");
    const [disableGrid, setDisableGrid] = useState(false);
    const [usedLetters, setUsedLetters] = useState({});
    const [message, setMessage] = useState("");
    const [receivedColors, setReceivedColors] = useState("");
    const [guessEnabled, setGuessEnabled] = useState(true);
    
    const value = {
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
        message,
        setMessage,
        receivedColors,
        setReceivedColors,
        guessEnabled,
        setGuessEnabled
    };

    return (
        <WordleContext.Provider value={value}>{children}</WordleContext.Provider>
    );
}