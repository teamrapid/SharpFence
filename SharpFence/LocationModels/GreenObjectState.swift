//
//  StateModel.swift
//  SharpFence
//
//  Created by Sebin on 17-01-2018.
//  Copyright © 2018 Rapid Value. All rights reserved.
//

import Foundation
import CoreLocation


class GreenObjectState: AbstractObjectState {
    
    
    var identifier: String {
        get {
            //code to execute
            return  self.identifier
        }
        set(newValue) {
            //code to execute
            self.identifier = newValue
        }
    }
    
    
    func processChangeState(wrapper:ObjectStateWrapper,fenceEvent: FenceEventModel, deviceEvent:DeviceEventModel){
        if(fenceEvent.isEventEntry()){
            processEntry(wrapper: wrapper, fenceEvent: fenceEvent, deviceEvent: deviceEvent)
        }else if (fenceEvent.isEventExit()){
            processExit(wrapper: wrapper,fenceEvent: fenceEvent);
        }
    }
    
    private func processExit(wrapper:ObjectStateWrapper,fenceEvent:FenceEventModel){
        CoreDataWrapper.addFenceEventToDB(stateObject: self, event: fenceEvent)
        wrapper.setState(state: WhiteObjectState())
        
    }
    
    
    private func processEntry(wrapper:ObjectStateWrapper,fenceEvent:FenceEventModel, deviceEvent: DeviceEventModel){
        let skippedState = WhiteObjectState()
        skippedState.processChangeState(wrapper: wrapper, fenceEvent: fenceEvent, deviceEvent: deviceEvent)
       // CoreDataWrapper.addFenceEventToDB(stateObject: self, event: fenceEvent)
        wrapper.setState(state: GreenObjectState())
    }
    
    // To be reviewed
    

    
    
}
