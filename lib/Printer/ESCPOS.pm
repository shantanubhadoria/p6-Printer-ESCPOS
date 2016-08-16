use v6;

class Printer::ESCPOS {

  subset Byte of Int where {
    0 <= $_ and $_ <= 255 or warn 'Byte must be a Int between 0 and 255';
  };

  subset Font of Int where {
    0 <= $_ <= 2 or warn 'Font must be a Int 0, 1 or 2';
  };

  subset HalfByte of Int where {
    0 <= $_ and $_ <= 15 or warn 'HalfByte must be a Int between 0 and 15';
  };

  subset TwoByte of Int where {
    0 <= $_ and $_ <= 65535 or warn 'Byte must be a Int between 0 and 255';
  };


  # Level 1 constants
  constant ESC = "\x1b";
  constant GS  = "\x1d";
  constant DLE = "\x10";
  constant FS  = "\x1c";

  # Level 2 constants
  constant FF  = "\x0c";
  constant SP  = "\x20";
  constant EOT = "\x04";
  constant DC4 = "\x14";


  subset Alignment of Str where {
    lc $_ ∈ <left right center full> or warn 'Alignment must be "left", "right", "center" or "full"';
  };
  method align(Alignment $alignment) {

    my %alignmentMap = left   => 0,
                       center => 1,
                       right  => 2,
                       full   => 3;
    self.print( ESC ~ 'a' ~ %alignmentMap{lc $alignment} );
  }

  subset BarcodeTextPosition of Str where {
    $_ ∈ <none above below aboveandbelow>
      or warn 'Barcode TextPosition must be "none", "above", "below" or "aboveandbelow"';
  };
  subset BarcodeSystem of Str where {
    $_ ∈ <UPC-A UPC-E JAN13 JAN8 CODE39 ITF CODABAR CODE93 CODE128>
      or warn 'Barcode System must be "UPC-A", "UPC-E", "JAN13", "JAN8", "CODE39", "ITF", "CODABAR", "CODE93" or "CODE128"';
  };
  method barcode(
    Str $text,
    BarcodeTextPosition :$textPosition = 'below',
    Font :$font = 0,
    Byte :$height = 50,
    Byte :$width = 2,
    BarcodeSystem :$system = 'CODE93') {


      my %barcodeSystemMap = UPC-A   => 0,
                             UPC-B   => 1,
                             JAN13   => 2,
                             JAN8    => 3,
                             CODE39  => 4,
                             ITF     => 5,
                             CODABAR => 6,
                             CODE93  => 7,
                             CODE128 => 8;

      my %barcodeTextPositionMap = none          => 0,
                                   above         => 1,
                                   below         => 2,
                                   aboveandbelow => 3;

      self.print( GS ~ 'H' ~ chr(%barcodeTextPositionMap{$textPosition}) );
      self.print( GS ~ 'f' ~ chr($font) );
      self.print( GS ~ 'h' ~ chr($height) );
      self.print( GS ~ 'w' ~ chr($width) );
      self.print( GS ~ 'k' ~ chr(%barcodeSystemMap{$system} + 65) );
      self.print( chr($text.chars) ~ $text);
  }

  method beep() {
    self.print( "\x07" );
  }

  method bold(Bool $bold) {
    self.print( ESC ~ 'E' ~ $bold.value ); # Get value for Bool as we need to pass a 1 or 0
  }

  method cancel() {
    self.print( "\x18" );
  }

  method charSpacing(Byte $charSpacing) {
    self.print( ESC ~ SP ~ chr($charSpacing) );
  }

  subset Color of Int where {
    0 <= $_ <= 7 or warn 'Color must be a Int between 0 and 7';
  };
  method color(Color $color) {
    self.print( ESC ~ 'r' ~ chr($color) );
  }

  method cr() {
    self.print( "\x0d" );
  }

  method cutPaper(Bool :$partialCut = False, Bool :$feed = True) {
    self.lf;

    my Int $value = $partialCut.value + 65 × $feed.value;
    say $feed;
    say $value;
    self.print( GS ~ 'V' ~ chr(66) ~ chr(1) );
  }

  method doubleStrike(Bool $doubleStrike) {
    self.print( ESC ~ 'G' ~ $doubleStrike.value ); # Get value for Bool as we need to pass a 1 or 0
  }

  method drawerKickPulse(Int :$pin where * ∈ (0, 1) = 0, Int :$time where [1..8] = 8) {
    self.print( DLE ~ DC4 ~ '\x01' ~ chr($pin) ~ chr($time) );
  }

  method enable(Bool $enable) {
    self.print( ESC ~ '=' ~ chr($enable.value) ); # Get value for Bool as we need to pass a 1 or 0
  }

  method ff() {
    self.print( "\x0c" );
  }

  method font(Font $font) {
    self.print( ESC ~ 'M' ~ $font );
  }

  method horizontalPosition(TwoByte $horizontalPosition where * < 4096 = 0) {

  }

  method init() {
    self.print( ESC ~ '@' );
  }

  method invert(Bool $invert) {
    self.print( GS ~ 'B' ~ chr($invert.value) ); # Get value for Bool as we need to pass a 1 or 0 ASCII
  }

  method leftMargin(TwoByte $leftMargin) {
    my ($nH, $nL) = self!splitBytes($leftMargin, 2);
    self.print( GS ~ 'L' ~ chr($nL) ~ chr($nH) );
  }

  method lf() {
    self.print( "\n" );
  }

  subset LineSpacingCommandSet of Str where {
    $_ ∈ <+ 3 A> or warn 'LineSpacing CommandSet must be "+", "3" or "A"';
  }
  method lineSpacing(Byte $lineSpacing, LineSpacingCommandSet $commandSet = '3' ) {
    if $commandSet eq 'A' and $lineSpacing > 85 {
      X::Adhoc.new('Line Spacing must be less than 85 when command set is "A".');
    }
    self.print( ESC ~ $commandSet ~ chr($lineSpacing) );
  }

  method rot90(Bool $rot90) {
    self.print( ESC ~ 'V' ~ chr($rot90.value) );
  }

  method tab() {
    self.print( "\t" );
  }

  method textSize(HalfByte :$height!, HalfByte :$width!) {
    my $size = $width +< 4 +| $height;
    self.print( GS ~ '!' ~ chr($size) );
  }

  subset Underline of Int where {
    0 <= $_  <= 2 or warn 'Underline must be a Int 0, 1 or 2';
  };
  method underLine(Underline $underLine) {
    self.print( ESC ~ '-' ~ $underLine );
  }

  method upsideDown(Bool $upsideDown) {
    self.print( ESC ~ '{' ~ $upsideDown.value );  # Get value for Bool as we need to pass a 1 or 0
  }

  method !splitBytes(Int $value is copy, Int $minBytes = 0) {
    my @byteArray = [];
    while ($value != 0 or (@byteArray.elems) < $minBytes) {
      @byteArray.unshift($value +& 255);
      $value +>= 8;
    }
    return @byteArray;
  }
}
