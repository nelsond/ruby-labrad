require 'socket'
require 'stringio'
require 'labrad/protocol/packet'

class MockManager
  attr_accessor :buffer

  def initialize(port)
    @server = TCPServer.new(port)

    @buffer = []
  end

  def start
    Thread.new do
      @client = @server.accept

      @buffer.each do |packet|
        @client.write(packet.to_s)
      end
    end
  end

  def read_packets(length = 1024)
    string = read(length)
    stream = StringIO.new(string)

    packets = []
    packets << Labrad::Protocol::Packet.from_s(stream) until stream.eof?

    packets
  end

  def stop
    @server.close
  end

  private

  def read(length)
    @client.recv(length)
  end
end
