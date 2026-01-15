import { Observable } from "rxjs";
import { EAngularUnitTypes, EModels, ESourceLanguages, ETestFrameworks, EUniversalBlockKind } from "./enums";

export type SourceFile = {
  path: string;
  language: ESourceLanguages;
  content: string;
};

export type TestFile = {
  path: string;
  framework?: ETestFrameworks;
  content: string;
};

export type LegacyApp = {
  source: SourceFile[];
  tests: TestFile[];
};
export type CodeSynopsis = {
  files: {
    path: string;
    exports?: string[];
    entryPoint?: boolean;
  }[];
};
export interface OpenResponse {
  choices: { message: {content: string}}[];
}
export type tRequest = {
  "universal-prompt": string,
  "social-prompt": string,
  "individual-prompt": string,
  discussion: boolean;
  model: EModels; 
  recursion: number;
  temp: number;
  topic: string;
}
export type TParser = {
  ingest$(): Observable<string>;
}
export type TAiClient = {
  call$: (prompt: string) => Observable<string>;
}

export interface EntityField {
  name: string;
  type: string;
  remarks?: string;
}

export interface EntitySpec {
  name: string;
  fields: EntityField[];
  derivedFrom?: string;
}

export interface OperationSpec {
  name: string;
  signature: string;
  behavior: string;
  workflowExamples?: string[];
}

export interface InvariantSpec {
  description: string;
  enforcementNotes?: string;
}

export interface TestSpec {
  operation: string;
  input: any;
  expectedOutput: any;
  notes?: string;
}

export interface UniversalReport {
  systemPurpose: string;
  entities: EntitySpec[];
  operations: OperationSpec[];
  invariants: InvariantSpec[];
  tests: TestSpec[];
  unknowns?: string[];
}

export interface ResponsibilityUnit {
  id: number;
  name: string;
  evidenceFile?: string;
  evidenceLine?: number;
  responsibility: string;
  inputs: string[];
  outputs: string[];
  stateUsage: string[];
  sideEffects: string[];
  notes?: string;
}


export interface CombinedReport {
  universal: NormalizedUniversalBlock[];
  individual: IndividualUnit[];
}
export type UniversalEntity = {
  name: string;
  properties: Record<string, string>;
};

export type IndividualUnit = {
  id: number;
  name: string;
  evidence: string;
  responsibility: string;
  inputs: string[];
  outputs: string[];
  stateUsage: string[];
  sideEffects: string[];
  unitType: EAngularUnitTypes;
  selector: string;
  lifecycleHooks: string[],
  templateHints: string,
  parent: string,
  childComponents: string[]
};

export type Reports = {
  universal: {
    entities: UniversalEntity[];
  };
  individual: IndividualUnit[];
};


export interface NormalizedUniversalBlock {
  kind: EUniversalBlockKind;
  name: string;
  description?: string;
  fields?: { name: string; type?: string }[];
  signature?: string;
  behavior?: string;
  invariants?: string[];
  notes?: string[];
  raw?: unknown; // lossless fallback
}
export interface GeneratedFile {
  path: string;
  contents: string;
}
export interface LLMChunk {
  module: string; // inferred feature/module
  universalBlocks: NormalizedUniversalBlock[];
  units: IndividualUnit[];
  dependencies: Record<string, string[]>; // unitName -> childComponents
  llmHints: Record<string, any>; // unitName -> hints (inputs, outputs, stateUsage, sideEffects, lifecycleHooks, templateHints)
}