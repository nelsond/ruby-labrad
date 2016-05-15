# rubocop:disable Style/Documentation

require 'labrad/protocol/data'

module LabRAD
  module Protocol
    module Unpacker
      def unpack_b(_element, string)
        [1, string[0] == "\x01"]
      end

      def unpack_i(_element, string)
        [4, string[0..3].unpack('l').first]
      end

      def unpack_w(_element, string)
        [4, string[0..3].unpack('L').first]
      end

      def unpack_s(_element, string)
        length_size, length = unpack_i('i', string)
        range = length_size..length_size + length - 1
        [length_size + length, string[range]]
      end

      def unpack_v(_element, string)
        [8, string[0..7].unpack('d').first]
      end

      def unpack_c(_element, string)
        data = Data.new('vv')
        size, values = data.unpack(string, with_size: true)
        real, imag = values
        [size, Complex(real, imag)]
      end

      def unpack_t(_element, string)
        seconds, fractions = string[0..127].unpack('qq')
        timestamp = "#{seconds}.#{fractions}".to_f
        # timestamp is referenced to 1904
        [128, Time.at(timestamp - 2_082_844_800)]
      end

      def unpack_e(_element, string)
        data = Data.new('is')
        data.unpack(string, with_size: true)
      end

      def unpack_array(element, string)
        length_size, length = unpack_i('i', string)
        range = length_size..-1

        pattern = element[1..-1]
        data = Data.new(pattern * length)

        data.unpack(string[range], with_size: true)
      end

      def unpack_narray(element, string)
        ldata = Data.new('i' * element[1].to_i)
        lengths_size, lengths = ldata.unpack(string, with_size: true)

        data = Data.new(element[-1] * lengths.inject(:*))
        range = lengths_size..-1
        size, array = data.unpack(string[range], with_size: true)

        [size, reshape_array(array, lengths)]
      end

      def unpack_cluster(elements, string)
        pattern = elements[1..-2]
        data = Data.new(pattern)

        data.unpack(string, with_size: true)
      end

      def reshape_array(array, ndimensions)
        ndimensions.reverse[0..-2].each do |dimension|
          array = array.each_slice(dimension).to_a
        end

        array
      end
    end
  end
end
