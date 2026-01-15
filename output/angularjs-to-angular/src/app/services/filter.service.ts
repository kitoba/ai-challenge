import { Injectable } from '@angular/core';
import { Employee } from '../models/employee';

@Injectable({ providedIn: 'root' })
export class FilterService {
  private searchIndex: Record<number, string> = {};

  buildSearchIndex(employees: Employee[], callback?: () => void): void {
    setTimeout(() => {
      this.searchIndex = {};
      employees.forEach(emp => {
        const text = `${emp.name} ${emp.department} ${emp.skills?.join(' ')}`.toLowerCase();
        this.searchIndex[emp.id] = text;
      });
      callback?.();
    }, 0);
  }

  searchEmployees(employees: Employee[], searchText: string): Employee[] {
    if (!searchText) return employees;
    return employees.filter(emp => this.matchesSearch(emp, searchText));
  }

  matchesSearch(employee: Employee, searchText: string): boolean {
    const term = (searchText || '').toLowerCase().trim();
    if (!term) return true;
    const index = this.searchIndex[employee.id] || `${employee.name} ${employee.department}`.toLowerCase();
    return index.includes(term);
  }

  filterByDepartment(employees: Employee[], department: string): Employee[] | null {
    if (!department || department === 'All') return employees;
    return employees.filter(emp => emp.department === department);
  }
}
