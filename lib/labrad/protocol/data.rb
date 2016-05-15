# rubocop:disable Style/Documentation

require 'labrad/protocol/errors'
require 'labrad/protocol/packer'
require 'labrad/protocol/unpacker'

module LabRAD
  module Protocol
    class Data
      include Packer
      include Unpacker

      def initialize(pattern)
        @pattern = pattern

        base_regexp = '\*?[0-9]*[biwsvctE]'
        regexp = /(#{base_regexp}|\*?[0-9]*\((?:#{base_regexp})+\))/
        @pattern_elements = pattern.scan(regexp).flatten
      end

      def pack(*values)
        @pattern_elements.zip(values).map do |item|
          begin
            element, value = item
            send("pack_#{resolve(element)}", element, value)
          rescue
            raise PackError, "Can't pack '#{@pattern}' using #{values.inspect}"
          end
        end.join
      end

      def unpack(string, opts = {})
        pointer = 0
        result = @pattern_elements.map do |element|
          begin
            size, value = send("unpack_#{resolve(element)}", element,
                               string[pointer..-1])
            pointer += size
            value
          rescue
            raise UnpackError,
                  "Can't unpack '#{string.inspect}' using '#{@pattern}'"
          end
        end

        opts[:with_size] ? [pointer, result] : result
      end

      private

      def resolve(element)
        case element
        when /^\*[0-9]+[a-z]/ then :narray
        when /^\*/ then :array
        when /^\(.*\)$/ then :cluster
        else element.downcase.to_sym
        end
      end
    end
  end
end
