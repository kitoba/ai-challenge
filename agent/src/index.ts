
import { OpenRouterClient } from "./OpenRouterClient";
import { config } from "dotenv";
import { EModels, ESourceLanguages } from "./enums";
import { RxReadWrite } from "./RxReadWrite";
import { TAiClient } from "./types";
import { MultiModernizer } from "./MulitModernizer";
import { MultiFactory } from "./MultiFactory";
config();

const API_KEY: string = process.env.OPENROUTER_API_KEY as string;
const LIMIT: number = parseInt(process.env.OPENROUTER_LIMIT as string, 10);
const client: TAiClient = new OpenRouterClient(API_KEY, EModels.GPT_OSS, LIMIT);
const coderClient: TAiClient = new OpenRouterClient(API_KEY, EModels.CODEX, LIMIT);
const readWrite: RxReadWrite = new RxReadWrite();
const multiFactory: MultiFactory = new MultiFactory(readWrite, client, coderClient);
const modernizers: Record<ESourceLanguages, MultiModernizer> = multiFactory.create();
modernizers.perl.analyzeUniversal$().subscribe();
modernizers.struts.analyzeUniversal$().subscribe();
modernizers.angular.runFullModernize();