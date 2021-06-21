import ballerina/log;
import ballerina/websocket;

map<websocket:Caller> connectionMap = {};
string userName = "";

@websocket:ServiceConfig {
    subProtocols: ["xml", "json"],
    idleTimeout: 120
}
service /chat on new websocket:Listener(9090) {
    resource function get [string name]()
                        returns websocket:Service|websocket:UpgradeError {
        userName = name.clone();
        return new WsService();
    }
}

service class WsService {
    *websocket:Service;

    remote function onOpen(websocket:Caller caller) {
        connectionMap[caller.getConnectionId()] = caller;
    }

    remote function onTextMessage(websocket:Caller caller,
                                 string text) {
        broadcast(userName + ": " + text);
    }

    remote function onClose(websocket:Caller caller) {
        _ = connectionMap.remove(caller.getConnectionId());
    }
}

function broadcast(string text) {
    foreach var con in connectionMap {
        var err = con->writeTextMessage(text);
        if (err is websocket:Error) {
            log:printError("Error sending message", 'error = err);
        }
    }
}