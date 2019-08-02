require 'musiclint/chord'

module Factories
  class Chord
    def self.create(moment:, notes: [])
      MusicLint::Chord.new(moment: moment).tap { |chord|
        notes.each do |note|
          chord.add_note note
        end
      }
    end
  end
end
