use Oarm::Exception;

role Oarm::ColumnHOW {
    has Str  $.column;
    has Bool $.is_primary is default(False);
    has Bool $.retrieve_on_write is default(False);
    has Bool $.is_nullable is default(True);
    has Str  $.data_type;
    has Code $.inflator;
    has Code $.deflator;

    method oarm_moniker() {
        my $key = $.name;
        $key ~~ s/^\$(\!|\.)?//;
        return $key
    }

    method oarm_init_column(%def) {
        $!column = %def{'column'} || $.oarm_moniker();

        for $.^attributes.list -> $attr {
            my $key = $attr.name;
            $key ~~ s/^\$(\!|\.)?//;
            if (defined %def{$key}) {
                $attr.set_value(self , %def{$key}:delete)
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
