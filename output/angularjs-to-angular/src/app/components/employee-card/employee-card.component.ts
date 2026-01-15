import { Component, Input, Renderer2, ElementRef, HostBinding, OnChanges, SimpleChanges } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Employee } from '../../models/employee';
import { CustomCurrencyPipe } from '../../pipes/custom-currency.pipe';
import { CustomDatePipe } from '../../pipes/custom-date.pipe';

@Component({
  selector: 'employee-card',
  standalone: true,
  imports: [CommonModule, CustomCurrencyPipe, CustomDatePipe],
  templateUrl: './employee-card.component.html',
  styleUrls: ['./employee-card.component.scss']
})
export class EmployeeCardComponent implements OnChanges {
  @Input() employee!: Employee;
  @Input() onSelect?: (employee: Employee) => void;
  @Input() isSelected?: (employee: Employee) => boolean;

  @HostBinding('style.opacity') opacity = '1';

  constructor(private renderer: Renderer2, private el: ElementRef) {}

  ngOnChanges(changes: SimpleChanges): void {
    if (changes['employee']) {
      this.opacity = this.employee?.active ? '1' : '0.5';
    }
  }

  handleSelect(): void {
    this.onSelect?.(this.employee);
    const element = this.el.nativeElement.querySelector('.employee-card');
    this.renderer.addClass(element, 'highlight');
    setTimeout(() => this.renderer.removeClass(element, 'highlight'), 300);
  }

  get selected(): boolean {
    return this.isSelected ? this.isSelected(this.employee) : false;
  }
}
