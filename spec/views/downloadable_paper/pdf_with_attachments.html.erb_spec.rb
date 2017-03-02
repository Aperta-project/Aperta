require "rails_helper"

describe 'downloadable_paper/pdf_with_attachments' do
  let(:figures) do
    create_list(:figure, 2).map { |f| PaperConverters::FigureProxy.from_figure(f) }
  end
  let(:supporting_information_files) { [] }
  let(:journal_pdf_css) { "" }
  let(:page) { Capybara::Node::Simple.new(rendered) }
  subject(:do_render) do
    render template: 'downloadable_paper/pdf_with_attachments',
           locals: {
             figures: figures,
             supporting_information_files: supporting_information_files,
             journal_pdf_css: journal_pdf_css
           }
  end

  it 'renders an img tag for each figure' do
    do_render
    expect(page).to have_css('img', count: 2)
  end

  it 'renders an img tag with the correct src' do
    do_render
    imgs = page.all('img')
    figures.zip(imgs).each do |fig, img|
      expect(fig.href).to be_a_valid_url
      expect(img['src']).to eq fig.href
    end
  end

  it 'renders a label for each figure' do
    do_render
    expect(page).to have_css('figcaption', count: 2)
  end

  it 'renders a label with the correct label number' do
    do_render
    labels = page.all('figcaption')
    figures.zip(labels).each do |fig, label|
      expect(fig.title).to be_present
      expect(label.text).to eq fig.title
    end
  end
end
