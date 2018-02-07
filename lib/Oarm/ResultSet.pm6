class Oarm::ResultSet is export {
    has $!class;
    #submethod BUILD { ... }
    # method HOW {
    #
    # }
    # find
    # search
    # delete
    # update

    method hu() { say "RS FOR" ~ $!class.^name }
}

role Oarm::ResultSetHOW {

}
