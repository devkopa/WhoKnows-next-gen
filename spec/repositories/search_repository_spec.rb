require 'rails_helper'

RSpec.describe SearchRepository do
  describe '.search_items' do
    it 'returns empty array when query is blank' do
      expect(described_class.search_items('')).to eq([])
      expect(described_class.search_items(nil)).to eq([])
      expect(described_class.search_items('   ')).to eq([])
    end

    it 'delegates to Item.where with LIKE pattern and returns results' do
      item1 = double('Item', name: 'Alpha')
      item2 = double('Item', name: 'Alphabet Soup')
      relation = [item1, item2]

      fake_item_class = Class.new do
        def self.where(*args); end
      end
      stub_const('Item', fake_item_class)

      expect(Item).to receive(:where).with("name LIKE ?", "%alp%").and_return(relation)

      results = described_class.search_items('alp')
      expect(results).to eq(relation)
    end
  end
end
