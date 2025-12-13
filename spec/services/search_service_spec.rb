require 'rails_helper'

RSpec.describe SearchService do
  describe '.perform_search' do
    context 'when query is blank' do
      it 'returns an empty array' do
        expect(described_class.perform_search('')).to eq([])
        expect(described_class.perform_search('   ')).to eq([])
        expect(described_class.perform_search(nil)).to eq([])
      end
    end

    context 'when query is present' do
      it 'normalizes the query and calls where with LOWER(name) LIKE' do
        relation_double = instance_double('Relation', limit: [])
        item_stub = double('Item')
        allow(item_stub).to receive(:where)
          .with('LOWER(name) LIKE ?', '%hello world%')
          .and_return(relation_double)
        stub_const('Item', item_stub)

        described_class.perform_search('  HeLLo WoRLd  ')
        expect(item_stub).to have_received(:where)
          .with('LOWER(name) LIKE ?', '%hello world%')
      end

      it 'limits the results to 100' do
        relation_double = instance_double('Relation')
        allow(relation_double).to receive(:limit).with(100).and_return([])
        item_stub = double('Item')
        allow(item_stub).to receive(:where).and_return(relation_double)
        stub_const('Item', item_stub)

        described_class.perform_search('anything')
        expect(relation_double).to have_received(:limit).with(100)
      end
    end
  end
end
