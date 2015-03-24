TahiSupportingInformation::Engine.routes.draw do
  resources :files, path: 'supporting_information_files',
                    only: [:create, :destroy, :update]
end
