import { ChangeDetectionStrategy, Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Employee } from '../models/employee.model';

@Component({
  selector: 'employee-card',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './employee-card.component.html',
  styleUrl: './employee-card.component.scss',
  changeDetection: ChangeDetectionStrategy.OnPush
})
export class EmployeeCardComponent {
  @Input({ required: true }) employee!: Employee;
  @Input() onSelect?: (employee: Employee) => void;
  @Input() isSelected?: (employee: Employee) => boolean;

  handleSelect(): void {
    if (this.employee && this.onSelect) {
      this.onSelect(this.employee);
    }
  }

  get selected(): boolean {
    return this.isSelected ? this.isSelected(this.employee) : false;
  }
}
