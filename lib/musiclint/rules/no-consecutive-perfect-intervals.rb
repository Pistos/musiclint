require 'musiclint/nil-chord'
require 'musiclint/problem'

module MusicLint
  module Rules
    class NoConsecutivePerfectIntervals
      DESCRIPTION = %{
        Disallow a perfect interval in the same two voices in two
        consecutive chords.  Perfect fourths are not considered.
      }
      NAME = 'no-consecutive-perfect-intervals'

      def self.check(score)
        problems = []

        chords = score.chords
        chords.each_with_index do |chord, i|
          next_chord = chords[i+1] || NilChord.new
          intervals = chord.intervals
          next_intervals = next_chord.intervals

          intervals.each do |voices, int|
            next_int = next_intervals[voices] || NilInterval.new

            if (
              int.perfect? &&
              int.simple_number_integer != 4 &&
              next_int.perfect? &&
              next_int.simple_number_integer != 4
            )
              problems << Problem.new(
                details: "Consecutive perfect intervals: voices #{voices}  #{int}, #{next_int}",
                moment: chord.moment,
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
