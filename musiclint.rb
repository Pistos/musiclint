require 'bigdecimal'
require 'nokogiri'
require 'pp'

module MusicLint
  class Score
    def [](measure_number)
      @measures[measure_number]
    end

    def initialize(xml_doc:)
      @measures = Hash.new { |h,k| h[k] = Measure.new }

      xml_doc.xpath('//part').each do |part_node|
        part_node.xpath('measure').each do |measure_node|
          measure_number = measure_node.attribute('number').content.to_i
          measure = @measures[measure_number]
          measure.parse(measure_node: measure_node, part_node: part_node)
        end
      end
    end

    def chords
      @measures.values.map(&:chords).flatten
    end
  end

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

  # TODO: Maybe we should generate all piano Pitches ahead of time.
  #   This stuff is all static.
  class Pitch
    STEP_TO_INT = {
      'C' => 0,
      'D' => 2,
      'E' => 4,
      'F' => 5,
      'G' => 7,
      'A' => 9,
      'B' => 11,
    }

    attr_reader :to_i, :to_s

    def initialize(xml_node:)
      @octave = xml_node.at('octave').content.to_i
      alter_node = xml_node.at('alter')
      if alter_node
        alter = alter_node.content.to_i
      else
        alter = 0
      end
      step = xml_node.at('step').content

      @to_i = @octave * 12 + STEP_TO_INT[step] + alter
      @to_s = "#{step}#{@octave}"
    end
  end

  class Note
    attr_reader :duration, :pitch, :voice

    def initialize(part_id:, xml_node:)
      @duration = BigDecimal(xml_node.at('duration').content)
      pitch_node = xml_node.at('pitch')
      if pitch_node
        @pitch = Pitch.new(xml_node: pitch_node)
        @rest = false
      elsif xml_node.xpath('rest')
        @rest = true
      end
      xml_voice = xml_node.at('voice').content.to_i
      @voice = "#{part_id}-#{xml_voice}"
    end

    def rest?
      @rest
    end

    def to_s
      pitch.to_s
    end
  end

  class Interval
    def -(other_interval)
      self.to_i - other_interval.to_i
    end

    def initialize(note1, note2)
      @note1 = note1
      @note2 = note2
    end

    def inspect
      "#{@note1}-#{@note2} #{to_i}"
    end

    def perfect?
      [5, 7, 12].include? to_i
    end

    def to_i
      @note2.pitch.to_i - @note1.pitch.to_i
    end

    def to_s
      to_i.to_s
    end

    def voices
      [@note1.voice, @note2.voice]
    end
  end

  class NilInterval
    def perfect?
      nil
    end
  end

  class Chord
    attr_reader :location

    def [](index)
      notes[index]
    end

    def add_note(note)
      @notes[note.voice] = note
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
              _intervals[ [v1, v2] ] = Interval.new(
                @notes[v1],
                @notes[v2]
              )
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

  class NilChord
    def intervals
      Hash.new(NilInterval.new)
    end

    def note_by(voice:)
      nil  # NilNote.new
    end

    def notes
      []
    end

    def to_s
      nil
    end
  end

  class Problem
    ERROR_TYPE = 'error'
    WARNING_TYPE = 'warning'

    def initialize(
      details:,
      location:,
      name:,
      type:
    )
      @details = details
      @location = location
      @name = name
      @type = type
    end

    def to_s
      "%-24s  %-8s  %-40s  %s" % [@location, @type, @details, @name]
    end
  end

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
            next_int = next_intervals[voices]

            if int.perfect? && next_int.perfect?
              problems << Problem.new(
                details: 'Consecutive perfect intervals',
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

  class App
    def initialize
      doc = Nokogiri::XML(
        IO.read(ARGV[0])
      )
      @score = Score.new(xml_doc: doc)
    end

    def run
      problems = []
      rules = [
        Rules::NoConsecutivePerfectIntervals,
      ]

      rules.each do |rule|
        problems += rule.check(@score)
      end

      problems.each do |problem|
        puts problem
      end
    end
  end
end

MusicLint::App.new.run
