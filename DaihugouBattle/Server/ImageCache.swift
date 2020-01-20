//
//  ImageCache.swift
//  DaihugouBattle
//
//  Created by main on 2018/09/23.
//  Copyright © 2018 Main. All rights reserved.
//

import Foundation
import UIKit

final class RealmImageCache{
    static let shared = RealmImageCache()
    private typealias Key = NSNumber
    private var cache = NSCache<Key, UIImage>()
    private var loadings: [String : [() -> ()]] = [:]
    
    var countLimit: Int = 0{
        didSet{
            cache.countLimit = countLimit
        }
    }
    
    var totalCostLimit: Int = 0{
        didSet{
            cache.totalCostLimit = totalCostLimit
        }
    }
    
    func image(_ named: String)-> UIImage?{
        if let image = cache.object(forKey: convertKey(from: named)){
            return image
        }

        loadImage(named)
        return cache.object(forKey: convertKey(from: named))
    }
    
    func imageInBackground(_ named: String, completion: @escaping (_ image: UIImage?) -> ()){
        if let image = cache.object(forKey: convertKey(from: named)){
            completion(image)
            return
        }
        
        loadImageBackground(named, completion: {
            [weak self] in
            guard let `self` = self else {
                completion(nil)
                return
            }
            completion(self.cache.object(forKey: self.convertKey(from: named)))
        })
    }
    
    func loadImage(_ named: String){
        guard cache.object(forKey: convertKey(from: named)) == nil,
            let image = DataRealm.get(imageNamed: named) else{
                return
        }
        let i = drawImage(image)
        cache.setObject(i, forKey: convertKey(from: named))
        return
    }
    
    func loadImageBackground(_ named: String, completion: @escaping () -> ()){
        guard cache.object(forKey: convertKey(from: named)) == nil,
            let image = DataRealm.get(imageNamed: named) else{
                completion()
                return
        }
        if loadings[named] != nil{
            loadings[named]?.append(completion)
            return
        }
        
        loadings[named] = [completion]
        DispatchQueue.global(qos: .userInitiated).async {
            [weak self] in
            guard let `self` = self else {
                return
            }
            let i = self.drawImage(image)
            self.cache.setObject(i, forKey: self.convertKey(from: named))
            DispatchQueue.main.async {
                self.loadings[named]?.forEach({ $0() })
                self.loadings[named] = nil
            }
        }
    }
    
    func loadImagesBackground(_ nameds: [String], completion: @escaping () -> ()){
        let group = DispatchGroup()
        for named in nameds{
            group.enter()
            loadImageBackground(named, completion: {
                group.leave()
            })
        }
        group.notify(queue: .main, execute: completion)
    }
    
    func removeAllImages(){
        cache.removeAllObjects()
    }
    
    func removeImage(forKey: String){
        cache.removeObject(forKey: convertKey(from: forKey))
    }
    
    func removeImages(forKeys: [String]){
        for key in forKeys{
            removeImage(forKey: key)
        }
    }
    
    
    private func drawImage(_ image: UIImage)-> UIImage{
        UIGraphicsBeginImageContext(CGSize(width: image.size.width, height: image.size.height))
        image.draw(at: CGPoint(x: 0, y: 0))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    private func convertKey(from named: String)-> Key{
        return named.hashValue.nsNumber
    }
    
    private func cost(from image: UIImage)-> Int{
        return (image.size.width * image.size.height * image.scale * image.scale).i
    }
}


extension UIImageView{
    func setRealmImage(_ imageNamed: String){
        RealmImageCache.shared.imageInBackground(imageNamed, completion: {
            [weak self] image in
            self?.image = image
        })
    }
}


extension CALayer{
    func setRealmImage(_ imageNamed: String){
        RealmImageCache.shared.imageInBackground(imageNamed, completion: {
            [weak self] image in
            self?.contents = image?.cgImage
        })
    }
}
