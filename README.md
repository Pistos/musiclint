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

    measure 1, beat 1.0       error     Consecutive perfect intervals             no-consecutive-perfect-intervals
    measure 1, beat 2.0       error     Consecutive perfect intervals             no-consecutive-perfect-intervals
    measure 1, beat 3.0       error     Consecutive perfect intervals             no-consecutive-perfect-intervals

        3 problems (3 errors, 0 warnings)
