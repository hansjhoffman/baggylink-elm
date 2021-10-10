import * as IO from "fp-ts/IO";
import * as O from "fp-ts/Option";
import { pipe } from "fp-ts/function";
import { match } from "ts-pattern";

import { Elm } from "/src/Main.elm";
import "/css/app.css";

const app = Elm.Main.init({
  node: document.getElementById("app"),
});

const openExternalLink =
  (link: string): IO.IO<O.Option<void>> =>
  () => {
    return pipe(
      O.fromNullable(window),
      O.map((w) => w.open(link, "_blank")?.focus()),
    );
  };

app.ports.openExternalLink.subscribe((externalLink: string) => {
  return openExternalLink(externalLink)();
});
