//
//  ViewController.swift
//  TestVector
//
//  Created by Roman Kavinskyi on 10/14/22.
//

import UIKit
import PDFKit

class ViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!

    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    let topImageView = UIImageView()
    let bottomImageView = UIImageView()

    let start = Date().timeIntervalSince1970

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.backgroundColor = .orange
        setupScrollView()
        setupImageView()
//        fetchImage()
//        bottomImageView.loadWithSVGKit(urlString: "https://openclipart.org/download/181651/manhammock.svg")
        bottomImageView.loadWithWebView(urlString: "https://openclipart.org/download/181651/manhammock.svg")
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
        let topFrame = CGRect(x: 0,
                              y: 0,
                              width: contentView.frame.width,
                              height: contentView.frame.height / 2)

        topImageView.frame = topFrame
        topImageView.contentMode = .scaleAspectFit
        contentView.addSubview(topImageView)

        topImageView.image = UIImage(named: "zzz")

        let bottomFrame = CGRect(x: 0,
                                 y: contentView.frame.height / 2,
                                 width: contentView.frame.width,
                                 height: contentView.frame.height / 2)
        bottomImageView.frame = bottomFrame
        bottomImageView.contentMode = .scaleAspectFit
        contentView.addSubview(bottomImageView)
    }


    func convertPDFDataToImage() -> UIImage? {
        let url = URL(string: "http://naitbit.com/chess/zzz.pdf")!
        guard let document = CGPDFDocument(url as CFURL),
              let page = document.page(at: 1) else { return nil }

        let dpi: CGFloat = 9
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
        print(imageData.count / 1000)
        return UIImage(data: imageData)
    }

    func fetchImage() {
        let url = URL(string: "http://naitbit.com/chess/zzz.pdf")!
        let request = URLRequest(url: url)
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data else { fatalError() }

            DispatchQueue.main.async {
                self.bottomImageView.image = self.convertPDFDataToImage(from: data)
            }
        }
        .resume()
    }

    func convertPDFDataToImage(from data: Data) -> UIImage? {
        guard let document = PDFDocument(data: data),
              let page = document.page(at: 0) else { return nil }

        let dpi: CGFloat = 9
        let pageRect = page.bounds(for: .mediaBox)
        let imageSize = CGSize(width: pageRect.size.width * dpi, height: pageRect.size.height * dpi)

        let renderer = UIGraphicsImageRenderer(size: imageSize)

        let imageData = renderer.pngData { cnv in
            UIColor.clear.set()
            cnv.fill(pageRect)
            cnv.cgContext.interpolationQuality = .high
            cnv.cgContext.translateBy(x: 0.0, y: pageRect.size.height * dpi)
            cnv.cgContext.scaleBy(x: dpi, y: -dpi)

            page.draw(with: .mediaBox, to: cnv.cgContext)
        }
        print(imageData.count / 1000)
        print(Date().timeIntervalSince1970 - start)
        return UIImage(data: imageData)
    }
}

extension ViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
}

import SVGKit

extension UIImageView {
    func loadWithSVGKit(urlString: String) {
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let receivedicon: SVGKImage = SVGKImage(data: data),
                let image = receivedicon.uiImage
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }
}

import WebKit

extension UIImageView: UIWebViewDelegate {

    private func prepareForWebView() -> WKWebView {
        let webView = WKWebView()
        webView.scrollView.isScrollEnabled = false
        webView.contentMode = .scaleAspectFit
        webView.backgroundColor = .clear
        webView.isOpaque = false
        addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: trailingAnchor),
            webView.topAnchor.constraint(equalTo: topAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        return webView
    }

    func loadWithWebView(urlString: String) {
        let webView = prepareForWebView()
        webView.stopLoading()
        if let url = URL(string: urlString) {
            webView.load(URLRequest(url: url))
        }
    }
}
