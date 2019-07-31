require 'musiclint/interval'

module MusicLint
  class Chord
    attr_reader :location

    def [](index)
      notes[index]
    end

    def add_note(note)
      @notes[note.voice] = note
    end

    def initialize(location:)
      @notes = {}
      @location = location
    end

    def intervals
      vs1 = voices
      vs2 = vs1.dup

      Hash.new.tap { |_intervals|
        vs1.each_with_index do |v1, i|
          vs2.each_with_index do |v2, j|
            if j > i
              _intervals[ [v1, v2] ] = Interval.new(
                @notes[v1],
                @notes[v2]
              )
            end
          end
        end
      }
    end

    def note_by(voice:)
      @notes[voice]
    end

    def notes
      voices.map { |voice|
        note_by(voice: voice)
      }
    end

    def to_s
      notes.map(&:to_s).join('-')
    end

    def voices
      @notes.keys.sort.reverse
    end
  end
end
