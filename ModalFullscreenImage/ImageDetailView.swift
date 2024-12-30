//
//  ImageDetailView.swift
//  ModalFullscreenImage
//
//  Created by ryo.tsuzukihashi on 2024/12/27.
//

import Foundation
import SwiftUI

struct ImageDetailView: View {
    enum Constants {
        /// 最小ズームスケール
        static let minZoomScale: CGFloat = 1
    }

    @Binding var showImageDetail: Bool
    @Binding var transform: CGAffineTransform
    @Binding var bottomInsets: CGFloat
    // 表示領域のサイズ
    @State private var contentSize: CGSize = .zero
    @State private var showAnimation: Bool = false
    @State private var lastTransform: CGAffineTransform = .identity
    @State private var backgroundOpacity: CGFloat = 1.0

    var body: some View {
        ZStack {
            Color.black.opacity(showAnimation ? (backgroundOpacity * 1.0) : 0).ignoresSafeArea()
            Image(.sample)
                .resizable()
                .scaledToFit()
                .animatableTransformEffect(transform)
                .offset(y: -bottomInsets)
                .gesture(dragGesture)
                .gesture(singleTapGesture)
                .modify { view in
                    if #available(iOS 17.0, *) {
                        view.gesture(magnificationGesture)
                    } else {
                        view.gesture(oldMagnificationGesture)
                    }
                }
                .onGeometryChange(for: CGSize.self) { proxy in
                    proxy.size
                } action: { newValue in
                    contentSize = newValue
                }
        }
        .overlay(alignment: .bottomLeading) {
            Button {
                Task {
                    await dismissImage()
                }
            } label: {
                Image(systemName: "xmark")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.white)
                    .padding(.bottom, -bottomInsets)
            }
        }
        .opacity(showImageDetail ? 1 : 0)
        .animation(.easeInOut, value: transform)
        .animation(.easeInOut, value: backgroundOpacity)
        .animation(.easeInOut, value: bottomInsets)
        .onAppear {
            transform = .identity
            withAnimation(.easeInOut(duration: 0.2)) {
                showAnimation = true
                bottomInsets = -bottomInsets
            }
        }
    }

    /// ImageDetailを閉じる
    private func dismissImage() async {
        // 0.2秒で前画面の画像の高さの位置に戻す
        withAnimation(.easeInOut(duration: 0.2)) {
            bottomInsets = -bottomInsets
        }
        try? await Task.sleep(nanoseconds: 200 * 1000 * 1000)
        // 0.1秒で背景色を透明にしていく
        withAnimation(.easeInOut(duration: 0.1)) {
            showAnimation = false
        }
        try? await Task.sleep(nanoseconds: 100 * 1000 * 1000)
        // 遷移アニメーションを無効にする
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            showImageDetail = false
        }
    }

    /// 画像を並行移動する処理
    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                // スワイプ移動量のスケールを調整
                let scaleFactor: CGFloat = 0.8
                let adjustedTranslation = CGSize(
                    width: value.translation.width * scaleFactor,
                    height: value.translation.height * scaleFactor
                )
                // デフォルト倍率のとき、上下方向のスワイプで画像の大きさ、背景色を変更する
                if (lastTransform.scaleX == 1) && (lastTransform.scaleY == 1) {
                    let verticalOffset = abs(adjustedTranslation.height) / contentSize.height
                    let scale = max(0.8, 1.0 - verticalOffset * 0.7)
                    let newTransform = lastTransform
                        .translatedBy(
                            x: adjustedTranslation.width / transform.scaleX,
                            y: adjustedTranslation.height / transform.scaleY
                        )
                        .scaledBy(x: scale, y: scale)

                    transform = newTransform
                    backgroundOpacity = max(0.0, 1.0 - verticalOffset)
                } else {
                    // ズームしている状態なら、普通に並行移動する
                    transform = lastTransform.translatedBy(
                        x: value.translation.width / transform.scaleX,
                        y: value.translation.height / transform.scaleY
                    )
                }
            }
            .onEnded({ value in
                // デフォルト倍率のとき
                if (lastTransform.scaleX == 1) && (lastTransform.scaleY == 1) {
                    let verticalOffset = abs(value.translation.height) / contentSize.height
                    // 規定値より上下にスワイプしていたら閉じる
                    if verticalOffset > 0.3 {
                        Task {
                            await dismissImage()
                        }
                    } else {
                        // 規定値より上下にスワイプしていないなら状態を元に戻す
                        transform = .identity
                        lastTransform = .identity
                        backgroundOpacity = 1.0
                    }
                } else {
                    // デフォルト倍率でないなら、
                    onEndGesture()
                }
            })
    }

    /// 画像をタップしたとき、タップした位置にズームする
    /// 既にズームしていたならば、リセットする
    private var singleTapGesture: some Gesture {
        SpatialTapGesture(count: 1)
            .onEnded { value in
                let newTransform: CGAffineTransform =
                if transform.isIdentity {
                    .anchoredScale(scale: 3, anchor: value.location)
                } else {
                    .identity
                }
                transform = newTransform
                lastTransform = newTransform
            }
    }

    /// 表示されている位置を中心にズームできる
    @available(iOS 17.0, *)
    private var magnificationGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let newTransform = CGAffineTransform.anchoredScale(
                    scale: value.magnification,
                    anchor: .init(
                        x: value.startAnchor.x * contentSize.width,
                        y: value.startAnchor.y * contentSize.height
                    )
                )
                transform = lastTransform.concatenating(newTransform)
            }
            .onEnded { value in
                onEndGesture()
            }
    }

    /// 表示されている位置関係なく左上にズームできる
    @available(iOS, introduced: 16.0, deprecated: 17.0)
    private var oldMagnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                transform = lastTransform.scaledBy(x: value, y: value)
            }
            .onEnded { value in
                onEndGesture()
            }
    }

    /// Gesture終了後の共通処理
    private func onEndGesture() {
        let newTransform = limitTransform(transform)
        transform = newTransform
        lastTransform = newTransform
    }

    /// スワイプ、ズーム終了後に画像がない範囲に移動しないように制御
    private func limitTransform(_ transform: CGAffineTransform) -> CGAffineTransform {
        let scaleX = transform.scaleX
        let scaleY = transform.scaleY

        if scaleX < Constants.minZoomScale
            || scaleY < Constants.minZoomScale
        {
            return .identity
        }

        let maxX = contentSize.width * (scaleX - 1)
        let maxY = contentSize.height * (scaleY - 1)

        if transform.tx > 0
            || transform.tx < -maxX
            || transform.ty > 0
            || transform.ty < -maxY
        {
            let tx = min(max(transform.tx, -maxX), 0)
            let ty = min(max(transform.ty, -maxY), 0)
            var transform = transform
            transform.tx = tx
            transform.ty = ty
            return transform
        }

        return transform
    }
}

private extension View {
    @ViewBuilder
    func modify(@ViewBuilder _ fn: (Self) -> some View) -> some View {
        fn(self)
    }

    @ViewBuilder
    func animatableTransformEffect(_ transform: CGAffineTransform) -> some View {
        scaleEffect(
            x: transform.scaleX,
            y: transform.scaleY,
            anchor: .zero
        )
        .offset(x: transform.tx, y: transform.ty)
    }
}
