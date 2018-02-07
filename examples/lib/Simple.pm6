use Oarm;

class Simple is Oarm::Table('simple_table') {
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

    has @.related is has_one();
    #has @.related is has_many()

    has $.hell is rw;
    has $other;
}

class Other is Oarm::Table('other_table') {
    has $.id is column(
        is_primary => True,
        is_nullable => False
    );
}

my $x = Simple.oarm_resultset_new.hu();


#say Simple.HOW.oarm_table;
#ay Simple.HOW.oarm_primary;
my $h = Simple.new( name => 'hase', index => 22 );
say $h.oarm_in_db;
say $h.oarm_extra;
$h.oarm_insert({name => 'hui', hee => 1 });
say $h.name ~ ' -> ' ~ $h.index;
