require 'rails_helper'

describe Typesetter::BaseSerializer do
  subject(:klass) do
    Class.new(described_class) do
      attributes :test_without_p_tags, :test_fix_strong_em_tags, :test_strip_tags

      def test_without_p_tags
        without_p_tags(object.foo)
      end

      def test_fix_strong_em_tags
        fix_strong_em_tags(object.foo)
      end

      def test_strip_tags
        strip_tags(object.foo)
      end
    end
  end

  let!(:object) do
    Class.new do
      def foo
        "<p><strong>lorem</strong><p> </p><em>ipsum</em></p>"
      end
    end.new
  end

  describe "without_p_tags" do
    it "should remove p tags" do
      expect(klass.new(object).as_json[:test_without_p_tags]).to eq('<strong>lorem</strong> <em>ipsum</em>')
    end
  end

  describe "fix_strong_em_tags" do
    it "should replace strong tags with b" do
      expect(klass.new(object).as_json[:test_fix_strong_em_tags]).to match('<b>lorem</b>')
    end
  end

  describe "fix_strong_em_tags" do
    it "should replace em tags with i" do
      expect(klass.new(object).as_json[:test_fix_strong_em_tags]).to match('<i>ipsum</i>')
    end
  end

  describe "strip_tags" do
    it "should remove all tags" do
      expect(klass.new(object).as_json[:test_strip_tags]).to match('lorem ipsum')
    end
  end
end
