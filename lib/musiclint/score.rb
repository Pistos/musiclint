require 'musiclint/measure'

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
end
