//
//  PMComposeNewsViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/18/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//
#define TAG_PHOTOVIEW_LIBRARY 1
#define TAG_PHOTOVIEW_CAMERA  2
#define TAG_PHOTOVIEW_IMG     3
#define TAG_PHOTOVIEW_IMG_CANCEL 4

#define TAG_UTILVIEW_TITLE 1
#define TAG_UTILVIEW_SUMMARY 2
#define TAG_UTILVIEW_PHOTO 3

#define TAG_SUPERVIEW_DATEPICKER 100
#define ALPHA_DISABLE 0.5
#define ANIMATION_POPUP 0.3
#define TEXT_TITLE @"@Title: "
#define TEXT_SUMMARY @"@Summary: "

#import "PMComposeNewsViewController.h"
#import "PMHerokCacheRequest.h"
#import "PMAppDelegate.h"
#import "PMStandKeyConstant.h"
#import <QuartzCore/QuartzCore.h>


@interface PMComposeNewsViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (nonatomic) int enableButtonIndex;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *summaryText;
@property (strong, nonatomic) NSDate *eventDateTime;
@property (nonatomic) BOOL photoButtonEnable;
@property (nonatomic) BOOL cameraButtonEnable;
@end

@implementation PMComposeNewsViewController
@synthesize author_screen_name = _author_screen_name;
@synthesize address = _address;
@synthesize location = _location;

@synthesize utilView = _utilView;
@synthesize textView = _textView;
@synthesize locationView = _locationView;
@synthesize photoView = _photoView;
@synthesize completionHandler = _completionHandler;
@synthesize enableButtonIndex = _enableButtonIndex;

@synthesize titleText = _titleText;
@synthesize summaryText = _summaryText;
@synthesize eventDateTime = _eventDateTime;

@synthesize photoButtonEnable = _photoButtonEnable;
@synthesize cameraButtonEnable = _cameraButtonEnable;

#pragma mark - Setter/Getter
- (PMComposeViewControllerCompletionHandler)completionHandler
{
  if (_completionHandler == nil) {
    _completionHandler = ^(PMComposeViewControllerResult rs){};
  }
  return _completionHandler;
}

- (NSString *)titleText
{
  if (_titleText == nil) {
    _titleText = @"";
  }
  return _titleText;
}

- (NSString *)summaryText
{
  if (_summaryText == nil) {
    _summaryText= @"";
  }
  return _summaryText;
}

- (NSDate *)eventDateTime
{
  if (_eventDateTime == nil) {
    _eventDateTime = [NSDate date];
  }
  return _eventDateTime;
}

#pragma mark - private function
- (void) switchSelectedStateFrom:(UIButton *) wasHighlighted to:(UIButton *) willBeHighlighted
{
  // change the image
  wasHighlighted.enabled = YES;
  wasHighlighted.highlighted = NO;
  wasHighlighted.alpha = 1.0;
  willBeHighlighted.highlighted = YES;
  willBeHighlighted.enabled = NO;
  willBeHighlighted.alpha = 0.5;
}

- (void) respositionUitlView:(NSNotification *)notification
{
  CGSize size = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
  self.utilView.frame = CGRectMake(0, self.view.frame.size.height - self.utilView.frame.size.height - size.height, 
                                   size.width, 
                                   self.utilView.frame.size.height);
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  // get the frame value and reposition the utilView.
}

- (void) packedNewsWithInfor:(NSDictionary *) news {
  [news setValue:self.author_screen_name forKey:PASSIM_SCREEN_NAME];
  [news setValue:self.titleText forKey:PASSIM_NEWS_TITLE];
  [news setValue:[NSString stringWithFormat:@"%f", self.location.coordinate.latitude] forKey:PASSIM_LATITIUDE];
  [news setValue:[NSString stringWithFormat:@"%f", self.location.coordinate.longitude] forKey:PASSIM_LONGTITUDE];
  NSDateFormatter* formmater = [[NSDateFormatter alloc] init];
  [formmater setDateFormat:PASSIM_DATE_TIME_FORMAT];
  NSString* eventDateTime = [formmater stringFromDate:self.eventDateTime];
  [news setValue:eventDateTime forKey:PASSIM_DATE_TIME];
  [news setValue:[self.address valueForKey:@"City"] forKey:PASSIM_CITY];
  [news setValue:[self.address valueForKey:@"Country"] forKey:PASSIM_COUNTRY];
  [news setValue:[self.address valueForKey:@"State"] forKey:PASSIM_STATE];
  NSLog(@"%@", self.address);
  [news setValue:[self.address valueForKey:@"Name"] forKey:PASSIM_NEWS_ADDRESS];
  NSLog(@"name: %@", [news valueForKey:PASSIM_NEWS_ADDRESS]);
  [news setValue:self.summaryText forKey:PASSIM_NEWS_SUMMARY];
  if ([self.photoView viewWithTag:TAG_PHOTOVIEW_IMG] != nil)
    [news setValue:[(UIImageView *)[self.photoView viewWithTag:TAG_PHOTOVIEW_IMG] image] forKey:PASSIM_NEWS_PHOTO_UI];
}

