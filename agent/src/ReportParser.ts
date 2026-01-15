import fs from "fs";
import path from "path";
import {
  CombinedReport,
  IndividualUnit,
} from "./types";
import { EUniversalBlockKind } from "./enums";

export class ReportParser {
  parse(report: string) {
    const blocks: any[] = [];

    const sections = this.splitIntoSections(report);
    for (const section of sections) {
      const header = this.parseHeader(section.header);
      if (!header) {
        blocks.push({
          kind: 'Unknown',
          name: 'UnparseableSection',
          raw: section,
        });
        continue;
      }

      const { kind, name } = header;

      const block: any = { kind, name };

      switch (kind) {
        case 'Narrative':
          this.parseNarrative(section.body, block);
          break;

        case 'Model':
          this.parseModel(section.body, block);
          break;

        case 'Operation':
          this.parseOperation(section.body, block);
          break;

        case 'Invariant':
          this.parseInvariant(section.body, block);
          break;

        case 'EdgeCase':
          this.parseEdgeCase(section.body, block);
          break;

        case 'Unknown':
          this.parseUnknown(section.body, block);
          break;

        default:
          block.raw = section.body;
      }

      blocks.push(block);
    }
    console.log("universal report parsed");
    return blocks;
  }

  // ────────────────────────────────────────────────────────────
  // Section splitting
  // ────────────────────────────────────────────────────────────

  private splitIntoSections(report: string) {
  const lines = report.split(/\r?\n/);
  const sections: { header: string; body: string[] }[] = [];

  let currentHeader: string | null = null;
  let currentBody: string[] = [];

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();

    // Match Markdown bold headers: **Kind – Name**
    const headerMatch = line.match(/^\*\*(.+?)\*\*$/);
    if (headerMatch) {
      // Push previous section if any
      if (currentHeader !== null) {
        sections.push({ header: currentHeader, body: currentBody });
      }

      currentHeader = headerMatch[1].trim();
      currentBody = [];
    } else if (currentHeader !== null) {
      currentBody.push(lines[i]); // preserve indentation for parsing lists
    }
  }

  // push last section
  if (currentHeader !== null) {
    sections.push({ header: currentHeader, body: currentBody });
  }

  return sections;
}

  private parseHeader(header: string) {
    const match = header.match(/^(.+?)\s+–\s+(.+)$/);
    if (!match) return null;

    return {
      kind: match[1].trim() as EUniversalBlockKind,
      name: match[2].trim(),
    };
  }

  // ────────────────────────────────────────────────────────────
  // Block parsers
  // ────────────────────────────────────────────────────────────

  private parseNarrative(lines: string[], block: any) {
    const content = this.collectIndentedList(lines, 'Content');
    if (content.length) {
      block.notes = content;
    } else {
      block.raw = lines;
    }
  }

  private parseModel(lines: string[], block: any) {
    const fields: { name: string; type?: string }[] = [];

    const fieldLines = this.collectIndentedList(lines, 'Fields');

    for (const line of fieldLines) {
      // Example: id: number — unique identifier
      const match = line.match(/^(.+?):\s*([^\s—]+)?/);
      if (match) {
        fields.push({
          name: match[1].trim(),
          type: match[2]?.trim(),
        });
      }
    }

    if (fields.length) {
      block.fields = fields;
    } else {
      block.raw = lines;
    }
  }

  private parseOperation(lines: string[], block: any) {
    block.description = this.extractSingleLine(lines, 'Description');

    const behaviors = this.collectIndentedList(lines, 'Behaviors');
    if (behaviors.length) {
      block.behavior = behaviors.join('\n');
    }

    if (!block.description && !block.behavior) {
      block.raw = lines;
    }
  }

  private parseInvariant(lines: string[], block: any) {
    const statements = this.collectIndentedList(lines, 'Statements');
    if (statements.length) {
      block.invariants = statements;
    } else {
      block.raw = lines;
    }
  }

  private parseEdgeCase(lines: string[], block: any) {
    const scenarios = this.collectIndentedList(lines, 'Scenarios');
    if (scenarios.length) {
      block.notes = scenarios;
    } else {
      block.raw = lines;
    }
  }

  private parseUnknown(lines: string[], block: any) {
    const notes = this.collectIndentedList(lines, 'Notes');
    if (notes.length) {
      block.notes = notes;
    } else {
      block.raw = lines;
    }
  }

  // ────────────────────────────────────────────────────────────
  // Helpers
  // ────────────────────────────────────────────────────────────

  private extractSingleLine(lines: string[], label: string): string | undefined {
    const line = lines.find(l => l.trim().startsWith(`- ${label}:`));
    if (!line) return undefined;
    return line.replace(`- ${label}:`, '').trim();
  }

  private collectIndentedList(lines: string[], label: string): string[] {
    const result: string[] = [];
    let collecting = false;

    for (const line of lines) {
      if (line.trim().startsWith(`- ${label}:`)) {
        collecting = true;
        continue;
      }

      if (collecting) {
        if (line.startsWith('  - ')) {
          result.push(line.replace(/^  - /, '').trim());
        } else if (line.trim() === '') {
          continue;
        } else {
          break;
        }
      }
    }

    return result;
  }

  /**
   * Main function: reads raw report files and produces CombinedReport JSON
   */
  generateCombinedReport(
    universalPath: string,
    individualPath: string
  ): CombinedReport {
    const universalRaw = fs.readFileSync(path.resolve(universalPath), "utf-8");
    const individualRaw = fs.readFileSync(
      path.resolve(individualPath),
      "utf-8"
    );
    const combined: CombinedReport = {
      universal: this.parse(universalRaw),
      individual: JSON.parse(individualRaw) as IndividualUnit[]
    };
    return combined;
  }
}
