use v6;

use lib 'lib';;
use Printer::ESCPOS::Network;

await Printer::ESCPOS::Network.connect('10.0.13.108', 9100).then( -> $p {
  if $p.status {
    given $p.result {
      .init;
      #.textSize(height => 3, width => 2);
      #.barcode("TEST", system => 'CODE93');
      #.lf;
      .leftMargin(260);
      .print('margin 1');
      #.lf;

      .leftMargin(20);
      #.print('margin 2');
      #.lf;

      #.cutPaper;
      .lf;
      .close;
    }
  }
});

=begin pod

=head2 ss

await IO::Socket::Async.connect('10.0.13.108', 9100).then( -> $p {
  if $p.status {
    given $p.result {
      .print("Hello, Perl 6\n\n\n\n\n\n");
      react {
        whenever .Supply() -> $v {
          $v.say;
          done;
        }
      }
      .close;
    }
  }
});

=cut


=end pod
