//
//  SheetBackgroundClearView.swift
//  ModalFullscreenImage
//
//  Created by ryo.tsuzukihashi on 2024/12/30.
//

import SwiftUI

/// sheet/fullScreenCoverで表示した親Viewを透明にしたView
struct SheetBackgroundClearView: UIViewRepresentable {
    func makeUIView(context _: Context) -> UIView {
        let view = ParentClearView()
        return view
    }

    func updateUIView(_: UIView, context _: Context) {}

    class ParentClearView: UIView {
        override func layoutSubviews() {
            guard let parentView = superview?.superview else { return }
            parentView.backgroundColor = .clear
        }
    }
}

