use Oarm::Table;
use Oarm::Column;
use Oarm::Exception;
use Oarm::Sql;
use Oarm::ResultSet;

class Oarm {};

multi trait_mod:<is>(Mu:U $class, Oarm::Table:U $aspect!) is export {
    Oarm::X::Class.new(
        class => $class.^name,
        error => 'Cannot extend (use "is Oarm::Table(\'table\')" instead )'
    ).throw;
}

multi trait_mod:<is>(Mu:U $class, Oarm::Table:U $aspect!, Str $table) is export {
    say "CLASS Trait:" ~ $class.^name ~ " for table "~ $table;
    my $classHOW = $class.HOW;
    $classHOW.add_role($class, Oarm::Table);
    $classHOW.^mixin: Oarm::TableHOW;

    # TODO set via accessor
    $classHOW.oarm_table($table);
    #$classHOW.!table = $table;
    #$classHOW.table = $table
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
