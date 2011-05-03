package Geo::Postcodes::NO::Fresh::Injection::LexicalSnatcher;

use strict;
use PadWalker 'peek_my';

sub TIESCALAR {
  my ($class, $callback) = @_;
  return bless { callback => $callback }, $class;
}
sub FETCH {
  my $self = shift;
  $self->{callback}(peek_my(1));
  return;
}


package Geo::Postcodes::NO::Fresh::Injection;

use strict;
use Geo::Postcodes::NO;
use File::ShareDir ':ALL';
use File::Spec::Functions;
use Storable;

my @types = (qw/borough_number type location borough/);
my $data = load_file();

sub load_file {
  my $file = '/tmp/postcode-data';
  return retrieve($file);
}


my $snatcher;
tie($snatcher, 'Geo::Postcodes::NO::Fresh::Injection::LexicalSnatcher',
    sub {
      my $peek = shift;
      foreach my $t (@types) {
        if (keys %{$peek->{'%'.$t}} && $data->{$t}) {
          %{$peek->{'%'.$t}} = %{$data->{$t}};
        }
      }
    });



#
# These methods are called in void context only to inject the sneaky
# snatcher in the lexical scope of the method to replace the data with
# our data.
#

Geo::Postcodes::NO::type_of($snatcher); 
Geo::Postcodes::NO::borough_number2borough($snatcher);
Geo::Postcodes::NO::location_of($snatcher);
Geo::Postcodes::NO::borough_number_of($snatcher);


1;
