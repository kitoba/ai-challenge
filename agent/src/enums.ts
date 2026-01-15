export enum ETestFrameworks {
    JEST = "jest",
    PERL = "perl",
    STRUTS = "struts"
}
export enum EModels {
    GPT_4_MINI = "openai/gpt-4o-mini",
    GPT_5_MINI = "openai/gpt-5-mini",
    GPT_OSS = "openai/gpt-oss-120b",
    MISTRAL = "mistralai/devstral-2512",
    GROK = "x-ai/grok-code-fast-1",
    CLAUDE = "anthropic/claude-opus-4.5",
    CODEX = "openai/gpt-5.2-codex"
}
export enum ESourceLanguages {
    ANGULARJS = "angular",
    PERL = "perl",
    STRUTS = "struts"
}
export enum EExtensions {
    JS = ".js",
    TS = ".ts",
    JSX = ".jsx",
    COFFEE = ".coffee"
}
export enum EExclusions {
    NODE_MODULES = "node_modules",
    DIST= "dist", 
    BUILD = "build"
}
export enum EUniversalBlockKind {
    MODEL = "Model",
    OPERATION = "Operation",
    INVARIANT = "Invariant",
    EDGE_CASE = "EdgeCase",
    NARRATIVE = "Narrative",
    UNKNOWN = "Unknown"
}
export enum EAngularUnitTypes {
    COMPONENT = 'component',
    DIRECTIVE = 'directive',
    PIPE =  'pipe',
    SERVICE = 'service',
    CONTROLLER = 'controller',
    OTHER = 'other'
}
export enum EReportTypes {
    INDIVIDUAL = "individual",
    GLOBAL = "global",
    RELATIONAL = "relational"
}