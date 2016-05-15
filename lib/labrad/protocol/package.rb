# rubocop:disable Style/Documentation

require 'labrad/protocol/data'
require 'labrad/protocol/record'

module LabRAD
  module Protocol
    class Package
      attr_reader :context
      attr_accessor :request, :target, :records

      alias source target
      alias source= target=

      def initialize(opts = {})
        @labrad_data = Data.new('ww i w s')

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

      def to_s
        @labrad_data.pack(*@context,
                          @request,
                          @target,
                          @records.map(&:to_s).join)
      end

      def self.from_s(string)
        labrad_data = Data.new('(ww) i w s')

        context, request, target, records_string = labrad_data.unpack(string)

        package = Package.new(context: context,
                              request: request,
                              target: target,
                              records: Record.many_from_s(records_string))

        package
      end
    end
  end
end
