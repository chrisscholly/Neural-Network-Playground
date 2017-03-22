import UIKit

@objc public protocol InteractiveGraphDelegate: class {
    @objc optional func didAddPoint(graph: InteractiveGraph, newPoint: CGPoint)
}

public class InteractiveGraph: UIView {
    // MARK: - Public properties
    public var points: [CGPoint] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    public var circleRadius: CGFloat = 5 {
        didSet {
            setNeedsDisplay()
        }
    }
    public var dotColor: UIColor = #colorLiteral(red: 0.3647058904, green: 0.06666667014, blue: 0.9686274529, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    public var strokeColor: UIColor = #colorLiteral(red: 0.1960784346, green: 0.3411764801, blue: 0.1019607857, alpha: 1) {
        didSet {
            setNeedsDisplay()
        }
    }
    public var continuousFunction: ((Double) -> Double)? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public weak var delegate: InteractiveGraphDelegate?
    
    
    // MARK: - Private properties
    private var tapGesture = UITapGestureRecognizer()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        init2()
    }
    
    
    // MARK: - Initialization
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        init2()
    }
    
    private func init2() {
        tapGesture.addTarget(self, action: #selector(receivedTap))
        addGestureRecognizer(tapGesture)
        
        backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    // MARK: - Gesture actions
    @objc private func receivedTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        points.append(location)
        delegate?.didAddPoint?(graph: self, newPoint: location)

        setNeedsDisplay()
    }
    
    
    // MARK: - Drawing logic
    public override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        // we don't want to do anything if we have no context
        if let context = UIGraphicsGetCurrentContext() {
            drawPoints(context: context)
            drawContinuousFunction()
        }
    }
    
    private func drawContinuousFunction() {
        // make sure we have a function to graph
        guard let continuousFunction = continuousFunction else {
            return
        }
        
        let path = UIBezierPath()
        for x in 0..<Int(bounds.width) {
            let y = Double(bounds.height) - continuousFunction(Double(x))
            let point = CGPoint(x: CGFloat(x), y: CGFloat(y))
            
            if x == 0 {
                path.move(to: point)
            }
            else {
                path.addLine(to: point)
            }
        }
        
        // stroke the line
        strokeColor.set()
        path.stroke()
    }
    
    private func drawPoints(context: CGContext) {
        // calculate the translation and size
        let pointTranslation = CGAffineTransform(translationX: -circleRadius, y: -circleRadius)
        let circleSize = CGSize(width: circleRadius * 2, height: circleRadius * 2)
        
        // add to context
        for centerPoint in points {
            // get (top left) location of circle
            let point = centerPoint.applying(pointTranslation)
            let location = CGRect(origin: point, size: circleSize)
            context.addEllipse(in: location)
        }
        
        // stroke the circles
        dotColor.set()
        context.strokePath()
    }
}
