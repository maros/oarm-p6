use Oarm::Exception;

role Oarm::ColumnHOW {
    has Str  $.oarm_column;
    has Bool $.oarm_is_primary is default(False);
    has Bool $.oarm_retrieve_on_write is default(False);
    has Bool $.oarm_is_nullable is default(True);
    has Str  $.oarm_data_type;
    has Code $.oarm_inflator;
    has Code $.oarm_deflator;

    method oarm_moniker() {
        my $key = $.name;
        $key ~~ s/^\$(\!|\.)?//;
        return $key
    }

    method oarm_init_column(%def) {
        if (defined $!oarm_column) {
            Oarm::X::Class.new(
                class   => self.package.^name,
                error   => 'Cannot call oarm_init_column twice',
            ).throw;
        }

        %def<column> ||= $.oarm_moniker();

        for $.^attributes.list -> $attr {
            my $key = $attr.name;
            if ($key ~~ m/\$(\!|\.)?oarm_(.+)/) {
                $key = $1.STR;
                if (defined %def{$key}) {
                    $attr.set_value(self , %def{$key}:delete)
                }
            }
        }

        if (%def.Int) {
            Oarm::X::Class.new(
                class   => self.package.^name,
                error   => 'Unknown attributes in column definition: ' ~ %def.keys.join(', ')
            ).throw;
        }
    }
}
