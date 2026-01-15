import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'customDate', standalone: true })
export class CustomDatePipe implements PipeTransform {
  transform(input: string | null | undefined): string {
    if (!input) return '';
    const [year, month, day] = input.split('-').map(Number);
    const date = new Date(year, month - 1, day);
    return date.toLocaleDateString('en-US', { month: 'short', day: '2-digit', year: 'numeric' });
  }
}
