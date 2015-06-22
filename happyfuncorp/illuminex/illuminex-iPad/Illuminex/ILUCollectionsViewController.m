//
//  ILUCollectionsViewController.m
//  illuminex
//
//  Created by Joe Gallo on 11/11/14.
//  Copyright (c) 2014 HappyFunCorp. All rights reserved.
//

#import "ILUCollectionsViewController.h"
#import "ILUCollectionCollectionViewCell.h"
#import "ILUCollection.h"
#import "ILUCollectionDetailsViewController.h"
#import "ILUNewCollectionCollectionViewCell.h"
#import "ILUBookmarkedItem.h"
#import "ILUBookmarkedItemTableViewCell.h"
#import "ILUItem.h"
#import "ILUDetailsViewController.h"

@interface ILUCollectionsViewController ()
    // collections
    @property (strong, nonatomic) NSMutableArray *collections;
    @property (weak, nonatomic) IBOutlet UICollectionView *collectionsCollectionView;

    // bookmarked diamonds
    @property (strong, nonatomic) NSMutableArray *bookmarkedItems;
    @property (weak, nonatomic) IBOutlet UITableView *bookmarkedItemsTableView;

    // drag and drop [from bookmarked items tableview to collections collectionview
    @property (nonatomic, strong) I3DragBetweenHelper* helper;
@end

@implementation ILUCollectionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIImageView *collectionsbgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collections-bg"]];
    collectionsbgImageView.frame = self.collectionsCollectionView.bounds;
    self.collectionsCollectionView.backgroundView = collectionsbgImageView;
    
    // bookmarked items
    self.bookmarkedItems = [self getBookmarkedItems];
    
    UIImageView *bookmarkedbgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookmarked-table-bg"]];
    bookmarkedbgImageView.frame = self.collectionsCollectionView.bounds;
    self.bookmarkedItemsTableView.backgroundView = bookmarkedbgImageView;
    
    self.bookmarkedItemsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // drag and drop
    self.helper = [[I3DragBetweenHelper alloc] initWithSuperview:self.view
                                                         srcView:self.bookmarkedItemsTableView
                                                         dstView:self.collectionsCollectionView];
    self.helper.delegate = self;
    
    self.helper.isSrcRearrangeable = NO;
    self.helper.isDstRearrangeable = NO;
    
    self.helper.doesSrcRecieveDst = NO;
    self.helper.doesDstRecieveSrc = YES;
    
    self.helper.hideDstDraggingCellCopy = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getCollections];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Get collections

- (void)getCollections {
    self.collections = [[NSMutableArray alloc] init];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/collections?collection[page]=1&collection[per_page]=10",
                     SITE_DOMAIN, API_PATH];
    [appDelegate.requestManager GET:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        DDLogInfo(@"%@", JSON);
        
        NSArray *collections = JSON[@"collections"];
        for (NSDictionary *collection in collections) {
            int id = [collection[@"id"] intValue];
            NSString *name = collection[@"name"];
            ILUCollection *collection = [[ILUCollection alloc] initWithId:id name:name];
            [self.collections addObject:collection];
        }
        
        // sort by id
        [self.collections sortUsingComparator:^NSComparisonResult(id a, id b) {
            int firstId = [(ILUCollection *)a id];
            int secondId = [(ILUCollection *)b id];

            if (firstId < secondId) {
                return NSOrderedAscending;
            } else if (firstId > secondId) {
                return NSOrderedDescending;
            } else {
                return NSOrderedSame;
            }
        }];
        
        [self.collectionsCollectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@", error);
    }];
}

#pragma mark - Get bookmarked items

- (NSMutableArray *)getBookmarkedItems {
    // TODO: get bookmarked items from server
    
    NSMutableArray *bookmarkedItems = (NSMutableArray *)[appDelegate objectForKey:@"bookmarkedItems"];
    if (!bookmarkedItems) {
        bookmarkedItems = [[NSMutableArray alloc] init];
    }
    
    return bookmarkedItems;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1 + self.collections.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell;
    if (indexPath.item == 0) {
        ILUNewCollectionCollectionViewCell *thisCell = (ILUNewCollectionCollectionViewCell *)
        [collectionView dequeueReusableCellWithReuseIdentifier:@"NewCollectionCell"
                                                  forIndexPath:indexPath];
        cell = thisCell;
    } else {
        ILUCollection *collection = self.collections[indexPath.item - 1];
        
        ILUCollectionCollectionViewCell *thisCell = (ILUCollectionCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionCell" forIndexPath:indexPath];
        thisCell.nameLabel.text = collection.name;
        thisCell.containsLabel.text = [NSString stringWithFormat:@"Contains %ld items", collection.items.count];
        
        cell = thisCell;
    }
    
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item == 0) {
        [self createNewCollection];
    } else {
        ILUCollection *collection = self.collections[indexPath.item - 1];
        
        ILUCollectionDetailsViewController *collectionDetailsVC = (ILUCollectionDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"CollectionDetails"];
        collectionDetailsVC.collection = collection;
        appDelegate.viewDeckController.centerController = collectionDetailsVC;
    }
}

