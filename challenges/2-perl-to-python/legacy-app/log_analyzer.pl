#!/usr/bin/perl

# Log Analyzer - Legacy Perl Script
# Problems: no strict/warnings, global state, regex-heavy, system calls, CPAN dependencies

# Problem: No use strict or use warnings!
# This allows sloppy variable declarations and typos

# Problem: Global variables everywhere
$log_file = "";
%error_counts = ();
%warning_counts = ();
%info_counts = ();
@all_ips = ();
%ip_frequency = ();
%user_logins = ();
%request_times = ();
$total_lines = 0;
$start_time = "";
$end_time = "";

# Problem: Using system calls instead of proper file handling
sub check_file_exists {
    my $file = shift;
    # Problem: System call that could use built-in -e
    my $result = `test -f $file && echo "exists"`;
    chomp $result;
    return $result eq "exists";
}

# Problem: Main logic not in a function, just running at file scope
if (@ARGV < 1) {
    # Problem: die without proper error handling
    die "Usage: $0 <log_file> [options]\n";
}

$log_file = $ARGV[0];

# Problem: Not checking if file exists before using it
unless (check_file_exists($log_file)) {
    print "Error: File not found: $log_file\n";
    exit 1;
}

# Parse command line options (problem: manual parsing instead of Getopt)
$show_errors = 0;
$show_warnings = 0;
$show_stats = 0;
$show_ips = 0;
$show_users = 0;
$show_times = 0;
$output_format = "text";

# Problem: Manual argument parsing with loops
for (my $i = 1; $i < @ARGV; $i++) {
    if ($ARGV[$i] eq "--errors") {
        $show_errors = 1;
    }
    elsif ($ARGV[$i] eq "--warnings") {
        $show_warnings = 1;
    }
    elsif ($ARGV[$i] eq "--stats") {
        $show_stats = 1;
    }
    elsif ($ARGV[$i] eq "--ips") {
        $show_ips = 1;
    }
    elsif ($ARGV[$i] eq "--users") {
        $show_users = 1;
    }
    elsif ($ARGV[$i] eq "--times") {
        $show_times = 1;
    }
    elsif ($ARGV[$i] eq "--json") {
        $output_format = "json";
    }
}

# Default: show stats if nothing specified
unless ($show_errors || $show_warnings || $show_stats || $show_ips || $show_users || $show_times) {
    $show_stats = 1;
}

# Problem: Opening file without proper error handling style
open(LOGFILE, "<", $log_file) or die "Cannot open $log_file: $!";

# Problem: Reading entire file into memory instead of line-by-line processing
@lines = <LOGFILE>;
close(LOGFILE);

$total_lines = scalar @lines;

# Problem: Complex regex parsing in a loop (should be more structured)
foreach $line (@lines) {
    chomp $line;

    # Problem: Capturing groups with complex regex, hard to maintain
    # Format: YYYY-MM-DD HH:MM:SS LEVEL [Module] Message
    if ($line =~ /^(\d{4}-\d{2}-\d{2}\s+\d{2}:\d{2}:\d{2})\s+(INFO|WARN|ERROR|DEBUG)\s+\[([^\]]+)\]\s+(.*)$/) {
        $timestamp = $1;
        $level = $2;
        $module = $3;
        $message = $4;

        # Track time range
        $start_time = $timestamp unless $start_time;
        $end_time = $timestamp;

        # Problem: Using if/elsif chain instead of hash dispatch
        if ($level eq "ERROR") {
            $error_counts{$module}++;
        }
        elsif ($level eq "WARN") {
            $warning_counts{$module}++;
        }
        elsif ($level eq "INFO") {
            $info_counts{$module}++;
        }

        # Problem: Nested regex for IP extraction
        if ($message =~ /(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})/) {
            $ip = $1;
            push @all_ips, $ip;
            $ip_frequency{$ip}++;
        }

        # Problem: Another nested regex for user login extraction
        if ($message =~ /User\s+'([^']+)'\s+logged in/) {
            $user = $1;
            $user_logins{$user}++;
        }

        # Problem: Yet another regex for request timing
        if ($message =~ /Request processed:.*in\s+(\d+)ms/) {
            $duration = $1;
            push @{$request_times{$module}}, $duration;
        }
    }
}

