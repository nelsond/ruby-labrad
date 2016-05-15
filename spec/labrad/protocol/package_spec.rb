require 'labrad/protocol/package'
require 'labrad/protocol/record'

describe LabRAD::Protocol::Package do
  before(:each) do
    @package = LabRAD::Protocol::Package.new
  end

  describe '#initialize' do
    it 'sets default values for context, request, target/soruce, and records' do
      expect(@package.context).to eq([0, 0])
      expect(@package.request).to eq(1)
      expect(@package.target).to eq(1)
      expect(@package.records).to eq([])
    end

    it 'accepts hash for context, request, target/source, and records' do
      record = LabRAD::Protocol::Record.new
      package = LabRAD::Protocol::Package.new(context: 1,
                                              request: 2,
                                              target: 1,
                                              records: [record])

      expect(package.context).to eq([0, 1])
      expect(package.request).to eq(2)
      expect(package.target).to eq(1)
      expect(package.records).to eq([record])
    end
  end

  describe '#source' do
    it 'is an alias of #target' do
      @package.target = 10

      expect(@package.source).to eq(10)
    end
  end

  describe '#source=' do
    it 'is an alias of #target=' do
      @package.source = 10

      expect(@package.target).to eq(10)
    end
  end

  describe '#context=' do
    it 'accepts Array argument' do
      @package.context = [1, 1]

      expect(@package.context).to eq([1, 1])
    end

    it 'accepts Fixnum argument' do
      @package.context = 10

      expect(@package.context).to eq([0, 10])
    end
  end

  describe '#<<' do
    it 'adds record' do
      record = LabRAD::Protocol::Record.new
      @package << record

      expect(@package.records).to eq([record])
    end
  end

  describe '#to_s' do
    it 'packs package' do
      @package.context = [0, 1]
      @package.request = 1
      @package.target = 1
      3.times { @package << LabRAD::Protocol::Record.new }

      data = LabRAD::Protocol::Data.new('ww i w s')

      expected_result = data.pack(*@package.context,
                                  @package.request,
                                  @package.target,
                                  @package.records.map(&:to_s).join)

      expect(@package.to_s).to eq(expected_result)
    end
  end

  describe '.from_s' do
    it 'unpacks context, request, target/source, and records' do
      context = [0, 1]
      request = 1
      target = 1
      records = []
      3.times { records << LabRAD::Protocol::Record.new }

      data = LabRAD::Protocol::Data.new('ww i w s')

      string = data.pack(*context,
                         request,
                         target,
                         records.map(&:to_s).join)
      package = LabRAD::Protocol::Package.from_s(string)

      expect(package.context).to eq(context)
      expect(package.request).to eq(request)
      expect(package.target).to eq(target)
      expect(package.records).to eq(records)
    end
  end
end
