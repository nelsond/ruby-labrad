# rubocop:disable Style/Documentation, ClassLength, CyclomaticComplexity
# rubocop:disable AbcSize, MethodLength

module LabRAD
  module Protocol
    class Data
      def initialize(pattern)
        @pattern = pattern
      end

      def pack(*values)
        pattern_elements.zip(values).map do |item|
          element, value = item

          begin
            case element
            when /^\*[0-9]+/
              pack_narray(element, value)
            when /^\*[a-z]$/
              pack_array(element, value)
            else
              pack_element(element, value)
            end
          rescue
            raise PackError, "Can't pack '#{@pattern}' using #{values.inspect}"
          end
        end.join
      end

      def unpack(string, opts = {})
        pointer = 0
        result = pattern_elements.map do |element|
          size = 0
          value = nil
          remaining_string = string[pointer..-1]

          begin
            case element
            when /^\*[0-9]+/
              size, value = unpack_narray(element, remaining_string)
            when /^\*[a-z]$/
              size, value = unpack_array(element, remaining_string)
            else
              size, value = unpack_element(element, remaining_string)
            end
          rescue
            raise UnpackError, "Can't unpack '#{string}' using '#{@pattern}'"
          end

          pointer += size
          value
        end

        opts[:with_size] ? [pointer, result] : result
      end

      private

      def pattern_elements
        @pattern.scan(/(\*?[0-9]*[biwsvctE])/).flatten
      end

      def pack_element(element, value)
        case element
        when 'b'
          [value ? 1 : 0].pack('c')
        when 'i'
          [value].pack('l')
        when 'w'
          [value].pack('L')
        when 's'
          length = pack_element('i', value.length)
          length + value
        when 'v'
          [value].pack('d')
        when 'c'
          pack_element('v', value.real) + pack_element('v', value.imag)
        when 't'
          # reference timestamp to 1904
          value = value.to_f + 2_082_844_800
          seconds, fractions = value.to_s.split('.').map(&:to_i)
          [seconds, fractions].pack('qq')
        when 'E'
          code, message = value
          pack_element('i', code) + pack_element('s', message)
        end
      end

      def pack_array(element, array)
        element = element[-1]
        length = pack_element('i', array.length)

        length + array.map { |v| pack_element(element, v) }.join
      end

      def pack_narray(element, array)
        dimension = element[1].to_i
        element = element[-1]

        a = array
        lengths = []
        dimension.times do
          lengths << pack_element('i', a.length)
          a = a.first
        end

        lengths.join + array.flatten.map { |v| pack_element(element, v) }.join
      end

      def unpack_element(element, string)
        case element
        when 'b'
          [1, string[0] == "\x01"]
        when 'i'
          [4, string[0..3].unpack('l').first]
        when 'w'
          [4, string[0..3].unpack('L').first]
        when 's'
          length_size, length = unpack_element('i', string)
          range = length_size..length_size + length - 1
          [length_size + length, string[range]]
        when 'v'
          [8, string[0..7].unpack('d').first]
        when 'c'
          size, values = unpack_elements('vv', string)
          real, imag = values
          [size, Complex(real, imag)]
        when 't'
          seconds, fractions = string[0..127].unpack('qq')
          timestamp = "#{seconds}.#{fractions}".to_f
          # timestamp is referenced to 1904
          [128, Time.at(timestamp - 2_082_844_800)]
        when 'E'
          unpack_elements('is', string)
        end
      end

      def unpack_elements(elements, string)
        pointer = 0
        values = elements.split('').map do |element|
          element_size, value = unpack_element(element, string[pointer..-1])
          pointer += element_size
          value
        end

        [pointer, values]
      end

      def unpack_array(element, string)
        element = element[-1]
        length_size, length = unpack_element('i', string)

        range = length_size..-1
        unpack_elements(element * length, string[range])
      end

      def unpack_narray(element, string)
        dimension = element[1].to_i
        element = element[-1]
        lengths_size, lengths = unpack_elements('i' * dimension, string)

        range = lengths_size..-1
        size, array = unpack_elements(element * lengths.inject(:*),
                                      string[range])

        [size, reshape_array(array, lengths)]
      end

      def reshape_array(array, dimensions)
        dimensions.reverse[0..-2].each do |dimension|
          array = array.each_slice(dimension).to_a
        end

        array
      end
    end

    class PackError < RuntimeError
    end

    class UnpackError < RuntimeError
    end
  end
end