# Problem: Output logic mixed with processing logic
sub print_section_header {
    my $title = shift;
    # Problem: String concatenation instead of printf
    print "\n" . ("=" x 70) . "\n";
    print "  " . $title . "\n";
    print ("=" x 70) . "\n\n";
}

# Problem: Postfix conditionals (Perl-specific idiom)
print_section_header("Log Analysis Report") if $output_format eq "text";

# Show errors
if ($show_errors) {
    if ($output_format eq "json") {
        print_errors_json();
    }
    else {
        print_section_header("Error Summary");
        $total_errors = 0;

        # Problem: Each for sorting, not very readable
        foreach $module (sort keys %error_counts) {
            $count = $error_counts{$module};
            $total_errors += $count;
            # Problem: Manual formatting instead of sprintf
            print "$module: $count errors\n";
        }

        print "\nTotal Errors: $total_errors\n";
    }
}

# Show warnings
if ($show_warnings) {
    unless ($output_format eq "json") {  # Problem: unless instead of if !
        print_section_header("Warning Summary");
        $total_warnings = 0;

        foreach $module (sort keys %warning_counts) {
            $count = $warning_counts{$module};
            $total_warnings += $count;
            printf "%-20s %5d warnings\n", $module, $count;
        }

        print "\nTotal Warnings: $total_warnings\n";
    }
    else {
        print_warnings_json();
    }
}

# Show stats
if ($show_stats) {
    unless ($output_format eq "json") {
        print_section_header("Statistics");

        # Calculate totals
        $total_errors = 0;
        $total_errors += $_ for values %error_counts;

        $total_warnings = 0;
        $total_warnings += $_ for values %warning_counts;

        $total_info = 0;
        $total_info += $_ for values %info_counts;

        print "Time Range: $start_time to $end_time\n";
        print "Total Lines: $total_lines\n";
        print "Total Errors: $total_errors\n";
        print "Total Warnings: $total_warnings\n";
        print "Total Info: $total_info\n";
        print "Unique IPs: " . (scalar keys %ip_frequency) . "\n";
        print "Unique Users: " . (scalar keys %user_logins) . "\n";
    }
    else {
        print_stats_json();
    }
}

# Show IP analysis
if ($show_ips) {
    unless ($output_format eq "json") {
        print_section_header("IP Address Analysis");

        # Problem: Sort by value using Schwartzian transform (Perl idiom)
        my @sorted_ips = map { $_->[0] }
                        sort { $b->[1] <=> $a->[1] }
                        map { [$_, $ip_frequency{$_}] }
                        keys %ip_frequency;

        my $count = 0;
        foreach my $ip (@sorted_ips) {
            last if $count >= 10;  # Problem: postfix modifier
            printf "%-15s %5d occurrences\n", $ip, $ip_frequency{$ip};
            $count++;
        }
    }
    else {
        print_ips_json();
    }
}

# Show user login analysis
if ($show_users) {
    unless ($output_format eq "json") {
        print_section_header("User Login Summary");

        foreach my $user (sort keys %user_logins) {
            printf "%-40s %3d logins\n", $user, $user_logins{$user};
        }
    }
    else {
        print_users_json();
    }
}

# Show request timing analysis
if ($show_times) {
    unless ($output_format eq "json") {
        print_section_header("Request Timing Analysis");

        foreach my $module (sort keys %request_times) {
            my @times = @{$request_times{$module}};
            next unless @times;  # Problem: postfix unless

            my $sum = 0;
            $sum += $_ for @times;
            my $avg = $sum / scalar @times;

            # Problem: Manual min/max calculation
            my $min = $times[0];
            my $max = $times[0];
            foreach (@times) {
                $min = $_ if $_ < $min;
                $max = $_ if $_ > $max;
            }

            printf "%-20s Avg: %6.1fms  Min: %4dms  Max: %4dms  Count: %3d\n",
                   $module, $avg, $min, $max, scalar @times;
        }
    }
    else {
        print_times_json();
    }
}

