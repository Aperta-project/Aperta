require 'rails_helper'

describe FigureInserter do
  let(:raw_html_tree) { parse raw_html }
  let(:raw_html) do
    <<-HTML
      <p>Doesn't matter</p>
      <p id="only-for-testing">Figure 1. This is the caption</p>
      <p>Also doesn't matter</p>
    HTML
  end
  let(:alternate_html) do
    <<-HTML
      <p>Doesn't matter</p>
      <p id="only-for-testing">Figure 1: This is the caption</p>
      <p>Also doesn't matter</p>
    HTML
  end
  let(:figure_inserter) { FigureInserter.new(raw_html, []) }

  describe "#call" do
    context "there are no figures" do
      it "returns the same html as that inputted" do
        return_tree = parse figure_inserter.call
        expect(return_tree).to be_equivalent_to(raw_html_tree)
      end
    end

    context "there is one figure" do
      let(:figure) { create :figure, title: "1" }
      let(:no_caption_figure) { create :figure, title: "2" }
      let(:bad_rank_figure) { create :figure, title: "not a number" }

      it "returns a document which has an img inserted before the caption" do
        figure_inserter = FigureInserter.new(raw_html, [figure])
        allow(figure).to receive(:detail_src).and_return('/an/image.png')
        html = figure_inserter.call
        expect(html).to be_an_instance_of(String)
        expected_tree = parse <<-HTML
          <p>Doesn't matter</p>
          <img class="paper-body-figure"
               data-figure-id="#{figure.id}"
               data-figure-rank="#{figure.rank}"
               src="#{figure.detail_src}">
          <p id="only-for-testing">Figure 1. This is the caption</p>
          <p>Also doesn't matter</p>
        HTML
        expect(parse html).to be_equivalent_to(expected_tree)
      end

      it 'returns a document which has an img inserted before the caption allowing :' do
        figure_inserter = FigureInserter.new(alternate_html, [figure])
        allow(figure).to receive(:detail_src).and_return('/an/image.png')
        html = figure_inserter.call
        expect(html).to be_an_instance_of(String)
        expected_tree = parse <<-HTML
          <p>Doesn't matter</p>
          <img class="paper-body-figure"
               data-figure-id="#{figure.id}"
               data-figure-rank="#{figure.rank}"
               src="#{figure.detail_src}">
          <p id="only-for-testing">Figure 1: This is the caption</p>
          <p>Also doesn't matter</p>
        HTML
        expect(parse html).to be_equivalent_to(expected_tree)
      end

      it "appends the image to the end of the doc if there's no caption" do
        figure_inserter = FigureInserter.new(raw_html, [no_caption_figure])
        allow(no_caption_figure).to receive(:detail_src).and_return('/an/image.png')
        html = figure_inserter.call
        expect(html).to be_an_instance_of(String)
        expected_tree = parse <<-HTML
          <p>Doesn't matter</p>
          <p id="only-for-testing">Figure 1. This is the caption</p>
          <p>Also doesn't matter</p>
          <img class="paper-body-figure"
               data-figure-id="#{no_caption_figure.id}"
               data-figure-rank="#{no_caption_figure.rank}"
               src="#{no_caption_figure.detail_src}">
          <p class="paper-body-figure-caption">#{no_caption_figure.title}.</p>
        HTML
        expect(parse html).to be_equivalent_to(expected_tree)
      end

      it "appends the image to the end of the doc if it doesn't have a rank" do
        figure_inserter = FigureInserter.new(raw_html, [bad_rank_figure])
        allow(bad_rank_figure).to receive(:detail_src).and_return('/an/image.png')
        html = figure_inserter.call
        expect(html).to be_an_instance_of(String)
        expected_tree = parse <<-HTML
          <p>Doesn't matter</p>
          <p id="only-for-testing">Figure 1. This is the caption</p>
          <p>Also doesn't matter</p>
          <img class="paper-body-figure"
               data-figure-id="#{bad_rank_figure.id}"
               data-figure-rank="#{bad_rank_figure.rank}"
               src="#{bad_rank_figure.detail_src}">
          <p class="paper-body-figure-caption">#{bad_rank_figure.title}.</p>
        HTML
        expect(parse html).to be_equivalent_to(expected_tree)
      end
    end

    context 'there are two figures' do
      let(:figures) do
        %w(1 2).map do |title|
          create(:figure, title: title).tap do |fig|
            allow(fig).to receive(:detail_src).and_return("/img/#{fig.title}")
          end
        end
      end

      context 'the html has no captions' do
        let(:raw_html) do
          <<-HTML
          <p id="the-end"></p>
          HTML
        end
        let(:raw_html_doc) { parse raw_html }
        let(:figure_inserter) { FigureInserter.new(raw_html, figures) }

        it 'appends the figures in order to the end of the document' do
          html = figure_inserter.call
          figure_1, figure_2 = figures.sort_by(&:rank).to_a
          expected_tree = parse <<-HTML
            <p id="the-end"></p>
            <img class="paper-body-figure"
               data-figure-id="#{figure_1.id}"
               data-figure-rank="#{figure_1.rank}"
               src="#{figure_1.detail_src}">
            <p class="paper-body-figure-caption">#{figure_1.title}.</p>
            <img class="paper-body-figure"
               data-figure-id="#{figure_2.id}"
               data-figure-rank="#{figure_2.rank}"
               src="#{figure_2.detail_src}">
            <p class="paper-body-figure-caption">#{figure_2.title}.</p>
          HTML
          expect(parse html).to be_equivalent_to(expected_tree).respecting_element_order
        end
      end
    end
  end

  describe "#caption_node" do
    context 'the raw html has one figure caption' do
      let(:raw_html) do
        <<-HTML
          <p>Doesn't matter</p>
          <p id="only-for-testing">Fig 1. This is the caption</p>
          <p>Also doesn't matter</p>
        HTML
      end
      let(:raw_html_doc) { parse raw_html }
      let(:expected_node) { get_node(raw_html_doc, '#only-for-testing') }
      let(:figure_inserter) { FigureInserter.new(raw_html, []) }

      it 'returns the node of the figure caption corresponding to the figure number' do
        caption_node = figure_inserter.send(:find_caption_node, 1)
        expect(caption_node).to be_equivalent_to expected_node
      end

      it 'returns nil if the figure caption is not found' do
        caption_node = figure_inserter.send(:find_caption_node, 2)
        expect(caption_node).to be_nil
      end
    end

    context 'the raw html has a non-standard figure caption' do
      let(:raw_html) do
        <<-HTML
          <p>Doesn't matter</p>
          <p id="only-for-testing">Figure 1. This is the caption</p>
          <p>Also doesn't matter</p>
        HTML
      end
      let(:raw_html_doc) { parse raw_html }
      let(:expected_node) { get_node(raw_html_doc, '#only-for-testing') }
      let(:figure_inserter) { FigureInserter.new(raw_html, []) }

      it 'returns the node of the figure caption corresponding to the figure number' do
        caption_node = figure_inserter.send(:find_caption_node, 1)
        expect(caption_node).to be_equivalent_to expected_node
      end
    end

    context 'the raw html has a figure caption with weird markup in it' do
      let(:raw_html) do
        <<-HTML
          <p>Doesn't matter</p>
          <p id="only-for-testing"><span>Fig 1.</span> This is the caption</p>
          <p>Also doesn't matter</p>
        HTML
      end
      let(:raw_html_doc) { parse raw_html }
      let(:expected_node) { get_node(raw_html_doc, '#only-for-testing') }
      let(:figure_inserter) { FigureInserter.new(raw_html, []) }

      it 'returns the node of the figure caption corresponding to the figure number' do
        caption_node = figure_inserter.send(:find_caption_node, 1)
        expect(caption_node).to be_equivalent_to expected_node
      end
    end

    context 'the raw html has two figure captions' do
      let(:raw_html) do
        <<-HTML
          <p>Doesn't matter</p>
          <p id="only-for-testing-1">Fig 1. This is the caption</p>
          <p>Also doesn't matter</p>
          <p id="only-for-testing-2">Fig 2. This is the caption</p>
        HTML
      end
      let(:raw_html_doc) { parse raw_html }
      let(:expected_node_1) { get_node raw_html_doc, '#only-for-testing-1' }
      let(:expected_node_2) { get_node raw_html_doc, '#only-for-testing-2' }
      let(:figure_inserter) { FigureInserter.new(raw_html, []) }

      it 'returns the node of the figure caption corresponding to the figure number' do
        caption_node = figure_inserter.send(:find_caption_node, 1)
        expect(caption_node).to be_equivalent_to expected_node_1

        caption_node = figure_inserter.send(:find_caption_node, 2)
        expect(caption_node).to be_equivalent_to expected_node_2
      end
    end
  end

  describe '#figure_url' do
    let(:figure) do
      create(:figure).tap do |f|
        allow(f).to receive(:detail_src).and_return '/resource_proxy/'
        allow(f).to receive(:proxyable_url).and_return 'amazonaws.com'
      end
    end
    it 'returns a proxyable img url' do
      expect(figure_inserter.send(:figure_url, figure)).to include 'resource_proxy'
    end

    it 'returns an expiring AWS url if prompted' do
      figure_inserter = FigureInserter.new(raw_html, [], direct_img_links: true)
      expect(figure_inserter.send(:figure_url, figure)).to include 'amazonaws'
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

  describe '#remove_figures' do
    let(:raw_html) do
      <<-HTML
        <p id="the-beginning"></p>
        <img src="whatever">
        <p id="the-end"></p>
      HTML
    end
    let(:expected_html) do
      parse <<-HTML
        <p id="the-beginning"></p>

        <p id="the-end"></p>
      HTML
    end
    let(:raw_html_doc) { parse raw_html }
    let(:figure_inserter) { FigureInserter.new(raw_html, []) }
    it 'strips imgs from the text' do
      figure_inserter.send(:remove_figures)
      no_figure_html = figure_inserter.instance_variable_get(:@html_tree)
      expect(no_figure_html).to be_equivalent_to(expected_html)
    end
  end
end
