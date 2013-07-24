//
//  ViewController.m
//  Zhaonige
//
//  Created by lwh on 13-5-5.
//  Copyright (c) 2013年 air. All rights reserved.
//

#import "ViewController.h"
#import "GDataXMLNode.h"
#import "MaxRectsBinPack.h"
#import "MyRect.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    using namespace std;
    
    NSString *xmlPath = [[NSBundle mainBundle] pathForResource:@"1-1" ofType:@"xml"];
    NSData *xmlData = [[NSData alloc] initWithContentsOfFile:xmlPath];
    
    GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData options:0 error:nil];
    [xmlData release];
    GDataXMLElement *rootElement = [doc rootElement];

    
    NSString *resPath = [[NSBundle mainBundle] pathForResource:@"1_1" ofType:@"png"];
    NSData *resData = [[NSData alloc] initWithContentsOfFile:resPath];
    
    UIImage *img= [UIImage imageWithData:resData];
    [resData release];
    
    
    // scroll view
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
    sv.delegate = self;
    
    sv.pagingEnabled = NO;
    sv.backgroundColor = [UIColor grayColor];
    sv.showsVerticalScrollIndicator = NO;
    sv.showsHorizontalScrollIndicator = NO;
   
    CGSize newSize = CGSizeMake(480 * 4,320);
    [sv setContentSize:newSize];
    
    
    //////
    MaxRectsBinPack bin;
    int binWidth = 480 * 4;
    int binHeight = 295;

    bin.Init(binWidth,binHeight);
    
    
    NSArray *users = [rootElement elementsForName:@"Image"];
    
    for (GDataXMLElement *user in users) {
       
        CGImageRef cgImgRef = CGImageCreateWithImageInRect([img CGImage], CGRectMake([[[user attributeForName:@"XPos"] stringValue] intValue], [[[user attributeForName:@"YPos"] stringValue] intValue], [[[user attributeForName:@"Width"] stringValue] intValue], [[[user attributeForName:@"Height"] stringValue] intValue]));
        
        UIImage *m1 = [UIImage imageWithCGImage:cgImgRef];
        UIImageView *imgView = [[UIImageView alloc] initWithImage:m1];
        [imgView setTransform:CGAffineTransformMakeScale(.8, .8)];
        
        MaxRectsBinPack::FreeRectChoiceHeuristic heuristic = MaxRectsBinPack::RectBestAreaFit;
        MyRect packedRect = bin.Insert([imgView frame].size.width, [imgView frame].size.height, heuristic);
       
        if(packedRect.height > 0)
        {
            float ratio = .8;
            [imgView setFrame:CGRectMake(packedRect.x, packedRect.y, [imgView frame].size.width * ratio, [imgView frame].size.height * ratio)];
            [sv addSubview:imgView];
        }
        
        [imgView release];
       
    }
     
    //
    [self.view addSubview:sv];
    [sv release];
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    for (UIView *viewToShake in scrollView.subviews)
    {
            if(viewToShake.frame.origin.x > ABS(scrollView.contentOffset.x) && viewToShake.frame.origin.x < ABS(scrollView.contentOffset.x) + 480)
        {
            [self check:viewToShake];
        }
    }
}

-(void)check:(UIView *)viewToShake
{
    CGFloat t = 0.1;
    CGAffineTransform oriTrans = viewToShake.transform;
    CGAffineTransform translateRight  = CGAffineTransformRotate(viewToShake.transform, t);
    CGAffineTransform translateLeft = CGAffineTransformRotate(viewToShake.transform, -t);
    
    viewToShake.transform = translateLeft;
    
    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionAutoreverse|UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:4];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform = oriTrans;
            } completion:NULL];
        }
    }];
    
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)dealloc
{
    
    [super dealloc];
}
@end
