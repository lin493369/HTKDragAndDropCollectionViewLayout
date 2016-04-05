//
//  HTKSampleCollectionViewController.m
//  HTKDragAndDropCollectionView
//
//  Created by Henry T Kirk on 11/9/14.
//  Copyright (c) 2014 Henry T. Kirk (http://www.henrytkirk.info)
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "HTKSampleCollectionViewController.h"
#import "HTKSampleCollectionViewCell.h"
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height
@interface HTKSampleCollectionViewController ()

/**
 * Sample data array we're reordering
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

@end

@implementation HTKSampleCollectionViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        // Create Array for Demo data and fill it with some items
        _dataArray = [NSMutableArray array];
        for (NSUInteger i = 0; i < 6; i++) {
            [_dataArray addObject:[NSString stringWithFormat:@"%lu", i]];
        }
        [self setup];
    }
    return self;
}

- (void)setup {
    // basic setup
    self.title = @"Drag & Drop Demo";
    // Add button that will "add" item to demo
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(userDidTapAddButton:)];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // Register cell
    // If you are using Storyboards/Nibs, make sure you "registerNib:" instead.
    [self.collectionView registerClass:[HTKSampleCollectionViewCell class] forCellWithReuseIdentifier:HTKDraggableCollectionViewCellIdentifier];
    
    // Setup item size
    HTKDragAndDropCollectionViewLayout *flowLayout = (HTKDragAndDropCollectionViewLayout *)self.collectionView.collectionViewLayout;
  
    flowLayout.itemSize = CGSizeMake(SCREEN_WIDTH/2, 100);
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.lineSpacing = 0;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
//    flowLayout.headerReferenceSize = CGSizeMake(100, 100);
}

#pragma mark - User Actions

- (void)userDidTapAddButton:(id)sender {
    // Called when user taps the "+" button in nav bar
    // Add another item to the demo
    NSUInteger count = self.dataArray.count;
    NSString *newItem = [NSString stringWithFormat:@"%lu", count];
    [self.dataArray addObject:newItem];
    [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:count inSection:0]]];
    
}

#pragma mark - UICollectionView Datasource/Delegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (section == 0) {
        
        return 1;
    }
    return self.dataArray.count;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT/2);
    }
    return CGSizeMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        HTKSampleCollectionViewCell *cell = (HTKSampleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:HTKDraggableCollectionViewCellIdentifier forIndexPath:indexPath];
        
        // Set number on cell
        cell.numberLabel.text = @"hello";
//        cell.frame = CGRectMake(0, 0, SCREEN_WIDTH, 100);
        // Set our delegate for dragging
        cell.draggingDelegate = self;
        
        return cell;

    }
    HTKSampleCollectionViewCell *cell = (HTKSampleCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:HTKDraggableCollectionViewCellIdentifier forIndexPath:indexPath];
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(click:)];
        gesture.numberOfTapsRequired = 1;
        [cell addGestureRecognizer:gesture];
    cell.tag = indexPath.row;
    // Set number on cell
    cell.numberLabel.text = self.dataArray[indexPath.row];
//    cell.backgroundColor = [UIColor blueColor];
    // Set our delegate for dragging
    cell.draggingDelegate = self;
    
    return cell;
}
-(void)click:(UITapGestureRecognizer *)sender{
    
    NSLog(@"click %li",sender.view.tag);
}
#pragma mark - HTKDraggableCollectionViewCellDelegate

- (BOOL)userCanDragCell:(UICollectionViewCell *)cell {
    // All cells can be dragged in this demo
    return YES;
}

- (void)userDidEndDraggingCell:(UICollectionViewCell *)cell {
    
    HTKDragAndDropCollectionViewLayout *flowLayout = (HTKDragAndDropCollectionViewLayout *)self.collectionView.collectionViewLayout;

    // Save our dragging changes if needed
    if (flowLayout.finalIndexPath != nil) {
        // Update datasource
        NSObject *objectToMove = [self.dataArray objectAtIndex:flowLayout.draggedIndexPath.row];
        [self.dataArray removeObjectAtIndex:flowLayout.draggedIndexPath.row];
        [self.dataArray insertObject:objectToMove atIndex:flowLayout.finalIndexPath.row];
    }
    
    // Reset
    [flowLayout resetDragging];
}

@end
