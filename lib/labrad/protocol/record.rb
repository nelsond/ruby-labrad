# rubocop:disable Style/Documentation

require 'labrad/protocol/data'

module LabRAD
  module Protocol
    class Record
      RECORD_DATA = Data.new('w s s')

      attr_reader :type
      attr_accessor :setting, :data

      def initialize(opts = {})
        @labrad_data = Data.new('w s s')

        options = {
          setting: 0,
          type: 's',
          data: ''
        }.merge(opts)

        options.map { |k, v| send("#{k}=", v) }
      end

      def type=(tag)
        @type = tag
        @type_labrad_data = Data.new(tag)
      end

      def ==(other)
        to_s == other.to_s
      end

      def to_s
        @labrad_data.pack(@setting,
                          @type,
                          @type_labrad_data.pack(@data))
      end

      def self.from_s(string)
        setting, type, data = RECORD_DATA.unpack(string)
        type_labrad_data = Data.new(type)
        data = type_labrad_data.unpack(data).first

        Record.new(setting: setting, type: type, data: data)
      end

      def self.many_from_s(stream)
        stream = StringIO.new(stream) if stream.is_a?(String)

        records = []
        records << from_s(stream) until stream.eof?

        records
      end
    end
  end
end
