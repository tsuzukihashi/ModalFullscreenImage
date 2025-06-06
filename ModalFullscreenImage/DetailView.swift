//
//  DetailView.swift
//  ModalFullscreenImage
//
//  Created by ryo.tsuzukihashi on 2024/12/20.
//

import SwiftUI

struct DetailView: View {
  @State var showImageDetail: Bool = false
  @State var transform: CGAffineTransform = .identity
  @State var bottomInsets: CGFloat = .zero

  var body: some View {
    NavigationStack {
      ScrollViewReader { scrollProxy in
        ScrollView {
          VStack {
            Image(.sample)
              .resizable()
              .scaledToFit()
              .opacity(showImageDetail ? 0 : 1)
              .scaleEffect(x: transform.scaleX, y: transform.scaleY, anchor: .zero)
              .offset(x: transform.tx, y: transform.ty)
              .contentShape(Rectangle())
              .onTapGesture {
                var transaction = Transaction()
                transaction.disablesAnimations = true
                withTransaction(transaction) {
                  showImageDetail.toggle()
                }
                scrollProxy.scrollTo("top", anchor: .top)
              }
              .id("top")
              .zIndex(.infinity)

            Text("私わたくしはその人を常に先生と呼んでいた。だからここでもただ先生と書くだけで本名は打ち明けない。これは世間を憚はばかる遠慮というよりも、その方が私にとって自然だからである。私はその人の記憶を呼び起すごとに、すぐ「先生」といいたくなる。筆を執とっても心持は同じ事である。よそよそしい頭文字かしらもじなどはとても使う気にならない。私が先生と知り合いになったのは鎌倉かまくらである。その時私はまだ若々しい書生であった。暑中休暇を利用して海水浴に行った友達からぜひ来いという端書はがきを受け取ったので、私は多少の金を工面くめんして、出掛ける事にした。私は金の工面に二に、三日さんちを費やした。ところが私が鎌倉に着いて三日と経たたないうちに、私を呼び寄せた友達は、急に国元から帰れという電報を受け取った。電報には母が病気だからと断ってあったけれども友達はそれを信じなかった。友達はかねてから国元にいる親たちに勧すすまない結婚を強しいられていた。彼は現代の習慣からいうと結婚するにはあまり年が若過ぎた。それに肝心かんじんの当人が気に入らなかった。それで夏休みに当然帰るべきところを、わざと避けて東京の近くで遊んでいたのである。彼は電報を私に見せてどうしようと相談をした。私にはどうしていいか分らなかった。けれども実際彼の母が病気であるとすれば彼は固もとより帰るべきはずであった。それで彼はとうとう帰る事になった。せっかく来た私は一人取り残された。")
          }
        }
        .navigationTitle("投稿詳細")
        .navigationBarTitleDisplayMode(.inline)
      }

    }
    .animation(.easeInOut, value: showImageDetail)
    .animation(.easeInOut, value: transform)
    .onGeometryChange(for: EdgeInsets.self, of: { proxy in
      proxy.safeAreaInsets
    }, action: { newValue in
      bottomInsets = newValue.bottom
    })
    .onChange(of: showImageDetail, perform: { _ in
      transform = .identity
    })
    .fullScreenCover(isPresented: $showImageDetail) {
      ImageDetailView(
        showImageDetail: $showImageDetail,
        transform: $transform,
        bottomInsets: $bottomInsets
      )
      .ignoresSafeArea(.all)
      .background(SheetBackgroundClearView())
    }
  }
}

#Preview {
  DetailView()
}

