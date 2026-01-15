// Custom date filter
// Problem: Custom filter when built-in date filter exists
employeeApp.filter('customDate', function() {
    return function(input) {
        if (!input) return '';

        // Problem: Manual date parsing instead of using Date object properly
        var parts = input.split('-');
        if (parts.length !== 3) return input;

        var year = parts[0];
        var month = parts[1];
        var day = parts[2];

        // Problem: Hardcoded month names
        var monthNames = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                         'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

        var monthIndex = parseInt(month) - 1;
        var monthName = monthNames[monthIndex];

        return monthName + ' ' + day + ', ' + year;
    };
});
