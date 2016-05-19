# rubocop:disable Style/Documentation

require 'labrad/protocol/packer'
require 'labrad/protocol/unpacker'
require 'labrad/errors'

module LabRAD
  module Protocol
    class Data
      include Packer
      include Unpacker

      BASE_REGEXP = '\*?[0-9]*[\?biwsvctE_]'.freeze

      def initialize(pattern)
        @pattern = sanitize_pattern(pattern)

        regexp = /(#{BASE_REGEXP}|\*?[0-9]*\((?:#{BASE_REGEXP})+\))/
        @pattern_elements = @pattern.scan(regexp).flatten
      end

      def pack(*values)
        @pattern_elements.zip(values).map do |item|
          element, value = item
          send("pack_#{resolve(element)}", element, value)
        end.join

      rescue
        raise LabRAD::PackError,
              "Can't pack '#{@pattern}' using #{values.inspect}"
      end

      def unpack(stream)
        stream = StringIO.new(stream) if stream.is_a?(String)

        result = @pattern_elements.map do |element|
          # do not support unpacking of any (?)
          next if element == '?'

          send("unpack_#{resolve(element)}", element, stream)
        end

        result

      rescue
        raise LabRAD::UnpackError,
              "Can't unpack '#{stream.inspect}' using '#{@pattern}'"
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

      # See https://github.com/labrad/pylabrad/blob/7f4f327e5b283536089a2b97bb0b713e7ca29c12/labrad/types.py#L185
      def sanitize_pattern(pattern)
        pattern.gsub(/\s/, '')
               .gsub(/^([^:]+):.+/, '\1')
               .gsub(/\{[^\{\}]*\}/, '')
      end
    end
  end
end
