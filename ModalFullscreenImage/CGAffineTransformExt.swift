//
//  CGAffineTransformExt.swift
//  ModalFullscreenImage
//
//  Created by ryo.tsuzukihashi on 2024/12/30.
//

import Foundation

extension CGAffineTransform {
  static func anchoredScale(scale: CGFloat, anchor: CGPoint) -> CGAffineTransform {
    .init(translationX: anchor.x, y: anchor.y)
    .scaledBy(x: scale, y: scale)
    .translatedBy(x: -anchor.x, y: -anchor.y)
  }

  var scaleX: CGFloat {
    sqrt(a * a + c * c)
  }

  var scaleY: CGFloat {
    sqrt(b * b + d * d)
  }
}
