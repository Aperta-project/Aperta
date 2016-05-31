require 'rails_helper'

describe FigureInserter do
  def image_html(figure)
    <<-HTML
      <img class="paper-body-figure pdf-image pdf-image-with-caption"
         data-figure-id="#{figure.id}"
         data-figure-rank="#{figure.rank}"
         src="#{figure.detail_src}">
    HTML
  end

  def caption_and_image_html(figure)
    <<-HTML
      #{image_html(figure)}
      <p class="paper-body-figure-caption">#{figure.title}.</p>
    HTML
  end
  describe "#call" do
    let(:figure1) do
      figure = create :figure, title: "1"
      allow(figure).to receive(:detail_src).and_return('/an/image1.png')
      allow(figure).to receive(:attachment?).and_return(true)
      figure
    end

    let(:figure11) do
      figure = create :figure, title: "11"
      allow(figure).to receive(:detail_src).and_return('/an/image2.png')
      allow(figure).to receive(:attachment?).and_return(true)
      figure
    end

    let(:figure_inserter) { FigureInserter.new(html, figures) }

    subject(:modified_html) { parse figure_inserter.call }
    context "there are no figures" do
      let(:figures) { [] }

      context "the input has no image tags but has a valid caption" do
        let(:html) do
          <<-HTML
            <p>Doesn't matter</p>
            <p>Figure 1. This is the caption</p>
            <p>Also doesn't matter</p>
          HTML
        end

        let(:output) { parse html }

        it 'returns the same html as the input' do
          is_expected.to be_equivalent_to(output)
        end
      end

      context "the input has an image tag" do
        let(:html) do
          <<-HTML
            <p></p>
            <img src="whatever">
            <p></p>
          HTML
        end

        let(:output) do
          parse <<-HTML
            <p></p>
            <p></p>
          HTML
        end

        it "strips existing image tags" do
          is_expected.to be_equivalent_to(output)
        end
      end
    end

    context "with one figure" do
      RSpec.shared_examples 'matching caption' do |custom_caption|
        let(:caption_text) { custom_caption }
        let(:html) do
          <<-HTML
            <p>Doesn't matter</p>
            <p>#{caption_text}</p>
            <p>Also doesn't matter</p>
          HTML
        end
        let(:output) do
          parse <<-HTML
            <p>Doesn't matter</p>
            #{image_html(figure1)}
            <p>#{caption_text}</p>
            <p>Also doesn't matter</p>
          HTML
        end

        it 'inserts a new image tag before the existing caption' do
          is_expected.to be_equivalent_to(output)
        end
      end
      let(:figures) { [figure1] }

      context "caption that matches the figure's rank" do
        it_behaves_like 'matching caption', 'Figure 1. This is the caption'
        it_behaves_like 'matching caption', 'Figure 1'
        it_behaves_like 'matching caption', 'Fig. 1'
        it_behaves_like 'matching caption', 'Fig 1: Shortest'
        it_behaves_like 'matching caption', 'Figure 1- Any delimiter'
        it_behaves_like 'matching caption', 'Figure 1A'
      end

      context 'with a caption that does not match the figure' do
        let(:html) do
          <<-HTML
            <p>Doesn't matter</p>
            <p><span style="font-weight:bold">Figure 11</span></p>
            <p>Also doesn't matter</p>
          HTML
        end
        let(:output) do
          parse <<-HTML
            <p>Doesn't matter</p>
            <p><span style="font-weight:bold">Figure 11</span></p>
            <p>Also doesn't matter</p>
            #{caption_and_image_html(figure1)}
          HTML
        end
        it "appends a new caption and image for the figure" do
          is_expected.to be_equivalent_to(output)
        end
      end

      context "with a missing caption" do
        let(:html) do
          <<-HTML
            <p>Doesn't matter</p>
            <p>Fig newton does not match</p>
            <p>Figure A does not match</p>
            <p>Fig. one does not match</p>
            <p>Fig.1 does not match</p>
            <p>Look at Fig. 1</p>
            <p>Also doesn't matter</p>
          HTML
        end
        let(:output) do
          parse <<-HTML
            <p>Doesn't matter</p>
            <p>Fig newton does not match</p>
            <p>Figure A does not match</p>
            <p>Fig. one does not match</p>
            <p>Fig.1 does not match</p>
            <p>Look at Fig. 1</p>
            <p>Also doesn't matter</p>
            #{caption_and_image_html(figure1)}
          HTML
        end
        it "appends a new image and caption for the figure" do
          is_expected.to be_equivalent_to(output)
        end
      end
    end

    context "with a figure that has no rank" do
      let(:rankless_figure) do
        figure = create :figure, title: "some title that won't create a rank"
        allow(figure).to receive(:detail_src).and_return('/an/image3.png')
        allow(figure).to receive(:attachment?).and_return(true)
        figure
      end
      let(:figures) { [rankless_figure] }
      let(:html) do
        <<-HTML
          <p>Doesn't matter</p>
          <p>Figure 1. This is the caption</p>
          <p>Also doesn't matter</p>
        HTML
      end
      let(:output) do
        parse <<-HTML
          <p>Doesn't matter</p>
          <p>Figure 1. This is the caption</p>
          <p>Also doesn't matter</p>
          #{caption_and_image_html(rankless_figure)}
        HTML
      end
      it "appends a new caption and image for the rankless figure" do
        is_expected.to be_equivalent_to(output)
      end
    end

    context 'with multiple figures' do
      let(:figures) { [figure1, figure11] }

      context 'when the html has no captions' do
        let(:html) do
          <<-HTML
          <p></p>
          HTML
        end

        let(:output) do
          parse <<-HTML
            <p></p>
            #{caption_and_image_html(figure1)}
            #{caption_and_image_html(figure11)}
          HTML
        end

        it "inserts images and captions in order of the figures' ranks" do
          is_expected.to be_equivalent_to(output).respecting_element_order
        end
      end

      context 'when there are multiple figure references' do
        let(:html) do
          <<-HTML
            <p>Doesn't matter</p>
            <p>Figure 1. This is the caption</p>
            <p>Also doesn't matter</p>
            <p>Figure 11. This is the caption</p>
            <p>Figure 1. This is a reference</p>
          HTML
        end
        let(:output) do
          parse <<-HTML
            <p>Doesn't matter</p>
            #{image_html(figure1)}
            <p>Figure 1. This is the caption</p>
            <p>Also doesn't matter</p>
            #{image_html(figure11)}
            <p>Figure 11. This is the caption</p>
            <p>Figure 1. This is a reference</p>
          HTML
        end

        it "only inserts on the first occurrence" do
          is_expected.to be_equivalent_to(output).respecting_element_order
        end
      end
    end
  end

  describe '#figure_url' do
    let(:fake_figure) { create(:figure) }
    it 'returns a proxyable img url' do
      figure_inserter = FigureInserter.new("", [], direct_img_links: true)
      allow(fake_figure).to receive(:proxyable_url).and_return '/resource_proxy/'
      expect(figure_inserter.send(:figure_url, fake_figure)).to include 'resource_proxy'
    end

    it 'returns an expiring AWS url if prompted' do
      figure_inserter = FigureInserter.new("", [], direct_img_links: false)
      allow(fake_figure).to receive(:detail_src).and_return 'amazonaws.com'
      expect(figure_inserter.send(:figure_url, fake_figure)).to include 'amazonaws'
    end
  end

  def parse(html)
    Nokogiri::HTML::DocumentFragment.parse html
  end

  def get_node(doc, selector)
    doc.at_css(selector).tap do |node|
      expect(node).to be_present
    end
  end
end
