use Oarm;

class Simple is oarm_table( table => 'simple_table' ) {
    has $.id is column(
        is_primary => True,
        is_nullable => False
    );
    has $.name is column(
        is_nullable => True,
        data_type => 'VARCHAR',
        #ssdfs => 'ss'
    ) is rw;
    has $.index is column(
        column => 'idx',
    );
    has $.other is column(
        column => 'idx',
        inflator => 'inflate_other'
    );


    has @.related is has_one();
    #has @.related is has_many()

    has $.hell is rw;

    method inflate_other($raw) {
        say "INFLATE_OTHER";
    }
}

class Other is oarm_table( table => 'other_table' ) {
    has $.id is column(
        is_primary => True,
        is_nullable => False
    );
}

say "##########################################";
#my $x = Simple.oarm_resultset_new.hu();


#say Simple.HOW.oarm_table;
#ay Simple.HOW.oarm_primary;
my $h = Simple.new( name => 'hase', index => 22, other => 'hehe' );
say 'Indb'~$h.oarm_in_db;
say 'Index'~$h.index;
$h.oarm_insert({name => 'hui', hee => 1 });
say 'DIRTY:' ~ $h.oarm_is_dirty() ~ ';' ~ $h.oarm_is_dirty('name') ~ ';' ~ $h.oarm_is_dirty('other');
say 'Name:' ~$h.name ~ ' -> ' ~ $h.index;
say $h.other;
