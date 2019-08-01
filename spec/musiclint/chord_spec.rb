require 'factories/note'
require 'musiclint/chord'

describe MusicLint::Chord do
  let(:location) { 'some location' }
  let(:chord) { MusicLint::Chord.new(location: location) }
  let(:n1) { Factories::Note.create(step: 'C', octave: 4, voice: '1') }
  let(:n2) { Factories::Note.create(step: 'F', octave: 3, voice: '2') }
  let(:n3) { Factories::Note.create(step: 'G', octave: 3, voice: '3') }

  describe "#add_note" do
    it "adds a note to the chord" do
      expect(chord.to_s).to eq ''
      chord.add_note n1
      expect(chord.to_s).to eq 'C4'
      chord.add_note n2
      expect(chord.to_s).to eq 'F3-C4'
    end
  end

  context "given a chord with notes" do
    before do
      chord.add_note n1
      chord.add_note n2
      chord.add_note n3
    end

    describe "#notes" do
      it "returns the notes in ascending order by pitch" do
        expect(chord.notes).to eq [
          n2,
          n3,
          n1,
        ]
      end
    end
  end
end
