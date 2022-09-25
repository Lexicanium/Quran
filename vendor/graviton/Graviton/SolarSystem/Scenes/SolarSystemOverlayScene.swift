//
//  SolarSystemOverlayScene.swift
//  Graviton
//
//  Created by Ben Lu on 1/9/17.
//  Copyright © 2017 Ben Lu. All rights reserved.
//

import SpriteKit
import UIKit

class SolarSystemOverlayScene: SKScene {
    lazy var velocityLabel: SKLabelNode = {
        self.monoLabel()
    }()

    lazy var distanceLabel: SKLabelNode = {
        self.monoLabel()
    }()

    private func monoLabel() -> SKLabelNode {
        let label = SKLabelNode()
        label.fontName = "Menlo"
        label.fontSize = 10
        label.fontColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        return label
    }

    public override init(size: CGSize) {
        super.init(size: size)
        backgroundColor = UIColor.black
        addChild(velocityLabel)
        addChild(distanceLabel)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
