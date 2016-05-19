require 'labrad/protocol/record'
require 'labrad/protocol/data'

describe LabRAD::Protocol::Record do
  before(:each) do
    @record = LabRAD::Protocol::Record.new
  end

  describe '#initialize' do
    it 'sets setting to 0 by default' do
      expect(@record.setting).to eq(0)
    end

    it 'sets type to s by default' do
      expect(@record.type).to eq('s')
    end

    it 'sets data to "" by default' do
      expect(@record.data).to eq('')
    end

    it 'uses hash argument for setting' do
      record = LabRAD::Protocol::Record.new(setting: 1)
      expect(record.setting).to eq(1)
    end

    it 'uses hash argument for type' do
      record = LabRAD::Protocol::Record.new(type: 'i')
      expect(record.type).to eq('i')
    end

    it 'uses data argument for data' do
      record = LabRAD::Protocol::Record.new(data: 'Hello World!')
      expect(record.data).to eq('Hello World!')
    end
  end

  describe '#==' do
    it 'is true if #to_s is equal' do
      record_a = LabRAD::Protocol::Record.new
      record_b = LabRAD::Protocol::Record.new

      expect(record_a).to eq(record_b)
    end

    it 'is false if #to_s is unequal' do
      record_a = LabRAD::Protocol::Record.new
      record_b = LabRAD::Protocol::Record.new(type: 's', data: 'Hello World!')

      expect(record_a).not_to eq(record_b)
    end
  end

  describe '#to_s' do
    it 'packs record' do
      @record.type = 'i'
      @record.data = 1024

      rdata = LabRAD::Protocol::Data.new('w s s')
      tdata = LabRAD::Protocol::Data.new('i')
      expected_result = rdata.pack(@record.setting,
                                   @record.type,
                                   tdata.pack(1024))

      expect(@record.to_s).to eq(expected_result)
    end
  end

  describe '.from_s' do
    before(:each) do
      @setting = 2
      @type = 'v'
      @data = 1.23

      rdata = LabRAD::Protocol::Data.new('w s s')
      tdata = LabRAD::Protocol::Data.new(@type)

      string = rdata.pack(@setting,
                          @type,
                          tdata.pack(@data))
      @record = LabRAD::Protocol::Record.from_s(string)
    end

    it 'unpacks setting' do
      expect(@record.setting).to eq(@setting)
    end

    it 'unpacks type' do
      expect(@record.type).to eq(@type)
    end

    it 'unpacks data' do
      expect(@record.data).to eq(@data)
    end
  end

  describe '.many_from_s' do
    it 'unpacks multiple records' do
      rdata = LabRAD::Protocol::Data.new('w s s')
      tdata = LabRAD::Protocol::Data.new('v')

      string = Array.new(3) do
        rdata.pack(2, 'v', tdata.pack(1.23))
      end.join

      records = LabRAD::Protocol::Record.many_from_s(string)

      expect(records.first).to be_a(LabRAD::Protocol::Record)
      expect(records.length).to eq(3)
    end
  end
end
