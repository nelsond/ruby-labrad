# rubocop:disable Style/Documentation

require 'labrad/protocol/data'
require 'labrad/protocol/record'

module LabRAD
  module Protocol
    class Packet
      PACKET_DATA = Protocol::Data.new('(ww) i w s')

      attr_reader :context
      attr_accessor :request, :target, :records

      alias source target
      alias source= target=

      def initialize(opts = {})
        options = {
          context: 0,
          request: 1,
          target: 1,
          records: []
        }.merge(opts)

        options.map { |k, v| send("#{k}=", v) }
      end

      def context=(x)
        @context = x.is_a?(Array) ? x : [0, x]
      end

      def <<(record)
        @records << record
      end

      def has_records?
        @records.length > 0
      end

      def to_s
        PACKET_DATA.pack(@context,
                         @request,
                         @target,
                         @records.map(&:to_s).join)
      end

      def self.from_s(string)
        context, request, target, records_string = PACKET_DATA.unpack(string)

        Packet.new(context: context,
                   request: request,
                   target: target,
                   records: Record.many_from_s(records_string))
      end
    end
  end
end
