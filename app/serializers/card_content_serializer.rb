class CardContentSerializer < ActiveModel::Serializer
  attributes :id, :ident, :text, :value_type, :content_type,
    :children, :config

  def children
    if @options[:admin]
      object.children.map do |c|
        CardContentSerializer.new(c, admin: true, root: false).as_json
      end
    else
      []
    end
  end
end
