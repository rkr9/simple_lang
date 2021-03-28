use Mouse;
use utf8;
use Kavorka;
use Regexp::Grammars;
#use Data::Dumper;

my %vars;

method AST::SimpleLang::X() {
    for my $element ( @{ $self->{Statement} } ) {
        $element->X();
    }
}

method AST::Statement::X() {
    (        $self->{Variable_Declaration}
          || $self->{Function_Call} )->X();
}

method AST::Variable_Declaration::X() {
    my $my       = $self->{My}->{''};
    my $variable = $self->{Variable_Name}->{''};
    my $value    = $self->{Value}->{''};
    if( $my eq 'my' ) {
        $vars{$variable} = $value;
    }
}

method AST::Function_Call::X() {
    my $func           = $self->{Func}->{''};
    my $variable_name  = $self->{Variable_Name}->{''};
    if( $func eq 'print') {
        print $vars{$variable_name} . "\n";
    }
}

#<debug: on>

my $Parser = qr {
    <nocontext:>

    <SimpleLang>

    <objrule:  AST::SimpleLang>              <[Statement]>+ % ;
    <objrule:  AST::Statement>               <Variable_Declaration> | <Function_Call>

    <objrule:  AST::Variable_Declaration>    <My> <Variable_Name> = <Value>
    <objrule:  AST::Function_Call>           <Func> <Variable_Name>

    <objtoken: Variable_Name>                [a-z]+
    <objtoken: Value>                        [0-9]+

    <objtoken: My>                           my
    <objtoken: Func>                         print

}xms;


fun parse($string) {
    if( $string =~ $Parser ) {
        $/{SimpleLang}->X();
    }
}

parse('my x = 23; print x; my y = 12; print y;')
