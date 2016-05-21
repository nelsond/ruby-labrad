require 'timeout'

module Labrad
  class PackError < ArgumentError
  end

  class UnpackError < ArgumentError
  end

  class AuthenticationError < RuntimeError
  end

  class TimeoutError < Timeout::Error
  end

  class InvalidResponseError < RuntimeError
  end
end
