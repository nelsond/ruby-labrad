require 'labrad/protocol/data'

describe LabRAD::Protocol::Data do
  describe '#pack' do
    it 'raises PackError for invalid arguments' do
      packer = LabRAD::Protocol::Data.new('s')

      expect { packer.pack(nil) }.to raise_error(LabRAD::PackError)
    end

    it 'packs boolean' do
      packer = LabRAD::Protocol::Data.new('b')

      result = packer.pack(true)
      expected_result = [1].pack('c')

      expect(result).to eq(expected_result)
    end

    it 'packs signed integer' do
      packer = LabRAD::Protocol::Data.new('i')

      result = packer.pack(1024)
      expected_result = [1024].pack('l')

      expect(result).to eq(expected_result)
    end

    it 'packs unsigned integer' do
      packer = LabRAD::Protocol::Data.new('w')

      result = packer.pack(1024)
      expected_result = [1024].pack('L')

      expect(result).to eq(expected_result)
    end

    it 'packs string' do
      packer = LabRAD::Protocol::Data.new('s')
      string = 'Hello World!'

      result = packer.pack(string)
      expected_result = [string.length].pack('l') + string

      expect(result).to eq(expected_result)
    end

    it 'packs value' do
      packer = LabRAD::Protocol::Data.new('v')
      value = 1.23456789

      result = packer.pack(value)
      expected_result = [value].pack('d')

      expect(result).to eq(expected_result)
    end

    it 'packs complex value' do
      packer = LabRAD::Protocol::Data.new('c')
      value = Complex(1.23, 4.56)

      result = packer.pack(value)
      expected_result = [value.real, value.imag].pack('dd')

      expect(result).to eq(expected_result)
    end

    it 'packs timestamp' do
      packer = LabRAD::Protocol::Data.new('t')
      timestamp = Time.at(0) - 2_082_844_800 # 12:00am Jan 1, 1904 UTC

      result = packer.pack(timestamp)
      expected_result = [0, 0].pack('qq')

      expect(result).to eq(expected_result)
    end

    it 'packs cluster' do
      packer = LabRAD::Protocol::Data.new('(ii)')

      result = packer.pack([1, 1])
      expected_result = [1, 1].pack('ll')

      expect(result).to eq(expected_result)
    end

    it 'packs array' do
      packer = LabRAD::Protocol::Data.new('*v')
      array = [1.23, 4.56]

      result = packer.pack(array)
      expected_result = [2, *array].pack('ld2')

      expect(result).to eq(expected_result)
    end

    it 'packs cluster array' do
      packer = LabRAD::Protocol::Data.new('*(iv)')
      array = [[1, 2.34], [5, 6.78]]

      result = packer.pack(array)
      expected_result = [2, *array.flatten].pack('lldld')

      expect(result).to eq(expected_result)
    end

    it 'packs n-dimensional array' do
      packer = LabRAD::Protocol::Data.new('*3i')
      array = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]

      result = packer.pack(array)
      expected_result = [2, 2, 2, *array.flatten].pack('l3l8')

      expect(result).to eq(expected_result)
    end

    it 'packs error' do
      packer = LabRAD::Protocol::Data.new('E')
      code = 101
      message = 'Some random error'

      result = packer.pack([code, message])
      expected_result = [code, message.length].pack('ll') + message

      expect(result).to eq(expected_result)
    end

    it 'packs error with element' do
      packer = LabRAD::Protocol::Data.new('Ev')
      code = 101
      message = 'Some random error'
      value = 1.23

      result = packer.pack([code, message], value)
      expected_result = [code, message.length].pack('ll') +
                        message + [value].pack('d')

      expect(result).to eq(expected_result)
    end

    it 'packs multiple elements' do
      packer = LabRAD::Protocol::Data.new('iv')
      values = [1024, 1.34]

      result = packer.pack(*values)
      expected_result = values.pack('ld')

      expect(result).to eq(expected_result)
    end
  end

  describe '#unpack' do
    it 'raises UnpackError for invalid arguments' do
      packer = LabRAD::Protocol::Data.new('s')

      expect { packer.unpack('') }.to raise_error(LabRAD::UnpackError)
    end

    it 'unpacks boolean' do
      packer = LabRAD::Protocol::Data.new('b')
      result = packer.unpack([1].pack('c'))

      expect(result).to eq([true])
    end

    it 'unpacks signed integer' do
      packer = LabRAD::Protocol::Data.new('i')
      result = packer.unpack([1024].pack('l'))

      expect(result).to eq([1024])
    end

    it 'unpacks unsigned integer' do
      packer = LabRAD::Protocol::Data.new('w')
      result = packer.unpack([1024].pack('L'))

      expect(result).to eq([1024])
    end

    it 'unpacks string' do
      packer = LabRAD::Protocol::Data.new('s')
      string = 'Hello World!'
      result = packer.unpack([string.length].pack('l') + string)

      expect(result).to eq([string])
    end

    it 'unpacks value' do
      packer = LabRAD::Protocol::Data.new('v')
      result = packer.unpack([1.2345].pack('d'))

      expect(result).to eq([1.2345])
    end

    it 'unpacks complex value' do
      packer = LabRAD::Protocol::Data.new('c')
      result = packer.unpack([1, 1].pack('dd'))

      expect(result).to eq([Complex(1, 1)])
    end

    it 'unpacks timestamp' do
      packer = LabRAD::Protocol::Data.new('t')
      result = packer.unpack([0, 0].pack('qq'))

      expect(result).to eq([Time.at(0) - 2_082_844_800])
    end

    it 'unpacks cluster' do
      packer = LabRAD::Protocol::Data.new('(ii)')
      result = packer.unpack([1, 1].pack('ll'))

      expect(result).to eq([[1, 1]])
    end

    it 'unpacks array' do
      packer = LabRAD::Protocol::Data.new('*v')
      array = [1.9, 2.8, 3.7, 4.6, 5.5, 6.4, 7.3, 8.2, 9.1]
      string = [9, *array].pack('ld9')
      result = packer.unpack(string, with_size: true)

      expect(result).to eq([string.size, [array]])
    end

    it 'unpacks cluster array' do
      packer = LabRAD::Protocol::Data.new('*(iv)')
      array = [[1, 2.34], [5, 6.78]]
      result = packer.unpack([2, *array.flatten].pack('lldld'))

      expect(result).to eq([array])
    end

    it 'unpacks n-dimensional array' do
      packer = LabRAD::Protocol::Data.new('*3i')
      array = [[[1, 2], [3, 4]], [[5, 6], [7, 8]], [[9, 10], [11, 12]]]
      string = [3, 2, 2, *array.flatten].pack('l3l12')
      result = packer.unpack(string, with_size: true)

      expect(result).to eq([string.size, [array]])
    end

    it 'unpacks error' do
      packer = LabRAD::Protocol::Data.new('E')
      code = 101
      message = 'Some random error'
      result = packer.unpack([code, message.length].pack('ll') + message)

      expect(result).to eq([[code, message]])
    end

    it 'unpacks error with element' do
      packer = LabRAD::Protocol::Data.new('Ev')
      code = 101
      message = 'Some random error'
      value = 1.23
      result = packer.unpack([code, message.length].pack('ll') +
                             message + [value].pack('d'))

      expect(result).to eq([[code, message], value])
    end

    it 'unpacks multiple elements' do
      packer = LabRAD::Protocol::Data.new('iv')
      values = [1024, 1.34]
      result = packer.unpack(values.pack('ld'))

      expect(result).to eq(values)
    end

    it 'optionally returns size along with result' do
      packer = LabRAD::Protocol::Data.new('i')
      result = packer.unpack([1024].pack('l'), with_size: true)

      expect(result).to eq([4, [1024]])
    end
  end
end
