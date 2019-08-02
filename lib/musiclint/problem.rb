module MusicLint
  class Problem
    ERROR_TYPE = 'error'
    WARNING_TYPE = 'warning'

    def error?
      @type == ERROR_TYPE
    end

    def initialize(
      details:,
      moment:,
      name:,
      type:
    )
      @details = details
      @moment = moment
      @name = name
      @type = type
    end

    def to_s
      "%-24s  %-8s  %-40s  %s" % [@moment, @type, @details, @name]
    end

    def warning?
      @type == WARNING_TYPE
    end
  end
end
