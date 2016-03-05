//
//  async.swift
//  slimane
//
//  Created by Yuki Takei on 1/11/16.
//  Copyright © 2016 MikeTOKYO. All rights reserved.
//

internal typealias SeriesCB = ((ErrorType?) -> ()) -> ()

internal func seriesTask(tasks: [SeriesCB], _ completion: (ErrorType?) -> Void) {
    if tasks.count == 0 {
        completion(nil)
        return
    }
    
    var index = 0
    
    func _series(current: SeriesCB?) {
        if let cur = current {
            cur { err in
                if err != nil {
                    return completion(err)
                }
                index += 1
                let next: SeriesCB? = index < tasks.count ? tasks[index] : nil
                _series(next)
            }
        } else {
            completion(nil)
        }
    }
    
    _series(tasks[index])
}