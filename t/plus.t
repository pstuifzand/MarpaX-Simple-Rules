use lib 'lib';

use Test::More;
use MarpaX::Simple::Rules 'parse_rules';

my $rules = parse_rules(<<"RULES");

xx        ::= y*
bb        ::= b+

RULES

is_deeply($rules, [
    { lhs => 'xx', rhs => [ qw/y/ ], min => 0 },
    { lhs => 'bb', rhs => [ qw/b/ ], min => 1 },
]);

done_testing();

