class Api::PaperSerializer < ActiveModel::Serializer
  attributes :id, :title, :authors, :paper_type, :epub

  def attributes
    data = super
    data[:epub_with_original] = epub_url(true) if object.manuscript.present?
    data
  end

  def epub
    epub_url(false)
  end

  private

  def epub_url(with_source)
    src_opts = with_source ? { include_original: true } : {}
    api_paper_url(object, src_opts.merge!(format: :epub))
  end
end
