require 'factories/note'
require 'musiclint/chord'

describe MusicLint::Chord do
  let(:location) { 'some location' }
  let(:chord) { MusicLint::Chord.new(location: location) }
  let(:n1) { Factories::Note.create(step: 'C', octave: 4, voice: '1') }
  let(:n2) { Factories::Note.create(step: 'F', octave: 3, voice: '2') }
  let(:n3) { Factories::Note.create(step: 'G', octave: 3, voice: '3') }
  let(:n4) { Factories::Note.create(step: 'E', octave: 4, voice: '4') }

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

  context "given two chords" do
    let(:chord1) { chord }
    let(:location2) { 'some other location' }
    let(:chord2) { MusicLint::Chord.new(location: location2) }

    before do
      chord1.add_note n1
      chord1.add_note n2
      chord2.add_note n3
      chord2.add_note n4
    end

    describe "#merge" do
      it "returns a chord contain the notes of both chords" do
        merged = chord1.merge(chord2)
        expect(merged.notes).to eq [n2, n3, n1, n4]
      end

      it "does not change either chord" do
        expect {
          chord1.merge(chord2)
        }.not_to change { chord1 }

        expect {
          chord1.merge(chord2)
        }.not_to change { chord2 }
      end
    end
  end
end
