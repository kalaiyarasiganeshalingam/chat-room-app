import ballerina/websocket;
import ballerina/io;

string name = "";
public function main(string... args) returns error? {
    boolean isTerminated = false;
    name = io:readln(string `Enter your name: `);
    websocket:Client wsClient = check new("ws://localhost:9090/chat/" + name);
    io:println("Chat room opened now.\nWhen you want to close the chat, type \"yes\".\nYou can chat with your friends until type yes");
    check wsClient->writeTextMessage("I join the chat room");
    check getMessage(wsClient);
    io:println("#######");
    while(!isTerminated) {
        string message = io:readln(string `Enter your message: `);
        if (message.equalsIgnoreCaseAscii("Yes")) {
            isTerminated = true;
            check wsClient->writeTextMessage("I left the chat room");
        }
        check wsClient->writeTextMessage(message);
        check getMessage(wsClient);
    }
}

function getMessage(websocket:Client wsClient) returns error? {
    string msg = check wsClient->readTextMessage();
    if (msg != "") {
        io:println("Inbox message by " + msg);
    }
}
