import { TParser } from "./types";
import { map, Observable } from "rxjs";
import path from "path";
import { ETestFrameworks } from "./enums";
import { RxReadWrite } from "./RxReadWrite";
import { universalPromptFromTests } from "./prompts";

export class TestParser implements TParser {
  private readonly matcher: Record<ETestFrameworks, RegExp> = {
    [ETestFrameworks.JEST]: /\b(describe|context)\s*\(/,
    [ETestFrameworks.PERL]: /\b(def)\s*\(/,
    [ETestFrameworks.STRUTS]: /\b(pass)\s*\(/
  }
  private readonly fullPath: string;
  constructor(
    private readonly type: ETestFrameworks,
    private readonly readWrite: RxReadWrite,
    testFilePath: string
  ) {
    this.fullPath = path.resolve(testFilePath);
  }
  ingest$(): Observable<string> {
      console.log(`Ingesting ${this.fullPath}`);
      return this.readWrite.read$(this.fullPath)
        .pipe(
          map((content: string) => universalPromptFromTests({
            path: this.fullPath,
            content: this.stripPreamble(content),
            framework: ETestFrameworks.JEST
          })));
  }
  stripPreamble(content: string): string {
    const match = content.match(this.matcher[this.type]);
    if (!match || match.index === undefined) {
      // If we can't find a test block, return content unchanged
      return content;
    }
    return content.slice(match.index);
  }

}