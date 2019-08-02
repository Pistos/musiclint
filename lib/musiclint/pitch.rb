module MusicLint
  # TODO: Maybe we should generate all piano Pitches ahead of time.
  #   This stuff is all static.
  class Pitch
    STEP_TO_STAFF_POSITION = {
      'C' => 1,
      'D' => 2,
      'E' => 3,
      'F' => 4,
      'G' => 5,
      'A' => 6,
      'B' => 7,
    }
    STEP_TO_INT = {
      'C' => 0,
      'D' => 2,
      'E' => 4,
      'F' => 5,
      'G' => 7,
      'A' => 9,
      'B' => 11,
    }
    ACCIDENTAL_FOR = {
      -2 => 'bb',
      -1 => 'b',
      0 => '',
      1 => '#',
      2 => '##',
    }

    attr_reader :staff_position, :to_i, :to_s

    def <=>(other_pitch)
      @to_i <=> other_pitch.to_i
    end

    def initialize(xml_node:)
      parsed = parse(xml_node: xml_node)

      alter = parsed[:alter]
      step = parsed[:step]
      accidental = ACCIDENTAL_FOR[alter]
      display_step = "#{step}#{accidental}"

      @octave = parsed[:octave]
      @staff_position = @octave * 7 + STEP_TO_STAFF_POSITION[step]
      @to_i = @octave * 12 + STEP_TO_INT[step] + alter
      @to_s = "#{display_step}#{@octave}"
    end

    private def parse(xml_node:)
      {
        alter: xml_node.at('alter')&.content.to_i,
        octave: xml_node.at('octave').content.to_i,
        step: xml_node.at('step').content,
      }
    end
  end
end
