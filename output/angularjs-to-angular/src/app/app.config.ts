import { InjectionToken } from '@angular/core';

export interface AppConfig {
  dataUrl: string;
  defaultSort: string;
  maxExportSize: number;
}

export const APP_CONFIG = new InjectionToken<AppConfig>('APP_CONFIG');

export function initGlobalConfig(config: AppConfig): void {
  (window as any).APP_CONFIG = config;
  (window as any).employeeCache = null;
  (window as any).lastLoadTime = null;
}
