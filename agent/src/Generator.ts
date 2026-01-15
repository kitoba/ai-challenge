import { forkJoin, map, Observable } from "rxjs";
import {
  IndividualUnit,
  GeneratedFile,
  CombinedReport,
  LLMChunk,
  TAiClient,
} from "./types";

export class Generator {
  constructor(
    private readonly client: TAiClient,
    private readonly report: CombinedReport
  ) {}

  createLLMChunks(): LLMChunk[] {
    const chunksMap: Record<string, LLMChunk> = {};

    // Step 1: Build parent -> children mapping
    const parentMap: Record<string, IndividualUnit[]> = {};
    for (const unit of this.report.individual) {
      const parent = unit.parent || "rootModule";
      if (!parentMap[parent]) parentMap[parent] = [];
      parentMap[parent].push(unit);
    }

    // Step 2: Recursive function to collect all children of a module/unit
    const collectUnits = (moduleName: string): IndividualUnit[] => {
      const directUnits = parentMap[moduleName] || [];
      const allUnits: IndividualUnit[] = [...directUnits];
      for (const u of directUnits) {
        if (u.childComponents && u.childComponents.length > 0) {
          for (const childName of u.childComponents) {
            const childUnit = this.report.individual.find(
              (x) => x.name === childName
            );
            if (childUnit && !allUnits.includes(childUnit)) {
              allUnits.push(...collectUnits(childUnit.name));
            }
          }
        }
      }
      return allUnits;
    };

    // Step 3: Create chunks
    for (const moduleName in parentMap) {
      const moduleUnits = collectUnits(moduleName);

      // Map dependencies: unitName -> childComponents
      const dependencies: Record<string, string[]> = {};
      const llmHints: Record<string, any> = {};

      for (const unit of moduleUnits) {
        dependencies[unit.name] = unit.childComponents || [];
        llmHints[unit.name] = {
          inputs: unit.inputs,
          outputs: unit.outputs,
          stateUsage: unit.stateUsage,
          sideEffects: unit.sideEffects,
          lifecycleHooks: unit.lifecycleHooks,
          templateHints: unit.templateHints,
        };
      }

      // Associate universal blocks that match units
      const associatedBlocks = this.report.universal.filter((block) =>
        moduleUnits.some((u) => u.name === block.name)
      );

      chunksMap[moduleName] = {
        module: moduleName,
        universalBlocks: associatedBlocks,
        units: moduleUnits,
        dependencies,
        llmHints,
      };
    }

    return Object.values(chunksMap);
  }

  private files: GeneratedFile[] = [];

  /** Generate the full app by iterating chunks */
   public generateApp$(): Observable<GeneratedFile[]> {
    const chunks = this.createLLMChunks();

    // Map each chunk to an observable and merge results
    const chunkObservables = chunks.map(chunk => this.generateChunk$(chunk));

    // forkJoin waits for all chunk observables and concatenates results
    return forkJoin(chunkObservables).pipe(
      map((filesArrays: GeneratedFile[][]) => {
        // Flatten array of arrays into single array of GeneratedFile
        return filesArrays.flat();
      })
    );
  }

  /** Generate one chunk using the LLM */
  private generateChunk$(
    chunk: ReturnType<typeof this.createLLMChunks>[0]
  ): Observable<GeneratedFile[]> {
    const prompt = this.buildPrompt(chunk);
    console.log("Chunk created to feed LLM");
    return this.client.call$(prompt).pipe(map((response: string) => {
      // Parse JSON output safely
      try {
        const generatedFiles: GeneratedFile[] = JSON.parse(response.replaceAll("```json", "").replaceAll("```", ""));
        console.log("Files returned...")
        return generatedFiles;
      } catch (err) {
        console.error("Failed to parse LLM output:", response);
        throw err;
      }
    }));
  }

  /** Build prompt for a single chunk */
  private buildPrompt(
    chunk: ReturnType<typeof this.createLLMChunks>[0]
  ): string {
    return `
You are generating a modern Angular v20 application. 
For the following module, generate all TypeScript, HTML, and SCSS files necessary to make it runnable.

- Use standalone: true for components where possible.
- Use Angular best practices (ReactiveForms, RxJS observables if state is reactive).
- Wire Inputs, Outputs, parent-child relationships, and lifecycle hooks correctly.
- Implement stub methods based on behavior and sideEffects.
- Generate HTML templates based on templateHints.
- Return output as JSON array with objects: { "path": "relative/path.ts", "contents": "..." }

Module JSON:
${JSON.stringify(chunk, null, 2)}
    `.trim();
  }
}
