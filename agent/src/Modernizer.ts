import path from "path";
import { delay, forkJoin } from "rxjs";
import { Analyzer } from "./Analyzer";
import { Generator } from "./Generator";
import { CombinedReport, GeneratedFile, TAiClient, TParser } from "./types";
import { ReportParser } from "./ReportParser";
import { RxReadWrite } from "./RxReadWrite";
import { EReportTypes } from "./enums";

export class Modernizer {
  constructor(
    private readonly client: TAiClient,
    private readonly readWrite: RxReadWrite,
    private readonly analyzer: Analyzer,
    private readonly testParser: TParser,
    private readonly codeParser: TParser,
    private readonly reportParser: ReportParser,
    private readonly updatedPath: string,
    private readonly reportPaths: Record<EReportTypes, string>
  ) {}

  runFullModernize() {
    forkJoin([
      this.analyzer.createAnalysis$(
        this.testParser,
        this.reportPaths[EReportTypes.GLOBAL]
      ),
      this.analyzer.createAnalysis$(
        this.codeParser,
        this.reportPaths[EReportTypes.INDIVIDUAL]
      ),
    ])
      .pipe(delay(10))
      .subscribe(() => {
        console.log("Individual and Global Reports completed.");
        this.generateCombinedReport();
      });
  }
  private addRootJsonFiles(files: GeneratedFile[]): GeneratedFile[] {
    const angularJson: GeneratedFile = {
      path: "angular.json",
      contents: `
{
  "$schema": "./node_modules/@angular/cli/lib/config/schema.json",
  "version": 1,
  "projects": {
    "generated-app": {
      "projectType": "application",
      "root": "src",
      "sourceRoot": "src",
      "prefix": "app",
      "targets": {
        "build": {
          "builder": "@angular-devkit/build-angular:browser",
          "options": {
            "outputPath": "dist/generated-app",
            "index": "src/index.html",
            "main": "src/main.ts",
            "polyfills": "src/polyfills.ts",
            "tsConfig": "tsconfig.json",
            "assets": [],
            "styles": [],
            "scripts": []
          }
        },
        "serve": {
          "builder": "@angular-devkit/build-angular:dev-server",
          "options": {
            "buildTarget": "generated-app:build"
          }
        }
      }
    }
  },
  "cli": {
    "analytics": false
  }
}
`.trim(),
    };

    const packageJson: GeneratedFile = {
      path: "package.json",
      contents: `
{
  "name": "generated-app",
  "version": "0.0.1",
  "scripts": {
    "start": "ng serve",
    "build": "ng build"
  },
  "dependencies": {
    "@angular/common": "^19.2.18",
    "@angular/core": "^19.2.18",
    "@angular/forms": "^19.2.18",
    "@angular/platform-browser": "^19.2.18",
    "@angular/router": "^19.2.18",
    "rxjs": "^7.8.2"
  },
  "devDependencies": {
    "@angular-devkit/build-angular": "^19.2.19",
    "@angular/cli": "^19.2.19",
    "typescript": "^5.8.3"
  }
}
`.trim(),
    };

    const tsconfig: GeneratedFile = {
      path: "tsconfig.json",
      contents: `
{
  "compileOnSave": false,
  "compilerOptions": {
    "baseUrl": "./",
    "outDir": "./dist/out-tsc",
    "sourceMap": true,
    "strict": true,
    "module": "es2020",
    "moduleResolution": "node",
    "target": "es2020",
    "lib": ["es2020", "dom"]
  }
}
`.trim(),
    };

    return [...files, angularJson, packageJson, tsconfig];
  }
  addMinimalRootFiles(files: GeneratedFile[]): GeneratedFile[] {
    const rootFiles: GeneratedFile[] = [
      {
        path: "src/main.ts",
        contents: `
import { bootstrapApplication } from '@angular/platform-browser';
import { AppComponent } from './app/app.component';

bootstrapApplication(AppComponent).catch(err => console.error(err));
      `.trim(),
      },
      {
        path: "src/polyfills.ts",
        contents: `
// Minimal polyfills; can be left empty for modern browsers
      `.trim(),
      },
      {
        path: "src/index.html",
        contents: `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <title>GeneratedApp</title>
  <base href="/" />
</head>
<body>
  <app-root></app-root>
</body>
</html>
      `.trim(),
      },
      {
        path: "src/app/app.component.ts",
        contents: `
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: '<div>App is running!</div>',
  standalone: true
})
export class AppComponent {}
      `.trim(),
      },
    ];

    return [...files, ...this.addRootJsonFiles(rootFiles)];
  }
  public generateCombinedReport(write: boolean = true) {
    console.log("Generating combined report");
    const report: CombinedReport = this.reportParser.generateCombinedReport(
      this.reportPaths[EReportTypes.GLOBAL],
      this.reportPaths[EReportTypes.INDIVIDUAL]
    );
    this.readWrite
      .write$(
        path.resolve(this.reportPaths[EReportTypes.RELATIONAL]),
        JSON.stringify(report, null, 2)
      )
      .subscribe(() => {
        console.log(
          `Combined report written to ${
            this.reportPaths[EReportTypes.RELATIONAL]
          }`
        );
        if (write) {
          this.writeFiles(report);
        }
      });
  }

  private writeFiles(report: CombinedReport) {
    const generator: Generator = new Generator(this.client, report);
    generator.generateApp$().subscribe((files: GeneratedFile[]) => {
      const allFiles = this.addMinimalRootFiles(files);
      console.log("files generated");
      this.readWrite.writeGeneratedFiles(allFiles, this.updatedPath);
      console.log("files written");
    });
  }
}
