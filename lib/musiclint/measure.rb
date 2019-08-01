require 'musiclint/chord'
require 'musiclint/nil-chord'
require 'musiclint/note'

module MusicLint
  class ChordLocationMismatchError < StandardError
  end

  class Measure
    attr_reader :number

    def chords
      @chords.keys.sort.map { |time|
        @chords[time]
      }
    end

    def initialize(divisions: nil)
      @divisions = divisions
      @chords = Hash.new { |h, k| h[k] = NilChord.new }
    end

    def parse(measure_node:, part_id:)
      @number ||= measure_node.attribute('number').content.to_i

      if measure_node.at('attributes/divisions')
        @divisions ||= BigDecimal(measure_node.at('attributes/divisions').content)
      end

      if @divisions
        total_duration = Hash.new(BigDecimal("0"))
        index = 0
        notes_at_time ||= Hash.new { |h, k| h[k] = [] }

        measure_node.xpath('note').map { |n|
          Note.new(part_id: part_id, xml_node: n)
        }.each do |note|
          voice = "#{part_id}-#{note.voice}"
          total_duration[voice] += note.duration / @divisions
          time = total_duration[voice]
          notes_at_time[time] << note
        end

        times = notes_at_time.keys.sort
        times.each do |t|
          notes_to_add = notes_at_time[t].find_all(&:note?)

          if notes_to_add.any?
            location = "measure #{@number}, beat #{t.to_s('F')}"

            existing_location = @chords[t].location
            if existing_location && existing_location != location
              raise ChordLocationMismatchError.new("Will not merge chords in different locations. #{existing_location} != #{location}")
            end

            @chords[t] = @chords[t].merge(
              Chord.new(location: location).tap { |chord|
                notes_to_add.each do |note|
                  chord.add_note(note)
                end
              }
            )
          end
        end
      end

      @divisions
    end
  end
end
