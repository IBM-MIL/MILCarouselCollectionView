/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit

class MILCarouselCollectionViewController: UICollectionViewController {

    //here you can customize what kind of objects the dataArray would hold, in this case we used strings for imageURL's
    var dataArray : [String] = []
    
    //ideally the MILCarouselCollectionView wouldn't have a imageCache itself, instead we would be caching to a global image cache so anywhere in the app we could access cached images.
    private var imageCache : [String : UIImage] = [String : UIImage]()
    
    //must set this string for placeHolder images to show while the it waits for image URL's to download
    var localPlaceHolderImageName = ""
    
    //property used to keep track of the current index shown
    private var currentIndex : CGFloat = 0
    
    //timer that auto scrolls the carousel
    private var timer : NSTimer!
    
    //page control that displays the current page index
    private var pageControl : UIPageControl!
    
    //used so viewDidLayoutSubview code is only ran once
    private var finishedSetup : Bool = false;
    
    //constant used for the height of the page control
    private let kPageControlHeight : CGFloat = 30
    
    //constant used to determine how often the timer will go off that auto scrolls the carousel
    private var timerInterval : NSTimeInterval = 4
    
    //Bool that sets auto scrolling to enabled or disabled
    private var autoScrollingEnabled = true
    
    //Bool that sets circular scrolling to enabled or disabled
    private var circularScrollingEnabled = true
    
    //sets the MILHorizontalCollectionView to handle image URL strings with built in mechanisms to display data in the cell
    private var handleImageURLStrings = true
    
    //sets the MILHorizontalCollectionView to handle image URL strings with SDWebImage to display data in the cell
    private var handleImageURLStringsUsingSDWebImage = false
    
    //sets the MILHorizontalCollectionView to handle local image name strings with built in mechanisms to display data in the cell
    private var handleLocalImageNameStrings = false
    
    
    /**
    This method sets up the dataArray with placeholder items while it waits for data from Server by calling setUpPlaceHolderItem
    */
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setUpCollectionView()
        self.resetTimer()
        
