# rubocop:disable Style/Documentation

module LabRAD
  module Protocol
    module Helper
      def self.reshape_array(array, ndimensions)
        ndimensions.reverse[0..-2].each do |dimension|
          array = array.each_slice(dimension).to_a
        end

        array
      end

      def self.ndimensions(array, dimension)
        a = array
        lengths = []
        dimension.times do
          lengths << a.length
          a = a.first
        end

        lengths
      end
    end
  end
end
