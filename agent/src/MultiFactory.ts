import { ESourceLanguages } from "./enums";
import { MultiModernizer } from "./MulitModernizer";
import { RxReadWrite } from "./RxReadWrite";
import { TAiClient } from "./types";

export class MultiFactory {
  constructor(
    private readonly readWrite: RxReadWrite,
    private readonly client: TAiClient,
    private readonly coderClient: TAiClient
  ) {}
  create(): Record<ESourceLanguages, MultiModernizer> {
    return {
      [ESourceLanguages.ANGULARJS]: new MultiModernizer(
        ESourceLanguages.ANGULARJS,
        this.readWrite,
        this.client,
        this.coderClient
      ),
      [ESourceLanguages.PERL]: new MultiModernizer(
        ESourceLanguages.PERL,
        this.readWrite,
        this.client,
        this.coderClient
      ),
      [ESourceLanguages.STRUTS]: new MultiModernizer(
        ESourceLanguages.STRUTS,
        this.readWrite,
        this.client,
        this.coderClient
      ),
    };
  }
}
