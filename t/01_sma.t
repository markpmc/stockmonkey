
use Test;

plan tests => 5;

use Math::Business::SMA; ok 1;

$sma = new Math::Business::SMA;

$sma->set_days(3);

$sma->insert( 3 ); ok !defined($sma->query);
$sma->insert( 8 ); ok !defined($sma->query);
$sma->insert( 9 ); ok($sma->query, ((3 + 8 + 9)/3.0) );
$sma->insert( 7 ); ok($sma->query, ((8 + 9 + 7)/3.0) );
