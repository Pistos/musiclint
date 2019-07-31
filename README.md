# MusicLint

A script which checks MusicXML files for harmony (voice leading) errors.

MusicXML format can be exported from most music notation software.  See
https://www.musicxml.com/software/ for a list.

## Requirements

* Ruby 2.4+

## Setup

    bundle install

## Usage

    ./musiclint my-piece.musicxml

## Example Output

    measure 1, beat 1.0       error     Consecutive perfect intervals: C3-C5 (P8), D3-D5 (P8)  no-consecutive-perfect-intervals
    measure 1, beat 2.0       error     Consecutive perfect intervals: D3-D5 (P8), C3-C5 (P8)  no-consecutive-perfect-intervals
    measure 1, beat 3.0       error     Consecutive perfect intervals: C3-G3 (P5), F2-F3 (P8)  no-consecutive-perfect-intervals

        3 problems (3 errors, 0 warnings)
