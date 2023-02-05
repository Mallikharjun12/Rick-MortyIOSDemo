//
//  CharactersListViewViewModel.swift
//  RickAndMorty
//
//  Created by Mallikharjun kakarla on 31/12/22.
//

import Foundation
import UIKit

protocol RMCharactersListViewViewModelDelegate:AnyObject {
    func didLoadInitialCharacters()
    func didLoadMoreCharacters(with newIndexpaths: [IndexPath])
    func didSelectCharacter(_ character: RMCharacter)
}

/// viewModel to handle character list view logic
final class RMCharactersListViewViewModel:NSObject {
    
    public weak var delegate:RMCharactersListViewViewModelDelegate?
    private var characters:[RMCharacter] = [] {
        didSet {
            for character in characters {
                let viewModel = RMCharacterCollectionViewCellViewModel(
                    characterName: character.name,
                    characterStatus: character.status,
                    characterImageUrl: URL(string: character.image)
                )
                if !cellViewModels.contains(viewModel) {
                    cellViewModels.append(viewModel)
                }
            }
        }
    }
    
    private var cellViewModels:[RMCharacterCollectionViewCellViewModel] = []
    private var apiInfo:RMGetAllCharactersResponse.Info? = nil
    
    private var isLoadingMoreCharacters = false
    
    /// fetch initial set of characters(20)
    func fetchCharacters() {
        RMService.shared.execute(RMRequest.listCharactersRequests, expecting: RMGetAllCharactersResponse.self) {[weak self] result in
            switch result {
            case .success(let responseModel):
                let results = responseModel.results
                let info = responseModel.info
                self?.characters = results
                self?.apiInfo = info
                DispatchQueue.main.async {
                    self?.delegate?.didLoadInitialCharacters()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /// paginate if additional characters are required
    public func fetchAdditionalCharacters(url: URL) {
        //Fetch Characeters
        guard !isLoadingMoreCharacters else {
            return
        }
        isLoadingMoreCharacters = true
        print("Fetching More characters")
        guard let request = RMRequest(url: url) else {
            isLoadingMoreCharacters = false
            print("Failed to create request")
            return
        }
        RMService.shared.execute(request,
                                 expecting: RMGetAllCharactersResponse.self) {[weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let responseModel):
                print("Pre-Update:\(strongSelf.cellViewModels.count)")
                let moreResults = responseModel.results
                let info = responseModel.info
                strongSelf.apiInfo = info
                
                let originalCount = strongSelf.characters.count
                let newCount = moreResults.count
                let total = originalCount + newCount
                let startingIndex = total - newCount
                let indexPathsToAdd:[IndexPath] = Array(startingIndex..<(startingIndex+newCount)).compactMap({
                    return IndexPath(row: $0, section: 0)
                })
                print(indexPathsToAdd)
                strongSelf.characters.append(contentsOf: moreResults)
                DispatchQueue.main.async {
                    strongSelf.delegate?.didLoadMoreCharacters(with: indexPathsToAdd)
                    strongSelf.isLoadingMoreCharacters = false
                }
                print("post - update:\(strongSelf.cellViewModels.count)")
            case .failure(let error):
                print(error)
                strongSelf.isLoadingMoreCharacters = false
            }
        }
    }
    
    public var shouldShowLoadMoreIndicator:Bool{
        return apiInfo?.next != nil
    }
}


//MARK: CollectionView implementation
extension RMCharactersListViewViewModel:UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cellViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RMCharacterCollectionViewCell.identifier, for: indexPath) as? RMCharacterCollectionViewCell else {
            fatalError("Cell not supported")
        }
        let viewModel = cellViewModels[indexPath.row]
        cell.configure(with: viewModel)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter,
              let footer = collectionView.dequeueReusableSupplementaryView(
                  ofKind: kind,
                  withReuseIdentifier: RMFooterLoadingCollectionReusableView.identifier, for: indexPath) as? RMFooterLoadingCollectionReusableView  else {
            fatalError("Unsupported")
        }
        
        
        footer.startAnimating()
        return footer
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard shouldShowLoadMoreIndicator else {
            return .zero
        }
        return CGSize(width: collectionView.frame.height, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let bounds = UIScreen.main.bounds
        let width = (bounds.width-30)/2
        return CGSize(width: width, height: width*1.5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let character = characters[indexPath.row]
        delegate?.didSelectCharacter(character)
    }
}
//MARK: Scroll View
extension RMCharactersListViewViewModel:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard shouldShowLoadMoreIndicator ,
        !isLoadingMoreCharacters,
        let nextUrlString = apiInfo?.next,
        let url = URL(string: nextUrlString)   else {
            return
        }
        
        let offset = scrollView.contentOffset.y
        let totalContentheight = scrollView.contentSize.height
        let totalScrollViewFixedHeight = scrollView.frame.size.height
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) {[weak self] timer in
            if offset > (totalContentheight - totalScrollViewFixedHeight - 100.0 - 20.0) {
                self?.fetchAdditionalCharacters(url: url)
            }
            timer.invalidate()
        }
        
//        print("offset:\(offset),totalContentheight:\(totalContentheight),totalScrollViewFixedHeight:\(totalScrollViewFixedHeight)")
    }
}
