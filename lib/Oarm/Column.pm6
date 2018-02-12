use Oarm::Types;
#require Oarm::Exception;

role Oarm::ColumnHOW {
    has Str  $.oarm_column is required;
    has Bool $.oarm_is_primary is default(False);
    has Bool $.oarm_retrieve_on_write is default(False);
    has Bool $.oarm_is_nullable is default(True);
    has Str  $.oarm_data_type;
    has Code $.oarm_inflator;
    has Code $.oarm_deflator;

    method oarm_moniker() {
        my $key = $.name;
        $key ~~ s/^\$(\!|\.)?//;
        return $key;
    }

    method oarm_build_accessor() {
        my $class   = self.package;
        my $moniker = $.oarm_moniker;
        my $attr    = self;

        # No need to build our some basic acessors
        return
            if self.readonly && ! defined $.oarm_inflator;

        # if (self.rw && self.oarm_is_nullable) {
        #     $class.HOW.add_method(
        #         $class,
        #         ''
        # }

        if (self.readonly ) {
            say "[C][A] Build readonly acessor " ~ $moniker;
            $class.HOW.add_method(
                $class,
                $moniker,
                method () {
                    say "Readonly";
                    my $value   = $attr.get_value(self);
                    if ($value ~~ Oarm::Raw) {
                        $value = $attr.oarm_inflate_value(self, $value);
                        $attr.set_value(self, $value);
                    }
                    return $value;
                }
            );
        } else {
            say "[C][A] Build rw acessor " ~ $moniker;
            $class.HOW.add_method(
                $class,
                $moniker,
                method ($set?) {
                    say "Rw";
                    my $value = $attr.get_value(self);
                    if (defined $set) {
                        $attr.set_value(self, $set);
                        if ($value !~~ $set) {
                            self
                        }
                        $value = $set;
                    } else {
                        if ($value ~~ Oarm::Raw) {
                            $value = $attr.oarm_inflate_value(self, $value);
                            $attr.set_value(self, $value);
                        }
                    }
                    return $value;
                }
            );
        }
    }

    method oarm_inflate_value($instance!, $value) {
        return $value
            unless defined $value && $.oarm_inflator;

        if ($.oarm_inflator ~~ Str) {
            return  $instance."$.oarm_inflator"($value);
        } elsif ($.oarm_inflator ~~ Callable) {
            return $.oarm_inflator.($instance, $value);
        }

        # TODO warn
        return $value;
    }

    # $class.HOW.add_method(
        #     $class,
        #     $moniker,
        # );
        #
        #     return method ($value?) {
        #         if ($value.)
        #     };
        # } else {
        #     return method () {
        #         say "ACC ro";
        #     };
        # }

    method oarm_init_column(%def) {
        my $class   = self.package;
        my $moniker = self.oarm_moniker;

        if (defined $!oarm_column) {
            Oarm::X::Class.new(
                class   => $class.^name,
                error   => 'Cannot call oarm_init_column twice',
            ).throw;
        }

        # Fallback
        %def<column> ||= $moniker;

        for $.^attributes.list -> $attr {
            my $key = $attr.name;
            if ($key ~~ m/\$(\!|\.)?oarm_(.+)/) {
                my $hash_key = $1.STR;
                if (defined %def{$hash_key}) {
                    $attr.set_value(self , %def{$hash_key}:delete)
                } elsif ($attr.can('required') && $attr.required) {
                    Oarm::X::Class.new(
                        class   => $class.^name,
                        error   => 'Missing attributes in column definition: ' ~ $hash_key
                    ).throw;
                }
            }
        }

        if (%def.Int) {
            Oarm::X::Class.new(
                class   => $class.^name,
                error   => 'Unknown attributes in column definition: ' ~ %def.keys.join(', ')
            ).throw;
        }
    }
}
