#!/usr/bin/env node

/**
 * Generate Golden Output Files
 *
 * This script simulates running the legacy AngularJS app and captures
 * the expected outputs for various operations. These become the "golden files"
 * that candidates' modernized Angular apps must match.
 */

const fs = require('fs');
const path = require('path');

// Load test data
const employeesData = JSON.parse(
    fs.readFileSync(path.join(__dirname, 'test-inputs/employees.json'), 'utf8')
);

// Output directory
const outputDir = path.join(__dirname, 'expected-outputs');
if (!fs.existsSync(outputDir)) {
    fs.mkdirSync(outputDir, { recursive: true });
}

console.log('Generating golden output files...\n');

// Helper: Filter by department
function filterByDepartment(employees, dept) {
    return employees.filter(e => e.department === dept);
}

// Helper: Filter by location
function filterByLocation(employees, location) {
    return employees.filter(e => e.location === location);
}

// Helper: Filter active only
function filterActive(employees) {
    return employees.filter(e => e.active === true);
}

// Helper: Search
function search(employees, searchText) {
    const lower = searchText.toLowerCase();
    return employees.filter(e =>
        e.firstName.toLowerCase().includes(lower) ||
        e.lastName.toLowerCase().includes(lower) ||
        e.email.toLowerCase().includes(lower) ||
        e.role.toLowerCase().includes(lower)
    );
}

// Helper: Sort
function sortBy(employees, field, order = 'asc') {
    const sorted = [...employees].sort((a, b) => {
        let aVal = a[field];
        let bVal = b[field];

        if (typeof aVal === 'string') {
            aVal = aVal.toLowerCase();
            bVal = bVal.toLowerCase();
        }

        if (aVal < bVal) return order === 'asc' ? -1 : 1;
        if (aVal > bVal) return order === 'asc' ? 1 : -1;
        return 0;
    });
    return sorted;
}

// 1. All employees (baseline)
const allEmployees = employeesData;
fs.writeFileSync(
    path.join(outputDir, 'all-employees.json'),
    JSON.stringify(allEmployees, null, 2)
);
console.log('✓ Generated: all-employees.json (20 employees)');

// 2. Filter by department: Engineering
const engineeringOnly = filterByDepartment(allEmployees, 'Engineering');
fs.writeFileSync(
    path.join(outputDir, 'filter-engineering.json'),
    JSON.stringify(engineeringOnly, null, 2)
);
console.log(`✓ Generated: filter-engineering.json (${engineeringOnly.length} employees)`);

// 3. Filter by department: Sales
const salesOnly = filterByDepartment(allEmployees, 'Sales');
fs.writeFileSync(
    path.join(outputDir, 'filter-sales.json'),
    JSON.stringify(salesOnly, null, 2)
);
console.log(`✓ Generated: filter-sales.json (${salesOnly.length} employees)`);

// 4. Filter by location: Columbus
const columbusOnly = filterByLocation(allEmployees, 'Columbus');
fs.writeFileSync(
    path.join(outputDir, 'filter-columbus.json'),
    JSON.stringify(columbusOnly, null, 2)
);
console.log(`✓ Generated: filter-columbus.json (${columbusOnly.length} employees)`);

// 5. Active employees only
const activeOnly = filterActive(allEmployees);
fs.writeFileSync(
    path.join(outputDir, 'filter-active.json'),
    JSON.stringify(activeOnly, null, 2)
);
console.log(`✓ Generated: filter-active.json (${activeOnly.length} employees)`);

// 6. Search: "smith"
const smithResults = search(allEmployees, 'smith');
fs.writeFileSync(
    path.join(outputDir, 'search-smith.json'),
    JSON.stringify(smithResults, null, 2)
);
console.log(`✓ Generated: search-smith.json (${smithResults.length} employees)`);

// 7. Search: "engineer"
const engineerResults = search(allEmployees, 'engineer');
fs.writeFileSync(
    path.join(outputDir, 'search-engineer.json'),
    JSON.stringify(engineerResults, null, 2)
);
console.log(`✓ Generated: search-engineer.json (${engineerResults.length} employees)`);

