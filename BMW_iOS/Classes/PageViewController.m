//
//  PageViewController.m
//  Leaderboard
//
//  Created by Rob Balian on 5/4/11.
//  Copyright 2011 Stanford University. All rights reserved.
//

#import "PageViewController.h"
#import "SBJSON.h"
#import "BMW_iOSAppDelegate.h"

@implementation PageViewController

@synthesize titleLabel, tv, dataURLString, data,titleString, pageNumber;	

-(void)loadDataFromURL
{
    //NSString *d = [NSString stringWithContentsOfURL:[NSURL URLWithString:dataURLString]];
    [ServerConnection sendGetRequestTo:dataURLString delegate:self];
}

-(void)receiveStats:(NSArray *)stats
{
    self.data = stats;
    [self.tv reloadData];
    [self performSelector:@selector(loadDataFromURL) withObject:nil afterDelay:5];

}

-(void)viewDidLoad
{
	[super viewDidLoad];
	titleLabel.text = titleString;
}

#pragma mark tableView Delegate Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 35.0;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [data count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
	[cell setSelected:NO];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
	}
	NSNumber *payload = [[data objectAtIndex:indexPath.row] objectForKey:@"payload"];
	//payload = [NSNumber numberWithFloat:[payload floatValue]*2.2369 ];
    BMW_iOSAppDelegate *del = [[UIApplication sharedApplication] delegate];
	NSString *name = [del getNameForUDID:[[data objectAtIndex:indexPath.row] objectForKey:@"udid"]];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%d) %@: %@",indexPath.row+1,name, [self stringValueForPayload:[payload floatValue] AndPage:pageNumber]];
	cell.textLabel.textColor = [UIColor whiteColor];
		
	// Set up the cell...
	return cell;
}

-(NSString *)stringValueForPayload:(float)num AndPage:(int)page {
    switch (page) {
        case TOP_SPEED:
            return [NSString stringWithFormat:@"%.2f mph", num*MPS_TO_MPH];
            break;
        case TOTAL_DISTANCE:
            return [NSString stringWithFormat:@"%.1f miles", num*MPS_TO_MPH];
            break;
        case LIGHT_TIME:
            return [NSString stringWithFormat:@"%.0f min.", num/60.0];
            break;
        case AVG_SPEED:
            return [NSString stringWithFormat:@"%.1f mph", num*MPS_TO_MPH];
            break;
        case BREAKATHON_ROUTE:
            return [NSString stringWithFormat:@"%.1f", num];
        default:
            return [NSString stringWithFormat:@"%.1f", num];
            break;
    }
}

- (void)tableView: (UITableView*)tableView 
  willDisplayCell: (UITableViewCell*)cell 
forRowAtIndexPath: (NSIndexPath*)indexPath
{
    cell.backgroundColor = indexPath.row % 2 
	? [UIColor colorWithRed:(38.0/255.0) green:(53.0/255.0) blue:(69.0/255.0) alpha:1.0]
	: [UIColor colorWithRed:(18.0/255.0) green:(27.0/255.0) blue:(39.0/255.0) alpha:1.0];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
