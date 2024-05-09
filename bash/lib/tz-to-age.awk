#!/usr/bin/env awk -f

{
    if ($col ~ /^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$/) {
        split($col, t, /[-:TZ]/);
        gsub(/Z/, "", t[7]);
        cmd = "date -u -d \"" t[1] "-" t[2] "-" t[3] " " t[4] ":" t[5] ":" t[6] "\" +%s";
        cmd | getline ts;
        close(cmd);
        age = now - ts;
        days = int(age / 86400);
        hours = int((age % 86400) / 3600);
        $col = days "d" hours "h";
    }
    print;
}
