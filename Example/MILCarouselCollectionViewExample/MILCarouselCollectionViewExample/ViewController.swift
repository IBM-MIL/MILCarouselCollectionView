/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class ViewController: UIViewController {
    
    //set in the prepareForSegue method
    var storyboardCarouselCollectionViewController : MILCarouselCollectionViewController!
    
    //set in the setUpProgrammaticHorizontalCollectionViewController method
    var programmaticCarouselCollectionViewController : MILCarouselCollectionViewController!
    
    //delay timer for fake server to return back data
    var kImageServerDelayTime : NSTimeInterval = 1.5
    
    //instance of the timer that causes the carousel collection view to switch pages
    var serverDelayTimer : NSTimer!
    
    
    /**
     Method called upon view did load. It sets up the programmatic carousel collection view controller and gets images from the server
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setUpProgrammaticCarouselCollectionViewController()
        self.getImagesFromServer()
    }
    
    /**
     Method called when the app receieves a memory warning from the OS
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    /**
    This method sets up the programmaticCarouselCollectionView so that it is a child view controller to self. This method all sets up the placeholder items needed to be shown while we wait for for the server to return data. Finally this method sets the background color of the programmaticCarouselCollectionView to be white instead of its default color of black.
    */
    func setUpProgrammaticCarouselCollectionViewController(){
        
        //initialize programmaticCarouselCollectionViewController using MILCarouselCollectionViewFlowLayout
        let flow = MILCarouselCollectionViewFlowLayout()
        self.programmaticCarouselCollectionViewController = MILCarouselCollectionViewController(collectionViewLayout: flow)
        
        //set frame of programmaticCarouselCollectionViewController's view
        self.programmaticCarouselCollectionViewController.view.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height/2, UIScreen.mainScreen().bounds.width, 194)
        
        //add programmaticCarouselCollectionViewController as child view controller to this view controller, and add the programmaticCarouselCollectionViewController's view to this ViewController's view
        self.addChildViewController(self.programmaticCarouselCollectionViewController)
        self.programmaticCarouselCollectionViewController.didMoveToParentViewController(self)
        self.view.addSubview(self.programmaticCarouselCollectionViewController.view)
        
        //set the locally stored place holder image to be shown in each cell while we wait for the server to return an array of imageURLs or for the images to download from the image url's
        self.programmaticCarouselCollectionViewController.localPlaceHolderImageName = "placeholder_grey_wide"
        
        //change default collectionView background color of black to white
        self.programmaticCarouselCollectionViewController.collectionView?.backgroundColor = UIColor.whiteColor()
        
    }
    
    
    /**
    This method fakes a query to a server to get images. It assumes a kImageServerDelayTime second delay
    */
    func getImagesFromServer(){
        self.serverDelayTimer = NSTimer.scheduledTimerWithTimeInterval(self.kImageServerDelayTime, target: self, selector: Selector("didReceiveImagesFromSever"), userInfo: nil, repeats: false)
    }
    
    
    /**
    This method fakes a call back from a server that has an array of imageURL's
    */
    func didReceiveImagesFromSever(){
        
        //imageURL array from server
        let imageURLArray = self.getImageURLArray()
        
        //refresh storyboardCarouselCollectionView with newly receieved data
        self.storyboardCarouselCollectionViewController.setToHandleImageURLStrings()
        self.storyboardCarouselCollectionViewController.refresh(imageURLArray)
        
        //refresh programmaticCarouselCollectionView with newly received data
        self.programmaticCarouselCollectionViewController.setToHandleImageURLStrings()
        self.programmaticCarouselCollectionViewController.refresh(imageURLArray)
    }
    
    
    /**
    This method sets up the imageURLArray used to populate the horizontal collection view
    */
    func getImageURLArray() -> [String]{
        
        let red = "http://i.imgur.com/6vus956.png"
        
        let blue = "http://i.imgur.com/LCJnJxO.png"
        
        let green = "http://i.imgur.com/ArMRWx4.png"
        
        let yellow = "http://i.imgur.com/wydD5dr.png"
        
        let imageURLArray = [red, blue, green, yellow]
        
        return imageURLArray
    }
    
    
    /**
     This method is how we get access to the storyboardCarouselCollectionView that is embeded in the container view on the Main.storyboard
     
     - parameter segue:
     - parameter sender:
     */
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == "carouselCollectionView"){
            self.storyboardCarouselCollectionViewController = segue.destinationViewController as! MILCarouselCollectionViewController
            
            //set the placeholder image for used to display something while we wait for the server to return data
            self.storyboardCarouselCollectionViewController.localPlaceHolderImageName = "placeholder_grey_wide"
            
        }
    }
    
}

