require 'dalli/client'
require 'dalli/ring'
require 'dalli/server'
require 'dalli/socket'
require 'dalli/version'
require 'dalli/options'
require 'dalli/compressor'
require 'dalli/railtie' if defined?(::Rails::Railtie)

module Dalli
  # generic error
  class DalliError < RuntimeError; end
  # socket/server communication error
  class NetworkError < DalliError; end
  # no server available/alive error
  class RingError < DalliError; end
  # application error in marshalling serialization
  class MarshalError < DalliError; end
  # application error in marshalling deserialization or decompression
  class UnmarshalError < DalliError; end
  # application error in data size
  class ValueTooBigError < DalliError; end

  def self.logger
    @logger ||= (rails_logger || default_logger)
  end

  def self.rails_logger
    (defined?(Rails) && Rails.respond_to?(:logger) && Rails.logger) ||
    (defined?(RAILS_DEFAULT_LOGGER) && RAILS_DEFAULT_LOGGER.respond_to?(:debug) && RAILS_DEFAULT_LOGGER)
  end

  def self.default_logger
    require 'logger'
    l = Logger.new(STDOUT)
    l.level = Logger::INFO
    l
  end

  def self.logger=(logger)
    @logger = logger
  end

  # Default serialization to Marshal
  @serializer = Marshal

  def self.serializer
    @serializer
  end

  def self.serializer=(serializer)
    @serializer = serializer
  end

  # Default serialization to Dalli::Compressor
  @compressor = Compressor

  def self.compressor
    @compressor
  end

  def self.compressor=(compressor)
    @compressor = compressor
  end
end

if defined?(RAILS_VERSION) && RAILS_VERSION < '3'
  raise Dalli::DalliError, "Dalli #{Dalli::VERSION} does not support Rails version < 3.0"
end
