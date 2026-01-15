// Custom currency filter
// Problem: Reinventing the wheel when currency filter exists
employeeApp.filter('customCurrency', function() {
    return function(input) {
        if (!input && input !== 0) return '';

        // Problem: Manual number formatting
        var num = parseFloat(input);
        if (isNaN(num)) return input;

        // Problem: Not handling localization
        var formatted = num.toFixed(2);

        // Problem: Manual thousands separator insertion
        var parts = formatted.split('.');
        parts[0] = parts[0].replace(/\B(?=(\d{3})+(?!\d))/g, ',');

        return '$' + parts.join('.');
    };
});
