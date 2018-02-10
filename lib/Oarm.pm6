use Oarm::Table;
use Oarm::Column;
use Oarm::Exception;
use Oarm::Sql;
use Oarm::ResultSet;

class Oarm {};

# multi trait_mod:<is>(Mu:U $class, :$oarm_tabe) is export {
#     Oarm::X::Class.new(
#         class => $class.^name,
#         error => 'Cannot extend (use "is Oarm::Table(\'table\')" instead )'
#     ).throw;
# }

multi trait_mod:<is>(Mu:U $class, :$oarm_table!) is export {
    say "CLASS Trait:" ~ $class.^name ~ " for table ";
    my $classHOW = $class.HOW;
    $classHOW.add_role($class, Oarm::Table);
    $classHOW.^mixin: Oarm::TableHOW;
    $classHOW.oarm_init_table($oarm_table.hash);
}

multi trait_mod:<is>(Attribute $a, :$has_one!) is export  {
    say "HAS ONE Trait: " ~ $a;
}

multi trait_mod:<is>(Attribute $a, :$column!) is export  {
    say "COLUMN Trait: " ~ $a;
    $a.^mixin: Oarm::ColumnHOW;
    if ($column ~~ Bool) {
        $a.oarm_init_column({});
    } else {
        $a.oarm_init_column($column.hash);
    }
}
