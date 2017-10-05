//
//  ViewController.swift
//  AHFMDownloadCenter
//
//  Created by ivsall2012 on 08/08/2017.
//  Copyright (c) 2017 ivsall2012. All rights reserved.
//

import UIKit
import AHServiceRouter

import AHFMDownloadListServices
import AHFMDownloadListManager

import AHFMAudioPlayerManager

import AHFMDownloaderManager

import AHFMDownloadCenterManager

import AHFMAudioPlayerVCManager


import AHFMNetworking
import AHFMDataTransformers
import SwiftyJSON
import AHFMDataCenter

import SVProgressHUD

class ViewController: UIViewController {
    lazy var networking = AHFMNetworking()
    let showId = 722
    override func viewDidLoad() {
        super.viewDidLoad()
        AHFMDownloadListManager.activate()
        AHFMDownloadCenterManager.activate()
        AHFMAudioPlayerManager.activate()
        AHFMDownloaderManager.activate()
        AHFMAudioPlayerVCManager.activate()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        SVProgressHUD.show()
        if let show = AHFMShow.query(byPrimaryKey: showId) {
            SVProgressHUD.dismiss()
            let info: [String: Any] = [AHFMDownloadListService.keyShowId: show.id, AHFMDownloadListService.keyShouldShowRightNavBarButton: true]
            AHServiceRouter.navigateVC(AHFMDownloadListService.service, taskName: AHFMDownloadListService.taskNavigation, userInfo: info, type: .push(navVC: self.navigationController!), completion: nil)
        }else{
            fetchShows()
        }
    }
    
    func fetchShows() {
        networking.showsByCategory("news") { (data, _) in
            if let data = data,let jsonShows = JSON(data)["results"].array {
                let showDictArr = AHFMShowTransform.transformJsonShows(jsonShows)
                var shows = [AHFMShow]()
                for showDict in showDictArr {
                    let show = AHFMShow(with: showDict)
                    shows.append(show)
                }
                AHFMShow.write {
                    AHFMShow.insert(models: shows)
                    
                    if shows.count > 0, let show = shows.first{
                        let id = show.id
                        let info: [String: Any] = [AHFMDownloadListService.keyShowId: id, AHFMDownloadListService.keyShouldShowRightNavBarButton: true]
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            AHServiceRouter.navigateVC(AHFMDownloadListService.service, taskName: AHFMDownloadListService.taskNavigation, userInfo: info, type: .push(navVC: self.navigationController!), completion: nil)
                        }
                    }
                }
                
            }
        }
    }
}

