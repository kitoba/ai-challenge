import { catchError, Observable, switchMap, tap } from "rxjs";
import { TAiClient, TParser } from "./types";
import { RxReadWrite } from "./RxReadWrite";
export class Analyzer {
  constructor(
    private readonly client: TAiClient,
    private readonly readWrite: RxReadWrite
  ) {}
  getPrompt$(parser: TParser): Observable<string> {
    return parser.ingest$();
  }
  getResponse$(prompt: string): Observable<string> {
    return this.client.call$(prompt);
  }
  createAnalysis$(parser: TParser, writePath: string): Observable<void> {
    console.log(`Starting analysis for ${writePath}...`);
    return this.getPrompt$(parser).pipe(
      tap((prompt) => console.log("Prompt created...")),
      switchMap((prompt) => this.getResponse$(prompt)),
      tap((response) => console.log("Response Received...")),
      switchMap((response) => this.readWrite.write$(writePath, response)),
      tap(() => console.log(`Wrote ${writePath}`))
    );
  }
}
