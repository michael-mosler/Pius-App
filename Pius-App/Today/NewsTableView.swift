//
//  NewsTableView.swift
//  Pius-App
//
//  Created by Michael Mosler-Krings on 27.11.18.
//  Copyright © 2018 Felix Krings. All rights reserved.
//

import UIKit

class NewsTableView: UITableView, UITableViewDelegate, UITableViewDataSource {
    private var sender: UITableView?;
    private let newsLoader = NewsLoader();
    private var newsItems: NewsItems?;

    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    private func doUpdate(with newsItems: NewsItems?, online: Bool) {
        if newsItems == nil {
            self.newsItems = [];
        } else {
            self.newsItems = newsItems;
        }
        
        DispatchQueue.main.async {
            self.dataSource = self;
            self.delegate = self;

            self.sender?.beginUpdates();
            self.reloadData();
            self.layoutSubviews();
            self.sender?.endUpdates();
        }
    }

    func loadData(sender: UITableView) {
        self.sender = sender;
        newsLoader.load(doUpdate);
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let newsItems = self.newsItems else { return 0; }
        return newsItems.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let newsItems = self.newsItems, let text = newsItems[indexPath.row].text else { return UITableViewCell(); }
        let cell = tableView.dequeueReusableCell(withIdentifier: "newsItem") as! NewsTableViewCell;

        if let imgUrl = newsItems[indexPath.row].imgUrl {
            do {
                let url = URL(string: imgUrl);
                let data = try Data(contentsOf : url!);
                let image = resizeImage(image: UIImage(data : data)!, targetSize: CGSize(width: 64, height: 64));
                cell.newsItemImageView.image = image;
            }
            catch {
                print("Failed to load image from \(imgUrl)");
            }
        }

        if text.count > 200 {
            let index = text.index(text.startIndex, offsetBy: 160)
            cell.newsItemTextLabel.text = String(newsItems[indexPath.row].text![..<index]) + "...";
        } else {
            cell.newsItemTextLabel.text = text;
        }

        return cell;
    }
}
