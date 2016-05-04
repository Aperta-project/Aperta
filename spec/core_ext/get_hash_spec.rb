require "rails_helper"
describe Array do
  describe ".compare" do
    it "should handle common overlap" do
      old = [1, 2, 3]
      new = [3, 4, 5]
      result = { added: [4, 5], common: [3], removed: [1, 2] }
      expect(Array.compare(old, new)).to eq(result)
    end

    it "should handle no overlap" do
      old = [1, 2, 3]
      new = []
      result = { added: [], common: [], removed: [1, 2, 3] }
      expect(Array.compare(old, new)).to eq(result)
    end

    it "should handle identical" do
      old = [1, 2, 3]
      new = [1, 2, 3]
      result = { added: [], common: [1, 2, 3], removed: [] }
      expect(Array.compare(old, new)).to eq(result)
    end

    it "should handle empty" do
      old = []
      new = []
      result = { added: [], common: [], removed: [] }
      expect(Array.compare(old, new)).to eq(result)
    end

    it "should handle all new" do
      old = []
      new = [1, 2, 3]
      result = { added: [1, 2, 3], common: [], removed: [] }
      expect(Array.compare(old, new)).to eq(result)
    end
  end
end
