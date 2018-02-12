use Oarm::ResultSet;
use Oarm::Column;


role Oarm::Table {
    has Bool $.oarm_in_db is default(False) is rw;
    has %.oarm_extra;
    has Bool %.oarm_dirty;

    method oarm_set_dirty($column) {
        $column = $column.name
            if $column ~~ Attribute;
        return %.oarm_dirty{$column} = True;
    }

    multi method oarm_is_dirty($column) {
        $column = $column.name
            if $column ~~ Attribute;
        return %.oarm_dirty{$column} // False;
    }

    multi method oarm_is_dirty() {
        return %.oarm_dirty.Bool;
    }

    method oarm_resultset_new() {
        my $resultset_type = self.HOW.oarm_resultset;
        say "BUILD NEW RS";
        say $resultset_type;
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
        Oarm::X::Record.new(
            error => "Object was already stored",
            item => self,
        ).throw if $.oarm_in_db;

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

    method oarm_read_db_values(%values) {
        my @oarm_columns = self.HOW.oarm_columns().list;
        for @oarm_columns -> $attr {

        }
    }

    method oarm_set_values(%extra) {
        my @oarm_columns = self.HOW.oarm_columns().list;
        # Loop attributes
        for @oarm_columns -> $attr {
            my $moniker = $attr.oarm_moniker;
            if (%extra{$moniker}:exists) {
                if ($attr.readonly) {
                    # TODO! fix typename
                    X::Assignment::RO.new( typename => $attr.name ).throw;
                } else {
                    $attr.oarm_set_value(self, %extra{$moniker}:delete)
                }
            }
        }

        # Check rest for possible colisions
        if (%extra.Int > 0) {
            for @oarm_columns -> $attr {
                my $column = $attr.oarm_column;
                if (%extra{$column}:exists) {
                    # TODO Exception
                    Oarm::X::Record.new(
                        error => "Setting " ~ $column ~ " conflicts with column definition",
                        item => self,
                    ).throw;
                }
            }
        }

        return %extra;
    }
}

role Oarm::TableHOW {
    has Str $!oarm_table is required;
    has $!oarm_resultset;

    method oarm_primary() {
        return self.oarm_columns.grep({
            $_.oarm_is_primary;
        });
    }

    method oarm_columns() {
        return self.attributes(self).grep({
            #$_.can('oarm_moniker');
            $_.does(Oarm::ColumnHOW);
        });
    }

    method oarm_resultset() {
        return $!oarm_resultset;
    }

    method oarm_table() {
        return $!oarm_table;
    }

    method oarm_init_table(%def) {
        if (defined $!oarm_table) {
            Oarm::X::Class.new(
                class   => self.package.^name,
                error   => 'Cannot call oarm_init_table twice',
            ).throw;
        }

        for $.^attributes.list -> $attr {
            my $key = $attr.name;
            if ($key ~~ m/\$(\!|\.)?oarm_(.+)/) {
                my $hash_key = $1.STR;
                if (defined %def{$hash_key}) {
                    $attr.set_value(self , %def{$hash_key}:delete)
                } elsif ($attr.can('required') && $attr.required) {
                    Oarm::X::Class.new(
                        class   => self.^name,
                        error   => 'Missing attributes in table definition: ' ~ $hash_key
                    ).throw;
                }
            }
        }

        if (%def.Int) {
            Oarm::X::Class.new(
                class   => self.^name,
                error   => 'Unknown attributes in table definition: ' ~ %def.keys.join(', ')
            ).throw;
        }
    }

    method compose(Mu:U $class) {
        say "[C] COMPOSE " ~ $class.^name;

        # Build accessors
        for self.oarm_columns() -> $attr {
            $attr.oarm_build_accessor();
        }

        callsame();

        # Build resultset class
        unless (defined $!oarm_resultset) {
            my $resultset_name = self.name($class) ~ '::ResultSet';
            say "[C] Build resultset " ~ $resultset_name;
            my $resultset_type = Metamodel::ClassHOW.new_type(
                name    => $resultset_name,
            );
            my $resultset_meta = $resultset_type.HOW;
            $resultset_meta.^mixin: Oarm::ResultSetHOW;
            $resultset_meta.add_parent($resultset_type, Oarm::ResultSet);
            $resultset_meta.compose($resultset_type);

            # TODO dynamic export
            #$resultset_meta.trait_mod:($resultset_type, export => True);

            $!oarm_resultset = $resultset_type;
        }


    }
}