        self.setUpPlaceHolderItem()
    }
    

    /**
    This method is called when the view has finished laying out the subviews. Within this method it offsets the collectionView's contentOffset.x by the width of the collectionView so the collectionView starts at the correct "0th index" rather than the "last index" or "-1th index" it starts at by default. This is needed because the last item in the original dataArray has been duplicated and put at the beginning of the newly updated dataArray to achieve a circular carousel effect when scrolling through the carouselCollectionView's pages.
    */
    override func viewDidLayoutSubviews() {
        
        //check to see if this is the first time viewDidLayoutSubviews has been called before
        if(finishedSetup == false){
            //offset the collectionView's contentOffset.x by the collectionView's width
            
            self.setCollectionViewStartingOffset()
            
            finishedSetup = true
        }
    }
    
    
    /**
    This method stops the timer whenever the view disappears.
    
    - parameter animated:
    */
    override func viewDidDisappear(animated: Bool) {
        self.stopTimer()
    }
    
    
    /**
    This method sets up the placeholder item for the carouselCollectionView as it waits for data from the server
    */
    private func setUpPlaceHolderItem(){
        if(self.dataArray.count == 0){
            self.dataArray.append("")
            setUpDataForCircularCarouselCollectionView()
        }
    }
    
    
    /**
    This method is called when there has been data recieved and parsed from the server. It sets up the collectionview to handle this new data.
    
    - parameter newDataArray: the new dataArray to populate the collectionView with
    */
    func refresh(newDataArray : [String]){
        if(newDataArray.count > 0){
            self.dataArray = newDataArray
            self.setUpDataForCircularCarouselCollectionView()
            self.setUpPageControl()
            self.collectionView!.reloadData()
            self.resetTimer()
        }
    }

    /**
     Method called when the app receives a memory warning from the OS
     */
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
    This method updates the dataArray needed to populate the carouselCollectionView when circular scrolling is enabled. What this method does is takes a copy of the first item in the data array and appends it to the end of the dataArray. As well it takes a copy of the last item in the data array and inserts it at the beginning of the dataArray. This is needed to achieve a circular carousel effect when scrolling through the carouselCollectionView's pages. How this works is explained in more detail in the description for the scrollViewDidScroll method.
    */
    private func setUpDataForCircularCarouselCollectionView(){
        
        //only set up the data for circular carousel collection view when circular scrolling is enabled
        if(circularScrollingEnabled == true){
            var workingArray = self.dataArray
        
            if(workingArray.count > 0){
                let arraySize = workingArray.count
                let firstItem = workingArray[0]
                let lastItem  = workingArray[arraySize - 1]
        
                workingArray.insert(lastItem, atIndex: 0)
                workingArray.append(firstItem)
            
                self.dataArray = workingArray
            }
        }
    }
    

    /**
    This method sets up the collectionView with various settings
    */
    private func setUpCollectionView(){
        
        //hide collectionView horizontal scroll bar
        self.collectionView!.showsHorizontalScrollIndicator = false;
        
        //create new instance of CarouselCollectionViewFlowLayout (needed to set up the carouselCollectionView's unique characteristics)
        let carouselCollectionViewFlowLayout : MILCarouselCollectionViewFlowLayout = MILCarouselCollectionViewFlowLayout()
        
        //set the collectionView's collectionViewLayout to the carouselCollectionViewFlowLayout
        self.collectionView!.setCollectionViewLayout(carouselCollectionViewFlowLayout, animated: false)
        
        //create an instance of the CarouselCollectionViewCell.xib file
        let nib : UINib = UINib(nibName: "MILCarouselCollectionViewCell", bundle:nil)
        
        //register the collectionview with this nib file
        self.collectionView!.registerNib(nib,
            forCellWithReuseIdentifier: "carouselcell")
    }
    
    
    /**
    This method sets up the UIPageControl and adds it the self.view.
    */
    private func setUpPageControl(){
        
        self.pageControl = UIPageControl()
        
        self.pageControl.frame = CGRectMake(0,  self.view.frame.size.height - self.kPageControlHeight,  self.view.frame.size.width, self.kPageControlHeight)
        
        if(circularScrollingEnabled == true){
            self.pageControl.numberOfPages = self.dataArray.count - 2
        }
        else{
            self.pageControl.numberOfPages = self.dataArray.count
        }
        
        self.pageControl.currentPage = 0

        self.pageControl.autoresizingMask = .None;
        self.view.addSubview(self.pageControl)
        self.view.bringSubviewToFront(self.pageControl)
    }
    
    
    /**
     Method sets the collection view starting content offset if the circular scrolling enabled
     */
    private func setCollectionViewStartingOffset(){

        if(circularScrollingEnabled == true){
            self.collectionView!.setContentOffset(CGPointMake(self.collectionView!.frame.size.width, 0), animated: false);
        }
    }
    
    
    /**
     This method sets the MILCarouselCollectionView to handle image URL strings with built in mechanisms to display data in the cell
     */
    func setToHandleImageURLStrings(){
        
        self.handleLocalImageNameStrings = false
        self.handleImageURLStrings = true
        self.handleImageURLStringsUsingSDWebImage = false
        
    }
    
    
    /**
     This method sets the MILCarouselCollectionView to handle image URL strings with SDWebImage to display data in the cell
     */
    func setToHandleImageURLStringsUsingSDWebImage(){
        
        self.handleLocalImageNameStrings = false
        self.handleImageURLStrings = false
        self.handleImageURLStringsUsingSDWebImage = true
        
    }
    
    
    /**
     This method sets the MILCarouselCollectionView to handle local image name strings with built in mechanisms to display data in the cell
     */
    func setToHandleLocalImageNameStrings(){
        
        self.handleLocalImageNameStrings = true
        self.handleImageURLStrings = false
        self.handleImageURLStringsUsingSDWebImage = false
        
    }
    
    
    /**
    This method is called as the timer's selector every 4 seconds. This method changes the "current page" visible in the collectionView by changing the collectionViews contentOffset to be equal to the (nextPage to be shown) * (the collectionView's pageWidth)
    */
    func nextItem(){
        
        let pageWidth :CGFloat = self.collectionView!.frame.size.width;
        
        let contentOffset : CGFloat = self.collectionView!.contentOffset.x;
   
        let nextPage : CGFloat = (contentOffset / pageWidth) + 1;
        
        let newOffset : CGPoint = CGPointMake(pageWidth * nextPage, 0);
        
        
        //handle autoscrolling when circular scrolling is disabled
        if(circularScrollingEnabled == false){
            if(Int(nextPage) <= (self.dataArray.count - 1)){
                self.collectionView!.setContentOffset(newOffset, animated: true);
            }
        }
        //handle autoscrolling when circular scrolling is enabled
        else{
            //update the collectionView's contentOffset.x to the newly calculated offset.
            self.collectionView!.setContentOffset(newOffset, animated: true);
        }
        
        //reset the timer everytime the page is changed
        self.resetTimer()
        
    }
    
    
    /**
     This method disabled autoscrolling
     */
    func disableCircularScrolling(){
    
        circularScrollingEnabled = false
    
    }
    
    
    /**
     This method disabled autoscrolling.
     */
    func disableAutoScrolling(){
        
        autoScrollingEnabled = false

    }
    
    /**
     Method sets the durtion of the uato scroll timer
     
     - parameter duration: NSTimerInterval
     */
    func setAutoScrollTimerDuration(duration : NSTimeInterval){
        self.timerInterval = duration
    }
    
    
    /**
    This method starts the timer and sets it to go off every self.kTimerInterval seconds. When the timer goes off it calls the nextItem() method.
    */
    private func startTimer(){
        if(autoScrollingEnabled == true){
            self.timer =  NSTimer.scheduledTimerWithTimeInterval(self.timerInterval, target: self, selector: Selector("nextItem"), userInfo: nil, repeats: true)
        }
    }
    
    
    /**
    This method resets the timer by stopping the timer and then starting it again
    */
    private func resetTimer(){
        stopTimer()
        startTimer()
    }
    
    
    /**
    This method stops the timer by invalidating the timer
    */
    private func stopTimer(){
        if(self.timer != nil){
            self.timer.invalidate()
        }
    }

    
    /**
    This method is called everytime the scrollView scrolls. It first resets the timer. Then it calls the checkPage method to check what page the UIPageControl should be set to and then it calls the checkContentOffsetXForCircularCarouselLogic method to check to see if any special logic needs to be handled to make the carousel collectionView circular
    
    - parameter scrollView:
    */
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        
        //only execute if all the subviews have finished setting up
        if(finishedSetup == true){
            self.resetTimer()
            self.checkPage(scrollView)
            self.checkContentOffsetXForCiruclarCarouselLogic(scrollView)
        }
    }
    
    
    /**
    This method is called within the scrollViewDidScroll method. This method checks to see if any special logic needs to be handled to make the carousel collectionView circular
    
    - parameter scrollView: the scrollView of the collectionView
    */
    private func checkContentOffsetXForCiruclarCarouselLogic(scrollView: UIScrollView){
        
        if(circularScrollingEnabled == true){
        
            var lastContentOffsetX : CGFloat =  0
        
            //grab the current X and Y offsets of the collectionView's scrollView
            let currentOffsetX = scrollView.contentOffset.x
            let currentOffsetY = scrollView.contentOffset.y
        
            let pageWidth = scrollView.frame.size.width
            let offset = pageWidth * CGFloat(self.dataArray.count - 2)
        
            if(currentOffsetX < pageWidth && lastContentOffsetX > currentOffsetX){
                lastContentOffsetX = currentOffsetX + offset
                scrollView.contentOffset = CGPoint(x: lastContentOffsetX, y: currentOffsetY);
            }
            else if(currentOffsetX > offset && lastContentOffsetX < currentOffsetX){
                lastContentOffsetX = currentOffsetX - offset
                scrollView.contentOffset = CGPoint(x: lastContentOffsetX, y: currentOffsetY)
            }
            else{
                lastContentOffsetX = currentOffsetX
            }
        }
    }
    
    
    /**
    This method checks to see if the UIPageControl needs to be updated. If it does, then it updates the UIPageControl's currentPage
    
    - parameter scrollView: the scrollView of the collectionView
    */
    private func checkPage(scrollView: UIScrollView){
        
        let pageWidth = scrollView.frame.size.width
        let currentPageFloat = scrollView.contentOffset.x / pageWidth;
        
        //when circular scrolling is disabled, handle changing what page is highlighted in the page control
        if(circularScrollingEnabled == false){
            self.pageControl.currentPage = Int(round(currentPageFloat))
        }
        //when circular scrolling is enabled, handle changing what page is highlighted in the page control
        else{
            let currentPageInt = Int(round(currentPageFloat - 1))
        
            //If the current page isn't a duplicated item from the dataArray
            if(currentPageInt >= 0){
                if(self.pageControl != nil){
                    self.pageControl.currentPage = currentPageInt
                }
            }
            
            //If the currentPage is negative then this means it is the duplicated last item from the original dataArray and this we hard code the currentPage to be the actual last item's index from the original dataArray
            else{
                if(self.pageControl != nil){
                    self.pageControl.currentPage = self.dataArray.count - 3
                }
            }
            
        }
    }


    /**
    This method sets the number of sections in the collection view. Since the carouselCollectionView is a single horizontal row, we only want one section
    
    - parameter collectionView:
    
    - returns:
    */
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    /**
    This method sets the number of items in a section, in this case, its the number of items in the dataArray
    
    - parameter collectionView:
    - parameter section:
    
    - returns:
    */
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }

    
    /**
    This method prepares the current cell for item at the current indexPath.
    
    - parameter collectionView:
    - parameter indexPath:
    
    - returns: 
    */
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("carouselcell", forIndexPath: indexPath) as! MILCarouselCollectionViewCell
        
        //1. Setup cell with image from image url (download image asynchronously and cache image)
        if(handleImageURLStrings == true){
            return self.setUpCellWithImageURL(cell, indexPath: indexPath)
        }
        //2. Setup cell with image from image url (Using SDWebImage framework to download image asynchronously and cache image)
        else if(handleImageURLStringsUsingSDWebImage == true){
            return self.setUpCellWithImageURLUsingSDWebImage(cell, indexPath: indexPath)
        }
        //3. Setup cell with locally stored images
        else{
            return self.setUpCellWithLocallyStoredImage(cell, indexPath: indexPath)
        }
        
    }
    
    
    /**
    This method sets up the MILHorizontalCollectionViewCell with a locally stored image with respect to indexPath.row in the dataArray. This method can be used when it is assumed that the strings the data array holds represent the names of locally stored images in Images.xcassets
    
    - parameter cell:
    - parameter indexPath:
    
    - returns: MILHorizontalCollectionViewCell
    */
    private func setUpCellWithLocallyStoredImage(cell : MILCarouselCollectionViewCell, indexPath : NSIndexPath) -> MILCarouselCollectionViewCell {
        
        let imageString : String = dataArray[indexPath.row] as String
        let image = UIImage(named: imageString)
        cell.imageView.image = image
        
        return cell
    }
    
    
    /**
    This method sets up the MILHorizontalCollectionViewCell with an image from a url. It first will set up the cell with a placeholder image. Then it will check the cache to see if the image has already been downloaded and cached. If the cache has the image, it sets the cell with the image. If not, then it will asynchronously download the image, cache it, and then set the cell with this image.
    
    - parameter cell:
    - parameter indexPath:
    
    - returns: MILHorizontalCollectionViewCell
    */
    private func setUpCellWithImageURL(cell : MILCarouselCollectionViewCell, indexPath : NSIndexPath) -> MILCarouselCollectionViewCell{
        
        //set the cell with temporary locally stored placeholder image
        let placeholderImage = UIImage(named: self.localPlaceHolderImageName)
        cell.imageView.image = placeholderImage
        
        let urlString = self.dataArray[indexPath.row]
        
        //check the image cache to see if cell has been previously downloaded and cached. If so set the cell with the image
        if let image = self.imageCache[urlString] {
            cell.imageView.image = image
        }
        //cache doesn't contain image, asynchronously download image and then cache it, then set cell.
        else{
            self.asychronouslyDownloadImageFromURLAndSetCollectionViewCellAtIndexPath(urlString, indexPath: indexPath)
        }
        
        return cell
    }
    
    
    /**
    This method sets up the MILHorizontalCollectionViewCell with an image from a url using the SDWebImage framework. The SDWebImage framework will out of the box asynchronously download the image, cache the image, and persist this cache accross multiple app instances.
    
    - parameter cell:
    - parameter indexPath:
    
    - returns: MILHorizontalCollectionViewCell
    */
    private func setUpCellWithImageURLUsingSDWebImage(cell : MILCarouselCollectionViewCell, indexPath : NSIndexPath) -> MILCarouselCollectionViewCell {
        
        
        //Code commented out since SDWebImage isn't imported in the project and to surpress errors and warnings, uncomment to use with sdWebImage
        /*
        let urlString = self.dataArray[indexPath.row]
        let url = NSURL(string: urlString)
        
        cell.imageView.sd_setImageWithURL(url, placeholderImage: UIImage(named: self.localPlaceHolderImageName))
        */
        
        return cell
    
    }
    
    
    /**
    This method asychronously downloades an image from the specified urlString, caches this image, and then updates the the collection view cell with this image.
    
    - parameter collectionView:
    - parameter indexPath:
    */
    private func asychronouslyDownloadImageFromURLAndSetCollectionViewCellAtIndexPath(urlString : String, indexPath : NSIndexPath){
        if(urlString != ""){
            if let url  = NSURL(string: urlString){
                
                let request: NSURLRequest = NSURLRequest(URL: url)
                let mainQueue = NSOperationQueue.mainQueue()
                
                NSURLConnection.sendAsynchronousRequest(request, queue: mainQueue, completionHandler: { (response, data, error) -> Void in
                    if error == nil {
                        let image = UIImage(data: data!)
                        // Store the image in the cache
                        self.imageCache[urlString] = image
                        // Update the cell with this image
                        dispatch_async(dispatch_get_main_queue(), {
                            if let cell = self.collectionView?.cellForItemAtIndexPath(indexPath) {
                                (cell as! MILCarouselCollectionViewCell).imageView.image = image
                            }
                        })
                    }
                    else {
                        print("Error: \(error!.localizedDescription)")
                    }
                })
            }
        }
    }
    
    
    
    
    /**
    This method can be used to define the action that is taken when a cell is selected

    */
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
     
        
    }


}


