//
//  ViewController.swift
//  ClientWorld
//
//  Created by Josh Johnson on 12/12/17.
//  Copyright © 2017 Pocketz World. All rights reserved.
//

import UIKit
import Starscream

class ViewController: UIViewController {
    
    @IBOutlet weak var userIdField: UITextField!
    @IBOutlet weak var roomTextField: UITextField!
    @IBOutlet weak var messageField: UITextField!
    @IBOutlet weak var connectButton: UIButton!

    let socketURL = "ws://35.186.219.54:80"
    var socket: WebSocket?
    
    var currentUserId = "007"
    var currentUserName = "James Bond"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userIdField.text = currentUserId
    }
    
    
    fileprivate func socketConnected() -> Bool {
        return socket != nil && socket?.isConnected == true
    }

    @IBAction func connectSocketTapped(_ sender: UIButton) {
        if socket == nil, let url = URL(string: socketURL) {
            socket = WebSocket(url: url)
            socket?.delegate = self
            socket?.connect()
            connectButton.isEnabled = false
        } else {
            self.showMessage("Could not connect to socket.")
        }
    }
    
    @IBAction func joinRoomTapped(_ sender: UIButton) {
        defer {
            UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        }
        guard let roomId = roomTextField.text, !roomId.isEmpty else { return }
        
        joinRoom(roomId)
    }
    
    @IBAction func sendMessageTapped(_ sender: UIButton) {
        defer {
            UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)
        }
        guard let message = messageField.text, !message.isEmpty else { return }

        sendMessage(message)
    }
    
    fileprivate func showMessage(_ message: String) {
        let alert = UIAlertController(title: "ClientWorld", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Okay", style: .cancel, handler: nil))
        show(alert, sender: nil)
    }

    func joinRoom(_ roomId: String) {
        guard socketConnected() else {
            showMessage("Cannot join room, no socket.")
            return
        }
        
        if let data = BufferController.default().joinRoomRequest(withUser: userIdField.text, name: currentUserName, roomId: roomId) {
            socket?.write(data: data, completion: {
                self.showMessage("Join Message Sent!")
            })
        }
    }
    
    func sendMessage(_ message: String) {
        guard socketConnected() else {
            showMessage("Cannot send message, no socket.")
            return
        }

        if let data = BufferController.default().sendVWMessageRequest(fromUser: userIdField.text, name: currentUserName, message: "Vodka Martini, Shaken not stirred") {
            socket?.write(data: data, completion: {
                self.showMessage("Message Sent…")
            })
        }
    }

}

extension ViewController: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocketClient) {
        print("Websocket Connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("Websocket Disconnected: \(error?.localizedDescription ?? "")")
        self.socket = nil
        connectButton.isEnabled = true
        self.showMessage("Disconnected")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        let message = BufferController.default().message(fromReceivedData: data)
        if let message = message {
            showMessage(message)
        }
    }

    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        print("Message: \(text)")
    }
    
}
