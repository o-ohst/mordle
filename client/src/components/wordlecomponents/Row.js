function Row(props) {

    if (props.guess) {
        return (
            <div className="row flex flex-row justify-center items-center">
                {props.guess.map((l, i) => (
                    <div key={i} className={"letterbox animate-pop " + (l.color === "green" ? "bg-tgreen" : l.color === "yellow" ? "bg-tyellow" : "bg-tgray")}>
                        <h6>{ l.key }</h6>
                    </div>
                ))}
            </div>
        )
    }

    if (props.currentGuess) {
        let letters = props.currentGuess.split('')
        return (
            <div className="row">
                {letters.map((letter, i) => (
                    <div key={i} className="letterbox text-white  border-2 border-white animate-wiggle">
                        <h6>{letter}</h6>
                    </div>
                ))}
                {[...Array(5 - letters.length)].map((u, i) => (
                    <div key={i} className="letterbox border-2 border-white"></div>
                ))}
            </div>
        )
    }

    return (
        <div className="row">
            <div className="letterbox border-2 border-white"></div>
            <div className="letterbox border-2 border-white"></div>
            <div className="letterbox border-2 border-white"></div>
            <div className="letterbox border-2 border-white"></div>
            <div className="letterbox border-2 border-white"></div>
        </div>
    )
}

export default Row;