//
//  Copyright (c) 2017 Google Inc.
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

#import "FUIAccountSettingsViewController+Common.h"

@implementation FUIAccountSettingsViewController (DeleteAccount)

- (void)deleteAccountWithLinkedProvider {
  [self showSelectProviderDialog:^(id<FIRUserInfo> provider) {
    [self reauthenticateWithProviderUI:provider actionHandler:^{
      [self showDeleteAccountView];
    }];
  } alertTitle:@"Delete Account?"
                    alertMessage:@"This will erase all data associated with your account, and can't be undone You will need t osign in again to complete this action"
                alertCloseButton:[FUIAuthStrings cancel]];
}

- (void)showDeleteAccountView {
  NSString *message = @"This will erase all data assosiated with your account, and can't be undone. Are you sure you want to delete your account?";
  UIViewController *controller =
      [[FUIStaticContentTableViewController alloc] initWithContents:nil
                                                          nextTitle:@"Delete"
                                                       nextAction:^{
                                                         [self onDeleteAccountViewNextAction];
                                                       }
                                                         headerText:message];
  // TODO: add localization
  controller.title = @"Delete account";
  [self pushViewController:controller];
  
}

- (void)onDeleteAccountViewNextAction {
  UIAlertController *alertController =
  [UIAlertController alertControllerWithTitle:@"Delete account?"
                                      message:@"This action can't be undone"
                               preferredStyle:UIAlertControllerStyleAlert];
  UIAlertAction *deleteAction =
      [UIAlertAction actionWithTitle:@"Delete Account"
                               style:UIAlertActionStyleDestructive
                             handler:^(UIAlertAction * _Nonnull action) {
                               [self deleteCurrentAccount];
                             }];
  UIAlertAction *action =
      [UIAlertAction actionWithTitle:[FUIAuthStrings cancel]
                               style:UIAlertActionStyleCancel
                             handler:nil];
  [alertController addAction:deleteAction];
  [alertController addAction:action];
  [self presentViewController:alertController animated:YES completion:nil];

}

- (void)deleteCurrentAccount {
  [self incrementActivity];
  [self.auth.currentUser deleteWithCompletion:^(NSError * _Nullable error) {
    [self decrementActivity];
    if (!error) {
      [self onBack];
      [self updateUI];
    } else {
      [self finishSignUpWithUser:self.auth.currentUser error:error];
    }
  }];
}

@end
