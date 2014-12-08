class FormatsController < ApplicationController
  respond_to :json
  def index
    render json: Format.new, serializer: FormatsSerializer, root: false
  end
end
