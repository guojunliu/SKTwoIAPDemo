//
//  ViewController.m
//  StoreKit2Demo
//
//  Created by steve on 2023/4/20.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
{
    NSArray *products;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UITableView *tableView = [[UITableView alloc] initWithFrame:self.view.bounds];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
    
    products = [self loadProducts];
    [tableView reloadData];
}

- (NSArray *)loadProducts {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Products" ofType:@"plist"];
    NSArray *products = [NSArray arrayWithContentsOfFile:path];
    return products;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return products.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.textLabel.text = @"xxx";
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
