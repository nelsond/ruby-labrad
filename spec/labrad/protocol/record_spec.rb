require 'labrad/protocol/record'
require 'labrad/protocol/data'

describe LabRAD::Protocol::Record do
  before(:each) do
    @record = LabRAD::Protocol::Record.new
  end

  describe '#initialize' do
    it 'sets default values for setting, type, and data without argument' do
      expect(@record.setting).to eq(0)
      expect(@record.type).to eq('s')
      expect(@record.data).to eq('')
    end

    it 'accepts hash for setting, type, and data using hash' do
      record = LabRAD::Protocol::Record.new(setting: 1,
                                            type: 'i',
                                            data: 0)

      expect(record.setting).to eq(1)
      expect(record.type).to eq('i')
      expect(record.data).to eq(0)
    end
  end

  describe '#==' do
    it 'compares based on #to_s' do
      record_a = LabRAD::Protocol::Record.new
      record_b = LabRAD::Protocol::Record.new
      record_c = LabRAD::Protocol::Record.new(type: 's', data: 'Hello World!')

      expect(record_a).to eq(record_b)
      expect(record_a).not_to eq(record_c)
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
    it 'unpacks setting, type and data' do
      setting = 2
      type = 'v'
      data = 1.23

      rdata = LabRAD::Protocol::Data.new('w s s')
      tdata = LabRAD::Protocol::Data.new(type)

      string = rdata.pack(setting,
                          type,
                          tdata.pack(data))
      record = LabRAD::Protocol::Record.from_s(string)

      expect(record.setting).to eq(setting)
      expect(record.type).to eq(type)
      expect(record.data).to eq(data)
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
