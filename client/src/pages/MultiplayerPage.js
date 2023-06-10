import { Socket } from "phoenix-socket";
import axios from "axios";

import { useNavigate } from "react-router-dom";
import MessageDisplay from "../components/wordlecomponents/MessageDisplay";
import Title from "../components/Title";
import { useContext, useState, useEffect } from "react";
import { MultiplayerContext } from "../contexts/MultiplayerContext";

function MultiplayerPage() {
  const {
    channel,
    setChannel,
    playerId,
    setPlayerId,
    setPlayers,
    playerName,
    setPlayerName,
    roomId,
    socket,
    setSocket,
    setRoomId,
    setGameStart,
    setRound,
    setRoundEnd,
    setGameEnd,
    setFinalScores,
    setTimerTime,
  } = useContext(MultiplayerContext);
  const [roomCreated, setRoomCreated] = useState(false);
  const [roomJoined, setRoomJoined] = useState(false);
  const [createClicked, setCreateClicked] = useState(false);
  const [joinClicked, setJoinClicked] = useState(false);
  const [joinEnabled, setJoinEnabled] = useState(true);
  const [createEnabled, setCreateEnabled] = useState(true)
  const [message, setMessage] = useState("");
  const navigate = useNavigate();

  function resetAll() {
    setChannel(null);
    setRoomId("");
    setPlayerId("");
    setPlayerName("");
    setRoomCreated(false);
    setRoomJoined(false);
    setCreateClicked(false);
    setJoinClicked(false);
    setJoinEnabled(true);
    setCreateEnabled(true);
    setMessage("");
  }

  useEffect(() => {
    console.log("useEffect, []");
    resetAll();
    if (playerId === "" || playerId === undefined) {
      console.log(localStorage.getItem("playerId"));
      if (localStorage.getItem("playerId") !== null) {
        setPlayerId(localStorage.getItem("playerId"));
        connectToSocket(localStorage.getItem("playerId"));
      }
      axios.get(process.env.REACT_APP_API_URL + "/register", { withCredentials: true }).then((res) => {
        setPlayerId(res.data.playerId);
        localStorage.setItem("playerId", res.data.playerId);
      });
    }
  }, []);

  useEffect(() => {
    //connect to socket after setting playerId
    if (playerId === "" || playerId === undefined) return;
    if (!(socket === null || socket === undefined)) return; //if no socket connection, then connect
    console.log("useEffect, playerId");
    connectToSocket(playerId)
  }, [playerId]);

  function connectToSocket(pid) {
    const ss = new Socket(process.env.REACT_APP_WS_URL, {
      params: { playerId: pid },
    });
    ss.connect();
    console.log(ss)
    setSocket(ss);
  }

  function handleNameChange(event) {
    setPlayerName(event.target.value);
  }

  function handleRoomIdChange(event) {
    setRoomId(event.target.value);
  }

  function handleCreate() {
    console.log("handleCreate");
    if (playerName === "" || playerName === undefined) {
      setMessage("Your name ain't it");
      setCreateEnabled(true);
      return;
    }
    axios //http
      .get(process.env.REACT_APP_API_URL + "/create-room", {
        params: { playerId: playerId },
        withCredentials: true
      })
      .then((res) => {
        console.log(res.data);
        setRoomId(res.data.roomId);
        setRoomCreated(true);
      }).catch(err => {
        setMessage(err.message);
        setCreateEnabled(true);
      });
  }

  function handleJoin() {
    console.log("handleJoin: " + roomId + " Name: " + playerName);
    if (playerName === "" || playerName === undefined) {
      setMessage("Your name ain't it");
      setJoinEnabled(true);
      return;
    }
    if (roomId.length < 11) {
      setMessage("Your room code ain't it");
      setJoinEnabled(true);
      return;
    }    
    joinRoom(roomId, playerName);
  }

  function joinRoom(id, name) {

    console.log("joinRoom ")

    const channel = socket.channel("room:" + id, {
      playerName: name,
    });

    channel.on("joined", (msg) => {
      console.log("joined received on multiplayer page");
      onPlayerJoin(
        msg.data.players.map((x) => [x.playerId, x.playerName, x.state])
      );
    });

    channel
      .join()
      .receive("ok", (res) => {   
        console.log("joined successfully");
        setChannel(channel);
        setRoomJoined(true);
        setPlayers(res.players.map(p => [p.playerId, res.room.players.filter(r => r.playerId === p.playerId)[0].playerName, p.row]))
        setGameStart(res.room.started)
        setRound(res.room.round)
        setRoundEnd(res.room.round !== 0 && (!res.room.started))
        setGameEnd(false)
        setFinalScores(res.players.map(p => [p.playerId, res.room.players.filter(r => r.playerId === p.playerId)[0].playerName, p.score]))
        setTimerTime(res.endTime);
      })
      .receive("error", ({ reason }) => {
        console.log("error");
        reason === "invalid room id"
          ? setMessage("Your room code is cap")
          : setMessage(reason)
        setJoinEnabled(true);
        return;
      });
    return () => {
      channel.leave();
    };
  }

  function onPlayerJoin(array) {
    setPlayers(array);
  }

  useEffect(() => {
    if (!roomCreated) return;
    joinRoom(roomId, playerName);
  }, [roomCreated]);

  useEffect(() => {
    if (!roomJoined) return;
    navigate("/room/" + roomId)
  }, [roomJoined]);


  return (
    <div className="flex flex-col h-full">
      <div className="flex justify-center">
        <Title></Title>
      </div>
      <div className="flex flex-col justify-center">
        <h1 className="mx-auto text-2xl mt-6">Multiplayer</h1>
        <div className="flex flex-col items-center gap-6">
          <input
            className="input p-3 mt-6 text-center"
            type="text"
            placeholder="Name"
            onChange={handleNameChange}
            value={playerName}
            required
            ></input>
        </div>
      </div>
      <div className="h-2/4 flex flex-col items-center mt-4">
        <button
          className="bg-tpurple"
          onClick={() => { if (createEnabled) { setCreateEnabled(false); setCreateClicked(true); } }} onTransitionEnd={() => { if (createClicked) { setCreateClicked(false); handleCreate(); } }}
        >
          Create Room
        </button>
        <div className="py-4">
          {message === "" ? <h2>OR</h2> : <MessageDisplay message={message}></MessageDisplay>}
        </div>
        <div className="rounded-2xl border-2 border-gray-200 p-4 flex flex-col items-center gap-4">
          <div>
            <input
              className="w-48 p-3 text-center font-mono"
              type="text"
              maxLength={11}
              onChange={handleRoomIdChange}
              value={roomId}
            ></input>
          </div>
          <button className="bg-torange" onClick={() => { if (joinEnabled) { setJoinEnabled(false); setJoinClicked(true); } }} onTransitionEnd={() => { if (joinClicked) { setJoinClicked(false); handleJoin(); } } }>
            Join Room
          </button>
        </div>
      </div>
    </div>
  );
}

export default MultiplayerPage;
