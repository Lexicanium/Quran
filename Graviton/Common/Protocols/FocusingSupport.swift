//
//  FocusingSupport.swift
//  Graviton
//
//  Created by Sihao Lu on 1/8/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import SceneKit

protocol FocusingSupport {
    var focusedNode: SCNNode? { get }
    func focus(atNode node: SCNNode)
}
