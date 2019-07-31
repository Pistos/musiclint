module MusicLint
  class Interval
    def -(other_interval)
      self.to_i - other_interval.to_i
    end

    def initialize(note1, note2)
      @note1 = note1
      @note2 = note2
    end

    def inspect
      "#{@note1}-#{@note2} #{to_i}"
    end

    def perfect?
      [5, 7, 12].include? to_i
    end

    def to_i
      @note2.pitch.to_i - @note1.pitch.to_i
    end

    def to_s
      to_i.to_s
    end

    def voices
      [@note1.voice, @note2.voice]
    end
  end
end
