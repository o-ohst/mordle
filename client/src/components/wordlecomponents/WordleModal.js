import { useEffect, useState, useContext } from "react";
import { useNavigate } from "react-router-dom";
import { MultiplayerContext } from "../../contexts/MultiplayerContext";
import { useTimer } from "react-timer-hook";

function WordleModal(props) {
  const { loggedIn } = useContext(MultiplayerContext);
  const { ready, setReady } = useState(false);

  const navigate = useNavigate();

  const time = new Date();
  time.setSeconds(time.getSeconds() + 5);

  const { seconds, start, pause } = useTimer({ expiryTimestamp: time, autoStart: false });

  function backHome() {
    navigate("/");
  }

  function readyFunc() {
    setReady(true);
    start();
  }

  useEffect(() => {
    if (seconds === 0) {
        pause();
        props.startFunc();
    }
  }, [seconds]);

  if (props.message !== "") {
    return (
      <div>
        <h3>{props.message}</h3>
        <button onClick={backHome}>Return to Main Page</button>
      </div>
    );
  }

  return (
    <div className="hidden overflow-y-auto overflow-x-hidden fixed top-0 right-0 left-0 z-50 md:inset-0 h-modal md:h-full">
      <div className="relative p-4 w-full max-w-md h-full md:h-auto">
        <div className="relative bg-white rounded-lg shadow dark:bg-gray-700">
          {/* <h3 className="mb-5 text-lg font-normal text-gray-500 dark:text-gray-400">Are you sure you want to delete this product?</h3>
                <button type="button" class="text-white bg-red-600 hover:bg-red-800 focus:ring-4 focus:outline-none focus:ring-red-300 dark:focus:ring-red-800 font-medium rounded-lg text-sm inline-flex items-center px-5 py-2.5 text-center mr-2">
                    Yes, I'm sure
                </button>
                <button type="button" class="text-gray-500 bg-white hover:bg-gray-100 focus:ring-4 focus:outline-none focus:ring-gray-200 rounded-lg border border-gray-200 text-sm font-medium px-5 py-2.5 hover:text-gray-900 focus:z-10 dark:bg-gray-700 dark:text-gray-300 dark:border-gray-500 dark:hover:text-white dark:hover:bg-gray-600 dark:focus:ring-gray-600">
                    No, cancel
                </button> */}
          {ready ? (
            <div className="p-6 text-center">
              <h3>Game starts in:</h3>
              <h3>{seconds}</h3>
            </div>
          ) : (
            <div className="p-6 text-center">
              <h3>Login Status: {loggedIn ? "Logged In" : "Not logged In"}</h3>
              <h3 className="text-lg text-white-500">
                Click to start today's Wordle
              </h3>
              <button
                onClick={readyFunc}
                className="text-white bg-green-600 hover:bg-green-800 focus:ring-4 focus:outline-none focus:ring-green-300 dark:focus:ring-green-800 font-medium rounded-lg text-sm inline-flex items-center px-5 py-2.5 text-center mr-2"
              >
                Ready
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default WordleModal;
