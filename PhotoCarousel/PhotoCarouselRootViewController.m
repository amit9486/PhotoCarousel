
#import "PhotoCarouselRootViewController.h"
#import "PhotoCarouselPhotoCell.h"
#import <AssetsLibrary/AssetsLibrary.h>

NSString *kPhotoCarouselPhotoCellID = @"photoCarouselPhotoCellID";
const int kPhotoCarouselPhotoCollectionViewTop = 100;
const int kPhotoCarouselPhotoCollectionViewHeight = 200;
const int kPhotoCarouselPhotoCellSpacing = 15;

const int kCollectionButtonMargin = 30;

const int kButtonWidth = 80;
const int kButtonHeight = 20;

@interface PhotoCarouselRootViewController ()

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation PhotoCarouselRootViewController

- (void)loadView
{
    [super loadView];
    
    [self setupViews];
}

- (void)setupViews
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    /********* configure collection view - begin *********/
    CGRect frame = CGRectMake (self.view.bounds.origin.x, kPhotoCarouselPhotoCollectionViewTop, self.view.bounds.size.width, kPhotoCarouselPhotoCollectionViewHeight);
    
    UICollectionViewFlowLayout *cvfl = [UICollectionViewFlowLayout alloc];
    cvfl.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    cvfl.minimumInteritemSpacing = kPhotoCarouselPhotoCellSpacing;
    
    UICollectionView *cv = [[UICollectionView alloc] initWithFrame: frame collectionViewLayout: cvfl];
    
    self.collectionView = cv;
    self.collectionView.backgroundColor = self.view.backgroundColor;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    [self.collectionView registerClass: [PhotoCarouselPhotoCell class]
            forCellWithReuseIdentifier: kPhotoCarouselPhotoCellID];
    
    [self.view addSubview: cv];
    
    /********* configure collection view - end *********/
    
    /********* configure button - begin *********/
    
    frame = CGRectMake (CGRectGetMidX (self.view.bounds) - (kButtonWidth / 2), CGRectGetMaxY (self.collectionView.frame) + kCollectionButtonMargin, kButtonWidth, kButtonHeight); // center horizontally
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    button.backgroundColor = [UIColor blueColor];
    button.frame = frame;
    [button setTitle: @"Count" forState: UIControlStateNormal];
    [button setTitleColor: [UIColor whiteColor]
                 forState: UIControlStateNormal];
    [button addTarget: self action: @selector(buttonAction) forControlEvents: UIControlEventTouchUpInside];
    
    [self.view addSubview: button];
    
    /********* configure button - end *********/
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.assetsLibrary == nil)
    {
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    
    if (self.assets == nil)
    {
        self.assets = [[NSMutableArray alloc] init];
    } else
    {
        [self.assets removeAllObjects];
    }
    
    // setup our failure alert in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock =
    ^(NSError *error)
    {
        NSString *errorMessage = nil;
        switch ([error code])
        {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Error" message: errorMessage delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
        [alert show];
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock =
    ^(ALAssetsGroup *group, BOOL *stop)
    {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter: onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock =
            ^(ALAsset *result, NSUInteger index, BOOL *stop)
            {
                if (result)
                {
                    [self.assets addObject: result];
                }
            };
            
            ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
            [group setAssetsFilter: onlyPhotosFilter];
            [group enumerateAssetsUsingBlock: assetsEnumerationBlock];
        } else
        {
            [self.collectionView reloadData];
        }
    };
    
    // enumerate only saved photos
    NSUInteger groupTypes = ALAssetsGroupSavedPhotos;
    [self.assetsLibrary enumerateGroupsWithTypes: groupTypes usingBlock: listGroupBlock failureBlock: failureBlock];
}

- (NSInteger)collectionView: (UICollectionView *)view numberOfItemsInSection: (NSInteger)section;
{
    return self.assets.count;
}

- (UICollectionViewCell *)collectionView: (UICollectionView *)cv cellForItemAtIndexPath: (NSIndexPath *)indexPath;
{
    // we're going to use a custom UICollectionViewCell, which will hold an image and a selection bubble
    PhotoCarouselPhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier: kPhotoCarouselPhotoCellID forIndexPath: indexPath];
    
    // load the image for this cell
    ALAsset *asset = self.assets[indexPath.row];
    CGImageRef thumbnailImageRef = [[asset defaultRepresentation] fullScreenImage];
    cell.image = [UIImage imageWithCGImage: thumbnailImageRef];
    
    CGRect cellFrame = cell.frame;
    
    [cell setFrame: CGRectMake (cellFrame.origin.x, CGRectGetMidY (self.collectionView.bounds) - (cellFrame.size.height / 2), cellFrame.size.width, cellFrame.size.height)]; // center vertically
    
    // adjust selection bubble position
    [self adjustSelectionBubble: cell];

    return cell;
}

- (void)adjustSelectionBubble: (PhotoCarouselPhotoCell *)cell
{
    if( CGRectGetMaxX (cell.frame) > (self.collectionView.contentOffset.x + self.collectionView.bounds.size.width) )
    {
        // cell has gone past scrollview
        cell.selectionBubbleRect = CGRectMake (cell.bounds.origin.x, cell.bounds.origin.y, cell.bounds.size.width - CGRectGetMaxX (cell.frame) + self.collectionView.contentOffset.x + self.collectionView.bounds.size.width, cell.bounds.size.height);
    } else
    {
        cell.selectionBubbleRect = cell.bounds;
    }
    
    [cell setNeedsDisplay];
}

- (CGSize)collectionView: (UICollectionView *)collectionView
                  layout: (UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath: (NSIndexPath *)indexPath
{
    // adjust size of the cell according to aspect
    // ratio of the image
    ALAsset *asset = self.assets[indexPath.row];
    CGImageRef thumbnailImageRef = [[asset defaultRepresentation] fullScreenImage];
    
    size_t height = CGImageGetHeight (thumbnailImageRef);
    size_t width = CGImageGetWidth (thumbnailImageRef);
    
    double aspect_ratio = ((double) width) / height;
    
    if( width > height )
    {
        return CGSizeMake (kPhotoCarouselPhotoCollectionViewHeight, kPhotoCarouselPhotoCollectionViewHeight / aspect_ratio);
    }
    
    return CGSizeMake (kPhotoCarouselPhotoCollectionViewHeight * aspect_ratio, kPhotoCarouselPhotoCollectionViewHeight);
}

- (void)scrollViewDidScroll: (UIScrollView *)scrollView
{
    // adjust selection bubble for visible cells
    // upon scrolling
    NSArray *cells = [self.collectionView visibleCells];
    
    for (PhotoCarouselPhotoCell *cell in cells)
    {
        [self adjustSelectionBubble: cell];
    }
}

- (void)buttonAction
{
    // alert user with number of selected photos
    NSString *message = [NSString stringWithFormat: @"The number of currently selected photos: %d", [[self.collectionView indexPathsForSelectedItems] count]];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Info" message: message delegate: self cancelButtonTitle: @"OK" otherButtonTitles: nil, nil];
    [alert show];
}

@end
