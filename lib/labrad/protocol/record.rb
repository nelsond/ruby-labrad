# rubocop:disable Style/Documentation

require 'labrad/protocol/data'

module LabRAD
  module Protocol
    class Record
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
        labrad_data = Data.new('w s s')

        setting, type, data = labrad_data.unpack(string)
        type_labrad_data = Data.new(type)
        data = type_labrad_data.unpack(data).first

        Record.new(setting: setting, type: type, data: data)
      end

      def self.many_from_s(string)
        records = []
        labrad_data = Data.new('w s s')
        pointer = 0
        while pointer < string.length
          size, = labrad_data.unpack(string[pointer..-1], with_size: true)
          s = string[pointer..pointer + size]
          records << Record.from_s(s)

          pointer += size
        end

        records
      end
    end
  end
end
