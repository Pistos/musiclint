require 'musiclint/interval'

module MusicLint
  class DuplicateNoteError < StandardError
  end

  class Chord
    attr_reader :location

    def [](index)
      notes[index]
    end

    def add_note(note)
      if @notes[note.voice]
        raise DuplicateNoteError.new("Chord at #{@location} already has a note by voice #{note.voice}")
      else
        @notes[note.voice] = note
      end
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
              n1 = @notes[v1]
              n2 = @notes[v2]

              if n1 && n2 && ! n1.rest? && ! n2.rest?
                _intervals[ [v1, v2] ] = Interval.new(n1, n2)
              else
                _intervals[ [v1, v2] ] = NilInterval.new
              end
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
