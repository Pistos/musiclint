module MusicLint
  class Moment
    attr_reader :measure_number, :time_in_measure

    def ==(other_moment)
      @measure_number == other_moment.measure_number &&
      @time_in_measure == other_moment.time_in_measure
    end

    def initialize(measure_number:, time_in_measure:)
      @measure_number = measure_number
      @time_in_measure = time_in_measure
      @display_time = @time_in_measure + BigDecimal(1)
    end

    def to_s
      "ms #{@measure_number}, bt #{@display_time.to_s('F')}"
    end
  end
end
