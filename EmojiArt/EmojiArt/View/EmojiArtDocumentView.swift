//
//  ContentView.swift
//  EmojiArt
//
//  Created by kuko on 06/08/2021.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    
    let defaultEmojiSize: CGFloat = 40
    let tmpEmojis = "😀😄😇😖😳🤬🤯"
    
    var body: some View {
        VStack(spacing: 0) {
            documentBody
            palette
        }
    }
    
    // MARK: - Document Component
    var documentBody: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(convertFromEmojiCords((0, 0), in: geometry))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundImageFetchStatus == .fetching {
                    ProgressView()
                } else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                            //.onDrag { NSItemProvider(object: emoji.text as NSString) }
                    }
                }
            }
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .clipped() // ensures that the background image doesnt go over bounds, i.e. under palette
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return drop(providers: providers, at: location, in: geometry) // return doesnt hove to be here
            }
        }
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        convertFromEmojiCords((emoji.x, emoji.y), in: geometry)
    }
    
    private func drop(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self) { url in
            document.setBackground(EmojiArtModel.Background.url(url.imageURL))
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }
        
        if !found {
            found = providers.loadObjects(ofType: String.self) { string in
                if let emoji = string.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: convertToEmojiCords(location, in: geometry),
                        size: defaultEmojiSize / zoomScale
                    )
                }
            }
        }
            
        return found
    }
    
    private func convertToEmojiCords(_ location: CGPoint, in geometry: GeometryProxy) -> (x: Int, y: Int) {
        let center = geometry.frame(in: .local).center
        let location = CGPoint(
            x: location.x - panOffset.width - center.x / zoomScale,
            y: location.y - panOffset.height - center.y / zoomScale
        )
        
        return (Int(location.x), Int(location.y))
    }
    
    private func convertFromEmojiCords(_ location: (x: Int, y: Int), in geometry: GeometryProxy) -> CGPoint {
        let center = geometry.frame(in: .local).center
        return CGPoint(
            x: center.x + CGFloat(location.x) * zoomScale + panOffset.width,
            y: center.y + CGFloat(location.y) * zoomScale + panOffset.height
        )
    }
    
    // Used with "Pan/Drag" Gesture
    @State private var steadyStatePanOffset: CGSize = CGSize.zero
    @GestureState private var gesturePanOffset: CGSize = CGSize.zero
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale // you cant do + with CGSize by default, this is extension from /Utility
    }
    
    // Used with "Pinch" Gesture
    @State private var steadyZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    private var zoomScale: CGFloat {
        steadyZoomScale * gestureZoomScale
    }
    
    private func zoomToFit(_ image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width // horizontal zoom
            let vZoom = size.height / image.size.height // vertical zoom
            steadyZoomScale = min(hZoom, vZoom)
            steadyStatePanOffset = .zero
            
        }
    }
    
    // MARK: - Gestures
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in // the '_' is transaction, that we dont need
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureValue in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureValue.translation / zoomScale)
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, ourGestureStateInOut, _ in // the '_' is transaction, that we dont need
                ourGestureStateInOut = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in // this needs a var (gestureScaleAtEnd), that contains the magnitude of the pinch (idk)
                steadyZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation {
                    zoomToFit(document.backgroundImage, in: size)
                }
            }
    }
    
    // MARK: - Palette Component
    var palette: some View {
        ScrollingEmojisView(emojis: tmpEmojis)
            .font(.system(size: defaultEmojiSize))
    }
}


struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag { NSItemProvider(object: emoji as NSString) }
                }
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