# Problem: JSON output functions that manually build JSON (should use CPAN module)
sub print_errors_json {
    print "{\n";
    print "  \"errors\": {\n";

    my @modules = sort keys %error_counts;
    for (my $i = 0; $i < @modules; $i++) {
        my $module = $modules[$i];
        my $count = $error_counts{$module};
        print "    \"$module\": $count";
        print "," unless $i == $#modules;  # Problem: manual comma handling
        print "\n";
    }

    print "  }\n";
    print "}\n";
}

sub print_warnings_json {
    print "{\n";
    print "  \"warnings\": {\n";

    my @modules = sort keys %warning_counts;
    for (my $i = 0; $i < @modules; $i++) {
        my $module = $modules[$i];
        my $count = $warning_counts{$module};
        print "    \"$module\": $count";
        print "," unless $i == $#modules;
        print "\n";
    }

    print "  }\n";
    print "}\n";
}

sub print_stats_json {
    # Problem: Manual JSON construction with string concatenation
    my $total_errors = 0;
    $total_errors += $_ for values %error_counts;

    my $total_warnings = 0;
    $total_warnings += $_ for values %warning_counts;

    my $total_info = 0;
    $total_info += $_ for values %info_counts;

    print "{\n";
    print "  \"stats\": {\n";
    print "    \"timeRange\": {\n";
    print "      \"start\": \"$start_time\",\n";
    print "      \"end\": \"$end_time\"\n";
    print "    },\n";
    print "    \"totalLines\": $total_lines,\n";
    print "    \"totalErrors\": $total_errors,\n";
    print "    \"totalWarnings\": $total_warnings,\n";
    print "    \"totalInfo\": $total_info,\n";
    print "    \"uniqueIPs\": " . (scalar keys %ip_frequency) . ",\n";
    print "    \"uniqueUsers\": " . (scalar keys %user_logins) . "\n";
    print "  }\n";
    print "}\n";
}

sub print_ips_json {
    print "{\n";
    print "  \"ipAddresses\": {\n";

    my @sorted_ips = map { $_->[0] }
                    sort { $b->[1] <=> $a->[1] }
                    map { [$_, $ip_frequency{$_}] }
                    keys %ip_frequency;

    for (my $i = 0; $i < @sorted_ips && $i < 10; $i++) {
        my $ip = $sorted_ips[$i];
        print "    \"$ip\": $ip_frequency{$ip}";
        print "," unless $i == $#sorted_ips || $i == 9;
        print "\n";
    }

    print "  }\n";
    print "}\n";
}

sub print_users_json {
    print "{\n";
    print "  \"users\": {\n";

    my @users = sort keys %user_logins;
    for (my $i = 0; $i < @users; $i++) {
        my $user = $users[$i];
        my $count = $user_logins{$user};
        # Problem: No JSON escaping of user strings
        print "    \"$user\": $count";
        print "," unless $i == $#users;
        print "\n";
    }

    print "  }\n";
    print "}\n";
}

sub print_times_json {
    print "{\n";
    print "  \"requestTimes\": {\n";

    my @modules = sort keys %request_times;
    for (my $i = 0; $i < @modules; $i++) {
        my $module = $modules[$i];
        my @times = @{$request_times{$module}};

        my $sum = 0;
        $sum += $_ for @times;
        my $avg = @times > 0 ? $sum / scalar @times : 0;

        my $min = @times > 0 ? $times[0] : 0;
        my $max = @times > 0 ? $times[0] : 0;
        foreach (@times) {
            $min = $_ if $_ < $min;
            $max = $_ if $_ > $max;
        }

        print "    \"$module\": {\n";
        printf "      \"average\": %.1f,\n", $avg;
        print "      \"min\": $min,\n";
        print "      \"max\": $max,\n";
        print "      \"count\": " . (scalar @times) . "\n";
        print "    }";
        print "," unless $i == $#modules;
        print "\n";
    }

    print "  }\n";
    print "}\n";
}

# Problem: Exit code not explicitly set
# (should exit 0 for success)
