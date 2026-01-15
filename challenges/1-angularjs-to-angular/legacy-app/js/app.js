// Main application module
// Problem: Uses old AngularJS 1.x patterns
var employeeApp = angular.module('employeeApp', []);

// Global configuration - problematic pattern
window.APP_CONFIG = {
    dataUrl: 'test-inputs/employees.json',
    defaultSort: 'lastName',
    maxExportSize: 50
};

// Problematic: Polluting global scope
window.employeeCache = null;
window.lastLoadTime = null;
