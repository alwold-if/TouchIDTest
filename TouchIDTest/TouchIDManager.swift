//
//  TouchIDManager.swift
//  TouchIDTest
//
//  Created by Albert Wold on 3/13/17.
//  Copyright © 2017 iFactor. All rights reserved.
//

import Foundation

enum TouchIDError : Error {
    case generic(String)
}

class TouchIDManager {
    static let shared = TouchIDManager()

    func save(username: String, password: String) throws {
        // Should be the secret invalidated when passcode is removed? If not then use kSecAttrAccessibleWhenUnlocked
        var error: Unmanaged<CFError>?
        let sacObject =
            SecAccessControlCreateWithFlags(kCFAllocatorDefault, kSecAttrAccessibleAlways, .touchIDAny, &error)
        if (sacObject == nil || error != nil) {
            let errorString = String(format: "SecItemAdd can't create sacObject: %@", error?.takeRetainedValue().localizedDescription ?? "Unknown")
            
            throw TouchIDError.generic(errorString)
        }
        
        /*
         We want the operation to fail if there is an item which needs authentication so we will use
         `kSecUseNoAuthenticationUI`.
         */
        if let secretPasswordTextData = password.data(using: .utf8) {
            let attributes: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword as String,
                kSecAttrService as String: "SampleService",
                kSecValueData as String: secretPasswordTextData,
                kSecUseNoAuthenticationUI as String: true,
                kSecAttrAccessControl as String: sacObject
            ]
            //        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            let status = SecItemAdd(attributes as CFDictionary, nil);
            NSLog("status: \(status)")
            //            NSString *message = [NSString stringWithFormat:@"SecItemAdd status: %@", [self keychainErrorToString:status]];
            //
            //            [self printMessage:message inTextView:self.textView];
            //            });
        } else {
            throw TouchIDError.generic("Couldn't convert the password to Data")
        }
        
    }

    func load() -> (String, String)? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword as String,
            kSecAttrService as String: "SampleService",
            kSecReturnData as String: true,
            kSecUseOperationPrompt as String: "Poof",
        ]
        
//        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        var result: AnyObject?
        let status = withUnsafeMutablePointer(to: &result) { result in
            SecItemCopyMatching(query as CFDictionary, result);
        }
            if (status == errSecSuccess) {
                if let data = result as? Data, let password = String(data: data, encoding: .utf8) {
                    return ("foo", password)
                } else {
                    NSLog("casting stuff failed")
                    return nil
                }
            }
            else {
                NSLog("error: \(status)")
                return nil
//                message = [NSString stringWithFormat:@"SecItemCopyMatching status: %@", [self keychainErrorToString:status]];
            }
            
//            [self printMessage:message inTextView:self.textView];
//            });
    }
}
