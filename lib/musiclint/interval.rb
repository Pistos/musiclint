module MusicLint
  class Interval
    NUMBER_WORDS = {
      1 => 'unison',
      2 => 'second',
      3 => 'third',
      4 => 'fourth',
      5 => 'fifth',
      6 => 'sixth',
      7 => 'seventh',
      8 => 'octave',
      9 => 'ninth',
      10 => 'tenth',
      11 => 'eleventh',
      12 => 'twelfth',
      13 => 'thirteenth',
      14 => 'fourteenth',
      15 => 'fifteenth',
    }

    AUGMENTED = 'augmented'
    DIMINISHED = 'diminished'
    MAJOR = 'major'
    MINOR = 'minor'
    PERFECT = 'perfect'

    QUALITY_ABBR = {
      AUGMENTED => 'A',
      DIMINISHED => 'd',
      MAJOR => 'M',
      MINOR => 'm',
      PERFECT => 'P',
    }

    def -(other_interval)
      self.to_i - other_interval.to_i
    end

    def initialize(note1, note2)
      @note1 = note1
      @note2 = note2
    end

    def number_word
      NUMBER_WORDS[number_integer] || number_integer.to_s
    end

    def number_integer
      @note2.staff_position - @note1.staff_position + 1
    end

    def perfect?
      quality == PERFECT
    end

    def quality
      case [simple_number_integer, to_i % 12]
      when [1, 0], [4, 5], [5, 7], [8, 0]
        PERFECT
      when [2, 0], [3, 2], [4, 4], [5, 6], [6, 7], [7, 9], [8, 11]
        DIMINISHED
      when [2, 1], [3, 3], [6, 8], [7, 10]
        MINOR
      when [1, 1], [2, 3], [3, 5], [4, 6], [5, 8], [6, 10], [7, 0]
        AUGMENTED
      when [2, 2], [3, 4], [6, 9], [7, 11]
        MAJOR
      end
    end

    def quality_abbr
      QUALITY_ABBR[quality]
    end

    def simple_number_integer
      sni = number_integer % 7
      if sni == 1 && number_integer > 7
        sni = 8
      end

      sni
    end

    def to_i
      @note2.pitch.to_i - @note1.pitch.to_i
    end

    def to_s
      "#{@note1}-#{@note2} (#{quality_abbr}#{simple_number_integer})"
    end

    def voices
      [@note1.voice, @note2.voice]
    end
  end
end
