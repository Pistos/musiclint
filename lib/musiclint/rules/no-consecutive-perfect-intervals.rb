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

      def check
        @chords.each_with_index do |chord, i|
          next_chord = @chords[i+1] || NilChord.new
          process_chord_pair(chord, next_chord)
        end

        @problems
      end

      private def consecutive_perfect_intervals?(interval, next_interval)
        interval.perfect? &&
        interval.simple_number_integer != 4 &&
        next_interval.perfect? &&
        next_interval.simple_number_integer != 4
      end

      def initialize(score)
        @score = score
        @chords = @score.chords
        @problems = []
      end

      private def process_chord_pair(chord, next_chord)
        chord.intervals.each do |voices, int|
          next_int = next_chord.intervals[voices] || NilInterval.new

          if consecutive_perfect_intervals?(int, next_int)
            @problems << Problem.new(
              details: "Consecutive perfect intervals: voices #{voices}  #{int}, #{next_int}",
              moment: chord.moment,
              name: NAME,
              type: Problem::ERROR_TYPE,
            )
          end
        end
      end
    end
  end
end
