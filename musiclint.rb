require 'bigdecimal'
require 'nokogiri'
require 'pp'

module MusicLint
  class Score
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

    def [](measure_number)
      @measures[measure_number]
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

  class Pitch
    STEP_TO_INT = {
      'Ab' => 11,
      'A' => 0,
      'A#' => 1,
      'Bb' => 1,
      'B' => 2,
      'B#' => 3,
      'Cb' => 2,
      'C' => 3,
      'C#' => 4,
      'Db' => 4,
      'D' => 5,
      'D#' => 6,
      'Eb' => 6,
      'E' => 7,
      'E#' => 8,
      'Fb' => 7,
      'F' => 8,
      'F#' => 9,
      'Gb' => 9,
      'G' => 10,
      'G#' => 11,
    }

    def initialize(xml_node:)
      @octave = xml_node.at('octave').content.to_i
      @step = xml_node.at('step').content
    end

    def interval(other_pitch)
      other_pitch.to_i - self.to_i
    end

    def to_i
      @octave * 12 + STEP_TO_INT[@step]
    end

    def to_s
      "#{@step}#{@octave}"
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

    def notes
      voices.map { |voice|
        @notes[voice]
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
      puts chords[1]
      n1 = chords[1][0]
      n2 = chords[1][1]

      puts n1
      puts n2
      puts n1.interval(n2)
    end
  end
end

MusicLint::App.new.run
