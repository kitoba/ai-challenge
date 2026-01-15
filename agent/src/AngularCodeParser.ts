import path from "path";
import { from, map, mergeMap, Observable, toArray } from "rxjs";
import { RxReadWrite } from "./RxReadWrite";
import { ESourceLanguages } from "./enums";
import { SourceFile, TParser } from "./types";
import { individualPromptFromCode } from "./prompts";

export class AngularCodeParser implements TParser {
  constructor(
    private readonly readWrite: RxReadWrite,
    private readonly rootDir: string
  ) {}

  ingest$(): Observable<string> {
    return this.walkAndGetFiles$().pipe(
      map((sourceFiles: SourceFile[]) => {
        return individualPromptFromCode(this.bundle(sourceFiles));
      })
    );
  }

  walkAndGetFiles$(): Observable<SourceFile[]> {
    return this.readWrite.walk$(this.rootDir).pipe(
      mergeMap((files: string[]) =>
        from(files).pipe(
          mergeMap((file) => this.loadFile$(file)),
          toArray()
        )
      )
    );
  }

  private loadFile$(path: string): Observable<SourceFile> {
    return this.readWrite.read$(path).pipe(
      map((content) => ({
        path,
        language: ESourceLanguages.ANGULARJS,
        content,
      }))
    );
  }
  private sortKey(filePath: string): number {
    const name = filePath.toLowerCase();

    if (name.includes("module")) return 0;
    if (name.includes("config") || name.includes("route")) return 1;
    if (name.includes("service") || name.includes("factory")) return 2;
    if (name.includes("directive")) return 3;
    if (name.includes("controller")) return 4;
    if (name.includes("filter")) return 5;

    return 10;
  }
  private stripComments(content: string): string {
    // Remove single-line comments
    let noSingleLine = content.replace(/\/\/(?!\/).*/g, "");

    // Remove block comments that are NOT JSDoc
    // Matches /* ... */ not starting with /**
    let noBlock = noSingleLine.replace(/\/\*(?!\*)([\s\S]*?)\*\//g, "");

    return noBlock;
  }
  private bundle(files: SourceFile[]): string {
    files.sort((a, b) => this.sortKey(a.path) - this.sortKey(b.path));
    const sections = files.map((file) => {
      const cleaned = this.stripComments(file.content);
      return [
        `## File: ${path.relative(this.rootDir, file.path)}`,
        cleaned.trim(),
      ].join("\n\n");
    });
    return [
      "===== BEGIN SOURCE CODE BUNDLE =====",
      ...sections,
      "===== END SOURCE CODE BUNDLE =====",
    ].join("\n\n");
  }
}
