require 'rails_helper'

describe Typesetter::BaseSerializer do
  subject(:klass) do
    Class.new(described_class) do
      attributes :test_without_p_tags, :test_fix_strong_em_tags, :test_strip_tags, :test_without_pre_u_tags

      def test_without_p_tags
        without_p_tags(object.foo)
      end

      def test_without_pre_u_tags
        without_pre_u_tags(object.foo)
      end

      def test_fix_strong_em_tags
        object.foo
      end

      def test_strip_tags
        strip_tags(object.foo)
      end
    end
  end

  let!(:object) do
    Class.new do
      def foo
        "<p><pre><strong>lorem</strong></pre><p> </p><u><em>ipsum</em></u></p>"
      end
    end.new
  end

  shared_examples_for "something that handles nil" do
    let!(:object) do
      Class.new do
        def foo
          nil
        end
      end.new
    end

    it 'return nil' do
      expect(subject).to be(nil)
    end
  end

  describe "without_p_tags" do
    subject { klass.new(object).as_json[:test_without_p_tags] }

    it "should remove p tags" do
      expect(subject).not_to match(%r{</?p>})
    end

    it_behaves_like "something that handles nil"
  end

  describe "without_pre_u_tags" do
    subject { klass.new(object).as_json[:test_without_pre_u_tags] }

    it "should remove pre and u tags" do
      expect(subject).not_to match(%r{</?(u|pre)>})
    end

    it_behaves_like "something that handles nil"
  end

  describe "fix_strong_em_tags" do
    subject { klass.new(object).as_json[:test_fix_strong_em_tags] }

    it "should replace strong tags with b on all attributes" do
      expect(subject).to match('<b>lorem</b>')
    end

    it_behaves_like "something that handles nil"
  end

  describe "fix_strong_em_tags" do
    subject { klass.new(object).as_json[:test_fix_strong_em_tags] }

    it "should replace em tags with i" do
      expect(subject).to match('<i>ipsum</i>')
    end

    it_behaves_like "something that handles nil"
  end

  describe "strip_tags" do
    subject { klass.new(object).as_json[:test_strip_tags] }

    it "should remove all tags" do
      expect(subject).to match('lorem ipsum')
    end

    it_behaves_like "something that handles nil"
  end
end
