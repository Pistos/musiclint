require 'musiclint/nil-interval'

module MusicLint
  class NilChord
    def intervals
      Hash.new(NilInterval.new)
    end

    def moment
      nil  # NilMoment.new
    end

    def merge(chord)
      chord
    end

    def note_by(*)
      nil  # NilNote.new
    end

    def notes
      []
    end

    def to_s
      nil
    end
  end
end
