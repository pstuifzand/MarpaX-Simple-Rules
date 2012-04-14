## NAME

MarpaX::Simple::Rules - Simplest way to create Marpa::XS rules.

## SYNOPSYS

    use Marpa::XS;
    use MarpaX::Simple::Rules 'parse_rules';
    
    my $rules = parse_rules(<<"RULES");
    expression  ::= term                => return_0
    term        ::= factor              => return_0
    term        ::= term plus term      => plus
    factor      ::= number              => return_0
    factor      ::= factor mul factor   => mul
    RULES
    
    my $grammar = Marpa::XS::Grammar->new({
        start => 'expression',
        rules => $rules,
        ...
    });


## FUNCTIONS

### `$rules = parse_rules(STRING)`

Parses a string containing a grammar description. Returns the rules in the form
that Marpa::XS::Grammar uses.


## SEE ALSO

[Marpa::XS](http://metacpan.org/release/Marpa-XS)


## AUTHOR

Peter Stuifzand

## LICENSE

Same as Perl5.

## COPYRIGHT

Peter Stuifzand 2012

