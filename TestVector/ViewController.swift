//
//  ViewController.swift
//  TestVector
//
//  Created by Roman Kavinskyi on 10/14/22.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = .orange
        setupScrollView()
        setupImageView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        heightConstraint?.constant = view.frame.height
    }

    func setupScrollView() {
        scrollView.maximumZoomScale = 10
        scrollView.minimumZoomScale = 0.1
        scrollView.zoomScale = 1.0
    }

    func setupImageView() {
        imageView.frame = contentView.frame
        imageView.contentMode = .scaleAspectFit
        contentView.addSubview(imageView)

//        imageView.image = UIImage(named: "zzz")
        imageView.image = convertPDFDataToImage()
    }


    func convertPDFDataToImage() -> UIImage? {
        let url = URL(string: "http://naitbit.com/chess/zzz.pdf")!
        guard let document = CGPDFDocument(url as CFURL),
              let page = document.page(at: 1) else { return nil }

        let dpi: CGFloat = 300.0 / 72.0
        let pageRect = page.getBoxRect(.mediaBox)
        let imageSize = CGSize(width: pageRect.size.width * dpi, height: pageRect.size.height * dpi)

        let renderer = UIGraphicsImageRenderer(size: imageSize)

        let imageData = renderer.pngData { cnv in
            UIColor.clear.set()
            cnv.fill(pageRect)
            cnv.cgContext.interpolationQuality = .high
            cnv.cgContext.translateBy(x: 0.0, y: pageRect.size.height * dpi)
            cnv.cgContext.scaleBy(x: dpi, y: -dpi)
            cnv.cgContext.drawPDFPage(page)
        }

        return UIImage(data: imageData)
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
