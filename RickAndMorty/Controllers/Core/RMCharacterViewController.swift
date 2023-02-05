//
//  RMCharacterViewController.swift
//  RickAndMorty
//
//  Created by Mallikharjun kakarla on 25/12/22.
//

import UIKit

/// Controller to show and search for Characters
final class RMCharacterViewController: UIViewController{
    
      private let characterListView = RMCharacterListView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Characters"
        view.backgroundColor = .systemBackground
        
//      let request = RMRequest(endPoint: .character,
//                             queryParameters: [URLQueryItem(name: "name", value: "rick"),
//                                              URLQueryItem(name: "status", value:"alive")
//                                                 ])
//        print(request.url)
        setUpView()
        characterListView.delegate = self
    }
    
    private func setUpView() {
        view.addSubview(characterListView)
        NSLayoutConstraint.activate([
            characterListView.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor),
            characterListView.leftAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leftAnchor),
            characterListView.rightAnchor.constraint(equalTo:view.safeAreaLayoutGuide.rightAnchor),
            characterListView.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor)])
    }
}

extension RMCharacterViewController:RMCharacterListViewDelegate {
    func rmCharacterListView(_ CharacterListView: RMCharacterListView, didSelectCharacter character: RMCharacter) {
        //Open detail controller for that character
        let viewModel = RMCharacterDetailViewViewModel(character: character)
        let detailVC = RMCharacterDetailViewController(viewModel)
        detailVC.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
