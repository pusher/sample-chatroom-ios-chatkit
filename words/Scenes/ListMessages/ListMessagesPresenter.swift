//
//  ListMessagesPresenter.swift
//  words
//
//  Created by Neo Ighodaro on 09/12/2017.
//  Copyright (c) 2017 CreativityKills Co.. All rights reserved.
//
//  This file was generated by the Clean Swift Xcode Templates so
//  you can apply clean architecture to your iOS and Mac projects,
//  see http://clean-swift.com
//

import UIKit

protocol ListMessagesPresentationLogic
{
  func presentSomething(response: ListMessages.Something.Response)
}

class ListMessagesPresenter: ListMessagesPresentationLogic
{
  weak var viewController: ListMessagesDisplayLogic?
  
  // MARK: Do something
  
  func presentSomething(response: ListMessages.Something.Response)
  {
    let viewModel = ListMessages.Something.ViewModel()
    viewController?.displaySomething(viewModel: viewModel)
  }
}
