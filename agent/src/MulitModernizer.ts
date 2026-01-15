import { Analyzer } from "./Analyzer";
import { EReportTypes, ESourceLanguages, ETestFrameworks } from "./enums";
import { Modernizer } from "./Modernizer";
import { AngularCodeParser } from "./AngularCodeParser";
import { ReportParser } from "./ReportParser";
import { RxReadWrite } from "./RxReadWrite";
import { TestParser } from "./TestParser";
import { TAiClient, TParser } from "./types";

export class MultiModernizer {
  private readonly reportPath = "./model";
  private readonly outputPath = "../output";
  private readonly basePaths: Record<ESourceLanguages, string> = {
    [ESourceLanguages.ANGULARJS]: "../challenges/1-angularjs-to-angular",
    [ESourceLanguages.PERL]: "../challenges/2-perl-to-python",
    [ESourceLanguages.STRUTS]: "../challenges/3-struts-to-spring",
  };
  private readonly testPaths: Record<ESourceLanguages, string> = {
    [ESourceLanguages.ANGULARJS]: "/tests/e2e/behavioral.test.ts",
    [ESourceLanguages.PERL]: "/tests/integration/test_behavioral.py",
    [ESourceLanguages.STRUTS]: "/tests/verify-spring-migration.sh",
  };
  private readonly outputPaths: Record<ESourceLanguages, string> = {
    [ESourceLanguages.ANGULARJS]: "/angularjs-to-angular",
    [ESourceLanguages.PERL]: "/perl-to-python",
    [ESourceLanguages.STRUTS]: "struts-to-spring",
  };
  private readonly testLanguages: Record<ESourceLanguages, ETestFrameworks> = {
    [ESourceLanguages.ANGULARJS]: ETestFrameworks.JEST,
    [ESourceLanguages.PERL]: ETestFrameworks.PERL,
    [ESourceLanguages.STRUTS]: ETestFrameworks.STRUTS,
  };

  private readonly agent: Modernizer;
  private readonly analyzer: Analyzer;
  private readonly testParser: TParser;
  private readonly codeParser: TParser;
  private readonly reportPaths: Record<EReportTypes, string>;
  constructor(
    private readonly type: ESourceLanguages,
    private readonly readWrite: RxReadWrite,
    client: TAiClient,
    coderClient: TAiClient
  ) {
    const updatedPath = `${this.outputPath}${this.outputPaths[type]}`;
    const testPath = `${this.basePaths[type]}${this.testPaths[type]}`;
    this.testParser = new TestParser(
      this.testLanguages[type],
      readWrite,
      testPath
    );
    this.codeParser = this.getCodeParser() as TParser;
    const reportParser = new ReportParser();
    this.reportPaths = this.getReportPaths();
    this.analyzer = new Analyzer(client, readWrite);
    this.agent = new Modernizer(
      coderClient,
      readWrite,
      this.analyzer,
      this.testParser,
      this.codeParser,
      reportParser,
      updatedPath,
      this.reportPaths
    );
    this.readWrite.ensureDirectoryExists(this.reportPath);
    this.readWrite.ensureDirectoryExists(`${this.reportPath}/${this.type}`);
    console.log("report directory created");
  }
  analyzeUniversal$() {
    return this.analyzer.createAnalysis$(this.testParser, this.reportPaths[EReportTypes.GLOBAL]);
  }
  analyzeIndividual$() {
    return this.analyzer.createAnalysis$(this.codeParser, this.reportPaths[EReportTypes.INDIVIDUAL]);
  }
  generateCombinedReport() {
    this.agent.generateCombinedReport();
  }
  runFullModernize() {
    this.agent.runFullModernize();
  }
  private getCodeParser(): TParser | null {
    switch (this.type) {
      case ESourceLanguages.ANGULARJS: {
        const codePath: string = `${this.basePaths[this.type]}/legacy-app`;
        return new AngularCodeParser(this.readWrite, codePath);
      }
    }
    return null;
  }
  private getReportPaths(): Record<EReportTypes, string> {
    return {
      [EReportTypes.GLOBAL]: `${this.reportPath}/${this.type}/${EReportTypes.GLOBAL}.md`,
      [EReportTypes.INDIVIDUAL]: `${this.reportPath}/${this.type}/${EReportTypes.INDIVIDUAL}.json`,
      [EReportTypes.RELATIONAL]: `${this.reportPath}/${this.type}/${EReportTypes.RELATIONAL}.json`,
    };
  }
}
