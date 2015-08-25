module EncodingSampler
  class DiffHunk
    attr_accessor :type

    def initialize(type, prefix = '', suffix = '')
      @type = type
      @buffer = ''
      @prefix = prefix
      @suffix = suffix
    end

    def <<(val)
      @buffer << val
    end

    def result
      "#{@prefix}#{@buffer}#{@suffix}"
    end
  end
end
