final class CharactersLoaderPresentationAdapter: CharactersViewControllerDelegate {
   private let characterLoader: CharacterLoader
   var presenter: CharactersPresenter?

   init(characterLoader: CharacterLoader) {
       self.characterLoader = characterLoader
   }

   func didRequestCharactersRefresh() {
       presenter?.didStartLoadingCharacters()

       characterLoader.load { [weak self] result in
           switch result {
           case let .success(characters):
               self?.presenter?.didFinishLoadingCharacters(with: characters)

           case let .failure(error):
               self?.presenter?.didFinishLoadingCharacters(with: error)
           }
       }
   }
}
