import { Link } from "react-router-dom";
import { useNavigate } from "react-router-dom";
import { useState } from "react";
import Title from "../components/Title";

function HomePage() {

  const navigate = useNavigate();
  const [singleClicked, setSingleClicked] = useState(false);
  const [multiClicked, setMultiClicked] = useState(false);

  return (
    <div className="flex flex-col h-screen items-center">
      <div className="flex flex-col items-center justify-center">
        <Title></Title>
      </div>
      <div className="flex flex-col mt-16 md:mt-24">
        <div className="link w-fit mx-auto">
          <button className="bg-tteal text-white mb-4" onClick={() => { setSingleClicked(true); }} onTransitionEnd={() => { if (singleClicked) navigate("/singleplayer"); }}>
            Singleplayer
          </button>
        </div>
        <div className="link w-fit mx-auto" to="/multiplayer">
          <button className="bg-tpurple text-white" onClick={() => { setMultiClicked(true); }} onTransitionEnd={() => { if (multiClicked) navigate("/multiplayer"); }}>
            Multiplayer
          </button>
        </div>
      </div>
    </div>
  );
}

export default HomePage;
