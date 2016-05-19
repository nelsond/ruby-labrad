require 'labrad/protocol/packet'
require 'labrad/protocol/record'

describe LabRAD::Protocol::Packet do
  before(:each) do
    @packet = LabRAD::Protocol::Packet.new
  end

  describe '#initialize' do
    it 'sets context to 0, 0 by default' do
      expect(@packet.context).to eq([0, 0])
    end

    it 'sets request to 1 by default' do
      expect(@packet.request).to eq(1)
    end

    it 'sets target to 1 by default' do
      expect(@packet.target).to eq(1)
    end

    it 'sets source to 1 by default' do
      expect(@packet.source).to eq(1)
    end

    it 'sets no records by default' do
      expect(@packet.records).to eq([])
    end

    it 'uses hash argument for context' do
      packet = LabRAD::Protocol::Packet.new(context: 1)

      expect(packet.context).to eq([0, 1])
    end

    it 'uses hash argument for request' do
      packet = LabRAD::Protocol::Packet.new(request: 2)

      expect(packet.request).to eq(2)
    end

    it 'uses hash argument for target' do
      packet = LabRAD::Protocol::Packet.new(target: 1)

      expect(packet.target).to eq(1)
    end

    it 'uses hash argument for source' do
      packet = LabRAD::Protocol::Packet.new(source: 1)

      expect(packet.source).to eq(1)
    end

    it 'uses hash argument for records' do
      records = [LabRAD::Protocol::Record.new]
      packet = LabRAD::Protocol::Packet.new(records: records)

      expect(packet.records).to eq(records)
    end
  end

  describe '#source' do
    it 'is an alias of #target' do
      @packet.target = 10

      expect(@packet.source).to eq(10)
    end
  end

  describe '#source=' do
    it 'is an alias of #target=' do
      @packet.source = 10

      expect(@packet.target).to eq(10)
    end
  end

  describe '#context=' do
    it 'accepts Array argument' do
      @packet.context = [1, 1]

      expect(@packet.context).to eq([1, 1])
    end

    it 'accepts Fixnum argument' do
      @packet.context = 10

      expect(@packet.context).to eq([0, 10])
    end
  end

  describe '#<<' do
    it 'adds record' do
      record = LabRAD::Protocol::Record.new
      @packet << record

      expect(@packet.records).to eq([record])
    end
  end

  describe '#to_s' do
    it 'packs packet' do
      3.times { @packet << LabRAD::Protocol::Record.new }

      data = LabRAD::Protocol::Data.new('(ww) i w s')
      expected_result = data.pack(@packet.context,
                                  @packet.request,
                                  @packet.target,
                                  @packet.records.map(&:to_s).join)

      expect(@packet.to_s).to eq(expected_result)
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

      @packet = LabRAD::Protocol::Packet.from_s(string)
    end

    it 'unpacks context' do
      expect(@packet.context).to eq(@context)
    end

    it 'unpacks request' do
      expect(@packet.request).to eq(@request)
    end

    it 'unpacks target' do
      expect(@packet.target).to eq(@target)
    end

    it 'unpacks source' do
      expect(@packet.target).to eq(@target)
    end

    it 'unpacks records' do
      expect(@packet.records).to eq(@records)
    end
  end
end
