//
//  PMComposeNewsViewController.m
//  Passim
//
//  Created by Philip Zhao on 1/18/12.
//  Copyright (c) 2012 University of Wisconsin-Madison. All rights reserved.
//
#define TAG_PHOTOVIEW_LIBRARY 1
#define TAG_PHOTOVIEW_CAMERA 2
#define TAG_UTILVIEW_TITLE 1
#define TAG_UTILVIEW_SUMMARY 2
#define TAG_UTILVIEW_PHOTO 3
#define ALPHA_DISABLE 0.5

#import "PMComposeNewsViewController.h"
@interface PMComposeNewsViewController() <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
@property (weak, nonatomic) UIButton *disEnableButton;
@end

@implementation PMComposeNewsViewController
@synthesize utilView = _utilView;
@synthesize textView = _textView;
@synthesize locationView = _locationView;
@synthesize photoView = _photoView;
@synthesize completionHandler = _completionHandler;
@synthesize disEnableButton = _disEnableButton;

#pragma mark - Setter/Getter
- (PMComposeViewControllerCompletionHandler) completionHandler
{
  if (_completionHandler == nil) {
    _completionHandler = ^(PMComposeViewControllerResult rs){};
  }
  return _completionHandler;
}

- (UIButton *) disEnableButton
{
  if (_disEnableButton == nil) {
    _disEnableButton = (UIButton *)[self.utilView viewWithTag:TAG_UTILVIEW_TITLE];
  }
  return _disEnableButton;
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
  [self.textView becomeFirstResponder];
  [self switchSelectedStateFrom:self.disEnableButton to:sender];
  self.disEnableButton = sender;
  self.textView.text = @"@Title";
}

- (IBAction)summaryButton:(UIButton *)sender {
  [self.textView becomeFirstResponder];
  [self switchSelectedStateFrom:self.disEnableButton to:sender];
  self.disEnableButton = sender;
  self.textView.text = @"@Summary";
}

- (IBAction)photoButton:(UIButton *)sender {
  [self switchSelectedStateFrom:self.disEnableButton to:sender];
  self.disEnableButton = sender;
  [self.textView resignFirstResponder];
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
  NSLog(@"didFinishPickingMediaWithInfor");
  [picker dismissModalViewControllerAnimated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
  NSLog(@"did cancel it");
  [picker dismissModalViewControllerAnimated:YES];
}

@end
