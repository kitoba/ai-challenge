// Filter Service
// Problems: Uses callbacks, builds unnecessary search index
employeeApp.service('FilterService', function($timeout) {

    var searchIndex = {};

    // Problem: Async operation with callback instead of promise
    this.buildSearchIndex = function(employees, callback) {
        // Problem: Simulating async work that doesn't need to be async
        $timeout(function() {
            searchIndex = {};

            for (var i = 0; i < employees.length; i++) {
                var emp = employees[i];
                var searchText = [
                    emp.firstName,
                    emp.lastName,
                    emp.email,
                    emp.department,
                    emp.role,
                    emp.location
                ].join(' ').toLowerCase();

                searchIndex[emp.id] = searchText;
            }

            if (callback) {
                callback();
            }
        }, 100);
    };

    // Problem: Not actually using the search index it built
    this.searchEmployees = function(employees, searchText) {
        if (!searchText || searchText.length === 0) {
            return employees;
        }

        var searchLower = searchText.toLowerCase();
        var results = [];

        // Problem: Inefficient search that doesn't use index
        for (var i = 0; i < employees.length; i++) {
            var emp = employees[i];
            if (this.matchesSearch(emp, searchLower)) {
                results.push(emp);
            }
        }

        return results;
    };

    this.matchesSearch = function(employee, searchText) {
        return employee.firstName.toLowerCase().indexOf(searchText) !== -1 ||
               employee.lastName.toLowerCase().indexOf(searchText) !== -1 ||
               employee.email.toLowerCase().indexOf(searchText) !== -1 ||
               employee.department.toLowerCase().indexOf(searchText) !== -1 ||
               employee.role.toLowerCase().indexOf(searchText) !== -1;
    };

    // Problem: Returning different data types based on input
    this.filterByDepartment = function(employees, department) {
        if (!department) {
            return employees; // Returns array
        }

        var filtered = [];
        for (var i = 0; i < employees.length; i++) {
            if (employees[i].department === department) {
                filtered.push(employees[i]);
            }
        }

        return filtered.length > 0 ? filtered : null; // Returns null sometimes!
    };
});
