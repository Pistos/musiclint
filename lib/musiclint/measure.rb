require 'musiclint/chord'
require 'musiclint/moment'
require 'musiclint/nil-chord'
require 'musiclint/note'

module MusicLint
  class ChordMomentMismatchError < StandardError
  end

  class Measure
    attr_reader :number

    private def add_notes(moment:, notes_to_add:)
      if notes_to_add.any?
        t = moment.time_in_measure
        @chords[t] = @chords[t].merge(
          Chord.new(moment: moment).tap { |chord|
            notes_to_add.each do |note|
              chord.add_note(note)
            end
          }
        )
      end
    end

    def chords
      @chords.keys.sort.map { |time|
        @chords[time]
      }
    end

    def initialize(divisions: nil)
      @divisions = divisions
      @chords = Hash.new { |h, k| h[k] = NilChord.new }
    end

    private def notes_sounding_at(divisions:, notes_by_time:, time_of_sound:)
      notes = {}
      times = notes_by_time.keys.sort

      times.each do |t|
        if t <= time_of_sound
          notes_by_time[t].find_all(&:note?).each do |note|
            if t + note.duration / divisions > time_of_sound
              notes[note.voice] = note
            end
          end
        end
      end

      notes.values
    end

    def parse(measure_node:, part_id:)
      parse_number(measure_node: measure_node)
      parse_divisions(measure_node: measure_node)

      if @divisions
        parse_notes(measure_node: measure_node, part_id: part_id)
      end

      @divisions
    end

    private def parse_divisions(measure_node:)
      if measure_node.at('attributes/divisions')
        @divisions ||= BigDecimal(measure_node.at('attributes/divisions').content)
      end
    end

    private def parse_number(measure_node:)
      @number ||= measure_node.attribute('number').content.to_i
    end

    private def parsed_notes(measure_node:, part_id:)
      measure_node.xpath('note').map { |n|
        Note.new(part_id: part_id, xml_node: n)
      }
    end

    private def parse_notes(measure_node:, part_id:)
      total_duration = Hash.new(BigDecimal(0))
      notes_by_time = Hash.new { |h, k| h[k] = [] }

      notes = parsed_notes(measure_node: measure_node, part_id: part_id)
      notes.each do |note|
        voice = "#{part_id}-#{note.voice}"
        time = total_duration[voice]
        total_duration[voice] += note.duration / @divisions
        notes_by_time[time] << note
      end

      process_notes(notes_by_time: notes_by_time)
    end

    private def process_notes(notes_by_time:)
      times = notes_by_time.keys.sort
      times.each do |t|
        process_notes_at(notes_by_time: notes_by_time, time: t)
      end
    end

    private def process_notes_at(notes_by_time:, time:)
      notes_to_add = notes_sounding_at(
        divisions: @divisions,
        notes_by_time: notes_by_time,
        time_of_sound: time
      )

      moment = Moment.new(measure_number: @number, time_in_measure: time)
      require_same_moment(moment, @chords[time].moment)

      add_notes(notes_to_add: notes_to_add, moment: moment)
    end

    private def require_same_moment(moment1, moment2)
      if moment2 && moment2 != moment1
        raise ChordMomentMismatchError.new(
          "Will not merge chords from different moments. #{moment2} != #{moment1}"
        )
      end
    end
  end
end
