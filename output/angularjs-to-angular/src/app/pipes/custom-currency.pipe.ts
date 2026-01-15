import { Pipe, PipeTransform } from '@angular/core';

@Pipe({ name: 'customCurrency', standalone: true })
export class CustomCurrencyPipe implements PipeTransform {
  transform(input: number | string | null | undefined): string {
    const num = Number(input);
    if (isNaN(num)) return '$0.00';
    return `$${num.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;
  }
}
