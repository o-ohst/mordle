import { Route, Routes } from "react-router-dom";

import HomePage from "./pages/HomePage";
import MultiplayerPage from "./pages/MultiplayerPage";
import SingleplayerPage from "./pages/SingleplayerPage";
import MultiplayerGamePage from "./pages/MultiplayerGamePage";

import { AppProvider } from "./contexts/AppContext";
import { MultiplayerProvider } from "./contexts/MultiplayerContext";
import { WordleProvider } from "./contexts/WordleContext";

function App() {
  return (
    <AppProvider>
      <WordleProvider>
        <MultiplayerProvider>
            <Routes>
              <Route path="/" element={<HomePage />} />
              <Route path="/singleplayer" element={<SingleplayerPage />} />
              <Route path="/multiplayer" element={<MultiplayerPage />} />
              <Route
                path="/room/:roomId"
                element={<MultiplayerGamePage />}
              />
            </Routes>
        </MultiplayerProvider>
      </WordleProvider>
    </AppProvider>
  );
}

export default App;
