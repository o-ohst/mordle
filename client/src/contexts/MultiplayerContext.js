import { createContext, useState} from "react";

export const MultiplayerContext = createContext();

export function MultiplayerProvider({children}) {
    const [channel, setChannel] = useState(null);
    const [socket, setSocket] = useState(null);
    const [validSession, setValidSession] = useState(true);
    const [gameStart, setGameStart] = useState(false);
    const [players, setPlayers] = useState([]);
    const [playerId, setPlayerId] = useState();
    const [playerName, setPlayerName] = useState();
    const [roomId, setRoomId] = useState("");
    const [round, setRound] = useState(0);
    const [roundEnd, setRoundEnd] = useState(false);
    const [gameEnd, setGameEnd] = useState(false);
    const [finalScores, setFinalScores] = useState([]);
    const [timerTime, setTimerTime] = useState();


    const value = {
        socket,
        setSocket,
        channel,
        setChannel,
        validSession,
        setValidSession,
        gameStart,
        setGameStart,
        players,
        setPlayers,
        playerId,
        setPlayerId,
        playerName,
        setPlayerName,
        roomId,
        setRoomId,
        round,
        setRound,
        roundEnd,
        setRoundEnd,
        gameEnd,
        setGameEnd,
        finalScores,
        setFinalScores,
        timerTime,
        setTimerTime
    };

    return (
        <MultiplayerContext.Provider value={value}>{children}</MultiplayerContext.Provider>
    );
}