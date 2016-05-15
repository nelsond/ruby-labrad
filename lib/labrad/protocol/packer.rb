# rubocop:disable Style/Documentation

require 'labrad/protocol/data'

module LabRAD
  module Protocol
    module Packer
      def pack_b(_element, value)
        [value ? 1 : 0].pack('c')
      end

      def pack_i(_element, value)
        [value].pack('l')
      end

      def pack_w(_element, value)
        [value].pack('L')
      end

      def pack_s(_element, value)
        length = pack_i('i', value.length)
        length + value
      end

      def pack_v(_element, value)
        [value].pack('d')
      end

      def pack_c(_element, value)
        data = Data.new('vv')
        data.pack(value.real, value.imag)
      end

      def pack_t(_element, value)
        # reference timestamp to 1904
        value = value.to_f + 2_082_844_800
        seconds, fractions = value.to_s.split('.').map(&:to_i)
        [seconds, fractions].pack('qq')
      end

      def pack_e(_element, value)
        data = Data.new('(is)')
        data.pack(value)
      end

      def pack_array(element, array)
        pattern = element[1..-1]
        data = Data.new(pattern)

        length = pack_i('i', array.length)
        length + array.map { |v| data.pack(v) }.join
      end

      def pack_narray(element, array)
        lengths = Helper.ndimensions(array, element[1].to_i)

        pattern = element[2..-1]
        data = Data.new(pattern)

        lengths.map { |d| pack_i('i', d) }.join +
          array.flatten.map { |v| data.pack(v) }.join
      end

      def pack_cluster(elements, cluster)
        pattern = elements[1..-2]
        data = Data.new(pattern)

        data.pack(*cluster)
      end
    end
  end
end
