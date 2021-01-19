//
//  ContentView.swift
//  Shared
//
//  Created by Shi'n'ichi Kogai on 2021/01/19.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        print("Hello, world!!!")
        let command: [UInt8] = [0x41, 0x42, 0x43, 0x44, 0x1b, 0x7a, 0x00, 0x1b, 0x64, 0x02]
        print(command)
        while true {
            var port : SMPort

            do {
            // Open port
            port = try SMPort.getPort(portName: "BT:Star Micronics", portSettings: "", ioTimeoutMillis: 10000)

            defer {
                // Close port
                SMPort.release(port)
            }

            var printerStatus: StarPrinterStatus_2 = StarPrinterStatus_2()

            // Start to check the completion of printing
            try port.beginCheckedBlock(starPrinterStatus: &printerStatus, level: 2)

            if printerStatus.offline == sm_true {
                break    // The printer is offline.
            }

            var total: UInt32 = 0

            while total < UInt32(command.count) {
                var written: UInt32 = 0

                // Send print data
                try port.write(writeBuffer: command, offset: total, size: UInt32(command.count) - total, numberOfBytesWritten: &written)

                total += written
            }

            // Stop to check the completion of printing
            try port.endCheckedBlock(starPrinterStatus: &printerStatus, level: 2)

            if printerStatus.offline == sm_true {
                break    // The printer is offline.
            }

            // Success
            break
            }
            catch let error as NSError {
                print("NS Error", error)
                break    // Some error occurred.
            }
        }
        return Text("Hello, world!")
            .padding()
    }
}

let sm_true:  UInt32 = 1     // SM_TRUE
let sm_false: UInt32 = 0     // SM_FALSE

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
