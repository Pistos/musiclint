require 'musiclint/chord'
require 'musiclint/moment'
require 'musiclint/nil-chord'
require 'musiclint/note'

module MusicLint
  class ChordMomentMismatchError < StandardError
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

    def notes_sounding_at(divisions:, notes_starting_at:, time_of_sound:)
      notes = {}
      times = notes_starting_at.keys.sort

      times.each do |t|
        if t <= time_of_sound
          notes_starting_at[t].find_all(&:note?).each do |note|
            if t + note.duration / divisions > time_of_sound
              notes[note.voice] = note
            end
          end
        end
      end

      notes.values
    end

    def parse(measure_node:, part_id:)
      @number ||= measure_node.attribute('number').content.to_i

      if measure_node.at('attributes/divisions')
        @divisions ||= BigDecimal(measure_node.at('attributes/divisions').content)
      end

      if @divisions
        total_duration = Hash.new(BigDecimal("0"))
        notes_starting_at ||= Hash.new { |h, k| h[k] = [] }

        measure_node.xpath('note').map { |n|
          Note.new(part_id: part_id, xml_node: n)
        }.each do |note|
          voice = "#{part_id}-#{note.voice}"
          time = total_duration[voice]
          total_duration[voice] += note.duration / @divisions
          notes_starting_at[time] << note
        end

        times = notes_starting_at.keys.sort
        times.each do |t|
          notes_to_add = notes_sounding_at(
            divisions: @divisions,
            notes_starting_at: notes_starting_at,
            time_of_sound: t
          )

          if notes_to_add.any?
            moment = Moment.new(measure_number: @number, time_in_measure: t)

            existing_moment = @chords[t].moment
            if existing_moment && existing_moment != moment
              raise ChordMomentMismatchError.new(
                "Will not merge chords from different moments. #{existing_moment} != #{moment}"
              )
            end

            @chords[t] = @chords[t].merge(
              Chord.new(moment: moment).tap { |chord|
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