#pragma mark - Life cycle
- (void)viewDidLoad
{
  [super viewDidLoad];
  NSLog(@"Composite News View Load");
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(respositionUitlView:) name:UIKeyboardWillShowNotification object:nil];
  [self.textView becomeFirstResponder];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  // hightlight "title" button and dis-able it
  
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    UIButton *photoButton = (UIButton *)[self.utilView viewWithTag:TAG_UTILVIEW_PHOTO];
    photoButton.enabled = NO;
    photoButton.alpha = ALPHA_DISABLE;
  }

  UIButton *cameraButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_CAMERA];
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    cameraButton.enabled = YES;
    cameraButton.hidden = NO;
  } else {
    cameraButton.enabled = NO;
    cameraButton.alpha = ALPHA_DISABLE;
  }
  UIButton *photoButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_LIBRARY];
  if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
    photoButton.enabled = YES;
    photoButton.hidden = NO;
  } else {
    photoButton.enabled = NO;
    photoButton.alpha = ALPHA_DISABLE;
  }
}

- (void)viewDidDisappear:(BOOL)animated
{
  [super viewDidDisappear:animated];
  // free all the resource that is holding
}

- (void)viewDidUnload
{
  [self setUtilView:nil];
  [self setTextView:nil];
  [self setLocationView:nil];
  [self setPhotoView:nil];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Target Action
- (IBAction)submitNews:(id)sender {
  if (self.enableButtonIndex == 0)
    self.titleText = self.textView.text;
  else if (self.enableButtonIndex == 1)
    self.summaryText = self.textView.text;

  // error checking and make sure it is OK.
  if (self.location != nil && [self.author_screen_name length] > 0 && self.address != nil && [self.titleText length] > 0) {
    id delegate = [[UIApplication sharedApplication] delegate];
    PMHerokCacheRequest *request = [delegate valueForKey:PMHEROKREQUEST_KEY];
    NSMutableDictionary *news = [NSMutableDictionary dictionaryWithCapacity:9];
    [self packedNewsWithInfor:news];
    NSLog(@"%@", news); 
    // animation
    [request postNews:news withCompleteBlock:^(BOOL finished) {
      if (finished) {
        NSLog(@"Result Done");
        self.completionHandler(PMComposeViewControllerResultDone);
      } else {
        NSLog(@"Result Failure");
        self.completionHandler(PMComposeViewControllerResultFailure);
      }
      // dismiss the animation
    }];
  } else {
    self.completionHandler(PMComposeViewControllerResultCancelled);
  }
  [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)cancelSumbit:(id)sender {
  [self dismissViewControllerAnimated:YES completion:^{}];
  self.completionHandler(PMComposeViewControllerResultCancelled);
}



- (void)titleButton:(UIButton *)sender {
  //[self switchSelectedStateFrom:self.disEnableButton to:sender];
  if (self.enableButtonIndex == 1) {
    //NSLog(@"this is a summary tag before");
    self.summaryText = self.textView.text;
  }
  self.textView.text = self.titleText;
  
  //self.disEnableButton = sender;
  [self.textView becomeFirstResponder];
}

- (void)summaryButton:(UIButton *)sender {
  //[self switchSelectedStateFrom:self.disEnableButton to:sender];
  if (self.enableButtonIndex == 0) {
    self.titleText = self.textView.text;
  }
  self.textView.text = self.summaryText;
  
  [self.textView becomeFirstResponder];
  //self.disEnableButton = sender;
}

- (void)photoButton:(UIButton *)sender {
  //[self switchSelectedStateFrom:self.disEnableButton to:sender];
  if (self.enableButtonIndex == 0) self.titleText = self.textView.text;
  else if (self.enableButtonIndex == 1) self.summaryText = self.textView.text;
  
  self.photoView.hidden = NO;
  UIDatePicker *datepicker;
  if ((datepicker = (UIDatePicker *)[self.view viewWithTag:TAG_SUPERVIEW_DATEPICKER]) != nil 
      && !datepicker.hidden) {
    [UIView animateWithDuration:ANIMATION_POPUP animations:^{
      datepicker.frame = CGRectMake(0, self.view.frame.size.height, datepicker.frame.size.width, datepicker.frame.size.height);
      //datepicker.hidden = YES;
    } completion:^(BOOL completed) {
      datepicker.hidden = YES;
    }];
  }
  [self.textView resignFirstResponder];
  //self.disEnableButton = sender;
}

- (void)timeButton:(UIButton *)sender {
  //[self switchSelectedStateFrom:self.disEnableButton to:sender];
 
  UIDatePicker *datepicker;
  if ((datepicker = (UIDatePicker *)[self.view viewWithTag:TAG_SUPERVIEW_DATEPICKER]) == nil) {
    datepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 244, datepicker.frame.size.width, datepicker.frame.size.height)];
    datepicker.tag = TAG_SUPERVIEW_DATEPICKER;
    [datepicker addTarget:self action:@selector(datePickerValueChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:datepicker];
    self.photoView.hidden = YES;
  } else {
    CGRect frame = CGRectMake(0, 244, datepicker.frame.size.width, datepicker.frame.size.width);
    if (![self.textView isFirstResponder]) {
      [UIView animateWithDuration:ANIMATION_POPUP animations:^{
        datepicker.frame = frame;
      } completion:^(BOOL completed) {
      self.photoView.hidden = YES;
      }];
    } else {
      datepicker.frame = frame;
      self.photoView.hidden = YES;
    }
  }
  datepicker.hidden = NO;
  [datepicker setDate:self.eventDateTime animated:YES];
  
  [self.textView resignFirstResponder];
  //self.disEnableButton = sender;
}

- (IBAction)photoChooseFromLibrary:(UIButton *)sender {
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [self presentModalViewController:picker animated:YES];
}

- (IBAction)photoChooseFromCamera:(UIButton *)sender {
  UIImagePickerController *picker = [[UIImagePickerController alloc] init];
  picker.delegate = self;
  picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  [self presentModalViewController:picker animated:YES];
}

- (IBAction)datePickerValueChange:(UIDatePicker *)sender {
  NSLog(@"%@",sender.date);
  self.eventDateTime = sender.date;
}

- (IBAction)cancelImage:(id)sender {
  NSLog(@"I am in called");
  UIButton *cameraButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_CAMERA];
  cameraButton.enabled = (cameraButton.alpha >= 1) ? YES: cameraButton.enabled;
  UIButton *photoButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_LIBRARY];
  photoButton.enabled = (photoButton.alpha >= 1) ? YES: photoButton.enabled;
  UIButton *imgCancelButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_IMG_CANCEL];
  UIImageView *imgView = (UIImageView *)[self.photoView viewWithTag:TAG_PHOTOVIEW_IMG];
  imgCancelButton.enabled = NO;
  imgCancelButton.hidden = imgView.hidden = YES;
  imgView.image = nil;
}

