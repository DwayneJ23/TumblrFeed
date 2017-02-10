//
//  PhotoDetailsViewController.swift
//  TumblrFeed
//
//  Created by Dwayne Johnson on 2/8/17.
//  Copyright © 2017 Dwayne Johnson. All rights reserved.
//

import UIKit

class PhotoDetailsViewController: UIViewController
{
    
    @IBOutlet weak var detailPhotoImage: UIImageView!
    
    var post: NSDictionary!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*let photos = post.value(forKeyPath: "photos") as? [NSDictionary]
        let imageUrlString = photos?[0].value(forKeyPath: "original_size.url") as! String
        let imageUrl = URL(string: imageUrlString)!
        detailPhotoImage.setImageWith(imageUrl)*/

        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            
            // Get the original size image url
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            
            // Convert imageUrlString to NSURL so long as its not nil
            if let imageUrl = URL(string: imageUrlString!) {
                
                // Set the image view in the cell so long as nothing is ni
                detailPhotoImage.setImageWith(imageUrl)
            }
        }

        
       // print(post)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
