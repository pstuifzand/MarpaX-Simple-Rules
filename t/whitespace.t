
use Test::More;

use MarpaX::Simple::Rules 'parse_rules';

{
    my $rules = parse_rules("");
    is_deeply($rules, []);
}

{
    my $rules = parse_rules(" ");
    is_deeply($rules, []);
}

{
    my $rules = parse_rules(" \t ");
    is_deeply($rules, []);
}

{
    my $rules = parse_rules(<<"RULES");
    \t

RULES
    is_deeply($rules, []);
}

{
    eval {
        parse_rules(<<"RULES");
abc
RULES
    };
    unlike($@, qr/Can't use an undefined value as a SCALAR reference/);
    like($@, qr/Missing "::=" operator/);
}

{
    eval {
        parse_rules(<<"RULES");
::= 
RULES
    };
    unlike($@, qr/Can't use an undefined value as a SCALAR reference/);
    like($@, qr/Missing name left of "::=" operator/);
}

{
    eval {
        parse_rules(<<"RULES");
::= hello world
RULES
    };
    unlike($@, qr/Can't use an undefined value as a SCALAR reference/);
    like($@, qr/Missing name left of "::=" operator/);
}

# No whitespace around operator
{
    eval {
        parse_rules(<<"RULES");
a::=b
RULES
    };
    unlike($@, qr/Can't use an undefined value as a SCALAR reference/);
    like($@, qr/Can't parse/);
}
done_testing();

