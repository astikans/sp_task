require 'rails_helper'

RSpec.describe Readers::JsonFileReader do
  describe '.read' do
    it 'delegates to instance method' do
      file_reader = instance_double(described_class)
      allow(described_class).to receive(:new).with('path/to/file.json').and_return(file_reader)
      allow(file_reader).to receive(:read).and_return({ 'key' => 'value' })

      result = described_class.read('path/to/file.json')

      expect(result).to eq({ 'key' => 'value' })
    end
  end

  describe '#initialize' do
    it 'sets the file path' do
      file_reader = described_class.new('path/to/file.json')
      expect(file_reader.instance_variable_get(:@file_path)).to eq('path/to/file.json')
    end
  end

  describe '#read' do
    it 'reads and parses JSON from file' do
      file_path = 'path/to/test.json'
      file_content = '{"key": "value"}'

      allow(File).to receive(:read).with(file_path).and_return(file_content)

      file_reader = described_class.new(file_path)
      result = file_reader.read

      expect(result).to eq({ 'key' => 'value' })
    end

    it 'raises error when file does not exist' do
      file_reader = described_class.new('non_existent_file.json')
      allow(File).to receive(:read).and_raise(Errno::ENOENT)

      expect { file_reader.read }.to raise_error(Errno::ENOENT)
    end

    it 'raises error when content is not valid JSON' do
      file_path = 'invalid.json'
      allow(File).to receive(:read).with(file_path).and_return('not valid json')

      file_reader = described_class.new(file_path)

      expect { file_reader.read }.to raise_error(JSON::ParserError)
    end
  end
end