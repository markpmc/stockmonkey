package Math::Business::WMA;

use strict;
use warnings;
use Carp;
use Math::Business::SMA;

our $VERSION = 1.0;

1;

sub recommended { croak "no recommendation" }

sub new { 
    my $class = shift;
    my $this  = bless [], $class;

    my $days = shift;
    if( defined $days ) {
        $this->set_days( $days );
    }

    return $this;
}

sub set_days { 
    my $this = shift; 
    my $arg  = int(shift);

    croak "days must be a positive non-zero even integer" if $arg <= 0 or ($arg/2) =~ m/\./;
    @$this = (
        $arg,
        $arg*($arg+1)/2,
        [],     # the data (we actually need to store it, although we can avoid calculating much of it)
        undef,  # the sum of the data
        undef,  # the the last numerator
        undef,  # the WMA
    );
}

sub insert {
    my $this = shift;
    my ($N, $D, $dat, $total_m, $numerator_m, $EMA) = @$this;

    croak "You must set the number of days before you try to insert" if not defined $N;
    while( defined( my $P = shift ) ) {
        push @$dat, $P;

        if( @$dat > $N ) {
            my $old = shift @$dat;

            $numerator_m = $numerator_m + $P*$N - $total_m;
                $total_m =     $total_m + $P - $old;
        }
    }

    @$this = ($N, $D, $dat, $total_m, $numerator_m, $numerator_m/$D);
}

sub query {
    my $this = shift;

    return $this->[-1];
}

__END__

=head1 NAME

Math::Business::WMA - Technical Analysis: Hull Moving Average

=head1 SYNOPSIS

  use Math::Business::WMA;

  my $avg = new Math::Business::WMA;
     $avg->set_days(8);

  my @closing_values = qw(
      3 4 4 5 6 5 6 5 5 5 5 
      6 6 6 6 7 7 7 8 8 8 8 
  );

  # choose one:
  $avg->insert( @closing_values );
  $avg->insert( $_ ) for @closing_values;

  if( defined(my $q = $avg->query) ) {
      print "value: $q.\n";  

  } else {
      print "value: n/a.\n";
  }

For short, you can skip the set_days() by suppling the setting to new():

  my $longer_avg = new Math::Business::WMA(10);

=head1 AUTHOR

Paul Miller <jettero@cpan.org>

I am using this software in my own projects...  If you find bugs, please please
please let me know.

I normally hang out on #perl on freenode, so you can try to get immediate
gratification there if you like.  L<irc://irc.freenode.net/perl>

=head1 COPYRIGHT

Copyright (c) 2008 Paul Miller -- LGPL [Software::License::LGPL_2_1]

    perl -MSoftware::License::LGPL_2_1 \
         -e '$l = Software::License::LGPL_2_1->new({
             holder=>"Paul Miller"});
             print $l->fulltext' | less

=head1 SEE ALSO

perl(1), L<Math::Business::StockMonkey>, L<Math::Business::StockMonkey::FAQ>, L<Math::Business::StockMonkey::CookBook>

L<http://www.alanhull.com.au/wma/wma.html>

=cut