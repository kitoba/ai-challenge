// Main Controller - uses $scope (not controllerAs pattern)
// Multiple problematic patterns intentionally included
employeeApp.controller('MainController', function($scope, EmployeeService, FilterService, $timeout) {

    // Problem: Using $scope instead of controllerAs
    $scope.employees = [];
    $scope.displayedEmployees = [];
    $scope.selectedEmployees = [];
    $scope.searchText = '';
    $scope.filterDept = '';
    $scope.filterLocation = '';
    $scope.filterActive = false;
    $scope.sortField = 'lastName';
    $scope.sortOrder = 'asc';

    // Problem: Initialization in controller instead of proper lifecycle
    $scope.init = function() {
        // Problem: Callback hell with nested promises
        EmployeeService.loadEmployees(function(data) {
            $scope.employees = data;

            // Problem: Direct function call instead of proper reactive patterns
            $scope.applyFilters();

            // Problem: Nested timeout
            $timeout(function() {
                FilterService.buildSearchIndex($scope.employees, function() {
                    console.log('Search index built');

                    // Problem: Another nested operation
                    $timeout(function() {
                        $scope.applySorting();
                    }, 100);
                });
            }, 200);
        }, function(error) {
            console.error('Failed to load employees:', error);
            alert('Error loading employee data');
        });
    };

    // Problem: Complex filtering logic that should be in a service
    $scope.applyFilters = function() {
        var filtered = $scope.employees;

        // Problem: Imperative DOM manipulation
        var loadingDiv = document.getElementById('loading');
        if (loadingDiv) {
            loadingDiv.style.display = 'block';
        }

        // Filter by department
        if ($scope.filterDept) {
            filtered = filtered.filter(function(emp) {
                return emp.department === $scope.filterDept;
            });
        }

        // Filter by location
        if ($scope.filterLocation) {
            filtered = filtered.filter(function(emp) {
                return emp.location === $scope.filterLocation;
            });
        }

        // Filter by active status
        if ($scope.filterActive) {
            filtered = filtered.filter(function(emp) {
                return emp.active === true;
            });
        }

        // Filter by search text
        if ($scope.searchText && $scope.searchText.length > 0) {
            var searchLower = $scope.searchText.toLowerCase();
            filtered = filtered.filter(function(emp) {
                return emp.firstName.toLowerCase().indexOf(searchLower) !== -1 ||
                       emp.lastName.toLowerCase().indexOf(searchLower) !== -1 ||
                       emp.email.toLowerCase().indexOf(searchLower) !== -1 ||
                       emp.role.toLowerCase().indexOf(searchLower) !== -1;
            });
        }

        $scope.displayedEmployees = filtered;

        // Problem: Another imperative DOM manipulation
        if (loadingDiv) {
            loadingDiv.style.display = 'none';
        }

        $scope.applySorting();
    };

    // Problem: Sorting logic in controller
    $scope.applySorting = function() {
        var sortField = $scope.sortField;
        var sortOrder = $scope.sortOrder;

        $scope.displayedEmployees.sort(function(a, b) {
            var aVal = a[sortField];
            var bVal = b[sortField];

            // Problem: String comparison without proper handling
            if (typeof aVal === 'string') {
                aVal = aVal.toLowerCase();
                bVal = bVal.toLowerCase();
            }

            if (aVal < bVal) {
                return sortOrder === 'asc' ? -1 : 1;
            }
            if (aVal > bVal) {
                return sortOrder === 'asc' ? 1 : -1;
            }
            return 0;
        });
    };

    $scope.toggleSortOrder = function() {
        $scope.sortOrder = $scope.sortOrder === 'asc' ? 'desc' : 'asc';
        $scope.applySorting();
    };

    $scope.selectEmployee = function(employee) {
        var index = $scope.selectedEmployees.indexOf(employee);
        if (index === -1) {
            $scope.selectedEmployees.push(employee);
        } else {
            $scope.selectedEmployees.splice(index, 1);
        }
    };

    $scope.deselectEmployee = function(employee) {
        var index = $scope.selectedEmployees.indexOf(employee);
        if (index !== -1) {
            $scope.selectedEmployees.splice(index, 1);
        }
    };

    $scope.isSelected = function(employee) {
        return $scope.selectedEmployees.indexOf(employee) !== -1;
    };

    $scope.clearSelection = function() {
        $scope.selectedEmployees = [];
    };

    $scope.getTotalCount = function() {
        return $scope.employees.length;
    };

    $scope.getFilteredCount = function() {
        return $scope.displayedEmployees.length;
    };

    $scope.getSelectedCount = function() {
        return $scope.selectedEmployees.length;
    };

    // Problem: Export logic in controller with complex nested callbacks
    $scope.exportSelected = function() {
        if ($scope.selectedEmployees.length === 0) {
            alert('No employees selected');
            return;
        }

        if ($scope.selectedEmployees.length > window.APP_CONFIG.maxExportSize) {
            alert('Cannot export more than ' + window.APP_CONFIG.maxExportSize + ' employees');
            return;
        }

        // Problem: Building export data with imperative code
        var exportData = [];
        for (var i = 0; i < $scope.selectedEmployees.length; i++) {
            var emp = $scope.selectedEmployees[i];
            exportData.push({
                id: emp.id,
                name: emp.firstName + ' ' + emp.lastName,
                email: emp.email,
                department: emp.department,
                role: emp.role,
                location: emp.location
            });
        }

        // Problem: Direct console output instead of proper export
        console.log('EXPORT_DATA:', JSON.stringify(exportData, null, 2));
        alert('Export data logged to console');
    };

    // Problem: Watch for search text changes (not reactive)
    $scope.$watch('searchText', function(newVal, oldVal) {
        if (newVal !== oldVal) {
            // Problem: Debouncing with timeout instead of proper rxjs
            if ($scope.searchTimeout) {
                $timeout.cancel($scope.searchTimeout);
            }
            $scope.searchTimeout = $timeout(function() {
                $scope.applyFilters();
            }, 300);
        }
    });

    // Initialize on load
    $scope.init();
});
