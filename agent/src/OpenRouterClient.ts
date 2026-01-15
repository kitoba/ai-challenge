import fetch, { Response } from "node-fetch";
import { OpenResponse, TAiClient, tRequest } from "./types.ts";

import { EModels } from "./enums.ts";
import { from, map, Observable, Observer } from "rxjs";

export class OpenRouterClient implements TAiClient {
  private temperature: number = 0.7;
  private readonly url = "https://openrouter.ai/api/v1/chat/completions";
  constructor(
    private readonly apiKey: string,
    private model: EModels,
    private readonly maxTokens: number
  ) {
    if (!this.apiKey) {
      throw new Error("apiKey is missing");
    }
  }
  updateVariables(request: tRequest) {
    this.temperature = request.temp;
    if (this.isValidModel(request.model)) {
      this.model = request.model;
    }
  }
  isValidModel(x: string): x is EModels {
    return Object.values(EModels).includes(x as EModels);
  }
  fetch$(prompt: string): Observable<Response> {
    return from(
      fetch(this.url, {
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          model: this.model,
          messages: [{ role: "user", content: prompt }],
          max_tokens: this.maxTokens,
          temperature: this.temperature,
        }),
      })
    );
  }

  call$(prompt: string): Observable<string> {
    return new Observable((observer: Observer<string>) => {
      this.fetch$(prompt).subscribe({
        next: (response: Response) => {
          response
            .json()
            .then((data: unknown) => {
              try {
                observer.next((data as OpenResponse).choices[0].message.content);
                observer.complete();
              } catch(e) {
                console.log(data);
              }
            })
            .catch((e) => {
              console.error(e);
              console.info(response);
              observer.error(e);
            });
        },
        error: (e) => {
          console.error(e);
          observer.error(e);
        },
      });
    });
  }
}
