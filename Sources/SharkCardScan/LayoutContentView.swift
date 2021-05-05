import UIKit

final class LayerContentView<Layer: CALayer>: UIView {
    
    let contentLayer: Layer
    init(frame: CGRect = .zero, contentLayer: Layer) {
        self.contentLayer = contentLayer
        super.init(frame: frame)
        contentLayer.frame = frame
        layer.addSublayer(contentLayer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard contentLayer.frame != bounds else {
            return
        }
        contentLayer.frame = bounds
    }
}
