require 'musiclint/nil-chord'
require 'musiclint/problem'

module MusicLint
  module Rules
    class NoConsecutivePerfectIntervals
      NAME = 'no-consecutive-perfect-intervals'

      def self.check(score)
        problems = []

        chords = score.chords
        chords.each_with_index do |chord, i|
          next_chord = chords[i+1] || NilChord.new
          intervals = chord.intervals
          next_intervals = next_chord.intervals
          voice_pairs = Set.new

          intervals.each do |voices, int|
            next_int = next_intervals[voices] || NilInterval.new

            if int.perfect? && next_int.perfect?
              problems << Problem.new(
                details: "Consecutive perfect intervals: #{int}, #{next_int}",
                location: chord.location,
                name: NAME,
                type: Problem::ERROR_TYPE,
              )
            end
          end
        end

        problems
      end
    end
  end
end
