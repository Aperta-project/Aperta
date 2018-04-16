# Copyright (c) 2018 Public Library of Science

# Permission is hereby granted, free of charge, to any person obtaining a
# copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.

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
      expect(URI.parse(img['src']).path).to eq URI.parse(fig.href).path
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
