final class CharacterImageDataLoaderPresentationAdapter<View: CharacterImageView, Image>: CharacterCellControllerDelegate where View.Image == Image {

   private let model: Character
   private let imageLoader: CharacterImageDataLoader
   private var task: CharacterImageDataLoaderTask?

   var presenter: CharacterImagePresenter<View, Image>?

   init(model: Character, imageLoader: CharacterImageDataLoader) {
       self.model = model
       self.imageLoader = imageLoader
   }

   func didRequestImage() {
       presenter?.didStartLoadingImageData(for: model)

       let model = self.model
       task = imageLoader.loadImageData(from: model.image) { [weak self] result in
           switch result {
           case let .success(data):
               self?.presenter?.didFinishLoadingImageData(with: data, for: model)

           case let .failure(error):
               self?.presenter?.didFinishLoadingImageData(with: error, for: model)
           }
       }
   }

   func didCancelImageRequest() {
       task?.cancel()
   }
}
