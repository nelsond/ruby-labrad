require 'digest/md5'
require 'labrad/connection'
require 'labrad/errors'
require 'labrad/manager'
require 'support/mock_manager'

describe Labrad::Connection do
  before(:each) do
    @connection = Labrad::Connection.new(host: 'localhost',
                                         password: '',
                                         timeout: 0.1)
    @manager = MockManager.new(7682)
    @manager.buffer << Labrad::Protocol::Packet.new do |p|
      p << Labrad::Protocol::Record.new(data: 'challenge')
    end
  end

  after(:each) do
    @manager.stop
  end

  describe '#initialize' do
    around(:each) do |example|
      labrad_host = ENV.fetch('LABRADHOST', nil)
      labrad_password = ENV.fetch('LABRADPASSWORD', nil)

      ENV.store('LABRADHOST', 'some-custom-host.com')
      ENV.store('LABRADPASSWORD', 'secret')

      @connection_with_defaults = Labrad::Connection.new
      example.run

      ENV.store('LABRADHOST', labrad_host)
      ENV.store('LABRADPASSWORD', labrad_password)
    end

    it 'uses $LABRADHOST as default' do
      expect(@connection_with_defaults.host).to eq(ENV['LABRADHOST'])
    end

    it 'uses $LABRADPASSWORD as default' do
      expect(@connection_with_defaults.password).to eq(ENV['LABRADPASSWORD'])
    end
  end

  context 'with wrong password' do
    before(:each) do
      @manager.buffer << Labrad::Protocol::Packet.new do |p|
        p << Labrad::Protocol::Record.new(type: 'E_',
                                          data: [101, 'Wrong password'])
      end
    end

    describe '#open' do
      it 'raises AuthenticationError' do
        @manager.start

        expect { @connection.open }.to raise_error(Labrad::AuthenticationError)
      end
    end
  end

  context 'with correct password' do
    before(:each) do
      @manager.buffer << Labrad::Protocol::Packet.new do |p|
        p << Labrad::Protocol::Record.new(data: 'Welcome')
      end
    end

    describe '#open' do
      it 'requests login with correct hash' do
        @manager.start
        @connection.open

        hash = @manager.read_packets.last.records.first.data
        expected_hash = Digest::MD5.digest('challenge' + '')

        expect(hash).to eq(expected_hash)
      end
    end

    describe '#recv_packet' do
      it 'raises TimeoutError if no response' do
        @manager.start
        @connection.open

        expect { @connection.recv_packet }.to raise_error(Labrad::TimeoutError)
      end

      it 'returns received packet' do
        packet = Labrad::Protocol::Packet.new
        @manager.buffer << packet
        @manager.start

        @connection.open

        expect(@connection.recv_packet).to eq(packet)
      end
    end

    describe '#recv_record' do
      it 'raises InvalidResponseError if no records in response' do
        @manager.buffer << Labrad::Protocol::Packet.new
        @manager.start

        @connection.open

        error = Labrad::InvalidResponseError
        expect { @connection.recv_record }.to raise_error(error)
      end

      it 'returns first record in received packet' do
        record = Labrad::Protocol::Record.new(type: 's', data: 'Hello World!')
        @manager.buffer << Labrad::Protocol::Packet.new(records: [record])
        @manager.start

        @connection.open

        expect(@connection.recv_record).to eq(record)
      end
    end

    describe '#send_packet' do
      it 'sends packet from hash argument' do
        @manager.start
        @connection.open

        packet = Labrad::Protocol::Packet.new do |p|
          p.context = 2
          p << Labrad::Protocol::Record.new(type: 's', data: 'Hello World!')
        end
        @connection.send_packet(context: packet.context,
                                records: packet.records)
        received_packet = @manager.read_packets.last

        expect(received_packet).to eq(packet)
      end
    end

    describe '#send_record' do
      it 'sends packet with single record from hash argument' do
        @manager.start
        @connection.open

        record = Labrad::Protocol::Record.new(type: 's', data: 'Hello World!')
        @connection.send_record(type: record.type, data: record.data)
        received_record = @manager.read_packets.last.records.first

        expect(received_record).to eq(record)
      end
    end

    describe '#close' do
      it 'expires context' do
        @manager.start
        @connection.open
        @connection.close

        last_record = @manager.read_packets.last.records.first

        expect(last_record.setting).to eq(Labrad::Manager::EXPIRE_ALL)
      end
    end
  end
end
