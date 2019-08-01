require 'musiclint/measure'

module MusicLint
  class Score
    def [](measure_number)
      @measures[measure_number]
    end

    def initialize(xml_doc:)
      @measures = {}

      xml_doc.xpath('//part').each do |part_node|
        divisions = nil

        part_node.xpath('measure').each do |measure_node|
          part_id = part_node.attribute('id').content

          measure_number = measure_node.attribute('number').content.to_i
          @measures[measure_number] ||= Measure.new(divisions: divisions)
          divisions = @measures[measure_number].parse(measure_node: measure_node, part_id: part_id)
        end
      end
    end

    def chords
      @measures.values.map(&:chords).flatten
    end
  end
end
