package MarpaX::Simple::Rules;
use strict;

our $VERSION='0.2.0';

use Marpa::XS;
use parent 'Exporter';

our @EXPORT_OK = qw/parse_rules/;

sub Rules { shift; return \@_; } 
sub Rule { shift; return { @{$_[0]}, @{$_[2]} }; }
sub RuleWithAction { shift; return { @{$_[0]}, @{$_[2]}, action => $_[4] }; }
sub Lhs { shift; return [lhs => $_[0]];}
sub Rhs { shift; return [rhs => $_[0]];}
sub Star { shift; return [rhs => [ $_[0] ], min => 0]; }
sub Plus { shift; return [rhs => [ $_[0] ], min => 1]; }
sub Names { shift; return [@_];}
sub Null { shift; return [rhs => []]; }

sub parse_rules {
    my ($string) = @_;

    my $grammar = Marpa::XS::Grammar->new({
        start   => 'Rules',
        actions => __PACKAGE__,
        
        rules => [
            { lhs => 'Rules',     rhs => [qw/Rule/],                min => 1 },
            { lhs => 'Rule',      rhs => [qw/Lhs ::= Rhs/],         action => 'Rule' },
            { lhs => 'Rule',      rhs => [qw/Lhs ::= Rhs => Name/], action => 'RuleWithAction' },
            { lhs => 'Lhs',       rhs => [qw/Name/] },
            { lhs => 'Rhs',       rhs => [qw/Names/] },
            { lhs => 'Rhs',       rhs => [qw/Name +/],              action => 'Plus' },
            { lhs => 'Rhs',       rhs => [qw/Name */],              action => 'Star' },
            { lhs => 'Rhs',       rhs => [qw/Null/],                action => 'Null' },
            { lhs => 'Names',     rhs => [qw/Name/],                min => 1 },
        ],

        lhs_terminals => 0,
    });
    $grammar->precompute;

    my $rec = Marpa::XS::Recognizer->new({grammar => $grammar});

    my @tokens = split /\s+/, $string;
    for (@tokens) {
        next if m/^\s*$/;

        if (m/^::=$/) {
            $rec->read('::=');
        }
        elsif (m/^Null$/) {
            $rec->read('Null');
        }
        elsif (m/^=>$/) {
            $rec->read('=>');
        }
        elsif (m/^[+]$/) {
            $rec->read('+');
        }
        elsif (m/^[*]$/) {
            $rec->read('*');
        }
        elsif (m/^(\w+)$/) {
            $rec->read('Name', $1);
        }
        elsif (m/^(\w+)([+*]?)$/) {
            $rec->read('Name', $1);
            $rec->read($2, $2);
        }
    }

    $rec->end_input;
    my $rules = ${$rec->value};

    return $rules;
}

1;

__END__

=head1 NAME

MarpaX::Simple::Rules - Simple definition language for rules

=head1 SYNOPSYS

    use Marpa::XS;
    use MarpaX::Simple::Rules 'parse_rules';

    my $rules = parse_rules(<<"RULES");
    Parser     ::= Expression      => Action_1
    Expression ::= Expression      => Action_2
    RULES

    my $grammar = Marpa::XS::Grammar->new({
        start => 'Parser',
        rules => $rules,
    });

=head1 DESCRIPTION

MarpaX::Simple::Rules is a specification language that allows us to write the
parameter for the rules argument of Marpa::XS grammar as a string.

The goal is to provide a language that will let you create all possible ways
that rules can be written in a short and simple way.

=head1 SEE ALSO

L<Marpa::XS>

=head1 HOMEPAGE

L<http://github.com/pstuifzand/MarpaX-Simple-Rules>

=head1 LICENSE 

This library is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 AUTHOR

Peter Stuifzand E<lt>peter@stuifzand.euE<gt>

=head1 COPYRIGHT

Copyright (c) 2012 Peter Stuifzand.  All rights reserved.

=cut

