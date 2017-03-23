module DraftjsExporter
  class << self
    attr_accessor :logger

    def logger
      @logger ||= NullLogger.new
    end
  end

  class NullLogger < Logger
    def initialize(*_)
    end

    def add(*_, &__)
    end
  end
end
