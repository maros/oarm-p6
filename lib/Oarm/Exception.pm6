#class Oarm::Exception {}

class Oarm::X is Exception is export {
    method  message {
        "Oarm Exception";
    }
}

class Oarm::X::Record is Exception is export {
    has Str $.error is required;
    has $.item is required;

    method message() {
        return sprintf('Error processing %s: %s', $.item.gist, $.error);
    }
}

class Oarm::X::Class is Exception is export {
    has Str $.error is required;
    has Str $.class is required;

    method message() {
        return sprintf('Could not compose class %s: %s', $.class, $.error);
    }
}
