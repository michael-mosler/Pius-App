//
//  Protocols.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 17.11.19.
//  Copyright © 2019 Felix Krings. All rights reserved.
//

import Foundation

protocol TimerDelegate: NSObject {
    func onTick(_ timer: Timer?)
}

/*
 * Observer protocol for data loaders. Data loaders must call didLoadData() when
 * data has been loaded from backend.
 */
protocol ItemContainerProtocol {
    func didLoadData(_ sender: Any?)
    func perform(segue: String, with data: Any?)
    
    func registerTimerDelegate(_ delegate: TimerDelegate)
}