- (void)createNewCollection {
    NSString *collectionName = [NSString stringWithFormat:@"Collection for Client #%ld", self.collections.count+1];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/collections", SITE_DOMAIN, API_PATH];
    NSDictionary *parameters = @{
                                 @"collection[name]": collectionName
                                 };
    [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
        DDLogInfo(@"%@", JSON);
        
        int id = [JSON[@"collection"][@"id"] intValue];
        NSString *name = JSON[@"collection"][@"name"];
        
        ILUCollection *newCollection = [[ILUCollection alloc] initWithId:id name:name];
        [self.collections addObject:newCollection];
        
        [self.collectionsCollectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@ %@", error, operation.responseString);
    }];
}

- (IBAction)removeCollection:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.collectionsCollectionView];
    NSIndexPath *indexPath = [self.collectionsCollectionView indexPathForItemAtPoint:buttonPosition];
    ILUCollection *collection = self.collections[indexPath.item-1];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@/collections/%d", SITE_DOMAIN, API_PATH, collection.id];
    [appDelegate.requestManager DELETE:url parameters:nil success:^(AFHTTPRequestOperation *operation, id JSON) {
        DDLogInfo(@"%@", JSON);
        
        [self.collections removeObjectAtIndex:indexPath.item-1];
        
        [self.collectionsCollectionView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DDLogError(@"%@ %@", error, operation.responseString);
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.bookmarkedItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BookmarkedItemCell";
    
    ILUBookmarkedItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[ILUBookmarkedItemTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                     reuseIdentifier:cellIdentifier];
    }
    
    ILUBookmarkedItem *bookmarkedItem = self.bookmarkedItems[indexPath.row];
    
    if (bookmarkedItem.item.onHand) {
        cell.onHandImageView.image = [UIImage imageNamed:@"diamond-status-on-hand"];
    } else {
        cell.onHandImageView.image = [UIImage imageNamed:@"diamond-status-not-on-hand"];
    }
    cell.itemImageView.image = [UIImage imageNamed:@"search-result-diamond-example-small"];
    cell.titleLabel.text = bookmarkedItem.item.title;
    cell.collectionsLabel.text = [[bookmarkedItem.collections valueForKey:@"name"] componentsJoinedByString:@","];
    
//    if (indexPath.row == self.bookmarkedItems.count - 1) {
//        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, cell.bounds.size.width);
//    } else {
//        cell.separatorInset = UIEdgeInsetsMake(0, 24, 0, 32);
//    }
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 65;
}

- (IBAction)goToItemDetails:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.bookmarkedItemsTableView];
    NSIndexPath *indexPath = [self.bookmarkedItemsTableView indexPathForRowAtPoint:buttonPosition];
    
    ILUBookmarkedItem *bookmarkedItem = self.bookmarkedItems[indexPath.row];
    ILUItem *item = bookmarkedItem.item;
    
    ILUDetailsViewController *detailsVC = (ILUDetailsViewController *)[storyboard instantiateViewControllerWithIdentifier:@"Details"];
    detailsVC.item = item;
    
    appDelegate.viewDeckController.centerController = detailsVC;
}

- (IBAction)unbookmarkItem:(id)sender {
    UIButton *button = (UIButton *)sender;
    CGPoint buttonPosition = [button convertPoint:CGPointZero toView:self.bookmarkedItemsTableView];
    NSIndexPath *indexPath = [self.bookmarkedItemsTableView indexPathForRowAtPoint:buttonPosition];
    [self.bookmarkedItems removeObjectAtIndex:indexPath.item];
    
    [appDelegate saveObject:self.bookmarkedItems forKey:@"bookmarkedItems"];
    
    [self.bookmarkedItemsTableView reloadData];
}

#pragma mark - Open flyout menu

- (IBAction)openFlyoutMenu:(id)sender {
    [appDelegate.viewDeckController toggleLeftView];
}

#pragma mark - I3DragBetweenDelegate

- (void)droppedOnDstAtIndexPath:(NSIndexPath*)to fromSrcIndexPath:(NSIndexPath*)from {
    // add bookmarked item to collection
    if (to.item > 0) {
        ILUBookmarkedItem *bookmarkedItem = self.bookmarkedItems[from.row];
        ILUItem *item = bookmarkedItem.item;
        
        ILUCollection *collection = self.collections[to.item - 1];
        
        NSString *url = [NSString stringWithFormat:@"%@/%@/collections/%d/add_diamond",
                         SITE_DOMAIN, API_PATH, collection.id];
        NSDictionary *parameters = @{
                                     @"collection[diamond_id]": [NSNumber numberWithInt:item.id]
                                     };
        [appDelegate.requestManager POST:url parameters:parameters success:^(AFHTTPRequestOperation *operation, id JSON) {
            [collection.items addObject:item];
            [self.collectionsCollectionView reloadData];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            DDLogError(@"%@ %@", error, operation.responseString);
        }];
    }
}

@end
