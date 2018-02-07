use Oarm::Column;
use Oarm::ResultSet;

role Oarm::Table {
    has Bool $.oarm_in_db is default(False) is rw;
    has Hash $.oarm_extra;
    # dirty values

    method oarm_resultset_new() {
        my $resultset_type = self.HOW.oarm_resultset;
        #say $rs.name;
        #say $resultset_type.HOW.new();
        #say "RS" ~ self;
        return $resultset_type.new( class => self );
    }

    method !oarm_check_in_db() {
        Oarm::X::Record.new(
            error => "Object wasn't stored yet",
            item => self,
        ).throw if ! $.oarm_in_db;
    }

    method oarm_update(%extra?, %args?) {
        self.oarm_check_in_db();

        # Update values in object if possible
        %extra = self.oarm_set_values(%extra)
            if defined %extra;

        # TODO build statement
        # TODO execute statement
        # TODO retrieve data
        # TODO set data
        # TODO reset dirty
    }

    method oarm_insert(%extra?, %args?) {
        die Oarm::X::Record.new(
            error => "Object was already stored",
            item => self,
        ) if $.oarm_in_db;

        # Set values in object if possible
        %extra = self.oarm_set_values(%extra)
            if defined %extra;

        # TODO build statement
        # TODO execute statement
        # TODO retrieve data
        # TODO set data

        $.oarm_in_db = True;
    }

    method oarm_delete(%args?) {
        self.oarm_check_in_db();

        # TODO build statement
        # TODO execute statement

        $.oarm_in_db = False;
    }

    method oarm_refresh(%args?) {
        self.oarm_check_in_db();

        # TODO build statement
        # TODO execute statement
        # TODO retrieve data
        # TODO set data
    }

    method oarm_set_values(%extra) {
        my @oarm_columns = self.HOW.oarm_columns().list;
        for @oarm_columns -> $attr {
            my $moniker = $attr.oarm_moniker;
            if (%extra{$moniker}:exists) {
                if ($attr.readonly) {
                    # TODO! fix typename
                    X::Assignment::RO.new( typename => $attr.name ).throw;
                } else {
                    $attr.set_value(self, %extra{$moniker}:delete)
                }
            }
        }
        if (%extra.Int > 0) {
            for @oarm_columns -> $attr {
                my $column = $attr.column;
                if (%extra{$column}:exists) {
                    # TODO Exception
                    die('Table colision!');
                }
            }
        }

        return %extra;
    }
}

role Oarm::TableHOW {
    has Str $!oarm_table;
    has $!oarm_resultset;

    method oarm_primary() {
        return self.oarm_columns.grep({
            $_.is_primary;
        });
    }

    method oarm_columns() {
        return self.attributes(self).grep({
            $_.does(Oarm::ColumnHOW);
        });
    }

    method oarm_resultset() {
        return $!oarm_resultset;
    }

    method oarm_table(Str $set?) {
        $!oarm_table = $set
            if $set;
        say "INIT ";
        return $!oarm_table;
    }

    method compose(Mu:U $class) {
        callsame();
        say "COMPOSE";
        my $resultset_name = self.name($class) ~ '::ResultSet';
        my $resultset_type = Metamodel::ClassHOW.new_type(
            name    => $resultset_name,
        );
        my $resultset_meta = $resultset_type.HOW;
        $resultset_meta.^mixin: Oarm::ResultSetHOW;
        $resultset_meta.add_parent($resultset_type, Oarm::ResultSet);
        $resultset_meta.compose($resultset_type);
        $!oarm_resultset = $resultset_type;
    }
}
