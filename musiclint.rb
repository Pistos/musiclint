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

    def chord_at(measure_number:, time:)
      @measures[measure_number].chord_at(time)
    end

    def chords
      @measures.map(&:chords).flatten
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
      Chord.new.tap { |chord|
        @notes[BigDecimal(time)].each do |note|
          chord.add_note(note)
        end
      }
    end
  end

  # TODO: Maybe we should generate all piano Pitches ahead of time.
  #   This stuff is all static.
  class Pitch
    STEP_TO_INT = {
      'Cb' => -1,
      'C' => 0,
      'C#' => 1,
      'Db' => 1,
      'D' => 2,
      'D#' => 3,
      'Eb' => 3,
      'E' => 4,
      'E#' => 5,
      'Fb' => 4,
      'F' => 5,
      'F#' => 6,
      'Gb' => 6,
      'G' => 7,
      'G#' => 8,
      'Ab' => 8,
      'A' => 9,
      'A#' => 10,
      'Bb' => 10,
      'B' => 11,
      'B#' => 12,
    }

    attr_reader :to_i, :to_s

    def initialize(xml_node:)
      @octave = xml_node.at('octave').content.to_i
      @step = xml_node.at('step').content

      @to_i = @octave * 12 + STEP_TO_INT[@step]
      @to_s = "#{@step}#{@octave}"
    end

    def interval(other_pitch)
      other_pitch.to_i - self.to_i
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

    def interval(other_note)
      @pitch.interval(other_note.pitch)
    end

    def rest?
      @rest
    end

    def to_s
      pitch.to_s
    end
  end

  class Chord
    def [](index)
      notes[index]
    end

    def add_note(note)
      @notes[note.voice] = note
    end

    def initialize
      @notes = {}
    end

    def intervals
      vs1 = voices
      vs2 = vs1.dup

      Hash.new.tap { |_intervals|
        vs1.each_with_index do |v1, i|
          vs2.each_with_index do |v2, j|
            if j > i
              _intervals[ [v1, v2] ] = @notes[v1].interval( @notes[v2] )
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

  class App
    def initialize
      doc = Nokogiri::XML(
        IO.read(ARGV[0])
      )
      @score = Score.new(xml_doc: doc)
    end

    def run
      chords = @score[1].chords
      cn = ARGV[1].to_i
      puts chords[cn]
      pp chords[cn].intervals
    end
  end
end

MusicLint::App.new.run
