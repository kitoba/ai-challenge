// Employee Card Directive
// Problems: Old directive syntax, inline template, manual DOM manipulation
employeeApp.directive('employeeCard', function() {
    return {
        restrict: 'E',
        scope: {
            employee: '=',
            onSelect: '&',
            isSelected: '&'
        },
        // Problem: Inline template as string instead of templateUrl
        template: '<div class="employee-card" ng-class="{\'selected\': isSelected({employee: employee}), \'inactive\': !employee.active}">' +
                  '  <div class="employee-header">' +
                  '    <h3>{{employee.firstName}} {{employee.lastName}}</h3>' +
                  '    <span class="employee-id">#{{employee.id}}</span>' +
                  '  </div>' +
                  '  <div class="employee-info">' +
                  '    <p><strong>Email:</strong> {{employee.email}}</p>' +
                  '    <p><strong>Department:</strong> {{employee.department}}</p>' +
                  '    <p><strong>Role:</strong> {{employee.role}}</p>' +
                  '    <p><strong>Location:</strong> {{employee.location}}</p>' +
                  '    <p><strong>Hire Date:</strong> {{employee.hireDate | customDate}}</p>' +
                  '    <p><strong>Salary:</strong> {{employee.salary | customCurrency}}</p>' +
                  '  </div>' +
                  '  <div class="employee-skills">' +
                  '    <strong>Skills:</strong>' +
                  '    <span class="skill-tag" ng-repeat="skill in employee.skills">{{skill}}</span>' +
                  '  </div>' +
                  '  <div class="employee-actions">' +
                  '    <button ng-click="selectCard()" class="select-btn">' +
                  '      {{isSelected({employee: employee}) ? "Deselect" : "Select"}}' +
                  '    </button>' +
                  '    <span ng-if="!employee.active" class="inactive-badge">Inactive</span>' +
                  '  </div>' +
                  '</div>',
        link: function(scope, element, attrs) {
            // Problem: Manual DOM manipulation in link function
            scope.selectCard = function() {
                scope.onSelect({employee: scope.employee});

                // Problem: Direct DOM manipulation
                var card = element[0].querySelector('.employee-card');
                if (card) {
                    card.classList.add('highlight');
                    setTimeout(function() {
                        card.classList.remove('highlight');
                    }, 300);
                }
            };

            // Problem: Watching for changes manually
            scope.$watch('employee.active', function(newVal) {
                if (!newVal) {
                    // Problem: More DOM manipulation
                    var card = element[0].querySelector('.employee-card');
                    if (card) {
                        card.style.opacity = '0.6';
                    }
                }
            });
        }
    };
});
