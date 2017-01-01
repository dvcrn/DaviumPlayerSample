//
//  AloeImageUtil.swift
//  Pods
//
//  Created by kawase yu on 2015/09/16.
//
//

import UIKit
import AlamofireImage
import Alamofire

public typealias AloeImageCallback = (_ image:UIImage, _ key:String, _ useCache:Bool)->()
public typealias AloeImageFailCallback = ()->()

open class AloeImage: NSObject {
   
    fileprivate let imageCache = AutoPurgingImageCache()
    fileprivate let downloader = ImageDownloader()
    
    open static let instance = AloeImage()
    override fileprivate init(){
        super.init()
    }
    
    open func loadImage(_ imageUrl:String, callback:@escaping AloeImageCallback, fail:AloeImageFailCallback?){
        
        if let cache = imageCache.image(withIdentifier: imageUrl) as Image?{
            callback(cache, imageUrl, true)
        }
        
        guard let url = URL(string: imageUrl) else {
            if let f = fail as AloeImageFailCallback?{
                f()
            }
            return
        }

        let request:URLRequest = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        
        downloader.download(request) { (response) in

            if let image = response.result.value as Image? {
                self.imageCache.add(image, withIdentifier: imageUrl)
                callback(image, imageUrl, false)
            }else{
                if let f = fail as AloeImageFailCallback?{
                    f()
                }
            }
        }
    }
    
    open func clearImageCache(){
        imageCache.removeAllImages()
    }
    
    open class func imageFromUIView(_ myUIView:UIView) ->UIImage
    {
        UIGraphicsBeginImageContextWithOptions(myUIView.frame.size, false, 0);//必要なサイズ確保
        let context:CGContext = UIGraphicsGetCurrentContext()!;
        context.translateBy(x: -myUIView.frame.origin.x, y: -myUIView.frame.origin.y);
        myUIView.layer.render(in: context);
        let renderedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext();
        return renderedImage;
    }
    
    open class func ImageViewFromUIView(_ view:UIView)->UIImageView{
        return UIImageView(image: self.imageFromUIView(view))
    }
    
    open class func fixWidthImage(_ originalImage:UIImage, width:CGFloat)->UIImage{
        let originalWidth = originalImage.size.width
        let originalHeight = originalImage.size.height
        
        let rate = width / originalWidth
        let height = originalHeight * rate
        
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
        originalImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
    open class func fixHeightImage(_ originalImage:UIImage, height:CGFloat)->UIImage{
        let originalWidth = originalImage.size.width
        let originalHeight = originalImage.size.height
        
        let rate = height / originalHeight
        let width = originalWidth * rate
        
        let size = CGSize(width: width, height: height)
        UIGraphicsBeginImageContextWithOptions(size, true, 2.0)
        originalImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
    }
    
    open class func cropImage(_ originalImage:UIImage, frame:CGRect)->UIImage{
        let scale:CGFloat = originalImage.scale;
        
        let cliprect = CGRect(x: frame.origin.x, y: frame.origin.y,
            width: frame.size.width, height: frame.size.height);
        
        func rad(_ deg:Double)->CGFloat{
            return CGFloat(deg / 180.0 * M_PI);
        }
        
        var rectTransform:CGAffineTransform
        switch originalImage.imageOrientation {
        case UIImageOrientation.left:
            rectTransform = CGAffineTransform(rotationAngle: rad(90)).translatedBy(x: 0, y: -cliprect.size.height);
            break;
        case UIImageOrientation.right:
            rectTransform = CGAffineTransform(rotationAngle: rad(-90)).translatedBy(x: -cliprect.size.width, y: 0);
            break;
        case UIImageOrientation.down:
            rectTransform = CGAffineTransform(rotationAngle: rad(-180)).translatedBy(x: -cliprect.size.width, y: -cliprect.size.height);
            break;
        default:
            rectTransform = CGAffineTransform.identity;
        };
        
        rectTransform = rectTransform.scaledBy(x: scale, y: scale);
        
        let srcImgRef = originalImage.cgImage
        let imgRef = srcImgRef!.cropping(to: cliprect.applying(rectTransform));
        
        print(originalImage.imageOrientation.rawValue)
        let resultImage = UIImage(cgImage: imgRef!, scale: scale, orientation: originalImage.imageOrientation)
        
        return resultImage;
    }
    
}
