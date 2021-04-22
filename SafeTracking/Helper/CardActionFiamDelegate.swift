
import Foundation
import FirebaseInAppMessaging

// [START fiam_card_action_delegate]
class CardActionFiamDelegate : NSObject, InAppMessagingDisplayDelegate {
    
    func messageClicked(_ inAppMessage: InAppMessagingDisplayMessage) {
        // ...
        print("jass1")
    }
    
    func messageDismissed(_ inAppMessage: InAppMessagingDisplayMessage,
                          dismissType: FIRInAppMessagingDismissType) {
        // ...
        print("jass2")
    }
    
    func impressionDetected(for inAppMessage: InAppMessagingDisplayMessage) {
        // ...
        print("jass3")
    }
    
    func displayError(for inAppMessage: InAppMessagingDisplayMessage, error: Error) {
        // ...
        print("jass4")
    }
    

}
// [END fiam_card_action_delegate]
