require 'rails_helper'

RSpec.describe Search do
  describe '.perform_search' do
    it 'returns empty array when query is blank' do
      expect(described_class.perform_search('')).to eq([])
      expect(described_class.perform_search(nil)).to eq([])
      expect(described_class.perform_search('   ')).to eq([])
    end

    it 'delegates to Item.where with ILIKE pattern and returns results' do
      alpha = double('Item', name: 'Alpha')
      alphabet = double('Item', name: 'Alphabet Soup')
      relation = [alpha, alphabet]

      fake_item_class = Class.new do
        def self.where(*args); end
      end
      stub_const('Item', fake_item_class)

      expect(Item).to receive(:where).with("name ILIKE ?", "%alp%").and_return(relation)

      results = described_class.perform_search('alp')
      names = results.map(&:name)
      expect(names).to include('Alpha', 'Alphabet Soup')
    end
  end
end
