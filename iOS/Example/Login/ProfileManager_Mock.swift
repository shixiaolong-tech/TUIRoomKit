//
//  profileManager.swift
//  trtcScenesDemo
//
//  Created by xcoderliu on 12/23/19.
//  Copyright © 2019 xcoderliu. All rights reserved.
//

import UIKit
import Alamofire
import ImSDK_Plus
import TUICore
import TUIRoomKit

@objc class LoginResultModel: NSObject, Codable {
    @objc var token: String
    @objc var phone: String
    @objc var name: String
    @objc var avatar: String
    @objc var userId: String
    @objc var userSig: String = ""
    
    init(userID: String) {
        userId = userID
        token = userID
        phone = userID
        name = userID
        
        userSig = GenerateTestUserSig.genTestUserSig(identifier: userID)
        avatar = "https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png"
        super.init()
    }
}

@objc public class ProfileManager: NSObject {
    @objc public static let shared = ProfileManager()
    private override init() {}
    
    var sessionId: String = ""
    @objc var curUserModel: LoginResultModel? = nil
    
    @objc public func autoLogin(success: @escaping ()->Void,
                                failed: @escaping (_ error: String)->Void) -> Bool {
        let tokenKey = "com.tencent.trtcScences.demo"
        if let cacheData = UserDefaults.standard.object(forKey: tokenKey) as? Data {
            if let cacheUser = try? JSONDecoder().decode(LoginResultModel.self, from: cacheData) {
                curUserModel = cacheUser
                let fail: (_ error: String)->Void = { err in
                    failed(err)
                    UserDefaults.standard.set(nil, forKey: tokenKey)
                }
                login(phone: curUserModel?.userId ?? "", name: curUserModel?.name ?? "", success: success, failed: fail, auto: true)
                return true
            }
        }
        return false
    }
    
    @objc public func login(phone: String, name: String, success: @escaping ()->Void,
                            failed: ((_ error: String) -> Void)? = nil , auto: Bool = false) {
        let phoneValue = phone
        if !auto {
            assert(phoneValue.count > 0)
            curUserModel = LoginResultModel(userID: phoneValue)
        }
        // cache data
        let tokenKey = "com.tencent.trtcScences.demo"
        do {
            let cacheData = try JSONEncoder().encode(curUserModel)
            UserDefaults.standard.set(cacheData, forKey: tokenKey)
        } catch {
            print("Save Failed")
        }
        success()
    }
    
    func localizeUserModel() {
        let tokenKey = "com.tencent.trtcScences.demo"
        do {
            let cacheData = try JSONEncoder().encode(curUserModel)
            UserDefaults.standard.set(cacheData, forKey: tokenKey)
        } catch {
            print("Save Failed")
        }
    }
    
    @objc public func setNickName(name: String, success: @escaping ()->Void,
                                  failed: @escaping (_ error: String)->Void) {
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = name
        curUserModel?.name = name
        V2TIMManager.sharedInstance()?.setSelfInfo(info: userInfo, succ: {
            success()
            debugPrint("set profile success")
        }, fail: { (code, desc) in
            failed(desc ?? "")
            debugPrint("set profile failed.")
        })
    }

    @objc func IMLogin(userSig: String, success: @escaping ()->Void, failed: @escaping (_ error: String)->Void) {
        guard let userID = curUserModel?.userId else {
            failed("userID wrong")
            return
        }
        let user = String(userID)
       
        TUILogin.login(Int32(SDKAppID), userID: user, userSig: userSig) {
            debugPrint("login success")
            V2TIMManager.sharedInstance()?.getUsersInfo([userID], succ: { [weak self] (infos) in
                guard let `self` = self else { return }
                if let info = infos?.first {
                    self.curUserModel?.avatar = info.faceURL ?? ""
                    self.curUserModel?.name = info.nickName ?? ""
                    success()
                }
                else {
                    failed("")
                }
            }, fail: { (code, err) in
                failed(err ?? "")
                debugPrint("get user info failed, code:\(code), error: \(err ?? "nil")")
            })
        } fail: { (code, errorDes) in
            failed(errorDes ?? "")
            debugPrint("login failed, code:\(code), error: \(errorDes ?? "nil")")
        }
    }
    
    @objc func curUserID() -> String? {
        guard let userID = curUserModel?.userId else {
            return nil
        }
        return userID
    }
    
    @objc public func removeLoginCache() {
        let tokenKey = "com.tencent.trtcScences.demo"
        UserDefaults.standard.set(nil, forKey: tokenKey)
    }
    
    @objc public func curUserSig() -> String {
        return curUserModel?.userSig ?? ""
    }
    
    @objc func synchronizUserInfo() {
        guard let userModel = curUserModel else {
            return
        }
        let userInfo = V2TIMUserFullInfo()
        userInfo.nickName = userModel.name
        userInfo.faceURL = userModel.avatar
        V2TIMManager.sharedInstance()?.setSelfInfo(info: userInfo, succ: {
            debugPrint("set profile success")
        }, fail: { (code, desc) in
            debugPrint("set profile failed.")
        })
    }
}

