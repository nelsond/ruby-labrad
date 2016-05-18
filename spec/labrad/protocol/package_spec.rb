require 'labrad/protocol/package'
require 'labrad/protocol/record'

describe LabRAD::Protocol::Package do
  before(:each) do
    @package = LabRAD::Protocol::Package.new
  end

  describe '#initialize' do
    it 'sets context to 0, 0 by default' do
      expect(@package.context).to eq([0, 0])
    end

    it 'sets request to 1 by default' do
      expect(@package.request).to eq(1)
    end

    it 'sets target to 1 by default' do
      expect(@package.target).to eq(1)
    end

    it 'sets source to 1 by default' do
      expect(@package.source).to eq(1)
    end

    it 'sets no records by default' do
      expect(@package.records).to eq([])
    end

    it 'uses hash argument for context' do
      package = LabRAD::Protocol::Package.new(context: 1)

      expect(package.context).to eq([0, 1])
    end

    it 'uses hash argument for request' do
      package = LabRAD::Protocol::Package.new(request: 2)

      expect(package.request).to eq(2)
    end

    it 'uses hash argument for target' do
      package = LabRAD::Protocol::Package.new(target: 1)

      expect(package.target).to eq(1)
    end

    it 'uses hash argument for source' do
      package = LabRAD::Protocol::Package.new(source: 1)

      expect(package.source).to eq(1)
    end

    it 'uses hash argument for records' do
      records = [LabRAD::Protocol::Record.new]
      package = LabRAD::Protocol::Package.new(records: records)

      expect(package.records).to eq(records)
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
      3.times { @package << LabRAD::Protocol::Record.new }

      data = LabRAD::Protocol::Data.new('(ww) i w s')
      expected_result = data.pack(@package.context,
                                  @package.request,
                                  @package.target,
                                  @package.records.map(&:to_s).join)

      expect(@package.to_s).to eq(expected_result)
    end
  end

  describe '.from_s' do
    before(:each) do
      @context = [0, 1]
      @request = 1
      @target = 1
      @records = []
      3.times { @records << LabRAD::Protocol::Record.new }

      data = LabRAD::Protocol::Data.new('(ww) i w s')
      string = data.pack(@context,
                         @request,
                         @target,
                         @records.map(&:to_s).join)

      @package = LabRAD::Protocol::Package.from_s(string)
    end

    it 'unpacks context' do
      expect(@package.context).to eq(@context)
    end

    it 'unpacks request' do
      expect(@package.request).to eq(@request)
    end

    it 'unpacks target' do
      expect(@package.target).to eq(@target)
    end

    it 'unpacks source' do
      expect(@package.target).to eq(@target)
    end

    it 'unpacks records' do
      expect(@package.records).to eq(@records)
    end
  end
end
