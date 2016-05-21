require 'labrad/protocol/data'

describe Labrad::Protocol::Data do
  describe '#pack' do
    it 'raises PackError for invalid arguments' do
      data = Labrad::Protocol::Data.new('s')

      expect { data.pack(nil) }.to raise_error(Labrad::PackError)
    end

    it 'packs boolean' do
      data = Labrad::Protocol::Data.new('b')

      result = data.pack(true)
      expected_result = [1].pack('c')

      expect(result).to eq(expected_result)
    end

    it 'packs signed integer' do
      data = Labrad::Protocol::Data.new('i')

      result = data.pack(1024)
      expected_result = [1024].pack('l')

      expect(result).to eq(expected_result)
    end

    it 'packs unsigned integer' do
      data = Labrad::Protocol::Data.new('w')

      result = data.pack(1024)
      expected_result = [1024].pack('L')

      expect(result).to eq(expected_result)
    end

    it 'packs string' do
      data = Labrad::Protocol::Data.new('s')
      string = 'Hello World!'

      result = data.pack(string)
      expected_result = [string.length].pack('l') + string

      expect(result).to eq(expected_result)
    end

    it 'packs value' do
      data = Labrad::Protocol::Data.new('v')
      value = 1.23456789

      result = data.pack(value)
      expected_result = [value].pack('d')

      expect(result).to eq(expected_result)
    end

    it 'packs complex value' do
      data = Labrad::Protocol::Data.new('c')
      value = Complex(1.23, 4.56)

      result = data.pack(value)
      expected_result = [value.real, value.imag].pack('dd')

      expect(result).to eq(expected_result)
    end

    it 'packs timestamp' do
      data = Labrad::Protocol::Data.new('t')
      timestamp = Time.at(0) - 2_082_844_800 # 12:00am Jan 1, 1904 UTC

      result = data.pack(timestamp)
      expected_result = [0, 0].pack('qq')

      expect(result).to eq(expected_result)
    end

    it 'packs cluster' do
      data = Labrad::Protocol::Data.new('(ii)')

      result = data.pack([1, 1])
      expected_result = [1, 1].pack('ll')

      expect(result).to eq(expected_result)
    end

    it 'packs array' do
      data = Labrad::Protocol::Data.new('*v')
      array = [1.23, 4.56]

      result = data.pack(array)
      expected_result = [2, *array].pack('ld2')

      expect(result).to eq(expected_result)
    end

    it 'packs cluster array' do
      data = Labrad::Protocol::Data.new('*(iv)')
      array = [[1, 2.34], [5, 6.78]]

      result = data.pack(array)
      expected_result = [2, *array.flatten].pack('lldld')

      expect(result).to eq(expected_result)
    end

    it 'packs n-dimensional array' do
      data = Labrad::Protocol::Data.new('*3i')
      array = [[[1, 2], [3, 4]], [[5, 6], [7, 8]]]

      result = data.pack(array)
      expected_result = [2, 2, 2, *array.flatten].pack('l3l8')

      expect(result).to eq(expected_result)
    end

    it 'packs none' do
      data = Labrad::Protocol::Data.new('_')

      result = data.pack('')
      expected_result = ''

      expect(result).to eq(expected_result)
    end

    it 'packs any with Integer' do
      i_data = Labrad::Protocol::Data.new('i')
      data = Labrad::Protocol::Data.new('?')

      result = data.pack(10)
      expected_result = i_data.pack(10)

      expect(result).to eq(expected_result)
    end

    it 'packs any with String' do
      s_data = Labrad::Protocol::Data.new('s')
      data = Labrad::Protocol::Data.new('?')

      result = data.pack('Hello World!')
      expected_result = s_data.pack('Hello World!')

      expect(result).to eq(expected_result)
    end

    it 'packs any with Float' do
      v_data = Labrad::Protocol::Data.new('v')
      data = Labrad::Protocol::Data.new('?')

      result = data.pack(1.23)
      expected_result = v_data.pack(1.23)

      expect(result).to eq(expected_result)
    end

    it 'packs any with Complex' do
      c_data = Labrad::Protocol::Data.new('c')
      data = Labrad::Protocol::Data.new('?')

      c = Complex(1, 1)
      result = data.pack(c)
      expected_result = c_data.pack(c)

      expect(result).to eq(expected_result)
    end

    it 'packs any with Time' do
      t_data = Labrad::Protocol::Data.new('t')
      data = Labrad::Protocol::Data.new('?')

      t = Time.now
      result = data.pack(t)
      expected_result = t_data.pack(t)

      expect(result).to eq(expected_result)
    end

    it 'packs error' do
      data = Labrad::Protocol::Data.new('E')
      code = 101
      message = 'Some random error'

      result = data.pack([code, message])
      expected_result = [code, message.length].pack('ll') + message

      expect(result).to eq(expected_result)
    end

    it 'packs error with element' do
      data = Labrad::Protocol::Data.new('Ev')
      code = 101
      message = 'Some random error'
      value = 1.23

      result = data.pack([code, message], value)
      expected_result = [code, message.length].pack('ll') +
                        message + [value].pack('d')

      expect(result).to eq(expected_result)
    end

    it 'packs multiple elements' do
      data = Labrad::Protocol::Data.new('iv')
      values = [1024, 1.34]

      result = data.pack(*values)
      expected_result = values.pack('ld')

      expect(result).to eq(expected_result)
    end

    it 'ignores comments in curly brackets' do
      i_data = Labrad::Protocol::Data.new('i')
      data = Labrad::Protocol::Data.new('i{comment}')

      result = data.pack(10)
      expected_result = i_data.pack(10)

      expect(result).to eq(expected_result)
    end

    it 'ignores comments after colon' do
      i_data = Labrad::Protocol::Data.new('i')
      data = Labrad::Protocol::Data.new('i: comment')

      result = data.pack(10)
      expected_result = i_data.pack(10)

      expect(result).to eq(expected_result)
    end
  end

  describe '#unpack' do
    it 'raises UnpackError for invalid arguments' do
      data = Labrad::Protocol::Data.new('s')

      expect { data.unpack('') }.to raise_error(Labrad::UnpackError)
    end

    it 'unpacks boolean' do
      data = Labrad::Protocol::Data.new('b')
      result = data.unpack([1].pack('c'))

      expect(result).to eq([true])
    end

    it 'unpacks signed integer' do
      data = Labrad::Protocol::Data.new('i')
      result = data.unpack([1024].pack('l'))

      expect(result).to eq([1024])
    end

    it 'unpacks unsigned integer' do
      data = Labrad::Protocol::Data.new('w')
      result = data.unpack([1024].pack('L'))

      expect(result).to eq([1024])
    end

    it 'unpacks string' do
      data = Labrad::Protocol::Data.new('s')
      string = 'Hello World!'
      result = data.unpack([string.length].pack('l') + string)

      expect(result).to eq([string])
    end

    it 'unpacks value' do
      data = Labrad::Protocol::Data.new('v')
      result = data.unpack([1.2345].pack('d'))

      expect(result).to eq([1.2345])
    end

    it 'unpacks complex value' do
      data = Labrad::Protocol::Data.new('c')
      result = data.unpack([1, 1].pack('dd'))

      expect(result).to eq([Complex(1, 1)])
    end

    it 'unpacks timestamp' do
      data = Labrad::Protocol::Data.new('t')
      result = data.unpack([0, 0].pack('qq'))

      expect(result).to eq([Time.at(0) - 2_082_844_800])
    end

    it 'unpacks cluster' do
      data = Labrad::Protocol::Data.new('(ii)')
      result = data.unpack([1, 1].pack('ll'))

      expect(result).to eq([[1, 1]])
    end

    it 'unpacks array' do
      data = Labrad::Protocol::Data.new('*v')
      array = [1.9, 2.8, 3.7, 4.6, 5.5, 6.4, 7.3, 8.2, 9.1]
      string = [9, *array].pack('ld9')
      result = data.unpack(string)

      expect(result).to eq([array])
    end

    it 'unpacks cluster array' do
      data = Labrad::Protocol::Data.new('*(iv)')
      array = [[1, 2.34], [5, 6.78]]
      result = data.unpack([2, *array.flatten].pack('lldld'))

      expect(result).to eq([array])
    end

    it 'unpacks n-dimensional array' do
      data = Labrad::Protocol::Data.new('*3i')
      array = [[[1, 2], [3, 4]], [[5, 6], [7, 8]], [[9, 10], [11, 12]]]
      string = [3, 2, 2, *array.flatten].pack('l3l12')
      result = data.unpack(string)

      expect(result).to eq([array])
    end

    it 'unpacks error' do
      data = Labrad::Protocol::Data.new('E')
      code = 101
      message = 'Some random error'
      result = data.unpack([code, message.length].pack('ll') + message)

      expect(result).to eq([[code, message]])
    end

    it 'unpacks error with element' do
      data = Labrad::Protocol::Data.new('Ev')
      code = 101
      message = 'Some random error'
      value = 1.23
      result = data.unpack([code, message.length].pack('ll') +
                             message + [value].pack('d'))

      expect(result).to eq([[code, message], value])
    end

    it 'unpacks none' do
      data = Labrad::Protocol::Data.new('_')
      result = data.unpack('')

      expect(result).to eq([''])
    end

    it 'unpacks multiple elements' do
      data = Labrad::Protocol::Data.new('iv')
      values = [1024, 1.34]
      result = data.unpack(values.pack('ld'))

      expect(result).to eq(values)
    end

    it 'ignores any (?)' do
      data = Labrad::Protocol::Data.new('i?')
      p = proc { data.unpack([10].pack('l')) }

      expect(p).not_to raise_error
    end
  end
end
