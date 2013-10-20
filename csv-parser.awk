
function csv_parse_field (record, pos, separator, quote, csv, num_fields) {
    if (substr(record, pos, 1) == quote) {
        quoted=1
        pos++
    } else {
        quoted=0
    }
    prev_char_is_quote=0
    field=""

    while (pos <= length(record)) {
        c = substr(record, pos, 1)
        if (c == separator && (! quoted || prev_char_is_quote)) {
            csv[num_fields] = field
            return ++pos
        } else if (c == quote) {
            if (! quoted) {
                csv_error="Missing opening quote before '" field "'!"
                return -1
            } else if (prev_char_is_quote) {
                prev_char_is_quote=0
                field = field quote
            } else {
                if (pos == length(record)) {
                    quoted=0
                } else {
                    prev_char_is_quote=1
                }
            }
        } else if (prev_char_is_quote) {
            csv_error="Missing separator after '" field "'!"
            return -2
        } else {
            field = field c
        }
        pos++
    }

    if (quoted) {
        csv_error="Missing closing quote after '" field "' in following record: '" record "'"
        return -3
    } else {
        csv[num_fields] = field
        return pos
    }
}

function csv_parse_record (record, separator, quote, csv) {
    if (length(record) == 0) {
        return
    }

    pos=1
    num_fields=0
    while (pos <= length(record)) {
        pos = csv_parse_field(record, pos, separator, quote, csv, num_fields)
        if (pos < 0) {
            print "[CSV ERROR: " pos "] " csv_error
            return pos
        }
        num_fields++
    }

    if (substr(record, length(record), 1) == separator) {
        csv[num_fields++]=""
    }

    return num_fields
}

function csv_parse_and_display (record, separator, quote, output_fs) {
    num_fields=csv_parse_record($0, separator, quote, csv)
    if (num_fields >= 0) {
        line=""
        for (i=0; i<num_fields; i++) {
            line=line csv[i] output_fs
        }
        print line
    }
}
