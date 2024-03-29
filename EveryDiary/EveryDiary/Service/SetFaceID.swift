//
//  SetFaceID.swift
//  EveryDiary
//
//  Created by Dahlia on 2/28/24.
//
import LocalAuthentication
import UIKit

class BiometricsAuth {
    func authenticateWithBiometrics(completion: @escaping (Bool, Error?) -> Void) {
        let context = LAContext()
        
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let reason = "인증이 필요합니다."
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) { success, authenticationError in
                if success {
                    completion(true, nil)
                } else {
                    // 사용자가 취소하거나 여러 번 실패한 경우, 시스템 비밀번호를 요청합니다.
                    if let error = authenticationError as NSError?, error.code == LAError.userCancel.rawValue || error.code == LAError.authenticationFailed.rawValue {
                        context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason, reply: { (success, error) in
                            DispatchQueue.main.async {
                                completion(success, error)
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            completion(false, authenticationError)
                        }
                    }
                }
            }
        } else {
            completion(false, error)
        }
    }
}
