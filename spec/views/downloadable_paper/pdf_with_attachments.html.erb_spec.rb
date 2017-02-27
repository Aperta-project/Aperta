require "rails_helper"

describe 'downloadable_paper/pdf_with_attachments' do
  let(:figures) { create_list :figure, 2 }
  let(:page) { Capybara::Node::Simple.new(rendered) }
  subject(:do_render) do
    render template: 'downloadable_paper/pdf_with_attachments',
           locals: { figures: figures }
  end

  it 'renders an img tag for each figure' do
    do_render
    expect(page).to have_css('img', count: 2)
  end

  it 'renders an img tag with the correct src' do
    do_render
    imgs = page.all('img')
    figures.zip(imgs).each do |fig, img|
      expect(fig.detail_src)
      expect(img['src']).to eq fig.detail_src
    end
  end

  it 'renders a label for each figure' do
    do_render
    expect(page).to have_css('p', count: 2)
  end

  it 'renders a label with the correct label number' do
    do_render
    labels = page.all('p')
    figures.zip(labels).each do |fig, label|
      expect(fig.title).to be_present
      expect(label.text).to eq fig.title
    end
  end
end
