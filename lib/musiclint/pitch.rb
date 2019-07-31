module MusicLint
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
    ACCIDENTAL_FOR = {
      -2 => 'bb',
      -1 => 'b',
      0 => '',
      1 => '#',
      2 => '##',
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
      accidental = ACCIDENTAL_FOR[alter]

      display_step = "#{step}#{accidental}"

      @to_i = @octave * 12 + STEP_TO_INT[step] + alter
      @to_s = "#{display_step}#{@octave}"
    end
  end
end
