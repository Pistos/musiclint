require 'factories/note'
require 'musiclint/chord'

describe MusicLint::Chord do
  let(:location) { 'some location' }
  let(:chord) { MusicLint::Chord.new(location: location) }

  describe "#add_note" do
    context "given a note" do
      let(:n1) { Factories::Note.create(step: 'C', octave: 4, voice: '1') }
      let(:n2) { Factories::Note.create(step: 'F', octave: 3, voice: '2') }

      it "adds a note to the chord" do
        expect(chord.to_s).to eq ''
        chord.add_note n1
        expect(chord.to_s).to eq 'C4'
        chord.add_note n2
        expect(chord.to_s).to eq 'F3-C4'
      end
    end
  end
end
