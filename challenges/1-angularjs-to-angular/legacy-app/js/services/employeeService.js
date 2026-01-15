// Employee Service
// Problems: Uses callbacks instead of promises, caches in global scope
employeeApp.service('EmployeeService', function($http) {

    // Problem: Using .success() and .error() which are deprecated
    this.loadEmployees = function(successCallback, errorCallback) {

        // Problem: Check global cache first
        if (window.employeeCache && window.lastLoadTime) {
            var now = new Date().getTime();
            var cacheAge = now - window.lastLoadTime;

            // Cache for 5 minutes
            if (cacheAge < 300000) {
                console.log('Using cached employee data');
                successCallback(window.employeeCache);
                return;
            }
        }

        var url = window.APP_CONFIG.dataUrl;

        // Problem: Using .then() instead of proper promises/observables
        $http.get(url)
            .then(function(response) {
                // Problem: Storing in global scope
                window.employeeCache = response.data;
                window.lastLoadTime = new Date().getTime();

                // Problem: Callback pattern instead of promises
                if (successCallback) {
                    successCallback(response.data);
                }
            })
            .catch(function(error) {
                console.error('Error loading employees:', error);
                if (errorCallback) {
                    errorCallback(error);
                }
            });
    };

    // Problem: Synchronous-looking function that depends on global state
    this.getEmployeeById = function(id) {
        if (!window.employeeCache) {
            return null;
        }

        for (var i = 0; i < window.employeeCache.length; i++) {
            if (window.employeeCache[i].id === id) {
                return window.employeeCache[i];
            }
        }
        return null;
    };

    // Problem: Business logic mixed with data access
    this.calculateAverageSalary = function(employees) {
        if (!employees || employees.length === 0) {
            return 0;
        }

        var sum = 0;
        for (var i = 0; i < employees.length; i++) {
            sum += employees[i].salary;
        }

        return sum / employees.length;
    };

    // Problem: Mutating input data
    this.addSkillToEmployee = function(employeeId, skill) {
        var emp = this.getEmployeeById(employeeId);
        if (emp && emp.skills) {
            emp.skills.push(skill);
            return true;
        }
        return false;
    };
});
