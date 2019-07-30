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

    def chord_at(measure_number:, time: 0)
      @measures[measure_number].chord_at(time)
    end
  end

  class Measure
    attr_reader :number

    def parse(measure_node:, part_node:)
      part_id = part_node.attribute('id').content

      notes = measure_node.xpath('note').map { |n|
        Note.new(part_id: part_id, xml_node: n)
      }
      @number ||= measure_node.attribute('number').content.to_i

      times = Set.new
      times << 0
      @notes ||= Hash.new { |h, k| h[k] = [] }

      total_duration = Hash.new(0)
      index = 0

      notes.each do |note|
        voice = "#{part_id}-#{note.voice}"
        total_duration[voice] += note.duration
        time = total_duration[voice]
        times << time
        @notes[time] << note
      end
    end

    def chord_at(time)
      Chord.new.tap { |chord|
        @notes[time].each do |note|
          chord.add_note(note)
        end
      }
    end
  end

  class Pitch
    def initialize(xml_node:)
      @octave = xml_node.at('octave').content
      @step = xml_node.at('step').content
    end

    def to_s
      "#{@step}#{@octave}"
    end
  end

  class Note
    attr_reader :duration, :pitch, :voice

    def initialize(part_id:, xml_node:)
      @duration = xml_node.at('duration').content.to_i
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

  class Chord
    def initialize
      @notes = {}
    end

    def add_note(note)
      @notes[note.voice] = note
    end

    def voices
      @notes.keys
    end

    def to_s
      voices.sort.reverse.map { |voice|
        @notes[voice].to_s
      }.join('-')
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
      c = @score.chord_at(measure_number: 1, time: ARGV[1].to_i)
      puts c
    end
  end
end

MusicLint::App.new.run