#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  [picker dismissModalViewControllerAnimated:YES];
  NSLog(@"imagePickerController: %@", info);
  
  NSString *sourceType = [info objectForKey:UIImagePickerControllerMediaType];
  // check sourceType isEqual to kUTTypeImage
  UIImage *choosedImage = [info objectForKey:UIImagePickerControllerEditedImage];
  if (choosedImage == nil) choosedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
  // need to shrink the image to the right ratio
#warning unfinished implementation
  UIImageView *uploadImageView;
  if ([self.photoView viewWithTag:TAG_PHOTOVIEW_IMG] == nil) {
    uploadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 8, 241, 136)];
    uploadImageView.tag = TAG_PHOTOVIEW_IMG;
    [self.photoView addSubview:uploadImageView];
  } else
    uploadImageView = (UIImageView *)[self.photoView viewWithTag:TAG_PHOTOVIEW_IMG];
  // init the image from selection
  uploadImageView.hidden = NO;
  uploadImageView.image = choosedImage;
  UIButton *imgCancelButton;
  if ([self.photoView viewWithTag:TAG_PHOTOVIEW_IMG_CANCEL] == nil) {
    imgCancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    imgCancelButton.frame = CGRectMake(40+241-15, 8-15, 30, 30);
    imgCancelButton.tag = TAG_PHOTOVIEW_IMG_CANCEL;
    [imgCancelButton setImage:[UIImage imageNamed:@"closeIcon.png"] forState:UIControlStateNormal];
    [imgCancelButton setImage:[UIImage imageNamed:@"closeIcon.png"] forState:UIControlStateHighlighted];
    [imgCancelButton addTarget:self action:@selector(cancelImage:) forControlEvents:UIControlEventTouchUpInside];
    [self.photoView addSubview:imgCancelButton];
  } else 
    imgCancelButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_IMG_CANCEL];
  imgCancelButton.hidden = NO;
  imgCancelButton.enabled = YES;
  
  UIButton *cameraButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_CAMERA];
  cameraButton.enabled = NO;
  UIButton *photoButton = (UIButton *)[self.photoView viewWithTag:TAG_PHOTOVIEW_LIBRARY];
  photoButton.enabled = NO;
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissModalViewControllerAnimated:YES];
}

- (IBAction)selectedSegment:(UISegmentedControl *)sender {
    switch ([sender selectedSegmentIndex]) {
        case 0:
            [self titleButton:nil];
            self.enableButtonIndex = 0;
            break;
        case 1:
            [self summaryButton:nil];
            self.enableButtonIndex = 1;
            break;
        case 2:
            [self timeButton:nil];
            self.enableButtonIndex = 2;
            break;
        case 3:
            [self photoButton:nil];
            self.enableButtonIndex = 3;
            break;
    }
}

@end
