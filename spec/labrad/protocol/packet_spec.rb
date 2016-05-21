require 'labrad/protocol/packet'
require 'labrad/protocol/record'

describe Labrad::Protocol::Packet do
  before(:each) do
    @packet = Labrad::Protocol::Packet.new
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
      packet = Labrad::Protocol::Packet.new(context: 1)

      expect(packet.context).to eq([0, 1])
    end

    it 'uses hash argument for request' do
      packet = Labrad::Protocol::Packet.new(request: 2)

      expect(packet.request).to eq(2)
    end

    it 'uses hash argument for target' do
      packet = Labrad::Protocol::Packet.new(target: 1)

      expect(packet.target).to eq(1)
    end

    it 'uses hash argument for source' do
      packet = Labrad::Protocol::Packet.new(source: 1)

      expect(packet.source).to eq(1)
    end

    it 'uses hash argument for records' do
      records = [Labrad::Protocol::Record.new]
      packet = Labrad::Protocol::Packet.new(records: records)

      expect(packet.records).to eq(records)
    end

    it 'allows block to set records' do
      record = Labrad::Protocol::Record.new
      packet = Labrad::Protocol::Packet.new do |p|
        p << record
      end

      expect(packet.records).to eq([record])
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
      record = Labrad::Protocol::Record.new
      @packet << record

      expect(@packet.records).to eq([record])
    end
  end

  describe '#to_s' do
    it 'packs packet' do
      3.times { @packet << Labrad::Protocol::Record.new }

      data = Labrad::Protocol::Data.new('(ww) i w s')
      expected_result = data.pack(@packet.context,
                                  @packet.request,
                                  @packet.target,
                                  @packet.records.map(&:to_s).join)

      expect(@packet.to_s).to eq(expected_result)
    end
  end

  describe '#records?' do
    it 'returns false if records is empty' do
      packet = Labrad::Protocol::Packet.new(records: [])

      expect(packet.records?).to be false
    end

    it 'returns true if records is empty' do
      record = Labrad::Protocol::Record.new
      packet = Labrad::Protocol::Packet.new(records: [record])

      expect(packet.records?).to be true
    end
  end

  describe '#==' do
    it 'is true if #to_s is equal' do
      packet_a = Labrad::Protocol::Packet.new
      packet_b = Labrad::Protocol::Packet.new

      expect(packet_a).to eq(packet_b)
    end

    it 'is false if #to_s is unequal' do
      packet_a = Labrad::Protocol::Packet.new
      packet_b = Labrad::Protocol::Packet.new(context: 100)

      expect(packet_a).not_to eq(packet_b)
    end
  end

  describe '.from_s' do
    before(:each) do
      @context = [0, 1]
      @request = 1
      @target = 1
      @records = []
      3.times { @records << Labrad::Protocol::Record.new }

      data = Labrad::Protocol::Data.new('(ww) i w s')
      string = data.pack(@context,
                         @request,
                         @target,
                         @records.map(&:to_s).join)

      @packet = Labrad::Protocol::Packet.from_s(string)
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
