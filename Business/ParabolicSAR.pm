package Math::Business::ParabolicSAR;

use strict;
use warnings;
use Carp;
use constant {
    LONG  => 7,
    SHORT => 9,
    HP    => 1,
    LP    => 0,
};

our $VERSION = 1.0;

1;

sub recommended {
    my $class = shift;
       $class->new(0.02, 0.20);
}

sub new {
    my $class = shift;
    my $this  = bless {e=>[], y=>[]}, $class;

    if( @_ ) {
       eval { $this->set_alpha(@_) };
       croak $@ if $@;
    }

    return $this;
}

sub set_alpha {
    my $this = shift;
    my ($as,$am) = @_;

    croak "set_alpha(as,am) takes two arguments, the alpha start (0<as<1) and the alpha max (0<as<am<1)"
        unless 0 < $as and $as < $am and $am < 1;

    $this->{as} = $as;
    $this->{am} = $am;

    return;
}

sub insert {
    my $this = shift;

    my ($as,$am);
    croak "must set_alpha(as,am) before inserting data" unless defined( $am = $this->{am} ) and defined( $as = $this->{as} );

    my ($y_low, $y_high) = @{$this->{y}};
    my ($open,$high,$low,$close);

    my $S;
    my $P = $this->{S};
    my $A = $this->{A};
    my $e = $this->{e};

    my $ls = $this->{ls};

    while( defined( my $ar = shift ) ) {
        croak "arguments to insert must be four touples (open,high,low,close)"
            unless ref($ar) eq "ARRAY" and @$ar==4 and $ar->[2]<$ar->[1];

        # NOTE: we really only use open and close to initialize ...
        ($open,$high,$low,$close) = @$ar;

        if( defined $ls ) {
            $e->[HP] = $high if $high > $e->[HP]; # the highest point during the trend
            $e->[LP] = $low  if $low  < $e->[LP]; # the  lowest point during the trend

            # calculate sar_t
            # The Encyclopedia of Technical Market Indicators - Page 495

            if( $ls == LONG ) {
                $S = $P + $A*($e->[HP] - $P); # adjusted upwards from the reset like so

                if( $S > $low or $S > $y_low ) {
                    $S = $e->[HP];
                    $A = $as;

                    $e->[HP] = ($high>$y_high ? $high : $y_high);
                    $e->[LP] = ($low <$y_low  ? $low  : $y_low );

                } else {
                    $A += $as;
                    $A = $am if $A > $am;
                }

            } else {
                $S = $P - $A*($e->[LP] - $P); # adjusted downwards from the reset like so

                if( $S < $high or $S < $y_high ) {
                    $S = $e->[LP];
                    $A = $as;

                    $e->[HP] = ($high>$y_high ? $high : $y_high);
                    $e->[LP] = ($low <$y_low  ? $low  : $y_low );

                } else {
                    $A += $as;
                    $A = $am if $A > $am;
                }
            }


        } else {
            # initialize somehow
            # (never did find a good description of how to initialize this mess,
            #   I think you're supposed to tell it how to start)
            # this is the only time we use open/close and it's not even in the definition

            if( $open < $close ) {
                $ls = LONG;
                $S  = $low;

            } else {
                $ls = SHORT;
                $S  = $high;
            }

            $e->[HP] = $high;
            $e->[LP] = $low;
        }

        $P = $S;

        ($y_low, $y_high) = ($low, $high);
    }

    $this->{S} = $S;
    $this->{A} = $A;

    @{$this->{y}} = ($y_low, $y_high);
}

sub start_with {
    my $this = shift;

    die "todo";
}

sub query {
    my $this = shift;

    $this->{S};
}

__END__

=head1 NAME

Math::Business::ParabolicSAR - Technical Analysis: Stop and Reversal (aka SAR)

=head1 SYNOPSIS

  use Math::Business::ParabolicSAR;

  my $sar = new Math::Business::ParabolicSAR;
     $sar->set_alpha(0.02, 0.2);

  # alternatively/equivilently
  my $sar = new Math::Business::ParabolicSAR(0.02, 0.2);

  # or to just get the recommended model ... (0.02, 0.2)
  my $sar = Math::Business::ParabolicSAR->recommended;

  my @data_points = (
      ["35.0300", "35.1300", "34.3600", "34.3900"],
      ["34.6400", "35.0000", "34.2100", "34.7400"],
      ["34.6900", "35.1400", "34.3800", "34.7900"],
      ["35.2900", "35.7900", "35.0800", "35.5200"],
      ["35.9000", "36.0600", "35.7500", "36.0600"],
      ["36.1300", "36.7200", "36.0500", "36.5800"],
      ["36.4100", "36.6400", "36.2600", "36.6100"],
      ["36.3500", "36.5500", "35.9400", "35.9700"],
  );

  # choose one:
  $sar->insert( @data_points );
  $sar->insert( $_ ) for @data_points;

  my $sar = $sar->query;
  print "SAR: $sar\n";

  # you may use this to kick start
  # TODO $sar->start_with($aPDM, $aMDM, $adx;

=head1 RESEARCHER

The Parabolic Stop and Reversal was designed by J. Welles Wilder Jr circa 1978.

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

perl(1)

L<http://en.wikipedia.org/wiki/Parabolic_SAR>

The Encyclopedia of Technical Market Indicators - Page 495

=cut
