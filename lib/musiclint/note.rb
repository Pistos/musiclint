require 'musiclint/pitch'

module MusicLint
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

    def staff_position
      @pitch&.staff_position
    end

    def step
      @pitch.step
    end

    def to_s
      pitch.to_s
    end
  end
end
