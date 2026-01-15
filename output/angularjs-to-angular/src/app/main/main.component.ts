import { Component, OnInit, OnDestroy } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormBuilder, FormGroup, ReactiveFormsModule } from '@angular/forms';
import { Subject, merge } from 'rxjs';
import { debounceTime, takeUntil } from 'rxjs/operators';
import { EmployeeService } from '../services/employee.service';
import { FilterService } from '../services/filter.service';
import { Employee } from '../models/employee.model';

@Component({
  selector: 'app-main',
  standalone: true,
  imports: [CommonModule, ReactiveFormsModule],
  templateUrl: './main.component.html',
  styleUrls: ['./main.component.scss']
})
export class MainComponent implements OnInit, OnDestroy {
  employees: Employee[] = [];
  displayedEmployees: Employee[] = [];
  selectedEmployees: Employee[] = [];

  filterForm: FormGroup;

  departments: string[] = [];
  locations: string[] = [];

  filterDept = '';
  filterLocation = '';
  filterActive = false;
  searchText = '';

  sortField: keyof Employee = 'name';
  sortOrder: 'asc' | 'desc' = 'asc';

  isLoading = false;

  private destroy$ = new Subject<void>();

  constructor(
    private fb: FormBuilder,
    private employeeService: EmployeeService,
    private filterService: FilterService
  ) {
    this.filterForm = this.fb.group({
      department: [''],
      location: [''],
      activeOnly: [false],
      searchText: ['']
    });
  }

  ngOnInit(): void {
    this.setupFilterSubscriptions();
    this.init();
  }

  ngOnDestroy(): void {
    this.destroy$.next();
    this.destroy$.complete();
  }

  init(): void {
    this.employeeService.getEmployees()
      .pipe(takeUntil(this.destroy$))
      .subscribe({
        next: (employees) => {
          console.log('Loaded employees', employees.length);
          this.employees = this.filterService.buildSearchIndex(employees);
          this.departments = this.getUnique(this.employees.map(e => e.department));
          this.locations = this.getUnique(this.employees.map(e => e.location));
          this.displayedEmployees = [...this.employees];
          this.applyFilters();
        },
        error: (err) => {
          console.error('Failed to load employees', err);
          alert('Failed to load employees.');
        }
      });
  }

  private setupFilterSubscriptions(): void {
    const searchControl = this.filterForm.get('searchText');
    if (searchControl) {
      searchControl.valueChanges
        .pipe(debounceTime(300), takeUntil(this.destroy$))
        .subscribe(() => this.applyFilters());
    }

    merge(
      this.filterForm.get('department')!.valueChanges,
      this.filterForm.get('location')!.valueChanges,
      this.filterForm.get('activeOnly')!.valueChanges
    )
      .pipe(takeUntil(this.destroy$))
      .subscribe(() => this.applyFilters());
  }

  applyFilters(): void {
    const loadingEl = document.getElementById('loading');
    if (loadingEl) {
      loadingEl.style.display = 'block';
    }
    this.isLoading = true;

    const { department, location, activeOnly, searchText } = this.filterForm.value;

    this.filterDept = department ?? '';
    this.filterLocation = location ?? '';
    this.filterActive = !!activeOnly;
    this.searchText = (searchText ?? '').toString();

    let filtered = [...this.employees];

    if (this.filterDept) {
      filtered = filtered.filter(emp => emp.department === this.filterDept);
    }
    if (this.filterLocation) {
      filtered = filtered.filter(emp => emp.location === this.filterLocation);
    }
    if (this.filterActive) {
      filtered = filtered.filter(emp => emp.active);
    }
    if (this.searchText.trim()) {
      const term = this.searchText.trim().toLowerCase();
      filtered = filtered.filter(emp => (emp.searchIndex ?? '').includes(term));
    }

    this.displayedEmployees = filtered;
    this.applySorting();

    this.isLoading = false;
    if (loadingEl) {
      loadingEl.style.display = 'none';
    }
  }

  applySorting(): void {
    const field = this.sortField;
    const order = this.sortOrder === 'asc' ? 1 : -1;
    this.displayedEmployees.sort((a: any, b: any) => {
      const valA = a[field];
      const valB = b[field];
      if (valA == null && valB == null) { return 0; }
      if (valA == null) { return -1 * order; }
      if (valB == null) { return 1 * order; }
      if (typeof valA === 'string' && typeof valB === 'string') {
        return valA.localeCompare(valB) * order;
      }
      if (valA > valB) { return 1 * order; }
      if (valA < valB) { return -1 * order; }
      return 0;
    });
  }

  toggleSortOrder(): void {
    this.sortOrder = this.sortOrder === 'asc' ? 'desc' : 'asc';
    this.applySorting();
  }

  onSortFieldChange(field: string): void {
    this.sortField = field as keyof Employee;
    this.applySorting();
  }

  selectEmployee(employee: Employee): void {
    const index = this.selectedEmployees.findIndex(e => e.id === employee.id);
    if (index === -1) {
      this.selectedEmployees.push(employee);
    } else {
      this.selectedEmployees.splice(index, 1);
    }
  }

  deselectEmployee(employee: Employee): void {
    const index = this.selectedEmployees.findIndex(e => e.id === employee.id);
    if (index !== -1) {
      this.selectedEmployees.splice(index, 1);
    }
  }

  isSelected(employee: Employee): boolean {
    return this.selectedEmployees.some(e => e.id === employee.id);
  }

  clearSelection(): void {
    this.selectedEmployees = [];
  }

  getTotalCount(): number {
    return this.employees.length;
  }

  getFilteredCount(): number {
    return this.displayedEmployees.length;
  }

  getSelectedCount(): number {
    return this.selectedEmployees.length;
  }

  exportSelected(): void {
    const maxExportSize = (window as any).APP_CONFIG?.maxExportSize ?? 50;
    if (this.selectedEmployees.length === 0) {
      alert('Please select at least one employee to export.');
      return;
    }
    if (this.selectedEmployees.length > maxExportSize) {
      alert(`You can export at most ${maxExportSize} employees at a time.`);
      return;
    }

    const payload = this.selectedEmployees.map(emp => ({
      id: emp.id,
      name: emp.name,
      department: emp.department,
      location: emp.location,
      active: emp.active
    }));

    console.log('Export payload:', payload);
    alert(`Exported ${payload.length} employees (see console).`);
  }

  trackById(_: number, emp: Employee): number {
    return emp.id;
  }

  private getUnique(items: Array<string | undefined>): string[] {
    return Array.from(new Set(items.filter(Boolean) as string[])).sort();
  }
}
