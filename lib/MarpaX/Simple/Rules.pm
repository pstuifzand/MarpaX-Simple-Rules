package MarpaX::Simple::Rules;
use strict;

use Marpa::XS;
use parent 'Exporter';

our @EXPORT_OK = qw/parse_rules/;

sub Rules {shift; return \@_; } 
sub Rule {shift;return { @{$_[0]}, @{$_[2]} }; }
sub RuleWithAction {shift;return { @{$_[0]}, @{$_[2]}, action => $_[4] }; }
sub Lhs {shift;return [lhs => $_[0]];}
sub Rhs {shift;return [rhs => $_[0]];}
sub Star {
    shift;
    return [rhs => $_[0], min => 0];
}
sub Plus {
    shift;
    return [rhs => $_[0], min => 1];
}
sub Names {shift;return [@_];}
sub Null { shift; return [rhs => []]; }

sub parse_rules {
    my ($string) = @_;

    my $grammar = Marpa::XS::Grammar->new({
        start   => 'Rules',
        actions => __PACKAGE__,
        
        rules => [
            { lhs => 'Rules',     rhs => [qw/Rule/], min => 1 },
            { lhs => 'Rule',      rhs => [qw/Lhs DeclareOp Rhs/], action => 'Rule' },
            { lhs => 'Rule',      rhs => [qw/Lhs DeclareOp Rhs Arrow Name/], action => 'RuleWithAction' },
            { lhs => 'Lhs',       rhs => [qw/Name/] },
            { lhs => 'Rhs',       rhs => [qw/Names/] },
            { lhs => 'Rhs',       rhs => [qw/Name Plus/], action => 'Plus' },
            { lhs => 'Rhs',       rhs => [qw/Name Star/], action => 'Star' },
            { lhs => 'Rhs',       rhs => [qw/Null/],      action => 'Null' },
            { lhs => 'Names',     rhs => [qw/Name/], min => 1 },
        ],

        lhs_terminals => 0,
    });
    $grammar->precompute;

    my $rec = Marpa::XS::Recognizer->new({grammar => $grammar});

    while ($string) {
        $string =~ s/^\s+//;
        print $string;

        if ($string =~ s/^::=//) {
            $rec->read('DeclareOp');
        }
        elsif ($string =~ s/^Null//) {
            $rec->read('Null');
        }
        elsif ($string =~ s/^=>//) {
            $rec->read('Arrow');
        }
        elsif ($string =~ s/^\+//) {
            $rec->read('Plus');
        }
        elsif ($string =~ s/^\*//) {
            $rec->read('Star');
        }
        elsif ($string =~ s/^(\w+)//) {
            $rec->read('Name', $1);
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

=cut

