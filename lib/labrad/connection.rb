# rubocop:disable Style/Documentation

require 'socket'
require 'digest/md5'
require 'timeout'
require 'labrad/protocol/data'
require 'labrad/protocol/packet'
require 'labrad/manager'

module LabRAD
  class Connection
    HEADER_SIZE = 20
    HEADER_DATA = Protocol::Data.new('(ww) i w w')

    attr_reader :host, :port, :password, :timeout

    def initialize(opts = {})
      options = {
        host: ENV.fetch('LABRADHOST', 'localhost'),
        port: 7682,
        password: ENV.fetch('LABRADPASSWORD', ''),
        timeout: 10
      }.merge(opts)

      options.each { |k, v| instance_variable_set("@#{k}", v) }

      @context = 1
    end

    def open
      @socket = TCPSocket.new(@host, @port)
      @socket.setsockopt(Socket::SOL_SOCKET, Socket::SO_KEEPALIVE, true)
      @socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, true)

      login
    end

    def close
      expire_all
      @socket.close
    end

    def send_packet(opts = {})
      opts = { context: @context }.merge(opts)
      packet = Protocol::Packet.new(opts)
      Timeout.timeout(@timeout) { @socket.write(packet.to_s) }
    rescue Timeout::Error
      raise TimeoutError
    end

    def send_record(opts = {})
      record = Protocol::Record.new(opts)
      send_packet(records: [record])
    end

    def recv_packet
      Timeout.timeout(2 * @timeout) do
        header = @socket.recv(HEADER_SIZE)
        _c, _r, _t, size = HEADER_DATA.unpack(header)
        remaining = size > 0 ? @socket.recv(size) : ''

        Protocol::Packet.from_s(header + remaining)
      end
    rescue
      raise TimeoutError
    end

    def recv_record
      packet = recv_packet
      raise InvalidResponseError if packet.records.empty?

      packet.records.first
    end

    private

    def login
      send_packet
      password_challenge = recv_record.data
      authenticate(password_challenge)
    end

    def authenticate(password_challenge)
      send_record(data: password_hash(password_challenge))
      raise AuthenticationError, 'Wrong password' if recv_record.type != 's'
    end

    def password_hash(challenge)
      Digest::MD5.digest(challenge + @password)
    end

    def expire_all
      send_record(setting: Manager::EXPIRE_ALL)
    end
  end
end
