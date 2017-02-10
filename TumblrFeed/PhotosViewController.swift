//
//  PhotosViewController.swift
//  TumblrFeed
//
//  Created by Dwayne Johnson on 2/2/17.
//  Copyright © 2017 Dwayne Johnson. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD


class PhotosViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var photosView: UITableView!
    var posts: [NSDictionary]?
    
    // Initialize a UIRefreshControl
    var refreshControl = UIRefreshControl()
    
    var scrollView = UIScrollView()
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        // add refresh control to table view
        photosView.insertSubview(refreshControl, at: 0)
        
        photosView.delegate = self
        photosView.dataSource = self
        
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x: 0, y: photosView.contentSize.height, width: photosView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        photosView.addSubview(loadingMoreView!)
        
        var insets = photosView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        photosView.contentInset = insets
        
        
        // Diplay HUD right before the request is made
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        
        //Load data from Tubmlr API
        networkRequest()
        
        // Hide HUD once the network request comes back (must be done on main UI thread)
        //MBProgressHUD.hide(for: self.view, animated: true)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        // Handle scroll behavior here
        
        if (!isMoreDataLoading)
        {
            //Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = photosView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - photosView.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if (scrollView.contentOffset.y > scrollOffsetThreshold && photosView.isDragging)
            {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: photosView.contentSize.height, width: photosView.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ..Code to Load more results
                networkRequest()

            }
        }
        
    }
    
    func networkRequest()
    {
        let url = URL(string:"https://api.tumblr.com/v2/blog/humansofnewyork.tumblr.com/posts/photo?api_key=Q6vHoaVm5L1u2ZAW1fqv3Jw48gFzYVg9P0vH0VHl3GVy6quoGV")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                
                
                // Update flag
                self.isMoreDataLoading = false
                
                // Stop the loading indicator
                self.loadingMoreView!.stopAnimating()
                
                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {
                        print("responseDictionary: \(responseDictionary)")
                        
                        // Recall there are two fields in the response dictionary, 'meta' and 'response'.
                        // This is how we get the 'response' field
                        let responseFieldDictionary = responseDictionary["response"] as! NSDictionary
                        
                        
                        
                        // This is where you will store the returned array of posts in your posts property
                        self.posts = responseFieldDictionary["posts"] as? [NSDictionary]
                        
                        self.photosView.reloadData()
                        
                        //Tell the refreshControl to stop spinning
                        self.refreshControl.endRefreshing()
                    }
                }
        });
        task.resume()
    }
    
    func refreshControlAction(_ refreshControl:UIRefreshControl)
    {
        networkRequest()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let posts = posts
        {
            return posts.count
        }
        else
        {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = photosView.dequeueReusableCell(withIdentifier: "PhotoCell") as! PhotoCell
        
        // To pull out a single post from our posts array
        let post = posts![indexPath.row]
        
        if let photos = post.value(forKeyPath: "photos") as? [NSDictionary] {
            
            // Get the original size image url
            let imageUrlString = photos[0].value(forKeyPath: "original_size.url") as? String
            
            // Convert imageUrlString to NSURL so long as its not nil
            if let imageUrl = URL(string: imageUrlString!) {
                
                // Set the image view in the cell so long as nothing is ni
                cell.imagePhotoCell.setImageWith(imageUrl)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Get rid of the gray slection effect by deselecting the cell with animation
        photosView.deselectRow(at: indexPath, animated: true)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        
        let cell = sender as! UITableViewCell
        let indexPath = photosView.indexPath(for: cell)
        let post = posts![indexPath!.row]
        
        let photoDetailVC = segue.destination as! PhotoDetailsViewController
        photoDetailVC.post = post
        
    }
    
    
}
