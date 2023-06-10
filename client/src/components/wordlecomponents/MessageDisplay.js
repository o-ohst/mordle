function MessageDisplay(props) {
    if (props.message !== "") {
        return (
            <h4 className="text-center text-tteal my-2">{props.message}</h4>
        )
    } else {
        return (<h4 className = "text-center my-2">&nbsp;</h4>)
    }
}

export default MessageDisplay;