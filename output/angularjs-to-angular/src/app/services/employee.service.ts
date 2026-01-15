import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { APP_CONFIG, AppConfig } from '../app.config';
import { Employee } from '../models/employee';
import { Observable, of } from 'rxjs';
import { catchError, tap } from 'rxjs/operators';

@Injectable({ providedIn: 'root' })
export class EmployeeService {
  private http = inject(HttpClient);
  private config = inject<AppConfig>(APP_CONFIG);

  loadEmployees(
    successCallback?: (employees: Employee[]) => void,
    errorCallback?: (error: any) => void
  ): Observable<Employee[]> {
    const w: any = window as any;
    if (w.employeeCache) {
      console.log('Using cached employees');
      const cached = w.employeeCache as Employee[];
      successCallback?.(cached);
      return of(cached);
    }

    console.log('Loading employees from network');
    return this.http.get<Employee[]>(this.config.dataUrl).pipe(
      tap(employees => {
        w.employeeCache = employees;
        w.lastLoadTime = Date.now();
        successCallback?.(employees);
      }),
      catchError(err => {
        console.error('Failed to load employees', err);
        errorCallback?.(err);
        throw err;
      })
    );
  }

  getEmployeeById(id: number, employees: Employee[]): Employee | null {
    return employees.find(e => e.id === id) || null;
  }

  calculateAverageSalary(employees: Employee[]): number {
    if (!employees || employees.length === 0) return 0;
    const total = employees.reduce((sum, e) => sum + (e.salary || 0), 0);
    return total / employees.length;
  }

  addSkillToEmployee(employeeId: number, skill: string, employees: Employee[]): boolean {
    const employee = this.getEmployeeById(employeeId, employees);
    if (!employee) return false;
    if (!employee.skills) employee.skills = [];
    employee.skills.push(skill);
    return true;
  }
}
