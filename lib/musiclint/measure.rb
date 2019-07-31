require 'musiclint/chord'
require 'musiclint/nil-chord'
require 'musiclint/note'

module MusicLint
  class Measure
    attr_reader :number

    def initialize
      @notes ||= Hash.new { |h, k| h[k] = [] }
      @times ||= Set.new
    end

    def parse(measure_node:, part_node:)
      part_id = part_node.attribute('id').content

      notes = measure_node.xpath('note').map { |n|
        Note.new(part_id: part_id, xml_node: n)
      }
      @number ||= measure_node.attribute('number').content.to_i

      @times << BigDecimal("0")

      total_duration = Hash.new(BigDecimal("0"))
      index = 0

      notes.each do |note|
        voice = "#{part_id}-#{note.voice}"
        total_duration[voice] += note.duration
        time = total_duration[voice]
        @times << time
        @notes[time] << note
      end
    end

    def chords
      @times.sort.map { |t| chord_at(t) }
    end

    def chord_at(time)
      t = BigDecimal(time)
      notes = @notes[t]

      if notes.empty?
        NilChord.new
      else
        Chord.new(
          location: "measure #{@number}, beat #{t.to_s('F')}"
        ).tap { |chord|
          notes.each do |note|
            chord.add_note(note)
          end
        }
      end
    end
  end
end
