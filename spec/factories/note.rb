require 'nokogiri'
require 'musiclint/note'

module Factories
  class Note
    def self.create(
      duration: 1,
      step: 'C',
      octave: 4,
      type: 'quarter',
      voice: '1'
    )
      MusicLint::Note.new(
        part_id: "P1",
        xml_node: Nokogiri::XML(%{
          <note default-x="82.47" default-y="-15.00">
            <duration>#{duration}</duration>
            <pitch>
              <step>#{step}</step>
              <octave>#{octave}</octave>
            </pitch>
            <stem>up</stem>
            <type>#{type}</type>
            <voice>#{voice}</voice>
          </note>
        })
      )
    end
  end
end
