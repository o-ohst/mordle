import { createContext, useState } from "react";

export const AppContext = createContext();

export function AppProvider({children}) {
    const [loggedIn, setLoggedIn] = useState(false);
    const [userId, setUserId] = useState();
    const [playedToday, setPlayedToday] = useState(false);

    const value = {
    loggedIn,
    setLoggedIn,
    userId,
    setUserId,
    playedToday,
    setPlayedToday
    };

    return (
        <AppContext.Provider value={value}>{children}</AppContext.Provider>
    );
}