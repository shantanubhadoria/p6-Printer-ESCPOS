use v6;
use Printer::ESCPOS;

class Printer::ESCPOS::Network is IO::Socket::Async is Printer::ESCPOS {
  method write() returns Bool {
    self.print("Hello, async Printer\n\n\n\n\n\n");
    return True;
  }
}
