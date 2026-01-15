import fs, { Dirent } from "fs";
import path from "path";
import {
  EMPTY,
  filter,
  from,
  map,
  mergeMap,
  Observable,
  Observer,
  of,
  reduce,
} from "rxjs";
import { EExclusions, EExtensions } from "./enums";
import { GeneratedFile } from "./types";

export class RxReadWrite {
  read$(filePath: string): Observable<string> {
    return new Observable((observer: Observer<string>) => {
      fs.readFile(filePath, { encoding: "utf-8" }, (err, content: string) => {
        if (err) {
          console.error(err);
          observer.error(err);
        }
        observer.next(content);
        observer.complete();
      });
    });
  }
  write$(filePath: string, content: string): Observable<void> {
    return new Observable((observer: Observer<void>) => {
      fs.writeFile(filePath, content, { encoding: "utf-8" }, (err) => {
        if (err) {
          console.error(err);
          observer.error(err);
        } else {
          observer.next();
          observer.complete();
        }
      });
    });
  }
  readDir$(dir: string): Observable<Dirent[]> {
    return new Observable((observer: Observer<Dirent[]>) => {
      fs.readdir(dir, { withFileTypes: true }, (err, files: Dirent[]) => {
        if (err) {
          console.error(err);
          return observer.error(err);
        }
        observer.next(files);
        observer.complete();
      });
    });
  }
  public walk$(dir: string): Observable<string[]> {
    return this.readDir$(dir).pipe(
      mergeMap((entries: Dirent[]) =>
        from(entries).pipe(
          filter(
            (entry) =>
              !Object.values(EExclusions).includes(entry.name as EExclusions)
          ),
          mergeMap((entry) => {
            const fullPath = path.join(dir, entry.name);

            if (entry.isDirectory()) {
              return this.walk$(fullPath);
            }

            if (this.isSourceFile(entry.name)) {
              return of([fullPath]);
            }

            return EMPTY;
          }),
          reduce((acc: string[], curr: string[]) => acc.concat(curr), [])
        )
      ),
      map((results) => results.sort()) // deterministic ordering
    );
  }
  private isSourceFile(name: string): boolean {
    return Object.values(EExtensions).some((ext) => name.endsWith(ext));
  }
  writeGeneratedFiles(files: GeneratedFile[], rootDir: string): void {
    for (const file of files) {
      const fullPath = path.join(rootDir, file.path);
      const dir = path.dirname(fullPath);

      this.ensureDirectoryExists(dir);
      // Write file
      fs.writeFileSync(fullPath, file.contents, "utf8");
    }
  }
  ensureDirectoryExists(dir: string) {
  // Ensure directory exists
      fs.mkdirSync(dir, { recursive: true });
  }
}
