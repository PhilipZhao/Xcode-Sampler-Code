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
#define TAG_UTILVIEW_TITLE 1
#define TAG_UTILVIEW_SUMMARY 2
#define TAG_UTILVIEW_PHOTO 3
#define TAG_SUPERVIEW_DATEPICKER 100
#define ALPHA_DISABLE 0.5
#define ANIMATION_POPUP 0.3
#define TEXT_TITLE @"@Title: "
#define TEXT_SUMMARY @"@Summary: "

#import "PMComposeNewsViewController.h"
@interface PMComposeNewsViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) UIButton *disEnableButton;
@property (strong, nonatomic) NSString *titleText;
@property (strong, nonatomic) NSString *summaryText;
@end

@implementation PMComposeNewsViewController
@synthesize utilView = _utilView;
@synthesize textView = _textView;
@synthesize locationView = _locationView;
@synthesize photoView = _photoView;
@synthesize completionHandler = _completionHandler;
@synthesize disEnableButton = _disEnableButton;

@synthesize titleText = _titleText;
@synthesize summaryText = _summaryText;

#pragma mark - Setter/Getter
- (PMComposeViewControllerCompletionHandler)completionHandler
{
  if (_completionHandler == nil) {
    _completionHandler = ^(PMComposeViewControllerResult rs){};
  }
  return _completionHandler;
}

- (UIButton *)disEnableButton
{
  if (_disEnableButton == nil) {
    _disEnableButton = (UIButton *)[self.utilView viewWithTag:TAG_UTILVIEW_TITLE];
  }
  return _disEnableButton;
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

#pragma mark - private function
- (void) switchSelectedStateFrom:(UIButton *) wasHighlighted to:(UIButton *) willBeHighlighted
{
  // change the image
  wasHighlighted.enabled = YES;
  wasHighlighted.highlighted = NO;
  willBeHighlighted.highlighted = YES;
  willBeHighlighted.enabled = NO;
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

- (void)viewDidUnload
{
  [self setUtilView:nil];
  [self setTextView:nil];
  [self setLocationView:nil];
  [self setPhotoView:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self];
  [super viewDidUnload];
  // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Target Action
- (IBAction)submitNews:(id)sender {
  // error checking and make sure it is OK.
  self.completionHandler(PMComposeViewControllerResultDone);
}

- (IBAction)cancelSumbit:(id)sender {
  self.completionHandler(PMComposeViewControllerResultCancelled);
}

- (IBAction)titleButton:(UIButton *)sender {
  
  [self switchSelectedStateFrom:self.disEnableButton to:sender];
  if (self.disEnableButton == [self.utilView viewWithTag:TAG_UTILVIEW_SUMMARY]) {
    NSLog(@"this is a summary tag before");
    self.summaryText = self.textView.text;
  }
  self.textView.text = self.titleText;
  
  self.disEnableButton = sender;
  [self.textView becomeFirstResponder];
}

- (IBAction)summaryButton:(UIButton *)sender {
  [self switchSelectedStateFrom:self.disEnableButton to:sender];
  if (self.disEnableButton == [self.utilView viewWithTag:TAG_UTILVIEW_TITLE]) {
    self.titleText = self.textView.text;
  }
  self.textView.text = self.summaryText;
  
  [self.textView becomeFirstResponder];
  self.disEnableButton = sender;
}

- (IBAction)photoButton:(UIButton *)sender {
  [self switchSelectedStateFrom:self.disEnableButton to:sender];
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
  self.disEnableButton = sender;
}

- (IBAction)timeButton:(UIButton *)sender {
  [self switchSelectedStateFrom:self.disEnableButton to:sender];
 
  UIDatePicker *datepicker;
  if ((datepicker = (UIDatePicker *)[self.view viewWithTag:TAG_SUPERVIEW_DATEPICKER]) == nil) {
    datepicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 244, datepicker.frame.size.width, datepicker.frame.size.height)];
    datepicker.tag = TAG_SUPERVIEW_DATEPICKER;
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
  [datepicker setDate:[NSDate date] animated:YES];
  
  [self.textView resignFirstResponder];
  self.disEnableButton = sender;
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


#pragma mark - UIImagePickerController Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
#warning test under the device
  NSString *sourceType = [info objectForKey:UIImagePickerControllerMediaType];
  // check sourceType isEqual to kUTTypeImage
  UIImage *choosedImage = [info objectForKey:UIImagePickerControllerEditedImage];
  // need to shrink the image to the right ratio
#warning unfinished implementation
  UIImageView *uploadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 8, 241, 136)];
  // init the image from selection
  uploadImageView.tag = TAG_PHOTOVIEW_IMG;
  [self.photoView addSubview:uploadImageView];
  [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  [picker dismissModalViewControllerAnimated:YES];
}

@end