// 8. Sort by lastName ascending
const sortedLastNameAsc = sortBy(allEmployees, 'lastName', 'asc');
fs.writeFileSync(
    path.join(outputDir, 'sort-lastname-asc.json'),
    JSON.stringify(sortedLastNameAsc, null, 2)
);
console.log('✓ Generated: sort-lastname-asc.json');

// 9. Sort by lastName descending
const sortedLastNameDesc = sortBy(allEmployees, 'lastName', 'desc');
fs.writeFileSync(
    path.join(outputDir, 'sort-lastname-desc.json'),
    JSON.stringify(sortedLastNameDesc, null, 2)
);
console.log('✓ Generated: sort-lastname-desc.json');

// 10. Sort by salary ascending
const sortedSalaryAsc = sortBy(allEmployees, 'salary', 'asc');
fs.writeFileSync(
    path.join(outputDir, 'sort-salary-asc.json'),
    JSON.stringify(sortedSalaryAsc, null, 2)
);
console.log('✓ Generated: sort-salary-asc.json');

// 11. Sort by hireDate ascending
const sortedHireDateAsc = sortBy(allEmployees, 'hireDate', 'asc');
fs.writeFileSync(
    path.join(outputDir, 'sort-hiredate-asc.json'),
    JSON.stringify(sortedHireDateAsc, null, 2)
);
console.log('✓ Generated: sort-hiredate-asc.json');

// 12. Complex filter: Engineering + Columbus + Active
let complexFiltered = filterByDepartment(allEmployees, 'Engineering');
complexFiltered = filterByLocation(complexFiltered, 'Columbus');
complexFiltered = filterActive(complexFiltered);
fs.writeFileSync(
    path.join(outputDir, 'complex-engineering-columbus-active.json'),
    JSON.stringify(complexFiltered, null, 2)
);
console.log(`✓ Generated: complex-engineering-columbus-active.json (${complexFiltered.length} employees)`);

// 13. Complex filter: Sales + Active
let salesActive = filterByDepartment(allEmployees, 'Sales');
salesActive = filterActive(salesActive);
const salesActiveSorted = sortBy(salesActive, 'lastName', 'asc');
fs.writeFileSync(
    path.join(outputDir, 'complex-sales-active-sorted.json'),
    JSON.stringify(salesActiveSorted, null, 2)
);
console.log(`✓ Generated: complex-sales-active-sorted.json (${salesActiveSorted.length} employees)`);

// 14. Export format (simplified employee data)
const exportSample = [
    allEmployees[0],  // John Smith
    allEmployees[2],  // Michael Chen
    allEmployees[6]   // David Wilson
].map(emp => ({
    id: emp.id,
    name: `${emp.firstName} ${emp.lastName}`,
    email: emp.email,
    department: emp.department,
    role: emp.role,
    location: emp.location
}));
fs.writeFileSync(
    path.join(outputDir, 'export-sample.json'),
    JSON.stringify(exportSample, null, 2)
);
console.log(`✓ Generated: export-sample.json (${exportSample.length} employees)`);

// 15. Stats output
const stats = {
    total: allEmployees.length,
    byDepartment: {
        Engineering: filterByDepartment(allEmployees, 'Engineering').length,
        Sales: filterByDepartment(allEmployees, 'Sales').length,
        Marketing: filterByDepartment(allEmployees, 'Marketing').length,
        HR: filterByDepartment(allEmployees, 'HR').length,
        Finance: filterByDepartment(allEmployees, 'Finance').length
    },
    byLocation: {
        Columbus: filterByLocation(allEmployees, 'Columbus').length,
        'New York': filterByLocation(allEmployees, 'New York').length,
        'San Francisco': filterByLocation(allEmployees, 'San Francisco').length,
        Austin: filterByLocation(allEmployees, 'Austin').length,
        Chicago: filterByLocation(allEmployees, 'Chicago').length
    },
    active: filterActive(allEmployees).length,
    inactive: allEmployees.length - filterActive(allEmployees).length
};
fs.writeFileSync(
    path.join(outputDir, 'stats.json'),
    JSON.stringify(stats, null, 2)
);
console.log('✓ Generated: stats.json');

console.log('\n✅ All golden output files generated successfully!');
console.log(`   Location: ${outputDir}`);
console.log('\nThese files represent the expected behavior of the legacy app.');
console.log('Modernized Angular apps must produce identical outputs.\n');
