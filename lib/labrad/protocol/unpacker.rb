# rubocop:disable Style/Documentation

require 'labrad/protocol/data'

module Labrad
  module Protocol
    module Unpacker
      def unpack_b(_element, stream)
        stream.read(1) == "\x01"
      end

      def unpack_i(_element, stream)
        stream.read(4).unpack('l').first
      end

      def unpack_w(_element, stream)
        stream.read(4).unpack('L').first
      end

      def unpack_s(_element, stream)
        length = unpack_i('i', stream)
        stream.read(length)
      end

      def unpack_v(_element, stream)
        stream.read(8).unpack('d').first
      end

      def unpack_c(_element, stream)
        real, imag = Labrad::Protocol::Data.new('vv').unpack(stream)
        Complex(real, imag)
      end

      def unpack_t(_element, stream)
        seconds, fractions = stream.read(128).unpack('qq')
        # timestamp is referenced to 1904
        timestamp = "#{seconds}.#{fractions}".to_f - 2_082_844_800
        Time.at(timestamp)
      end

      def unpack_e(_element, stream)
        Labrad::Protocol::Data.new('is').unpack(stream)
      end

      def unpack__(_element, _stream)
        ''
      end

      def unpack_array(element, stream)
        length = unpack_i('i', stream)

        pattern = element[1..-1]
        data = Labrad::Protocol::Data.new(pattern * length)

        data.unpack(stream)
      end

      def unpack_narray(element, stream)
        ldata = Labrad::Protocol::Data.new('i' * element[1].to_i)
        lengths = ldata.unpack(stream)

        data = Labrad::Protocol::Data.new(element[-1] * lengths.inject(:*))
        array = data.unpack(stream)

        reshape_array(array, lengths)
      end

      def unpack_cluster(elements, stream)
        pattern = elements[1..-2]
        data = Labrad::Protocol::Data.new(pattern)

        data.unpack(stream)
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
